import csv

import time
from datetime import datetime
import logging

log_filename = f"sum1.log"

logging.basicConfig(
    level=logging.INFO,
    format='%(message)s',
    filename=log_filename,
    filemode='w'         # 'a'=追加，'w'=覆盖
)
logger = logging.getLogger(__name__)
sdata = {}
with open("./app0000-2000.log") as f:
    for row in csv.reader(f):
        if len(row) < 3:
            continue
        #print("len of row:"+str(len(row)))
        if int(row[3]) >= 98:
            if str(row[2]) in sdata:
                sdata[str(row[2])] = sdata[str(row[2])] + 1
            else:
                sdata[str(row[2])] =  1
#print(len(sdata))   
     
sorted_items = sorted(sdata.items(), key=lambda x: x[1], reverse=True)
for i in sorted_items:
    #if i[1] > 7:
    logger.info(f"{i[0]},")    
