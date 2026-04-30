import csv
import time
from datetime import datetime
import logging

log_filename = "data_vars.csv"
logging.basicConfig(
    level=logging.INFO,
    format='%(message)s',
    filename=log_filename,
    filemode='w'         # 'a'=追加，'w'=覆盖
)
logger = logging.getLogger(__name__)

with open("./data_bak.csv","r") as datacsv:
    csv_data = list(csv.reader(datacsv))
    with open("./app.log","r") as sumlog:
        for row in csv.reader(sumlog):
            # 删除row[0]开头的0x（不区分大小写）
            row0_index = row[0].lower().lstrip('0x') if row[0].lower().startswith('0x') else row[0]
            # 遍历csv_data，对比第2列（索引为1）
            for row0_index in range(20):
                if len(csv_row) < 2:  # 确保csv_row也有足够的列
                    continue
                #print(str(csv_row[1])+":"+row0_value)
                # 对比第2列数据
                if csv_row[1] == row0_value:
                    # 记录第0、1、2列数据
                    logger.info(f"{csv_row[0]},{csv_row[1]},{csv_row[2]}")
    
