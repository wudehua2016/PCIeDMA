import matplotlib.pyplot as plt
import matplotlib
matplotlib.rcParams['font.sans-serif'] = ['SimHei', 'DejaVu Sans']  # 支持中文显示
matplotlib.rcParams['axes.unicode_minus'] = False  # 解决负号显示问题

# 原始数据
data = {
    
    'L25S9': {
        'values': [386, 385, 375, 381, 357, 332, 310, 297, 159, 102, 97, 105, 94, 67, 51, 30, 21, 20, 6, 2],
        'labels': ['1b6e00000', '1b5c00000', '1b3200000', '1b2a00000', '1b1800000', 
                   '1b0000000', '1ae600000', '1ad400000', '1aa200000', '1a9000000', 
                   '1a8800000', '1a7e00000', '1a4c00000', '1a3a00000', '195e00000', 
                   '19b000000', '16e800000', '17bc00000', '180a00000', '196c00000']
    },
    'L25S19': {
        'values': [390, 383, 361, 368, 137, 358, 299, 262, 227, 171, 113, 109, 108, 83, 86, 41, 30, 9, 4, 4],
        'labels': ['1b6e00000', '1b5c00000', '1b3200000', '1b2a00000', '1b1800000', 
                   '1b0000000', '1ae600000', '1ad400000', '1aa200000', '1a9000000', 
                   '1a8800000', '1a7e00000', '1a4c00000', '1a3a00000', '195e00000', 
                   '19b000000', '16e800000', '17bc00000', '180a00000', '196c00000']
    },
    'L35S9': {
        'values': [398, 399, 395, 398, 395, 392, 397, 388, 357, 345, 326, 336, 331, 337, 323, 307, 305, 289, 247, 213],
        'labels': ['1b6e00000', '1b5c00000', '1b3200000', '1b2a00000', '1b1800000', 
                   '1b0000000', '1ae600000', '1ad400000', '1aa200000', '1a9000000', 
                   '1a8800000', '1a7e00000', '1a4c00000', '1a3a00000', '195e00000', 
                   '19b000000', '16e800000', '17bc00000', '180a00000', '196c00000']
    },
    'L35S19': {
        'values': [398, 394, 397, 395, 199, 385, 385, 387, 378, 360, 347, 333, 336, 324, 326, 324, 308, 308, 302, 236],
        'labels': ['1b6e00000', '1b5c00000', '1b3200000', '1b2a00000', '1b1800000', 
                   '1b0000000', '1ae600000', '1ad400000', '1aa200000', '1a9000000', 
                   '1a8800000', '1a7e00000', '1a4c00000', '1a3a00000', '195e00000', 
                   '19b000000', '16e800000', '17bc00000', '180a00000', '196c00000']
    },
    'L43S9': {
        'values': [399, 400, 399, 399, 399, 397, 398, 398, 394, 393, 395, 392, 390, 389, 386, 379, 372, 370, 361, 343],
        'labels': ['1b6e00000', '1b5c00000', '1b3200000', '1b2a00000', '1b1800000', 
                   '1b0000000', '1ae600000', '1ad400000', '1aa200000', '1a9000000', 
                   '1a8800000', '1a7e00000', '1a4c00000', '1a3a00000', '195e00000', 
                   '19b000000', '16e800000', '17bc00000', '180a00000', '196c00000']
    },
    'L43S19': {
        'values': [400, 400, 400, 400, 321, 398, 398, 396, 395, 397, 390, 387, 390, 387, 363, 370, 368, 369, 342, 340],
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
categories = ['L25S9', 'L25S19', 'L35S9', 'L35S19', 'L43S9', 'L43S19']

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
    
    # B4线条加粗
    if idx == 4:
        linewidth = 4.0
        markersize = 10
        alpha = 1.0
    else:
        linewidth = 1.5
        markersize = 7
        alpha = 0.8
    
    plt.plot(categories, values, 
             marker=marker, 
             linestyle=line_style,
             label=simple_label, 
             linewidth=linewidth, 
             markersize=markersize,
             alpha=alpha)

# 设置图表标题和标签
plt.title('', fontsize=16, fontweight='bold', pad=20)
plt.xlabel('Access Pattern', fontsize=18)
plt.ylabel('LLC Miss Counts', fontsize=18)
plt.xticks(categories, fontsize=18)
plt.yticks(fontsize=11)

# 将图例放在上方，多列显示
plt.legend(loc='upper center', bbox_to_anchor=(0.5, -0.08), 
           fontsize=14, ncol=10, frameon=True, shadow=True)

plt.grid(True, alpha=0.3, linestyle='--', linewidth=0.5)
plt.tight_layout()

# 保存图表
plt.savefig('./line_chart_bt.png', dpi=600, bbox_inches='tight')
print("折线图已生成并保存为 line_chart.png")
print(f"共绘制了 {len(unique_labels)} 条折线，代表 {len(unique_labels)} 个不同的标签")
print("\n标签映射关系：")
for idx, label in enumerate(label_data.keys()):
    print(f"B{idx} -> {label}")

# 显示图表
plt.show()