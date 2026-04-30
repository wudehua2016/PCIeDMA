import csv
import random
import os
import time
from datetime import datetime

import logging


files_list = []

def extract_dt(fname):
    # 把 "app0000-2000_2025-11-13_03:29:03.log" 里的日期时间部分切出来
    # 找到第一个 "_" 后出现 "2025-11-13_03:29:03" 的位置
    part = fname.split('_', 1)[1]          # "2025-11-13_03:29:03.log"
    dt_str = part.rsplit('.', 1)[0]        # "2025-11-13_03:29:03"
    return datetime.strptime(dt_str, "%Y-%m-%d_%H:%M:%S")

log_filename = "cdata_vars.csv"
logging.basicConfig(
    level=logging.INFO,
    format='%(message)s',
    filename=log_filename,
    filemode='w'         # 'a'=追加，'w'=覆盖
)
logger = logging.getLogger(__name__)

for dirpath, dirnames, filenames in os.walk('.'):
    for i in filenames:
        if "app0000-2000_2025-11-23_04" in i or "app0000-2000_2025-11-23_05" in i or "app0000-2000_2025-11-23_06" in i or "app0000-2000_2025-11-23_07" in i or "app0000-2000_2025-11-23_03" in i or "app0000-2000_2025-11-23_08" in i or "app0000-2000_2025-11-23_09" in i or "app0000-2000_2025-11-23_10" in i or "app0000-2000_2025-11-23_11" in i:
            files_list.append(i)
files_list.sort(key=extract_dt)   # 升序，最早的在最前面
print(len(files_list))

times = {}
count_bool = False  
for file in files_list:
    src_file = f'./{file}'
    # 1. 一次性读入所有行
    with open(src_file, newline='') as f:
        rows = list(csv.reader(f))
        for row in rows:
            if len(row) < 3:
                continue
            if row[2] not in times:
                times[row[2]] = 1
            else:
                times[row[2]] += 1
    
    # 3. 按出现次数降序排列
    sorted_items = sorted(times.items(), key=lambda x: x[1], reverse=True)
    logger.info(f"new:{src_file}") 
    # 4. 输出到日志（或你想打印/写入的任何地方）
    for k, v in sorted_items:
        if int(v) >=30:
            count_bool = True
        logger.info(f"{k},{v}")      # 格式：值,次数
    times = {}
if count_bool:
    print("max than 97\n")    
    count_bool = False

