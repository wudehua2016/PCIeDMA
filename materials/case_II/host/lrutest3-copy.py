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
    val_tag = 0
    
    def test_mem(self):
        dev = DeviceMem()
        data = dev.mem_read(self.TEST_ADDR, 0x100)
        dev.mem_write(self.TEST_ADDR, data)

    def test_normal(self,addr=TEST_ADDR):
        #n = 1
        tag1 = dev.mem_read_8(addr)


if __name__ == '__main__':
    tm = TestMem()
    while True:
        tm.test_normal()
    
