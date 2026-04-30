import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
import matplotlib.patches as mpatches
import numpy as np

# 数据准备
data = {
    'Block Index': [2354, 2358, 2474, 2476, 2483, 2570, 2725, 2972, 3196, 4374, 
                    4592, 9477, 9478, 9542, 9764, 9963, 9983, 10101, 14276, 14277],
    'Hit': [6, 9, 10, 6, 11, 9, 8, 6, 7, 7, 9, 6, 7, 7, 7, 6, 9, 6, 9, 6],
    'Miss': [5, 2, 1, 5, 0, 2, 3, 5, 4, 4, 2, 4, 3, 3, 3, 4, 1, 4, 1, 4],
    'Start_Addr': [0x126400000, 0x126c00000, 0x135400000, 0x135800000, 0x136600000,
                   0x141400000, 0x154a00000, 0x173800000, 0x18f800000, 0x222c00000,
                   0x23e000000, 0x4a0a00000, 0x4a0c00000, 0x4a8c00000, 0x4c4800000,
                   0x4dd600000, 0x4dfe00000, 0x4eea00000, 0x6f8800000, 0x6f8a00000]
}
df = pd.DataFrame(data)
df['Hit_Ratio'] = df['Hit'] / (df['Hit'] + df['Miss'])

fig, ax = plt.subplots(figsize=(18, 4))

# 设置物理地址范围，Y轴留出空间给箭头标注
START_ADDR = 0x100000000
END_ADDR = 0x87FFFFFFF
ax.set_xlim(START_ADDR, END_ADDR)
ax.set_ylim(-0.5, 1.2)  # 向上扩展空间放置箭头

# 绘制内存空间背景
ax.barh(0, END_ADDR - START_ADDR, left=START_ADDR, height=0.5, 
        color='#E0E0E0', alpha=0.3, label='Memory Space')

# 内核代码区域参数
KERNEL_START = 0x6f7a00000
KERNEL_END = 0x6f8a02401
kernel_center = (KERNEL_START + KERNEL_END) / 2

# ===== 箭头标注内核区域（在图上方）=====
ax.annotate('Linux Kernel Code\n(0x6f7a00000 - 0x6f8a02401)', 
            xy=(kernel_center, 0.2),       # 箭头指向内核区域（条形图上方一点）
            xytext=(kernel_center, 0.5),   # 文本位置在图上方
            arrowprops=dict(arrowstyle='->', color='blue', lw=2),
            fontsize=18, color='blue', fontweight='bold',
            ha='center', va='bottom',
            bbox=dict(boxstyle='round,pad=0.5', facecolor='lightblue', 
                     edgecolor='blue', alpha=0.8))

# 绘制热点区域，内核内热点用蓝色边框高亮
colors = plt.cm.RdYlGn(df['Hit_Ratio'])
block_size = 0x200000
for idx, row in df.iterrows():
    is_in_kernel = KERNEL_START <= row['Start_Addr'] <= KERNEL_END
    edge_color = 'black' if is_in_kernel else 'black'
    line_width = 2.5 if is_in_kernel else 2.5
    z_order = 6 if is_in_kernel else 5  # 内核内热点置顶
    
    ax.barh(0, block_size, left=row['Start_Addr'], height=0.4, 
            color=colors[idx], alpha=0.9, edgecolor=edge_color, 
            linewidth=line_width, zorder=z_order)

# 刻度设置（每4GB一个）
ax.xaxis.set_major_locator(ticker.MultipleLocator(0x100000000))
def simple_formatter(x, pos):
    gb_offset = int((x - START_ADDR) / (1024**3))
    hex_short = f"0x{int(x):X}"[:4]
    return f"{hex_short}\n(+{gb_offset}GB)"

ax.xaxis.set_major_formatter(ticker.FuncFormatter(simple_formatter))

ax.set_xlabel('Physical Address Index', fontsize=18)
#ax.set_title('Cache Hotspots in 32GB Physical Memory\n(Linux Kernel Region Annotated)', 
#             fontsize=14, pad=20)
ax.set_yticks([0])
ax.set_yticklabels(['Memory\nSpace'])
ax.grid(True, axis='x', alpha=0.3, linestyle='--')

# 图例
hit_patch = mpatches.Patch(color='black', alpha=0.9, label='Cache Hotspot (2MB)')
kernel_patch = mpatches.Patch(edgecolor='black', facecolor='none', 
                              linewidth=2, label='Inside Kernel Region')
ax.legend(handles=[hit_patch], loc='upper left', fontsize=18)

# 统计信息
kernel_hits = df[(df['Start_Addr'] >= KERNEL_START) & (df['Start_Addr'] <= KERNEL_END)]
ax.tick_params(axis='x', labelsize=18) 
ax.tick_params(axis='y', labelsize=18)  

plt.tight_layout()
plt.savefig('memory_map_kernel_arrow.png', dpi=600, bbox_inches='tight', facecolor='white')
plt.show()