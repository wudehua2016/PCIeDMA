import csv
import sys

# 检查命令行参数
if len(sys.argv) < 2:
    print("使用方法: python analyze_latency.py <csv文件路径>")
    print("示例: python analyze_latency.py data.csv")
    sys.exit(1)

csv_file = sys.argv[1]

# 解析数据
errors = []
num_rows = 0    
try:
    with open(csv_file, 'r', encoding='utf-8') as f:
        csv_reader = csv.reader(f)
        for row in csv_reader:
            num_rows += 1
            if len(row) != 2:
                continue
            try:
                idx, latency = int(row[0]), int(row[1])
            except ValueError:
                # 跳过表头或无效行
                continue
            
            if idx % 2 == 0:  # 分类M：idx为偶数
                if latency < 100:  # 应该小于98，但实际大于等于98
                    errors.append({
                        'idx': idx,
                        'latency': latency,
                        'category': 'M',
                        'expected': '<100',
                        'actual': latency
                    })
            else:  # 分类H：idx为奇数
                if latency > 100:  # 应该大于98，但实际小于等于98
                    errors.append({
                        'idx': idx,
                        'latency': latency,
                        'category': 'H',
                        'expected': '>100',
                        'actual': latency
                    })

except FileNotFoundError:
    print(f"错误: 找不到文件 '{csv_file}'")
    sys.exit(1)
except Exception as e:
    print(f"错误: 读取文件时发生异常: {e}")
    sys.exit(1)

# 打印结果
print("=" * 60)
print("Latency 错误检测结果")
print("=" * 60)

if errors:
    print(f"\n发现 {len(errors)} 个错误:\n")
    for err in errors:
        print(f"idx: {err['idx']:2d} | "
              f"分类: {err['category']} | "
              f"latency: {err['latency']:3d} | "
              f"期望: {err['expected']:4s} | "
              f"状态: ❌ 不符合")
else:
    print("\n✓ 所有数据都符合要求！")

print("\n" + "=" * 60)
print(f"错误总数: {len(errors)}")
print(f"总行数: {num_rows}")
print(f"错误率: {len(errors)/num_rows*100:.2f}%")
print("=" * 60)