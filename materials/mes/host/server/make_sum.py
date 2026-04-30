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

with open("./sum_vars.log") as f1:
    with open("./data.csv") as f2:
        # 先将csv数据全部读入列表，因为需要多次遍历
        csv_data = list(csv.reader(f2))
        
        for row in csv.reader(f1):
            
            # 删除row[0]开头的0x（不区分大小写）
            row0_value = row[0].lower().lstrip('0x') if row[0].lower().startswith('0x') else row[0]
            
            # 遍历csv_data，对比第2列（索引为1）
            for csv_row in csv_data:
                if len(csv_row) < 2:  # 确保csv_row也有足够的列
                    continue
                #print(str(csv_row[1])+":"+row0_value)
                # 对比第2列数据
                if csv_row[1] == row0_value:
                    # 记录第0、1、2列数据
                    logger.info(f"{csv_row[0]},{csv_row[1]},{csv_row[2]}")