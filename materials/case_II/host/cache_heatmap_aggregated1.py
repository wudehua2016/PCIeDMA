import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap
import os

def parse_address(addr_str):
    addr_str = str(addr_str).strip()
    if ':' in addr_str:
        addr_str = addr_str.split(':')[-1].strip()
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

def read_cache_data(csv_file):
    df = pd.read_csv(csv_file, header=None)
    
    if len(df.columns) == 3:
        df.columns = ['label', 'address', 'value']
    elif len(df.columns) == 2:
        df.columns = ['address', 'value']
    else:
        df = df.iloc[:, -2:]
        df.columns = ['address', 'value']
    
    df['address_int'] = df['address'].apply(parse_address)
    df = df[df['address_int'].notna()].copy()
    
    df['value_decimal'] = df['value'].apply(parse_hex_value)
    df = df[df['value_decimal'].notna()].copy()
    df['value'] = df['value_decimal']
    
    df['in_cache'] = df['value'] < 0x64
    df['block_index'] = (df['address_int'] // 0x200000).astype(int)
    
    return df

def aggregate_blocks(df, method='mean'):
    """
    聚合同一2MB块内的多个地址
    
    method选项:
    - 'mean': 平均值（推荐）- 反映该2MB块的平均cache性能
    - 'min': 最小值 - 最乐观估计
    - 'max': 最大值 - 最保守估计
    - 'median': 中位数 - 鲁棒的中间值
    - 'hit_rate': cache命中率 (0-1之间) - 该块有多少比例在cache中
    - 'majority_vote': 多数投票 - 该块中>100和<100哪个出现次数更多
    - 'last': 最后一个值（当前的默认行为）
    """
    
    if method == 'hit_rate':
        # 计算每个块的cache命中率
        block_stats = df.groupby('block_index').agg({
            'in_cache': 'mean',  # 命中率
            'value': 'count'      # 采样数
        }).rename(columns={'in_cache': 'hit_rate', 'value': 'sample_count'})
        
        # 将命中率转换为0-150的值（0%=150, 100%=90）
        block_stats['aggregated_value'] = 150 - (block_stats['hit_rate'] * 60)
        
    elif method == 'majority_vote':
        # 多数投票：看>100和<100哪个出现次数更多
        def vote(group):
            in_cache_count = (group['value'] < 100).sum()
            not_in_cache_count = (group['value'] >= 100).sum()
            total = len(group)
            
            # 如果命中次数更多，返回一个<100的值（比如95）
            # 如果未命中次数更多，返回一个>100的值（比如105）
            # 如果相等，返回100（边界值）
            if in_cache_count > not_in_cache_count:
                # 命中占优，返回95表示在cache中
                return pd.Series({
                    'aggregated_value': 95,
                    'sample_count': total,
                    'in_cache_votes': in_cache_count,
                    'not_in_cache_votes': not_in_cache_count
                })
            elif not_in_cache_count > in_cache_count:
                # 未命中占优，返回105表示不在cache中
                return pd.Series({
                    'aggregated_value': 105,
                    'sample_count': total,
                    'in_cache_votes': in_cache_count,
                    'not_in_cache_votes': not_in_cache_count
                })
            else:
                # 相等，返回边界值100
                return pd.Series({
                    'aggregated_value': 100,
                    'sample_count': total,
                    'in_cache_votes': in_cache_count,
                    'not_in_cache_votes': not_in_cache_count
                })
        
        block_stats = df.groupby('block_index').apply(vote, include_groups=False)
    
    elif method == 'last':
        # 保留最后一个值（原始行为）
        block_stats = df.groupby('block_index').last()[['value']]
        block_stats.rename(columns={'value': 'aggregated_value'}, inplace=True)
        block_stats['sample_count'] = df.groupby('block_index').size()
        
    else:
        # 数值聚合方法
        agg_func = {
            'mean': 'mean',
            'min': 'min',
            'max': 'max',
            'median': 'median'
        }.get(method, 'mean')
        
        block_stats = df.groupby('block_index').agg({
            'value': [agg_func, 'count']
        })
        block_stats.columns = ['aggregated_value', 'sample_count']
    
    return block_stats

def create_custom_colormap():
    """创建自定义配色方案"""
    valid_min = 90
    valid_max = 150
    threshold = 100
    threshold_pos = (threshold - valid_min) / (valid_max - valid_min)
    
    colors = [
        (0.0, (0.0, 0.7, 1.0)),           # 90: 亮蓝色
        (threshold_pos, (0.0, 0.3, 0.6)),  # 100: 深蓝色
        (threshold_pos + 0.01, (0.5, 0.0, 0.0)),  # 100+: 深红色
        (0.7, (0.3, 0.0, 0.0)),           # 125: 更深红色
        (1.0, (0.1, 0.0, 0.0))            # 150: 接近黑色
    ]
    
    cmap = LinearSegmentedColormap.from_list('custom_cache', 
                                             [(pos, color) for pos, color in colors])
    return cmap

def create_heatmap(df, aggregation_method='mean', output_file='cache_heatmap.png'):
    """创建热力图"""
    
    # 聚合数据
    print(f"\nAggregation method: {aggregation_method}")
    block_stats = aggregate_blocks(df, method=aggregation_method)
    
    # 打印聚合统计
    print(f"Total unique 2MB blocks: {len(block_stats)}")
    print(f"Blocks with multiple samples: {(block_stats['sample_count'] > 1).sum()}")
    print(f"Max samples in one block: {block_stats['sample_count'].max()}")
    print(f"Average samples per block: {block_stats['sample_count'].mean():.2f}")
    
    # 获取块索引和值
    block_indices = block_stats.index.values
    values = block_stats['aggregated_value'].values
    
    min_block = block_indices.min()
    max_block = block_indices.max()
    total_blocks = max_block - min_block + 1
    
    blocks_per_row = 64
    num_rows = int(np.ceil(total_blocks / blocks_per_row))
    
    # 定义有效数据范围
    valid_min = 90
    valid_max = 150
    value_threshold = 100
    
    # 创建value矩阵
    value_map = np.full((num_rows, blocks_per_row), np.nan)
    
    for idx, val in zip(block_indices, values):
        relative_idx = idx - min_block
        row = relative_idx // blocks_per_row
        col = relative_idx % blocks_per_row
        if val > valid_max:
            value_map[row, col] = valid_max
        else:
            value_map[row, col] = val
    
    # 获取自定义配色方案
    cmap = create_custom_colormap()
    
    # 绘图
    fig, ax = plt.subplots(figsize=(16, max(4, num_rows * 0.25)))
    
    im = ax.imshow(value_map, cmap=cmap, aspect='auto', 
                   vmin=valid_min, vmax=valid_max, interpolation='nearest')
    
    # 设置Y轴
    y_tick_interval = max(1, num_rows // 10)
    y_ticks = list(range(0, num_rows, y_tick_interval))
    y_labels = []
    for row in y_ticks:
        block_idx = min_block + row * blocks_per_row
        phys_addr = block_idx * 0x200000
        y_labels.append(f'0x{phys_addr:x}')
    
    ax.set_yticks(y_ticks)
    ax.set_yticklabels(y_labels)
    
    method_desc = {
        'mean': 'Average',
        'min': 'Min (Best Case)',
        'max': 'Max (Worst Case)', 
        'median': 'Median',
        'hit_rate': 'Hit Rate',
        'majority_vote': 'Majority Vote',
        'last': 'Last Sample'
    }.get(aggregation_method, aggregation_method)
    
    ax.set_title(f'Physical Memory Cache Heatmap - Aggregation: {method_desc}\n(Cold Blue < 100 = In Cache, Dark Red >= 100 = Not in Cache)', 
                 fontsize=13, pad=20)
    ax.set_xlabel(f'Column (Each pixel = 2MB address space)', fontsize=10)
    ax.set_ylabel('Physical Address', fontsize=10)
    
    cbar = plt.colorbar(im, ax=ax, fraction=0.046, pad=0.04)
    cbar.set_label(f'Latency ({valid_min}-{valid_max})', rotation=270, labelpad=20)
    
    # 标记阈值
    threshold_pos = (value_threshold - valid_min) / (valid_max - valid_min)
    cbar.ax.axhline(threshold_pos, color='white', linewidth=3, linestyle='--')
    cbar.ax.text(1.6, threshold_pos, f' {value_threshold}', 
                va='center', fontsize=10, color='white', weight='bold',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='black', alpha=0.8))
    
    # 添加统计信息
    in_cache_blocks = (values < value_threshold).sum()
    stats_text = f'Unique blocks: {len(block_stats)}\n'
    stats_text += f'In cache: {in_cache_blocks} ({in_cache_blocks/len(block_stats)*100:.1f}%)\n'
    stats_text += f'Aggregation: {method_desc}'
    
    ax.text(1.15, 0.3, stats_text, transform=ax.transAxes,
            fontsize=9, verticalalignment='center',
            bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))
    
    plt.tight_layout()
    plt.savefig(output_file, dpi=300, bbox_inches='tight')
    print(f"Saved: {output_file}")
    plt.close()

# 主程序
if __name__ == "__main__":
    csv_file = "log.csv"
    output_dir = os.path.dirname(os.path.abspath(__file__))
    
    print("=" * 70)
    print("Cache Heatmap with Proper Block Aggregation")
    print("=" * 70)
    
    try:
        print("\nReading data...")
        df = read_cache_data(csv_file)
        print(f"Total samples: {len(df)}")
        print(f"Overall cache hit rate: {(df['in_cache'].sum() / len(df) * 100):.2f}%")
        
        # 检查数据分布
        blocks_per_address = df.groupby('block_index').size()
        print(f"\nData distribution per 2MB block:")
        print(f"  Total unique blocks: {len(blocks_per_address)}")
        print(f"  Blocks with 1 sample: {(blocks_per_address == 1).sum()}")
        print(f"  Blocks with >1 samples: {(blocks_per_address > 1).sum()}")
        if (blocks_per_address > 1).sum() > 0:
            print(f"  Max samples in one block: {blocks_per_address.max()}")
            print(f"  Example multi-sample blocks:")
            multi_sample = blocks_per_address[blocks_per_address > 1].head(3)
            for block_idx, count in multi_sample.items():
                phys_addr = block_idx * 0x200000
                print(f"    Block 0x{phys_addr:x}: {count} samples")
        
        # 生成多种聚合方法的热力图
        aggregation_methods = {
            'majority_vote': 'Majority vote: which is more - cache hits or misses (Recommended for binary classification)',
            'mean': 'Average of all samples in the block',
            'median': 'Median value (Robust to outliers)',
            'min': 'Minimum value (Best case scenario)',
            'max': 'Maximum value (Worst case scenario)',
            'hit_rate': 'Cache hit rate percentage'
        }
        
        print(f"\n{'=' * 70}")
        print("Generating heatmaps with different aggregation methods...")
        print(f"{'=' * 70}")
        
        for method, description in aggregation_methods.items():
            print(f"\n{method.upper()}: {description}")
            output_file = os.path.join(output_dir, f'cache_heatmap_{method}.png')
            create_heatmap(df, aggregation_method=method, output_file=output_file)
        
        print("\n" + "=" * 70)
        print("Complete! All heatmaps generated.")
        print(f"Output directory: {output_dir}")
        print("\nRecommendations:")
        print("  - Use 'majority_vote' for clear binary classification (in/out of cache)")
        print("  - Use 'mean' for nuanced view of average latency")
        print("=" * 70)
        
    except Exception as e:
        print(f"\nError: {e}")
        import traceback
        traceback.print_exc()