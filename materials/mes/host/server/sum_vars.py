import csv

import time
from datetime import datetime
import logging


log_filename = f"sum_vars.log"

logging.basicConfig(
    level=logging.INFO,
    format='%(message)s',
    filename=log_filename,
    filemode='w'         # 'a'=追加，'w'=覆盖
)
logger = logging.getLogger(__name__)
sum_vars = []
with open("./sum1.log") as f:
    for row in csv.reader(f):
        if len(row) < 1:
            continue
        #print("len of row:"+str(len(row)))
        if row[0] not in sum_vars:
            sum_vars.append(row[0])
            logger.info(f"{row[0]},")
print(f"len(sum_vars):{len(sum_vars)}")
