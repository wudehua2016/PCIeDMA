#!/bin/bash
# 物理地址计算脚本（完全修复版 - 兼容 sh/dash）

echo "========================================"
echo "内核虚拟地址到物理地址转换"
echo "========================================"
echo ""

# 输入地址
TARGET_ADDR="0xffffffffa30bc430"
TEXT_ADDR="0xffffffffa3000000"

# 标准内核基址
STANDARD_TEXT="0xffffffff81000000"
KERNEL_PHYS_BASE="0x1000000"  # 16MB

echo "[输入信息]"
echo "目标函数地址 (__x64_sys_getpid): $TARGET_ADDR"
echo "_text 地址:                       $TEXT_ADDR"
echo ""

# 辅助函数：十六进制转十进制（使用bc）
hex2dec() {
    local hex_val="$1"
    # 去掉 0x 前缀并转大写
    hex_val=$(echo "$hex_val" | sed 's/^0x//;s/^0X//' | tr '[:lower:]' '[:upper:]')
    # 使用 bc 转换
    echo "ibase=16; $hex_val" | bc
}

# 辅助函数：十进制转十六进制
dec2hex() {
    local dec_val="$1"
    if [ -z "$dec_val" ] || [ "$dec_val" = "0" ]; then
        echo "0"
        return
    fi
    echo "obase=16; $dec_val" | bc
}

# 转换地址到十进制
echo "[调试] 正在转换地址..."
target_dec=$(hex2dec "$TARGET_ADDR")
text_dec=$(hex2dec "$TEXT_ADDR")
standard_text_dec=$(hex2dec "$STANDARD_TEXT")
phys_base_dec=$(hex2dec "$KERNEL_PHYS_BASE")

# 检查转换是否成功
if [ -z "$target_dec" ] || [ -z "$text_dec" ]; then
    echo "错误：地址转换失败"
    exit 1
fi

echo "[步骤1] 计算相对偏移"
offset=$(echo "$target_dec - $text_dec" | bc)
offset_hex=$(dec2hex "$offset")
echo "  偏移 = $TARGET_ADDR - $TEXT_ADDR"
echo "       = 0x$offset_hex"
offset_kb=$(echo "scale=2; $offset/1024" | bc)
echo "       = $offset bytes ($offset_kb KB)"
echo ""

echo "[步骤2] 计算 KASLR 偏移"
kaslr_offset=$(echo "$text_dec - $standard_text_dec" | bc)
kaslr_hex=$(dec2hex "$kaslr_offset")
echo "  KASLR偏移 = $TEXT_ADDR - $STANDARD_TEXT"
echo "            = 0x$kaslr_hex"
kaslr_mb=$(echo "scale=2; $kaslr_offset/1048576" | bc)
echo "            = $kaslr_offset bytes ($kaslr_mb MB)"
echo ""

echo "[步骤3] 计算物理地址"
echo "  内核物理基址 = $KERNEL_PHYS_BASE (16MB)"
echo ""

# 计算物理地址
phys_addr=$(echo "$phys_base_dec + $offset" | bc)
phys_addr_hex=$(dec2hex "$phys_addr")
echo "  物理地址 = $KERNEL_PHYS_BASE + 0x$offset_hex"
echo "           = 0x$phys_addr_hex"
phys_mb=$(echo "scale=2; $phys_addr/1048576" | bc)
echo "           = $phys_addr bytes ($phys_mb MB)"
echo ""

echo "[步骤4] 缓存分析"
# 缓存参数
CACHE_LINE_SIZE=64
LLC_SETS=2048

# 缓存行对齐地址 (向下对齐到64字节边界)
cache_line=$(echo "($phys_addr / $CACHE_LINE_SIZE) * $CACHE_LINE_SIZE" | bc)
cache_line_hex=$(dec2hex "$cache_line")
echo "  缓存行地址 (64B对齐):    0x$cache_line_hex"

# 缓存集索引 = (物理地址 >> 6) & (LLC_SETS - 1)
# 即 (物理地址 / 64) % 2048
cache_set=$(echo "($phys_addr / 64) % $LLC_SETS" | bc)
cache_set_hex=$(dec2hex "$cache_set")
echo "  LLC缓存集索引:          $cache_set (0x$cache_set_hex)"

# 物理地址位 [16:6] - 就是缓存集索引的低11位
addr_bits=$(echo "($phys_addr / 64) % 2048" | bc)
addr_bits_hex=$(dec2hex "$addr_bits")
echo "  物理地址位 [16:6]:      0x$addr_bits_hex"

# 页内偏移 (低12位)
page_offset=$(echo "$phys_addr % 4096" | bc)
page_offset_hex=$(dec2hex "$page_offset")
echo "  页内偏移:               0x$page_offset_hex ($page_offset bytes)"

# 页帧号 (PFN) - 物理地址右移12位
pfn=$(echo "$phys_addr / 4096" | bc)
pfn_hex=$(dec2hex "$pfn")
echo "  页帧号 (PFN):           0x$pfn_hex ($pfn)"
echo ""

echo "[步骤5] LLC Prime+Probe 攻击提示"
echo "  ✓ 监控 LLC 缓存集 $cache_set 可以检测此函数的执行"
echo "  ✓ 物理地址的 [16:6] 位为 0x$addr_bits_hex，对应缓存集索引"
echo "  ✓ 同一缓存集的其他地址："

# 计算同一缓存集的其他可能物理地址
# 同一缓存集的地址满足：(addr >> 6) & 0x7FF == cache_set
# 即地址形式为：base + (cache_set << 6) + (n << 17)
base_addr=$(echo "($phys_addr / 131072) * 131072" | bc)  # 131072 = 2^17
for i in 0 1 2 3; do
    example_addr=$(echo "$base_addr + ($cache_set * 64) + ($i * 131072)" | bc)
    if [ "$example_addr" != "$phys_addr" ]; then
        example_hex=$(dec2hex "$example_addr")
        echo "    - 0x$example_hex"
    fi
done
echo ""

echo "[步骤6] 验证命令"
echo "  使用系统调用触发器测试："
echo "    ./syscall_trigger -s getpid &"
echo ""
echo "  使用 LLC Prime+Probe 工具监控缓存集 $cache_set："
echo "    ./your_llc_tool --monitor-set $cache_set"
echo ""
echo "  使用 perf 验证："
echo "    sudo perf stat -e LLC-load-misses -a ./syscall_trigger -s getpid -c 1000"
echo ""

echo "========================================"
echo "计算完成"
echo "========================================"
echo ""

echo "📋 总结："
echo "  虚拟地址: $TARGET_ADDR"
echo "  物理地址: 0x$phys_addr_hex"
echo "  LLC缓存集: $cache_set"
echo "  页帧号:   0x$pfn_hex"
echo ""

# 验证计算
echo "[验证]"
echo "  0x$offset_hex = $(echo "ibase=16; $offset_hex" | bc) (十进制)"
echo "  物理地址应该 = 16MB + $(echo "scale=2; $offset/1024" | bc)KB"
echo ""