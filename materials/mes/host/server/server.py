import os

import paramiko
import sys
import check_conflict

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


# 使用示例
if __name__ == "__main__":
    # 使用无密码的SSH密钥认证
    print("=== 使用无密码的id_rsa密钥认证 ===")
    
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
    print("\n" + "="*50 + "\n")
    
    
    

# 0.从log中提取地址，生成data.csv
#cmd = "python3 addr_extract.py"
#os.system(cmd)
# 1.将data.csv传输到远程服务器97
# 2.通知


