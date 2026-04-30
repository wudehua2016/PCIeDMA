import csv
import random
import os
import time
from datetime import datetime

import logging


files_list = []

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
        if "app0000" in i:
            files_list.append(i)

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
                if len(times) == 1:
                    for key in times:
                        logger.info(f"{key},0x{key},{times[key]}")
                continue
            if row[3] == "98":
                if row[2] not in times:
                    times[row[2]] = 1
                else:
                    times[row[2]] += 1



