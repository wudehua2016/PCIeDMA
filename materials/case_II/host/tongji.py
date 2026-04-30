import matplotlib.pyplot as plt
import matplotlib
import re

matplotlib.rcParams['font.sans-serif'] = ['SimHei', 'DejaVu Sans']
matplotlib.rcParams['axes.unicode_minus'] = False

# 指定的顺序
desired_order = [
    '1b6e00000','1b5c00000','1b3200000','1b2a00000','1b1800000','1b0000000','1ae600000','1ad400000','1aa200000','1a9000000','1a8800000','1a7e00000','1a4c00000','1a3a00000','195e00000','19b000000','16e800000','17bc00000','180a00000','196c00000',

]

# 读取文件并解析数据
def read_data_from_file(filename):
    data_dict = {}
    
    with open(filename, 'r', encoding='utf-8') as f:
        for line in f:
            # 匹配格式: 5dc200000       : 378次
            match = re.match(r'([0-9a-fA-F]+)\s*:\s*(\d+)次', line.strip())
            if match:
                address = match.group(1)
                count = int(match.group(2))
                data_dict[address] = count
    
    return data_dict

# 从文件读取数据
filename = 'data.txt'  # 请替换为您的文件名
data_dict = read_data_from_file(filename)

# 按照指定顺序组织数据
addresses = []
counts = []
for addr in desired_order:
    if addr in data_dict:
        addresses.append(addr)
        counts.append(data_dict[addr])

# 创建图表
fig, ax = plt.subplots(figsize=(14, 8))

# 绘制横向条形图
bars = ax.barh(range(len(addresses)), counts, color='steelblue', edgecolor='black', linewidth=0.5)

# 设置y轴标签（反转顺序使第一个在顶部）
ax.set_yticks(range(len(addresses)))
ax.set_yticklabels(addresses, fontsize=10)
ax.invert_yaxis()  # 反转y轴使第一个地址在顶部

# 设置x轴和标题
ax.set_xlabel('次数', fontsize=12, fontweight='bold')
ax.set_title('地址访问次数统计', fontsize=14, fontweight='bold', pad=20)

# 在每个条形上显示数值
for i, (bar, count) in enumerate(zip(bars, counts)):
    ax.text(count + 5, i, str(count), va='center', fontsize=9)
print(counts)
print(addresses)
# 添加网格线
ax.grid(axis='x', alpha=0.3, linestyle='--')
ax.set_axisbelow(True)

# 调整布局
plt.tight_layout()

# 保存图表
plt.savefig('address_frequency_chart.png', dpi=300, bbox_inches='tight')

# 显示图表
plt.show()

print(f"成功读取 {len(addresses)} 条数据")
print(f"总计数: {sum(counts)} 次")