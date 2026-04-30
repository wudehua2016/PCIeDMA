import os
import re
import csv
def check_conflict():
    src = 'app0000-2000.log'          # 原始文件
    out_dir = '.'             # 输出目录，可改成任意路径
    block_cnt = 0
    buf = []
    times = 0
    with open(src, 'r', encoding='utf-8') as f:
        is_null = True
        for line in f:
            line = line.rstrip('\n')
            # 用正则识别分隔行：整行只含 * 号
            if re.fullmatch(r'\*+', line):
                if buf:                       # 前一个数据块写完
                    block_cnt += 1
                    #if len(buf) <= 1:   # 数据块行数大于2才保存
                    print(f'--- len is {len(buf)}:{is_null} ---')
                    buf.clear()
                else:
                    times += 1
                    print('--- empty buf ---')
            else:
                is_null = False
                # 跳过空行、表头行（可自己再细化规则）
                if line.strip() and not line.startswith('0,') and not line[0].isdigit():
                    continue
                if line.strip():              # 只保留非空行
                    buf.append(line)

    # 最后一块
    if buf:
        block_cnt += 1
        out_file = os.path.join(out_dir, f'block_{block_cnt}.csv')
        with open(out_file, 'w', encoding='utf-8') as wf:
            wf.write('\n'.join(buf))
    times_list = {}
    count_bool = False
    with open(src, newline='') as f:
        rows = list(csv.reader(f))
        for row in rows:
            if len(row) < 3:
                continue
            if row[2] not in times_list:
                times_list[row[2]] = 1
            else:
                times_list[row[2]] += 1
    
    # 3. 按出现次数降序排列
    sorted_items = sorted(times_list.items(), key=lambda x: x[1], reverse=True)

    # 4. 输出到日志（或你想打印/写入的任何地方）
    for k, v in sorted_items:
        if int(v) >= 95:
            count_bool = True

    times_list = {}
    if count_bool:
        print("max than 97\n")    
        count_bool = False
        return 1

    print(f'共提取 {block_cnt} 个数据块，已保存到 {out_dir}--->{times}')
    return 100
#tet = check_conflict()
#print("sfd:"+str(tet))