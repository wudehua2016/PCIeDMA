import csv
import random
import os
import time
from datetime import datetime

import logging


files_list = []
t_files_list = []
def extract_dt(fname):
    # 把 "app0000-2000_2025-11-13_03:29:03.log" 里的日期时间部分切出来
    # 找到第一个 "_" 后出现 "2025-11-13_03:29:03" 的位置
    part = fname.split('_', 1)[1]          # "2025-11-13_03:29:03.log"
    dt_str = part.rsplit('.', 1)[0]        # "2025-11-13_03:29:03"
    return datetime.strptime(dt_str, "%Y-%m-%d_%H:%M:%S")

log_filename = "tdata_vars.csv"
logging.basicConfig(
    level=logging.INFO,
    format='%(message)s',
    filename=log_filename,
    filemode='w'         # 'a'=追加，'w'=覆盖
)
logger = logging.getLogger(__name__)

for dirpath, dirnames, filenames in os.walk('.'):
    for i in filenames:
        if "app0000-2000.log" == i:
            files_list.append(i)
        if "data_ori.csv" == i:
            t_files_list.append(i)
#files_list.sort(key=extract_dt)   # 升序，最早的在最前面

print("len of files_list:"+str(len(t_files_list)))

times = {}
sorted_tables = []
rows_tables = []
for file in t_files_list:
    src_file = f'./{file}'
    # 1. 一次性读入所有行
    with open(src_file, newline='') as f:
        rows = list(csv.reader(f))
        for row in rows:
            if len(row) < 3:
                continue
            rows_tables.append(row)



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
    
    # 3. 按出现次数升序排列
    sorted_items = sorted(times.items(), key=lambda x: x[1], reverse=False)
    # 4. 输出到日志（或你想打印/写入的任何地方）
    for k, v in sorted_items:
        sorted_tables.append(k.split('0x')[1])

write_table = []
print(rows_tables)
print("1.len of rows:"+str(len(rows)))


for entry in rows_tables:
    if entry[1] not in sorted_tables:
        logger.info(f"{entry[0]},{entry[1]},{str(entry[2])}")
        write_table.append(entry)



for entry_t in sorted_tables:
    print(entry_t)
    for entry in rows_tables:
        if entry_t == entry[1]:
            logger.info(f"{entry[0]},{entry[1]},{str(entry[2])}")
            write_table.append(entry)


print("len:"+str(len(write_table)))
with open('tdata_vars.csv', encoding='utf-8') as f, \
     open('uniq.csv', 'w', encoding='utf-8') as w:
    seen = set()
    for line in f:
        if line not in seen:
            seen.add(line)
            w.write(line)
cmd = "cp ./uniq.csv ./data.csv"
os.system(cmd)
cmd = "cp ./uniq.csv ./data_ori.csv"
os.system(cmd)