import os
import glob
import csv

def process_csv_files():
    """
    读取所有app000开头的CSV文件，根据第二列的奇偶性分类保存第四列数据
    """
    # 存储偶数和奇数行的数据
    even_data = []
    odd_data = []
    
    # 查找所有app000开头的CSV文件
    csv_files = glob.glob('app0000-2000_2025-12-07*.log')
    
    if not csv_files:
        print("未找到app000开头的CSV文件")
        return
    
    print(f"找到 {len(csv_files)} 个CSV文件")
    
    # 处理每个CSV文件
    for file_path in csv_files:
        print(f"正在处理: {file_path}")
        
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                reader = csv.reader(f)
                
                for row in reader:
                    # 跳过空行
                    if not row or len(row) < 4:
                        continue
                    
                    # 跳过可能的标题行（如果第二列不是数字）
                    try:
                        col2_value = int(row[1])  # 第二列（索引1）
                        col4_value = row[3]        # 第四列（索引3）
                        
                        # 根据第二列的奇偶性分类
                        if col2_value % 2 == 0:
                            even_data.append([col2_value, col4_value])
                        else:
                            odd_data.append([col2_value, col4_value])
                    
                    except (ValueError, IndexError):
                        # 跳过无法转换或索引错误的行
                        continue
        
        except Exception as e:
            print(f"处理文件 {file_path} 时出错: {e}")
    
    # 保存偶数行数据
    with open('even_data.csv', 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(['第二列值', '第四列值'])  # 写入表头
        writer.writerows(even_data)
    
    print(f"偶数行数据已保存到 even_data.csv，共 {len(even_data)} 条记录")
    
    # 保存奇数行数据
    with open('odd_data.csv', 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(['第二列值', '第四列值'])  # 写入表头
        writer.writerows(odd_data)
    
    print(f"奇数行数据已保存到 odd_data.csv，共 {len(odd_data)} 条记录")

if __name__ == '__main__':
    process_csv_files()