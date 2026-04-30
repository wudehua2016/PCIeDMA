import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import os

def parse_address(addr_str):
    """解析地址字符串，提取十六进制地址"""
    # 处理可能的格式: 6abe00080 或 0x6abe00080 或 test:6abe00080
    addr_str = str(addr_str).strip()
    
    # 如果包含冒号，取冒号后面的部分（兼容旧格式）
    if ':' in addr_str:
        addr_str = addr_str.split(':')[-1].strip()
    
    # 移除可能的0x前缀
    if addr_str.startswith('0x') or addr_str.startswith('0X'):
        addr_str = addr_str[2:]
    
    try:
        return int(addr_str, 16)
    except ValueError:
        print(f"Warning: Cannot parse address '{addr_str}'")
        return None

def read_cache_data(csv_file):
    """读取CSV文件并处理数据"""
    print(f"Reading file: {csv_file}")
    
    # 尝试读取CSV文件
    try:
        df = pd.read_csv(csv_file, header=None)
        print(f"Read {len(df)} rows")
        print(f"Columns: {len(df.columns)}")
        print("\nFirst 5 rows:")
        print(df.head())
        
        # 根据列数判断格式
        if len(df.columns) == 3:
            df.columns = ['label', 'address', 'value']
        elif len(df.columns) == 2:
            df.columns = ['address', 'value']
        else:
            print(f"Warning: Found {len(df.columns)} columns, checking CSV format")
            df = df.iloc[:, -2:]
            df.columns = ['address', 'value']
        
    except Exception as e:
        print(f"Error reading CSV: {e}")
        raise
    
    # 解析地址
    print("\nParsing addresses...")
    df['address_int'] = df['address'].apply(parse_address)
    
    # 删除无法解析的行
    rows_before = len(df)
    df = df[df['address_int'].notna()].copy()
    rows_after = len(df)
    print(f"Successfully parsed {rows_after} addresses (dropped {rows_before - rows_after} invalid addresses)")
    
    # 转换值为数字类型 - 注意：值本身是十六进制字符串
    print("Parsing values (hex to decimal)...")
    def parse_hex_value(val_str):
        try:
            val_str = str(val_str).strip()
            # 移除可能的0x前缀
            if val_str.startswith('0x') or val_str.startswith('0X'):
                val_str = val_str[2:]
            return int(val_str, 16)
        except:
            return None
    
    df['value_decimal'] = df['value'].apply(parse_hex_value)
    
    # 检查有多少值无法解析
    rows_before = len(df)
    df = df[df['value_decimal'].notna()].copy()
    rows_after = len(df)
    print(f"Successfully parsed {rows_after} values (dropped {rows_before - rows_after} invalid values)")
    
    # 显示前几个转换示例
    print("\nValue conversion examples:")
    for i in range(min(5, len(df))):
        orig = df.iloc[i]['value']
        converted = df.iloc[i]['value_decimal']
        print(f"  {orig} (hex) -> {converted} (decimal)")
    
    # 使用转换后的十进制值
    df['value'] = df['value_decimal']
    
    # 判断是否在cache中 (value < 0x64 = 100)
    df['in_cache'] = df['value'] < 0x64
    
    # 计算每个2MB块的索引（地址除以0x200000）
    df['block_index'] = (df['address_int'] // 0x200000).astype(int)
    
    print(f"\nData Statistics:")
    print(f"  Address range: 0x{df['address_int'].min():x} - 0x{df['address_int'].max():x}")
    print(f"  Value range: {df['value'].min():.0f} - {df['value'].max():.0f}")
    print(f"  Threshold: 0x64 = {0x64} (decimal)")
    print(f"  Cache hits: {df['in_cache'].sum()}")
    print(f"  Cache misses: {(~df['in_cache']).sum()}")
    
    return df

def create_heatmap(df, blocks_per_row=64, output_file='cache_heatmap_binary.png'):
    """创建热力图"""
    # 获取所有块的索引
    block_indices = df['block_index'].values
    in_cache = df['in_cache'].values
    
    # 确定数据范围
    min_block = block_indices.min()
    max_block = block_indices.max()
    total_blocks = max_block - min_block + 1
    
    print(f"\nCreating heatmap:")
    print(f"  Block range: {min_block} - {max_block}")
    print(f"  Total scanned blocks: {len(df)}")
    print(f"  Cache hit rate: {(in_cache.sum() / len(in_cache) * 100):.2f}%")
    
    # 创建亮度矩阵 (1.0 = 在cache中/亮, 0.0 = 不在cache中/暗)
    brightness_dict = {}
    for idx, cached in zip(block_indices, in_cache):
        brightness_dict[idx - min_block] = 1.0 if cached else 0.0
    
    # 计算网格尺寸
    num_rows = int(np.ceil(total_blocks / blocks_per_row))
    
    # 创建2D数组
    heatmap = np.full((num_rows, blocks_per_row), 0.5)  # 默认灰色
    
    for i in range(total_blocks):
        row = i // blocks_per_row
        col = i % blocks_per_row
        if i in brightness_dict:
            heatmap[row, col] = brightness_dict[i]
    
    # 绘图
    fig, ax = plt.subplots(figsize=(16, max(4, num_rows * 0.25)))
    
    # 使用灰度色图，白色=在cache中，黑色=不在cache中
    im = ax.imshow(heatmap, cmap='gray', aspect='auto', vmin=0, vmax=1, 
                   interpolation='nearest')
    
    # 设置Y轴显示真实的物理地址
    # 计算Y轴刻度：每行代表的起始地址
    y_tick_interval = max(1, num_rows // 10)  # 最多显示10个刻度
    y_ticks = list(range(0, num_rows, y_tick_interval))
    y_labels = []
    for row in y_ticks:
        # 该行的起始块索引
        block_idx = min_block + row * blocks_per_row
        # 转换为物理地址
        phys_addr = block_idx * 0x200000
        y_labels.append(f'0x{phys_addr:x}')
    
    ax.set_yticks(y_ticks)
    ax.set_yticklabels(y_labels)
    
    # 设置标题和标签（使用英文避免字体问题）
    ax.set_title('Physical Memory Cache Hit Rate Heatmap\n(White=In Cache, Black=Not in Cache)', 
                 fontsize=14, pad=20)
    ax.set_xlabel(f'Column (Each pixel = 2MB address space)', fontsize=10)
    ax.set_ylabel('Physical Address', fontsize=10)
    
    # 添加颜色条
    cbar = plt.colorbar(im, ax=ax, fraction=0.046, pad=0.04)
    cbar.set_label('Cache Status (1=Hit, 0=Miss)', rotation=270, labelpad=20)
    
    # 添加统计信息
    stats_text = f'Scanned blocks: {len(df)}\n'
    stats_text += f'Cache hits: {in_cache.sum()} ({in_cache.sum()/len(in_cache)*100:.1f}%)\n'
    stats_text += f'Cache misses: {(~in_cache).sum()} ({(~in_cache).sum()/len(in_cache)*100:.1f}%)'
    
    ax.text(1.15, 0.5, stats_text, transform=ax.transAxes,
            fontsize=10, verticalalignment='center',
            bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))
    
    plt.tight_layout()
    
    # 保存图片
    plt.savefig(output_file, dpi=300, bbox_inches='tight')
    print(f"Saved: {output_file}")
    
    return fig, ax

def create_detailed_view(df, value_threshold=0x64, output_file='cache_heatmap_detailed.png'):
    """创建更详细的视图，显示实际的value值"""
    from matplotlib.colors import LinearSegmentedColormap
    
    block_indices = df['block_index'].values
    values = df['value'].values
    
    min_block = block_indices.min()
    max_block = block_indices.max()
    total_blocks = max_block - min_block + 1
    
    blocks_per_row = 64
    num_rows = int(np.ceil(total_blocks / blocks_per_row))
    
    # 定义有效数据范围
    valid_min = 90
    valid_max = 150
    
    # 创建value矩阵，并处理超出范围的值
    value_map = np.full((num_rows, blocks_per_row), np.nan)
    
    for idx, val in zip(block_indices, values):
        relative_idx = idx - min_block
        row = relative_idx // blocks_per_row
        col = relative_idx % blocks_per_row
        
        # 将超过150的值钳制到150，保持在有效范围内显示
        if val > valid_max:
            value_map[row, col] = valid_max
        else:
            value_map[row, col] = val
    
    # 创建自定义配色方案：90-100用冷色调（蓝色），100-150用暗色调（深红到黑）
    # 计算100在90-150范围中的位置
    threshold_position = (value_threshold - valid_min) / (valid_max - valid_min)
    
    # 定义颜色：从亮蓝色(90) -> 深蓝色(100) -> 深红色 -> 黑色(150)
    colors = [
        (0.0, (0.0, 0.7, 1.0)),           # 90: 亮蓝色 (bright blue)
        (threshold_position, (0.0, 0.3, 0.6)),  # 100: 深蓝色 (dark blue)
        (threshold_position + 0.01, (0.5, 0.0, 0.0)),  # 100+: 深红色 (dark red)
        (0.7, (0.3, 0.0, 0.0)),           # 125: 更深红色
        (1.0, (0.1, 0.0, 0.0))            # 150: 接近黑色 (nearly black)
    ]
    
    cmap = LinearSegmentedColormap.from_list('custom_cache', 
                                             [(pos, color) for pos, color in colors])
    
    # 绘图
    fig, ax = plt.subplots(figsize=(16, max(4, num_rows * 0.25)))
    
    im = ax.imshow(value_map, cmap=cmap, aspect='auto', 
                   vmin=valid_min, vmax=valid_max, interpolation='nearest')
    
    # 设置Y轴显示真实的物理地址
    y_tick_interval = max(1, num_rows // 10)  # 最多显示10个刻度
    y_ticks = list(range(0, num_rows, y_tick_interval))
    y_labels = []
    for row in y_ticks:
        # 该行的起始块索引
        block_idx = min_block + row * blocks_per_row
        # 转换为物理地址
        phys_addr = block_idx * 0x200000
        y_labels.append(f'0x{phys_addr:x}')
    
    ax.set_yticks(y_ticks)
    ax.set_yticklabels(y_labels)
    
    ax.set_title(f'Physical Memory Access Latency Heatmap\n(Blue<100=In Cache, Dark>{value_threshold}=Not in Cache, Valid: {valid_min}-{valid_max})', 
                 fontsize=14, pad=20)
    ax.set_xlabel(f'Column (Each pixel = 2MB address space)', fontsize=10)
    ax.set_ylabel('Physical Address', fontsize=10)
    
    cbar = plt.colorbar(im, ax=ax, fraction=0.046, pad=0.04)
    cbar.set_label(f'Access Latency ({valid_min}-{valid_max}, >{valid_max}=Not in Cache)', rotation=270, labelpad=20)
    
    # 在colorbar上标记阈值100
    if value_threshold >= valid_min and value_threshold <= valid_max:
        threshold_pos = (value_threshold - valid_min) / (valid_max - valid_min)
        cbar.ax.axhline(threshold_pos, color='white', linewidth=3, linestyle='--', label='Threshold')
        cbar.ax.text(1.5, threshold_pos, f' {value_threshold}', 
                    va='center', fontsize=10, color='white', weight='bold',
                    bbox=dict(boxstyle='round,pad=0.3', facecolor='black', alpha=0.7))
    
    plt.tight_layout()
    
    # 保存图片
    plt.savefig(output_file, dpi=300, bbox_inches='tight')
    print(f"Saved: {output_file}")
    
    # 打印统计信息
    print(f"\nValue distribution:")
    print(f"  Valid range: {valid_min}-{valid_max}")
    print(f"  < {valid_min}: {(values < valid_min).sum()} ({(values < valid_min).sum()/len(values)*100:.2f}%)")
    print(f"  {valid_min}-{value_threshold}: {((values >= valid_min) & (values < value_threshold)).sum()} ({((values >= valid_min) & (values < value_threshold)).sum()/len(values)*100:.2f}%) - In Cache (Cold/Blue)")
    print(f"  {value_threshold}-{valid_max}: {((values >= value_threshold) & (values <= valid_max)).sum()} ({((values >= value_threshold) & (values <= valid_max)).sum()/len(values)*100:.2f}%) - Not in Cache (Dark)")
    print(f"  > {valid_max}: {(values > valid_max).sum()} ({(values > valid_max).sum()/len(values)*100:.2f}%) - Not in Cache (clamped to {valid_max}, Dark)")
    
    return fig, ax

# 主程序
if __name__ == "__main__":
    # 读取CSV文件
    csv_file = "log21.csv"  # 修改为你的CSV文件路径
    
    print("=" * 60)
    print("Cache Data Visualization Tool")
    print("=" * 60)
    
    try:
        # 确定输出目录
        output_dir = os.path.dirname(os.path.abspath(__file__))
        print(f"\nOutput directory: {output_dir}")
        
        print("\nReading CSV file...")
        df = read_cache_data(csv_file)
        
        print("\nCreating binary cache hit rate heatmap...")
        output1 = os.path.join(output_dir, 'cache_heatmap_binary.png')
        fig1, ax1 = create_heatmap(df, blocks_per_row=64, output_file=output1)
        
        print("\nCreating detailed latency heatmap...")
        output2 = os.path.join(output_dir, 'cache_heatmap_detailed.png')
        fig2, ax2 = create_detailed_view(df, value_threshold=0x64, output_file=output2)
        
        print("\n" + "=" * 60)
        print("Complete! Charts have been generated.")
        print(f"Output files:")
        print(f"  1. {output1}")
        print(f"  2. {output2}")
        print("=" * 60)
        
    except FileNotFoundError:
        print(f"\nError: File '{csv_file}' not found")
        print("Please make sure the CSV file exists and modify the file path in the script.")
    except Exception as e:
        print(f"\nError occurred: {e}")
        import traceback
        traceback.print_exc()