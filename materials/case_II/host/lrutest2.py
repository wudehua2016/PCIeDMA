import sys, os, time, array, fcntl, unittest
from struct import pack, unpack
from time import sleep
import paho.mqtt.client as mqtt
import json
import time
import logging
from datetime import datetime
import logging
import logging
from datetime import datetime
import csv


log_filename = f"app0000-2000.log"

logging.basicConfig(
    level=logging.INFO,
    format='%(message)s',
    filename=log_filename,
    filemode='a'         # 'a'=追加，'w'=覆盖
)
logger = logging.getLogger(__name__)

class MQTTReceiver:
    def __init__(self, broker_host="localhost", broker_port=1883, username=None, password=None):

        self.broker_host = broker_host
        self.broker_port = broker_port
        self.username = username
        self.password = password
        
        self.client = mqtt.Client()
        self.n = 0
        self.time = 0
        self.client.on_connect = self.on_connect
        self.client.on_message = self.on_message
        self.client.on_disconnect = self.on_disconnect
        self.client.on_subscribe = self.on_subscribe
        self.mem_addr = 0
        if self.username and self.password:
            self.client.username_pw_set(self.username, self.password)
    
    def on_connect(self, client, userdata, flags, rc):

        if rc == 0:
            print(f"connected MQTT broker{self.broker_host}:{self.broker_port}")
            self.subscribe_topics()
        else:
            print(f"recived code: {rc}")
    
    def on_message(self, client, userdata, msg):
        
        try:

            topic = msg.topic
            payload = msg.payload.decode('utf-8')
            timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
            #tm = TestMem()
            #tm.test_normal()
            print(f"[{timestamp}] recieved")
            print(f"topic: {topic}")
            print(f"context: {payload}")
            print("-" * 50)
            if "wudehua_target_addr" in payload:
                tests_case = payload.split("=")[2]
                tests_count = int(tests_case.split('_')[1],10)
                self.mem_addr = int(payload.split("=")[1],16)
                print(f"memory addr is {self.mem_addr:x}")
                self.n = tests_count
                print("tests_count=="+str(tests_count))
                #logger.info(f"{tests_case},{self.mem_addr}")
                tm = TestMem()
                tm.test_normal(self.n,self.mem_addr)
                #if self.time % 5 == 0:
                print("sfsffsd") 
                self.time = self.time + 1
                if tests_count >=100:
                    logger.info("***********************************")
                    exit()
            try:
                json_data = json.loads(payload)
                print(f"JSON: {json.dumps(json_data, indent=2, ensure_ascii=False)}")
            except json.JSONDecodeError:
                print("message not JSON")
            self.process_message(topic, payload)
            
        except Exception as e:
            print(f"error: {e}")
    
    def on_disconnect(self, client, userdata, rc):

        if rc != 0:
            print("disconnected...")
        else:
            print("disconected......")
    
    def on_subscribe(self, client, userdata, mid, granted_qos):
        print(f"topic ID: {mid}, QoS: {granted_qos}")
    
    def subscribe_topics(self):

        topics = [
            ("test", 0),
            ("sensor/humidity", 0),
            ("device/status", 1),
            ("test/+", 0),  
        ]
        
        for topic, qos in topics:
            result = self.client.subscribe(topic, qos)
            if result[0] == mqtt.MQTT_ERR_SUCCESS:
                print(f"topic: {topic}, QoS: {qos}")
            else:
                print(f"fails in topic: {topic}")
    
    def process_message(self, topic, payload):
        print(f"topic: {topic}")
    
    def connect(self):

        try:
            print(f"connected {self.broker_host}:{self.broker_port}...")
            self.client.connect(self.broker_host, self.broker_port, 60)
            return True
        except Exception as e:
            print(f"fails: {e}")
            return False
    
    def start(self):
        if self.connect():
            print("MQTTreceving...")
            try:

                self.client.loop_forever()
            except KeyboardInterrupt:
                print("donw...")
                self.stop()
        else:
            print("fails in start MQTT")
    
    def stop(self):
        self.client.disconnect()
        self.client.loop_stop()


class DeviceMem(object):
    PATH = '/dev/zc_dma_mem_0'

    # IOCTL commands
    ZC_DMA_MEM_IOCTL_GET_DEVICE_ID  = 0x1b1898000
    ZC_DMA_MEM_IOCTL_GET_DEVICE_ID_GPIO1 = 0x8004cc03  

    mem_write_1 = lambda self, addr, v: self.mem_write(addr, pack('B', v))
    mem_write_2 = lambda self, addr, v: self.mem_write(addr, pack('H', v))
    mem_write_4 = lambda self, addr, v: self.mem_write(addr, pack('I', v))
    mem_write_8 = lambda self, addr, v: self.mem_write(addr, pack('Q', v))

    mem_read_1 = lambda self, addr: unpack('B', self.mem_read(addr, 1))[0]
    mem_read_2 = lambda self, addr: unpack('H', self.mem_read(addr, 2))[0]
    mem_read_4 = lambda self, addr: unpack('I', self.mem_read(addr, 4))[0]
    mem_read_8 = lambda self, addr: unpack('Q', self.mem_read(addr, 8))[0]

    def __init__(self):
        # open target device
        self.fd = os.open(self.PATH, os.O_RDWR)

    def mem_read(self, addr, size):
        # set file pointer
        os.lseek(self.fd, addr, os.SEEK_SET)
        # read memory contents
        return os.read(self.fd, size)

    def mem_write(self, addr, data):
        # set file pointer
        os.lseek(self.fd, addr, os.SEEK_SET)
        # write memory contents
        os.write(self.fd, data)

    def get_device_id(self):
        buff = array.array('I', [0])
        # send IOCTL request to the driver
        fcntl.ioctl(self.fd, self.ZC_DMA_MEM_IOCTL_GET_DEVICE_ID, buff, 1)
        return buff[0]

    def get_device_id_gpio1(self):
        buff = array.array('I', [0])
        # send IOCTL request to the driver
        try:
            fcntl.ioctl(self.fd, self.ZC_DMA_MEM_IOCTL_GET_DEVICE_ID_GPIO1, buff, 1)
            return buff[0]
        except OSError as e:
            print(f"read GPIO1 (0x41210000) failes: {e}")
            raise

class DeviceTlp(object):
    PATH = '/dev/zc_dma_mem_1'
    RECV_BUFF_LEN = 0x1000

    ZC_DMA_MEM_IOCTL_RESET          = 0x0000cc00
    ZC_DMA_MEM_IOCTL_GET_DEVICE_ID  = 0x8004cc01
    ZC_DMA_MEM_IOCTL_CONFIG_READ    = 0xc004cc02

    def __init__(self):
        # open target device
        self.fd = os.open(self.PATH, os.O_RDWR)

    def reset(self):
        # send IOCTL request to the driver
        fcntl.ioctl(self.fd, self.ZC_DMA_MEM_IOCTL_RESET)

    def get_device_id(self):
        buff = array.array('I', [0])
        # send IOCTL request to the driver
        fcntl.ioctl(self.fd, self.ZC_DMA_MEM_IOCTL_GET_DEVICE_ID, buff, 1)
        return buff[0]

    def cfg_read(self, addr):
        buff = array.array('I', [addr])
        # send IOCTL request to the driver
        fcntl.ioctl(self.fd, self.ZC_DMA_MEM_IOCTL_CONFIG_READ, buff, 1)
        return buff[0]

    def tlp_send(self, data):
        data = b''.join(map(lambda dw: pack('I', dw), data))
        # send TLP
        os.write(self.fd, data)

    def tlp_recv(self):
        ret = []
        data = os.read(self.fd, self.RECV_BUFF_LEN)
        for i in range(0, len(data) // 4):
            ret.append(unpack('I', data[i * 4 : (i + 1) * 4])[0])
        return ret

class TestMem:
    TEST_ADDR = 0x3b2068060
    ATT_ADDR = 0x3b2068060
    

    def test_mem(self):
        dev = DeviceMem()
        data = dev.mem_read(self.TEST_ADDR, 0x100)
        dev.mem_write(self.TEST_ADDR, data)

    def test_normal(self,n,addr=TEST_ADDR):
        phys_addrs = []
        dev = DeviceMem()
        val = 0x0
        addr = addr + (20* n *8)
        old =0
        logger.info("***********************************")
        # obtain the target addr
        print("read addr:"+str(addr))
        
        with open("./data.csv", encoding='utf-8', newline='') as f:
            count = 0
            testsum = 0
            for row in csv.reader(f):
                addr = int(row[1],16)
                
                #print("target_addrs["+str(val)+"]:"+str(addr))
                #if count <= n: # testhere
                phys_addrs.append(addr)
                testsum = testsum +1

                count = count +1
                
            
        print(f"len(phys_addrs)= {len(phys_addrs)}")
        #if(len(phys_addrs)==2000):
        tga_index = 0xf0affaf8
        count = 0
        while True:
            val = 0
            tar = 0
            for it in range(1):
                for addr in phys_addrs:
                    old = dev.mem_read_8(addr)
                    try:
                        gpio1_id = dev.get_device_id_gpio1()
                        if gpio1_id < 98:
                            logger.info(f"{addr:x}")
                    except OSError:
                        break
                    val = val + 1
                    #if val >=200:
                    #    break
                    #if val >= tar:
                    #    logger.info("==========================")
                    #    break
                #logger.info("==========================")
                #print("sdfsfs---->1")
                count = count +1
                break
            break    

if __name__ == '__main__':
    BROKER_HOST = "166.111.238.139"  
    BROKER_PORT = 1883       
    USERNAME = "wdh"            
    PASSWORD = "wdh123wdh"           
    
    receiver = MQTTReceiver(
        broker_host=BROKER_HOST,
        broker_port=BROKER_PORT,
        username=USERNAME,
        password=PASSWORD
    )
    

    receiver.start()
    
