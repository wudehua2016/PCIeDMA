#!/usr/bin/env python3
"""
打印内核代码段物理地址范围
从 0x29DC00000 到 0x29E0025C8，每 64 字节打印一次
"""

def print_kernel_addresses():
    start_addr = 0x29E0025C8
    end_addr = 0x29E971000
    step = 64  # 64 bytes
    

    
    count = 0
    current_addr = start_addr
    
    while current_addr <= end_addr:
        # 打印地址（16进制，大写，补齐到11位）
        print(f"fc,{current_addr:X},1231341")
        current_addr += step
        count += 1
    #print("count:"+str(count))


if __name__ == "__main__":
    print_kernel_addresses()