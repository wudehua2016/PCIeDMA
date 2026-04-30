import pandas as pd
import numpy as np

def parse_address(addr_str):
    addr_str = str(addr_str).strip()
    if ':' in addr_str:
        addr_str = addr_str.split(':')[1]
    if addr_str.startswith('0x') or addr_str.startswith('0X'):
        addr_str = addr_str[2:]
    try:
        return int(addr_str, 16)
    except ValueError:
        return None

def parse_hex_value(val_str):
    try:
        val_str = str(val_str).strip()
        if val_str.startswith('0x') or val_str.startswith('0X'):
            val_str = val_str[2:]
        return int(val_str, 16)
    except:
        return None

# 读取数据
csv_file = "test_cache.csv"
df = pd.read_csv(csv_file, header=None)

if len(df.columns) == 3:
    df.columns = ['label', 'address', 'value']
elif len(df.columns) == 2:
    df.columns = ['address', 'value']

df['address_int'] = df['address'].apply(parse_address)
df = df[df['address_int'].notna()].copy()

df['value'] = df['value'].apply(parse_hex_value)
df = df[df['value'].notna()].copy()

# 详细统计
print("=" * 60)
print("数据分布详细分析")
print("=" * 60)

print(f"\n总行数: {len(df)}")
print(f"\n值的统计 (十进制):")
print(f"  最小值: {df['value'].min()}")
print(f"  最大值: {df['value'].max()}")
print(f"  平均值: {df['value'].mean():.2f}")
print(f"  中位数: {df['value'].median():.2f}")

print(f"\n阈值: 0x64 = {0x64} (十进制)")
print(f"  < 100 的数量: {(df['value'] < 100).sum()} ({(df['value'] < 100).sum() / len(df) * 100:.2f}%)")
print(f"  >= 100 的数量: {(df['value'] >= 100).sum()} ({(df['value'] >= 100).sum() / len(df) * 100:.2f}%)")

# 显示值的分布
print(f"\n值分布区间:")
bins = [0, 50, 60, 70, 80, 90, 95, 100, 110, 120, 150, 200, 300]
for i in range(len(bins)-1):
    count = ((df['value'] >= bins[i]) & (df['value'] < bins[i+1])).sum()
    print(f"  [{bins[i]:3d} - {bins[i+1]:3d}): {count:6d} ({count/len(df)*100:5.2f}%)")

# 显示 >= 100 的所有值
not_in_cache = df[df['value'] >= 100]
print(f"\n不在cache中的数据 (value >= 100):")
print(f"  数量: {len(not_in_cache)}")
if len(not_in_cache) > 0 and len(not_in_cache) <= 20:
    print(f"\n详细列表:")
    for idx, row in not_in_cache.iterrows():
        print(f"    地址: 0x{row['address_int']:x}, 值: {row['value']} (0x{row['value']:x})")

# 显示原始值（十六进制字符串）的分布
print(f"\n原始CSV中的值分布 (前20个不同的值):")
if len(df.columns) == 3:
    original_df = pd.read_csv(csv_file, header=None, names=['label', 'address', 'value_hex'])
else:
    original_df = pd.read_csv(csv_file, header=None, names=['address', 'value_hex'])

value_counts = original_df['value_hex'].value_counts().head(20)
for val, count in value_counts.items():
    try:
        decimal = int(str(val), 16)
        print(f"  {val} (0x{val}) = {decimal:3d} 十进制: {count:6d} 次")
    except:
        print(f"  {val}: {count:6d} 次 (无法解析)")

print("\n" + "=" * 60)