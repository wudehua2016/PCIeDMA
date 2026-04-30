import csv

import time
from datetime import datetime

import logging

log_filename = "data_vars1.csv"
logging.basicConfig(
    level=logging.INFO,
    format='%(message)s',
    filename=log_filename,
    filemode='w'         # 'a'=追加，'w'=覆盖
)
logger = logging.getLogger(__name__)


sdata = {}
with open("./data.csv") as f:
    sdata = list(csv.reader(f))


#print(sdata)

test_data = []

with open("./data_ori.csv") as f1:
    test_data_base = list(csv.reader(f1))
    for entry in sdata:
        if len(entry) < 3:
            print("error: not full in entry!!!!")
            continue
        for test_entry in test_data_base:
            if entry[1] == test_entry[1]:
                test_data.append(test_entry)
                logger.info(f"{entry[0]},{entry[1]},{entry[2]}")
print(len(test_data))   
     


