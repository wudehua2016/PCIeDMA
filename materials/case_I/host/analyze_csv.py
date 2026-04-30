import csv
from collections import Counter

def count_hex_numbers(csv_file_path):
    """
    从CSV文件中读取16进制数字并统计频次
    
    参数:
        csv_file_path: CSV文件路径
    """
    hex_counter = Counter()
    
    try:
        # 读取CSV文件
        with open(csv_file_path, 'r', encoding='utf-8') as file:
            # 使用csv.reader读取
            csv_reader = csv.reader(file)
            
            for row in csv_reader:
                # 处理每一行的每个单元格
                for cell in row:
                    cell = cell.strip()
                    # 跳过空白和分隔线
                    if cell and not cell.startswith('*'):
                        hex_counter[cell] += 1
        
        # 输出统计结果
        print("=" * 50)
        print("16进制数字出现频次统计")
        print("=" * 50)
        print()
        
        # 按频次降序排列
        for hex_num, count in sorted(hex_counter.items(), key=lambda x: x[1], reverse=True):
            print(f"{hex_num:15s} : {count:3d}次")
        
        print()
        print("=" * 50)
        print(f"总计数字: {sum(hex_counter.values())}个")
        print(f"不同数字: {len(hex_counter)}种")
        print("=" * 50)
        
        return hex_counter
        
    except FileNotFoundError:
        print(f"错误: 找不到文件 '{csv_file_path}'")
        print("请确保data.csv文件在当前目录下")
        return None
    except Exception as e:
        print(f"错误: {e}")
        return None

if __name__ == "__main__":
    # 读取data.csv文件
    result = count_hex_numbers("2-25-9.csv")
    
    # 可选：将结果保存到文件
    if result:
        with open("统计结果.txt", 'w', encoding='utf-8') as f:
            f.write("16进制数字出现频次统计\n")
            f.write("=" * 50 + "\n\n")
            for hex_num, count in sorted(result.items(), key=lambda x: x[1], reverse=True):
                f.write(f"{hex_num:15s} : {count:3d}次\n")
            f.write("\n" + "=" * 50 + "\n")
            f.write(f"总计数字: {sum(result.values())}个\n")
            f.write(f"不同数字: {len(result)}种\n")
        print("\n结果已保存到 '统计结果.txt'")