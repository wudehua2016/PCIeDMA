
import numpy as np
import matplotlib.pyplot as plt

# 从文件读取数据
with open('app0000-20000.log', 'r', encoding='utf-8') as f:
    data_text = f.read()


# 解析数据
experiments = []
current_exp = set()

for line in data_text.strip().split('\n'):
    if '***' in line:
        # 无论是否为空，都添加当前实验
        experiments.append(current_exp)
        current_exp = set()
    else:
        parts = line.strip().split(',')
        if len(parts) >= 2:
            index = int(parts[1])  # 第二列是索引
            current_exp.add(index)

# 添加最后一次实验（无论是否为空）
experiments.append(current_exp)

# 确定数据索引范围（0-20）
max_index = 20
n_experiments = len(experiments)

# 创建矩阵：行=实验次数，列=数据索引
# 1表示有效（黑色），0表示无效（白色）
matrix = np.zeros((n_experiments, max_index + 1))

for exp_idx, exp_data in enumerate(experiments):
    for data_idx in exp_data:
        if data_idx <= max_index:
            matrix[exp_idx, data_idx] = 1

# 绘制图形
fig, ax = plt.subplots(figsize=(12, n_experiments * 0.5))

# 使用imshow绘制，cmap='binary'表示白色到黑色
im = ax.imshow(matrix, cmap='binary', aspect='auto', interpolation='nearest')

# 设置坐标轴
ax.set_xlabel('数据索引', fontsize=12)
ax.set_ylabel('实验次数', fontsize=12)
ax.set_title('实验数据有效性可视化（黑色=有效，白色=无效）', fontsize=14, pad=20)

# 设置x轴刻度
ax.set_xticks(range(0, max_index + 1, 2))
ax.set_xticklabels(range(0, max_index + 1, 2))

# 设置y轴刻度
ax.set_yticks(range(n_experiments))
ax.set_yticklabels([f'实验 {i+1}' for i in range(n_experiments)])

# 移除网格线，使正方形紧密相连
ax.set_xticks(np.arange(-0.5, max_index + 1, 1), minor=True)
ax.set_yticks(np.arange(-0.5, n_experiments, 1), minor=True)
ax.grid(which='minor', color='gray', linestyle='-', linewidth=0.5)

plt.tight_layout()

# 保存图片到本地
plt.savefig('experiment_data_visualization.png', dpi=300, bbox_inches='tight')
print("图片已保存为: experiment_data_visualization.png")

plt.show()

# 打印统计信息
print(f"总实验次数: {n_experiments}")
print(f"数据索引范围: 0-{max_index}")
print(f"\n各实验有效数据统计:")
for i, exp_data in enumerate(experiments):
    print(f"实验 {i+1}: {len(exp_data)} 个有效数据, 索引: {sorted(exp_data)}")