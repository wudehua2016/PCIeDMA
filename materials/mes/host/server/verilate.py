import pandas as pd
from collections import Counter

# 读取CSV文件
input_file = 'input_data.csv'  # 请替换为你的输入文件名
output_file = 'output_result.csv'  # 输出文件名

# 读取数据，假设没有表头
df = pd.read_csv(input_file, header=None, names=['编号', '第二列', '第三列'])

# 分别统计第二列和第三列的数值出现次数
count_col2 = Counter(df['第二列'])
count_col3 = Counter(df['第三列'])

# 获取所有出现过的数值（两列的并集）
all_unique_values = sorted(set(list(df['第二列']) + list(df['第三列'])))

# 创建结果DataFrame
result_df = pd.DataFrame({
    '数值': all_unique_values,
    '第二列出现次数': [count_col2.get(val, 0) for val in all_unique_values],
    '第三列出现次数': [count_col3.get(val, 0) for val in all_unique_values]
})

# 保存到新的CSV文件
result_df.to_csv(output_file, index=False, encoding='utf-8-sig')

print(f"统计完成！结果已保存到 {output_file}")
print("\n统计结果预览：")
print(result_df)

# 显示一些统计信息
print(f"\n总共有 {len(result_df)} 个不同的数值")
print(f"第二列数据量: {len(df['第二列'])}")
print(f"第三列数据量: {len(df['第三列'])}")