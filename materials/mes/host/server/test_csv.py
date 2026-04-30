import csv
import random

def prune_obfuscate():
    src_file = './data.csv'
    part1_file = 'data_part12.csv'
    part2_file = 'data_part22.csv'
    

    # 1. 一次性读入所有行
    with open(src_file, newline='') as f:
        rows = list(csv.reader(f))

        total = len(rows)
        half  = (total + 1) // 2          # 奇数时前半多一行
    
        random.shuffle(rows)

        # 2. 写入两份
        with open(part1_file, 'w', newline='') as f1, \
            open(part2_file, 'w', newline='') as f2:
            writer1 = csv.writer(f1)
            writer2 = csv.writer(f2)

            writer1.writerows(rows[:half])
            writer2.writerows(rows[half:])

        print(f'总行数：{total}')
        print(f'已拆分 -> {part1_file}  {half} 行')
        print(f'           {part2_file}  {total - half} 行')

if __name__ == '__main__':
    prune_obfuscate()