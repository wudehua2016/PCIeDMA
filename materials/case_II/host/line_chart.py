import matplotlib.pyplot as plt
import matplotlib
matplotlib.rcParams['font.sans-serif'] = ['SimHei', 'DejaVu Sans']  # 支持中文显示
matplotlib.rcParams['axes.unicode_minus'] = False  # 解决负号显示问题

# 原始数据
data = {
    15: {
        'values': [326, 282, 174, 160, 74, 63, 48, 52, 60, 52, 19, 11, 6, 2, 1],
        'labels': ['1b6e00000', '1b5c00000', '1b3200000', '1b2a00000', '1b1800000', 
                   '1b0000000', '1ae600000', '1ad400000', '1aa200000', '1a9000000', 
                   '1a8800000', '1a7e00000', '1a4c00000', '1a3a00000', '195e00000']
    },
    21: {
        'values': [383, 379, 328, 343, 263, 198, 179, 131, 60, 65, 53, 45, 32, 22, 14, 11, 4, 3, 2, 1],
        'labels': ['1b6e00000', '1b5c00000', '1b3200000', '1b2a00000', '1b1800000', 
                   '1b0000000', '1ae600000', '1ad400000', '1aa200000', '1a9000000', 
                   '1a8800000', '1a7e00000', '1a4c00000', '1a3a00000', '195e00000', 
                   '19b000000', '16e800000', '17bc00000', '180a00000', '196c00000']
    },
    25: {
        'values': [394, 386, 377, 383, 346, 344, 328, 274, 232, 170, 150, 155, 165, 167, 153, 129, 76, 61, 32, 13],
        'labels': ['1b6e00000', '1b5c00000', '1b3200000', '1b2a00000', '1b1800000', 
                   '1b0000000', '1ae600000', '1ad400000', '1aa200000', '1a9000000', 
                   '1a8800000', '1a7e00000', '1a4c00000', '1a3a00000', '195e00000', 
                   '19b000000', '16e800000', '17bc00000', '180a00000', '196c00000']
    },
    30: {
        'values': [400, 396, 391, 391, 381, 370, 377, 366, 342, 334, 302, 284, 278, 262, 246, 247, 205, 180, 147, 117],
        'labels': ['1b6e00000', '1b5c00000', '1b3200000', '1b2a00000', '1b1800000', 
                   '1b0000000', '1ae600000', '1ad400000', '1aa200000', '1a9000000', 
                   '1a8800000', '1a7e00000', '1a4c00000', '1a3a00000', '195e00000', 
                   '19b000000', '16e800000', '17bc00000', '180a00000', '196c00000']
    },
    35: {
        'values': [399, 399, 399, 397, 391, 388, 385, 388, 382, 375, 369, 360, 355, 330, 333, 317, 298, 293, 288, 254],
        'labels': ['1b6e00000', '1b5c00000', '1b3200000', '1b2a00000', '1b1800000', 
                   '1b0000000', '1ae600000', '1ad400000', '1aa200000', '1a9000000', 
                   '1a8800000', '1a7e00000', '1a4c00000', '1a3a00000', '195e00000', 
                   '19b000000', '16e800000', '17bc00000', '180a00000', '196c00000']
    },
    42: {
        'values': [400, 399, 400, 398, 400, 399, 400, 397, 399, 400, 396, 399, 396, 396, 397, 397, 390, 374, 378, 359],
        'labels': ['1b6e00000', '1b5c00000', '1b3200000', '1b2a00000', '1b1800000', 
                   '1b0000000', '1ae600000', '1ad400000', '1aa200000', '1a9000000', 
                   '1a8800000', '1a7e00000', '1a4c00000', '1a3a00000', '195e00000', 
                   '19b000000', '16e800000', '17bc00000', '180a00000', '196c00000']
    }
}

# 转换数据结构：以标签为key，类别为横坐标
# 获取所有唯一的标签
all_labels = []
for content in data.values():
    all_labels.extend(content['labels'])
unique_labels = []
for label in all_labels:
    if label not in unique_labels:
        unique_labels.append(label)

# 类别列表（横坐标）
categories = [15, 21, 25, 30, 35, 42]

# 为每个标签创建一条折线
label_data = {}
for label in unique_labels:
    label_data[label] = []
    for category in categories:
        if label in data[category]['labels']:
            idx = data[category]['labels'].index(label)
            label_data[label].append(data[category]['values'][idx])
        else:
            label_data[label].append(None)  # 如果该类别没有此标签，使用None

# 定义不同的线型和标记样式
line_styles = ['-', '--', '-.', ':']
markers = ['o', 's', '^', 'D', 'v', '<', '>', 'p', '*', 'h', 'H', '+', 'x', 'd', '|', '_']

# 创建图表
plt.figure(figsize=(14, 8))

# 绘制每条折线（每个标签一条线）
for idx, (label, values) in enumerate(label_data.items()):
    line_style = line_styles[idx % len(line_styles)]
    marker = markers[idx % len(markers)]
    simple_label = f'B{idx}'  # 简化标签名
    
    plt.plot(categories, values, 
             marker=marker, 
             linestyle=line_style,
             label=simple_label, 
             linewidth=1.5, 
             markersize=7,
             alpha=0.8)

# 设置图表标题和标签
plt.title('', fontsize=16, fontweight='bold', pad=20)
plt.xlabel('Sequence Lengths', fontsize=18)
plt.ylabel('LLC Miss Counts', fontsize=18)
plt.xticks(categories, fontsize=11)
plt.yticks(fontsize=11)

# 将图例放在上方，多列显示
plt.legend(loc='upper center', bbox_to_anchor=(0.5, -0.08), 
           fontsize=14, ncol=10, frameon=True, shadow=True)

plt.grid(True, alpha=0.3, linestyle='--', linewidth=0.5)
plt.tight_layout()

# 保存图表
plt.savefig('./line_chart.png', dpi=600, bbox_inches='tight')
print("折线图已生成并保存为 line_chart.png")
print(f"共绘制了 {len(unique_labels)} 条折线，代表 {len(unique_labels)} 个不同的标签")
print("\n标签映射关系：")
for idx, label in enumerate(label_data.keys()):
    print(f"B{idx} -> {label}")

# 显示图表
plt.show()