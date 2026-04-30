#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
MQTT 订阅 + 发布  demo
兼容 paho-mqtt 1.x 与 2.x
"""
import json
import time
import random
import threading
import paho.mqtt.client as mqtt
import os
import logging
from datetime import datetime
from time import sleep
import csv

import paramiko
import sys
import check_conflict

log_filename = f"app.log"

logging.basicConfig(
    level=logging.INFO,
    format='%(message)s',
    filename=log_filename,
    filemode='w'         # 'a'=追加，'w'=覆盖
)
logger = logging.getLogger(__name__)

def ssh_execute_command(host, username, key_file, command='ls -la', port=22):
    """
    通过SSH连接服务器并执行shell命令(使用无密码的SSH密钥)
    
    参数:
        host: 服务器地址
        username: 用户名
        key_file: SSH私钥文件路径 (例如: ~/.ssh/id_rsa)
        command: 要执行的shell命令
        port: SSH端口,默认22
    
    返回:
        tuple: (stdout, stderr, exit_status)
    """
    # 创建SSH客户端
    client = paramiko.SSHClient()
    
    # 自动添加主机密钥(首次连接时)
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    try:
        # 使用SSH密钥认证(无密码)
        print(f"使用密钥文件 {key_file} 连接到 {host}...")
        client.connect(
            hostname=host,
            port=port,
            username=username,
            key_filename=key_file,
            look_for_keys=True,  # 允许查找密钥
            allow_agent=True     # 允许使用ssh-agent
        )
        
        print(f"成功连接到服务器!")
        print(f"执行命令: {command}")
        print("-" * 50)
        
        # 执行命令
        stdin, stdout, stderr = client.exec_command(command)
        
        # 获取命令输出
        output = stdout.read().decode('utf-8')
        error = stderr.read().decode('utf-8')
        exit_status = stdout.channel.recv_exit_status()
        
        # 打印输出
        if output:
            print("标准输出:")
            print(output)
        
        if error:
            print("错误输出:")
            print(error)
        
        print(f"退出状态码: {exit_status}")
        
        return output, error, exit_status
        
    except paramiko.AuthenticationException:
        print("认证失败,请检查用户名和密码/密钥")
        return None, None, -1
    except paramiko.SSHException as e:
        print(f"SSH连接错误: {e}")
        return None, None, -1
    except Exception as e:
        print(f"发生错误: {e}")
        return None, None, -1
    finally:
        # 关闭连接
        client.close()
        print("SSH连接已关闭")

# ---------------- 公共配置 ----------------
BROKER_HOST = "166.111.238.139"
BROKER_PORT = 1883
USERNAME = "wdh"
PASSWORD = "wdh123wdh"
TOPIC = "test"

# --------------- 版本兼容 -----------------
try:  # 2.x
    from paho.mqtt.enums import CallbackAPIVersion
    API_VERSION = CallbackAPIVersion.VERSION1
except ImportError:  # 1.x
    API_VERSION = None


def make_client(cid):
    """生成 Client 实例，自动适配 1.x / 2.x"""
    if API_VERSION is None:  # 1.x
        return mqtt.Client(cid)
    return mqtt.Client(API_VERSION, cid)

mqtt_msg = ""

# ================= 订阅端 =================
class MQTTSubscriber:
    def __init__(self, topic, qos=0):
        self.topic = topic
        self.qos = qos
        self.client = make_client(f"sub-{random.randint(1000, 9999)}")
        self.client.username_pw_set(USERNAME, PASSWORD)
        self.client.on_connect = self._on_connect
        self.client.on_message = self._on_message
        self.client.on_disconnect = self._on_disconnect

    # ---------- 回调 ----------
    def _on_connect(self, client, userdata, flags, rc, prop=None):
        if rc == 0:
            print(f"[Subscriber] 连接成功，订阅主题：{self.topic}")
            client.subscribe(self.topic, self.qos)
        else:
            print(f"[Subscriber] 连接失败，rc={rc}")

    def _on_message(self, client, userdata, msg):
        global mqtt_msg
        payload = msg.payload.decode()
        mqtt_msg = payload

    def _on_disconnect(self, client, userdata, rc, prop=None):
        print("[Subscriber] 连接断开")

    # ---------- 启停 ----------
    def start(self):
        self.client.connect(BROKER_HOST, BROKER_PORT, keepalive=60)
        self.client.loop_start()

    def stop(self):
        self.client.loop_stop()
        self.client.disconnect()


# ================= 发布端 =================
class MQTTPublisher:
    def __init__(self):
        self.client = make_client(f"pub-{random.randint(1000, 9999)}")
        self.client.username_pw_set(USERNAME, PASSWORD)
        self.client.on_connect = self._on_connect
        self.client.on_disconnect = self._on_disconnect

    # ---------- 回调 ----------
    def _on_connect(self, client, userdata, flags, rc, prop=None):
        print("[Publisher] 连接成功" if rc == 0 else f"[Publisher] 连接失败，rc={rc}")

    def _on_disconnect(self, client, userdata, rc, prop=None):
        print("[Publisher] 连接断开")

    # ---------- 启停 ----------
    def connect(self):
        self.client.connect(BROKER_HOST, BROKER_PORT, keepalive=60)
        self.client.loop_start()

    def publish(self, topic, payload, qos=0, retain=False):
        if isinstance(payload, dict):
            payload = json.dumps(payload)
        info = self.client.publish(topic, payload, qos, retain)
        info.wait_for_publish()
        print(f"[Publisher] 已发布：{payload}")

    def disconnect(self):
        self.client.loop_stop()
        self.client.disconnect()


# ================= 演示 ==================
def run_subscriber():
    sub = MQTTSubscriber(topic=TOPIC, qos=1)
    sub.start()
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("\nSubscriber 退出")
        sub.stop()


def run_publisher():
    pub = MQTTPublisher()
    pub.connect()
    data = {"index": 10, "value": random.randint(0, 100)}
    pub.publish(TOPIC, data, qos=1)
    pub.disconnect()
    print("Publisher 发送完毕")


def split_csv_half():
    src_file = './data.csv'
    part1_file = 'data_part1.csv'
    part2_file = 'data_part2.csv'
    

    # 1. 一次性读入所有行
    with open(src_file, newline='') as f:
        rows = list(csv.reader(f))

    total = len(rows)
    half  = (total + 1) // 2          # 奇数时前半多一行

    # 2. 写入两份
    with open(part1_file, 'w', newline='') as f1, \
        open(part2_file, 'w', newline='') as f2:
        writer1 = csv.writer(f1)
        writer2 = csv.writer(f2)

        writer1.writerows(rows[:half])
        writer2.writerows(rows[half:])

    print(f'总行数：{total}')
    print(f'已拆分 -> {part1_file}  {half} 行')
    print(f'           {part2_file}  {total - half} 行')

def prune_obfuscate():
    src_file = './data.csv'
    part1_file = 'data_part1.csv'
    part2_file = 'data_part2.csv'
    

    # 1. 一次性读入所有行
    with open(src_file, newline='') as f:
        rows = list(csv.reader(f))

        total = len(rows)
        half  = (total + 1) // 2          # 奇数时前半多一行
    
        random.shuffle(rows)

        # 2. 写入两份
        with open(part1_file, 'w', newline='') as f1, \
            open(part2_file, 'w', newline='') as f2:
            writer1 = csv.writer(f1)
            writer2 = csv.writer(f2)

            writer1.writerows(rows[:half])
            writer2.writerows(rows[half:])

        print(f'总行数：{total}')
        print(f'已拆分 -> {part1_file}  {half} 行')
        print(f'           {part2_file}  {total - half} 行')

def prune_one_by_one(index:int):
    src_file = './data_ori.csv'
    part_file = 'data.csv'
    

    # 1. 一次性读入所有行
    with open(src_file, newline='') as f:
        rows = list(csv.reader(f))

        total = len(rows)
        for i in range(total):
            if i == index:
                ts_str = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                logger.info(f"{ts_str},{index} of rows poped is: {rows[i]}")
                rows.pop(i)

        with open(part_file, 'w', newline='') as f1:
            writer1 = csv.writer(f1)
            writer1.writerows(rows)


def execute():
    cmd = "cp ./data.csv ../"
    os.system(cmd)
    cmd = "python3 ./copy_data_to_97.py"
    os.system(cmd)
    ts_str = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    logger.info(f"{ts_str},start to execute ReEngineering0000.py on 97 server.....")
    ssh_execute_command(
        host='166.111.238.97',
        username='root',
        key_file='/home/riscv/.ssh/id_rsa',  # 或使用完整路径: '/home/user/.ssh/id_rsa'
        command='rm /home/uisrc/app0000-2000.log'
    )

    ssh_execute_command(
        host='166.111.238.97',
        username='root',
        key_file='/home/riscv/.ssh/id_rsa',  # 或使用完整路径: '/home/user/.ssh/id_rsa'
        command='cd /home/uisrc/ && nohup python3 ./ReEngineering0000.py > log.txt &'
    ) 


# -------------- 主入口 --------------
if __name__ == "__main__":
    # 1. 启动订阅线程
    t = threading.Thread(target=run_subscriber, daemon=True)
    t.start()
    mode = 0
    threadhold = 1600

    # 2. 稍等确保订阅已就绪
    ts_str = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(ts_str)          # 2025-11-08 14:37:52
    pop_index = 0

    # 3. 启动发布
    run_publisher()
    is_done = False
    while True:
        time.sleep(1)
        print("mqtt_msg:", mqtt_msg)
        if "" == mqtt_msg:
            continue
        elif "start_to_run" == mqtt_msg:
            ts_str = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            logger.info(f"{ts_str},start_to_run")
            #extract data from log
            cmd = "python3 ./addr_extract.py"
            os.system(cmd)
            ts_str = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            logger.info(f"{ts_str},data extracted")
            cmd = "python3 ./check_same.py"
            os.system(cmd)
            ts_str = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            logger.info(f"{ts_str},check the same entry in data.csv and data_ori.csv")
            cmd = "cp ./data_vars1.csv ./data.csv"
            os.system(cmd)
            execute()
            is_done = True
            continue
        elif "mode_change" in mqtt_msg:
            ts_str = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            logger.info(f"{ts_str},{mqtt_msg}")
            tests_case = mqtt_msg.split("=")[2]
            mode_to_change = int(tests_case.split('_')[1],10) 
            print("mode:",mode_to_change)
            mode = mode_to_change
            continue
        elif "wudehua_target_addr" in mqtt_msg:
            ts_str = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            logger.info(f"{ts_str},{mqtt_msg}")
            tests_case = mqtt_msg.split("=")[2]
            tests_count = int(tests_case.split('_')[1],10) 
            print("tests_count:",tests_count)
            if tests_count >= 101:
                #1.从97服务器获取log文件
                cmd = "python3 ./copy_applog_from_97.py"
                os.system(cmd)
                #2.检查是否有冲突
                conflict_times = check_conflict.check_conflict()
                ts_str = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                logger.info(f"{ts_str},conflict_times={conflict_times}")
                # 3.检查../data.csv的行数
                with open("../data.csv", newline='') as f:
                    rows = list(csv.reader(f))
                total = len(rows)
                ts_str = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                logger.info(f"{ts_str},the len of data.csv is {total}")
                match mode:
                    case 0:#init
                        # 4.对../data.csv 进行二分
                        cmd = "cp ./data.csv ./data_ori.csv"
                        os.system(cmd)
                        #split_csv_half()
                        ts_str = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                        logger.info(f"{ts_str},initing,data.csv has been split into two parts")
                        mode = 1
                        #cmd = "cp ./data_part1.csv ./data.csv"
                        #os.system(cmd)
                        is_done = True
                        execute()
                        
                    case 1:# 执行结束后，通过采样数据
                        if total >= threadhold:
                            #检查conflict_times
                            if conflict_times <= 1:
                                # 4.对../data.csv 进行二分
                                cmd = "cp ../data.csv ."
                                os.system(cmd)
                                cmd = "cp ./data.csv ./data_ori.csv"
                                os.system(cmd)
                                ts_str = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                                logger.info(f"{ts_str},start to new loop,data.csv has been split into two parts")
                                split_csv_half()
                                cmd = "cp ./data_part1.csv ./data.csv"
                                os.system(cmd)
                                execute()
                                is_done = True
                                mode = 1
                            elif conflict_times > 1:
                                ts_str = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                                logger.info(f"{ts_str},conflict_times > 1,data.csv does not meet requirement, need to change test data")
                                cmd = "cp ./data_part2.csv ./data.csv"
                                os.system(cmd)
                                execute()
                                is_done = True
                                mode = 2
                        if total <= threadhold:
                            ts_str = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                            logger.info(f"{ts_str},total <= threadhold,data.csv does not meet requirement, need to change test data")
                            is_done = True
                            mode = 2
                    case 2:
                        if total >= threadhold:
                            if conflict_times > 1:
                                # 4.对../data.csv 进行二分
                                cmd = "cp ./data_ori.csv ./data.csv"
                                os.system(cmd)
                                prune_obfuscate()
                                cmd = "cp ./data_part1.csv ./data.csv"
                                os.system(cmd)
                                ts_str = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                                logger.info(f"{ts_str},data.csv has been prune_obfuscate into two parts")
                                mode = 1
                                is_done = True
                                execute()
                            elif conflict_times <= 1:
                                # 4.对../data.csv 进行二分
                                cmd = "cp ../data.csv ./data.csv"
                                os.system(cmd)
                                cmd = "cp ./data.csv ./data_ori.csv"
                                os.system(cmd)
                                cmd = "cp ../data.csv ./data_ori.csv"
                                os.system(cmd)
                                split_csv_half()
                                cmd = "cp ./data_part1.csv ./data.csv"
                                os.system(cmd)
                                is_done = True
                                ts_str = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                                logger.info(f"{ts_str},data.csv has been prune_obfuscate into two parts")
                                mode = 1
                                execute()
                        if total <= threadhold:
                            if conflict_times <= 1:
                                ts_str = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                                logger.info(f"{ts_str},total <= threadhold prune index:{pop_index},data.csv does not meet requirement, need to change test data one by one")
                                is_done = True
                                cmd = "cp ../data.csv ./data.csv"
                                os.system(cmd)
                                cmd = "cp ./data.csv ./data_ori.csv"
                                os.system(cmd)
                                mode = 3
                                prune_one_by_one(pop_index)
                                execute()
                            elif conflict_times > 1:
                                ts_str = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                                logger.info(f"{ts_str},total <= threadhold and conflict_times > 1,data.csv need to reprune the data one by one:{pop_index}")
                                is_done = True
                                mode = 3
                                cmd = "cp ../data.csv ./data.csv"
                                os.system(cmd)
                                cmd = "cp ./data.csv ./data_ori.csv"
                                os.system(cmd)
                                pop_index = pop_index +1
                                prune_one_by_one(pop_index)
                                #cmd = "cp ./data_part1.csv ./data.csv"
                                #os.system(cmd)
                                execute()

                    case 3:
                        if pop_index >= threadhold:
                            ts_str = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                            logger.info(f"{ts_str},find the minimal prune index:{pop_index},break to prune one by one")
                            break
                        if conflict_times > 1:
                            ts_str = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                            logger.info(f"{ts_str},total lines fewer than the threadhold and conflict_times > 1, data.csv need to reprune the data:{pop_index}, and test data one by one")
                            pop_index += 1
                            prune_one_by_one(pop_index)
                            is_done = True
                            execute()
                        elif conflict_times <= 1:
                            ts_str = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                            logger.info(f"{ts_str},total lines fewer than the threadhold and conflict_times <= 1,data.csv meets requirement,test another lines:{pop_index}")
                            cmd ="cp ../data.csv ./data_ori.csv"
                            os.system(cmd)
                            prune_one_by_one(pop_index)
                            is_done = True
                            execute()
                    case 4:
                        pop_index = 0
                        ts_str = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                        logger.info(f"{ts_str},to prune the data by 10 strides from the minimal prune index:{pop_index}, break to prune one by one")
                        


                        break
                    case _:
                        pass
        #if is_done:
        mqtt_msg = ""   
            #is_done = False         
                # 4.对../data.csv 进行二分
                
