#!/bin/bash
# 反推内核物理基址脚本

echo "========================================"
echo "从 DMA 地址反推内核物理基址"
echo "========================================"
echo ""

# 已知信息
LINUX_BANNER_VIRT="0xffffffffa415f4a0"
TEXT_VIRT="0xffffffffa3000000"
LINUX_BANNER_DMA="0x2c72001a0"

echo "[已知信息]"
echo "linux_banner 虚拟地址:  $LINUX_BANNER_VIRT"
echo "_text 虚拟地址:         $TEXT_VIRT"
echo "linux_banner DMA地址:   $LINUX_BANNER_DMA"
echo ""

# 辅助函数
hex2dec() {
    local hex_val="$1"
    hex_val=$(echo "$hex_val" | sed 's/^0x//;s/^0X//' | tr '[:lower:]' '[:upper:]')
    echo "ibase=16; $hex_val" | bc
}

dec2hex() {
    local dec_val="$1"
    if [ -z "$dec_val" ] || [ "$dec_val" = "0" ]; then
        echo "0"
        return
    fi
    echo "obase=16; $dec_val" | bc
}

# 转换为十进制
banner_virt_dec=$(hex2dec "$LINUX_BANNER_VIRT")
text_virt_dec=$(hex2dec "$TEXT_VIRT")
banner_dma_dec=$(hex2dec "$LINUX_BANNER_DMA")

echo "[步骤1] 计算虚拟地址偏移"
offset=$(echo "$banner_virt_dec - $text_virt_dec" | bc)
offset_hex=$(dec2hex "$offset")
echo "  偏移 = $LINUX_BANNER_VIRT - $TEXT_VIRT"
echo "       = 0x$offset_hex"
offset_mb=$(echo "scale=2; $offset/1048576" | bc)
echo "       = $offset bytes ($offset_mb MB)"
echo ""

echo "[步骤2] 反推内核物理基址"
kernel_phys_base=$(echo "$banner_dma_dec - $offset" | bc)
kernel_phys_base_hex=$(dec2hex "$kernel_phys_base")
echo "  内核物理基址 = $LINUX_BANNER_DMA - 0x$offset_hex"
echo "               = 0x$kernel_phys_base_hex"
kernel_base_mb=$(echo "scale=2; $kernel_phys_base/1048576" | bc)
echo "               = $kernel_phys_base bytes ($kernel_base_mb MB)"
echo ""

echo "[步骤3] 验证计算"
verify_banner=$(echo "$kernel_phys_base + $offset" | bc)
verify_banner_hex=$(dec2hex "$verify_banner")
echo "  验证：内核基址 + 偏移 = 0x$kernel_phys_base_hex + 0x$offset_hex"
echo "                       = 0x$verify_banner_hex"
if [ "$verify_banner_hex" = "$(echo $LINUX_BANNER_DMA | sed 's/^0x//' | tr '[:lower:]' '[:upper:]')" ]; then
    echo "  ✓ 计算正确！"
else
    echo "  ✗ 计算错误，请检查输入"
fi
echo ""

echo "[步骤4] 重新计算其他地址的物理地址"
echo ""
echo "  使用新的内核物理基址 0x$kernel_phys_base_hex："
echo ""

# 计算 __x64_sys_getpid 的物理地址
GETPID_VIRT="0xffffffffa30bc430"
getpid_virt_dec=$(hex2dec "$GETPID_VIRT")
getpid_offset=$(echo "$getpid_virt_dec - $text_virt_dec" | bc)
getpid_offset_hex=$(dec2hex "$getpid_offset")
getpid_phys=$(echo "$kernel_phys_base + $getpid_offset" | bc)
getpid_phys_hex=$(dec2hex "$getpid_phys")

echo "  __x64_sys_getpid:"
echo "    虚拟地址: $GETPID_VIRT"
echo "    偏移:     0x$getpid_offset_hex"
echo "    物理地址: 0x$getpid_phys_hex"
echo ""

# 计算缓存集
cache_set=$(echo "($getpid_phys / 64) % 2048" | bc)
echo "    LLC缓存集: $cache_set"
echo ""

echo "========================================"
echo "总结"
echo "========================================"
echo ""
echo "你的系统配置："
echo "  内核物理基址: 0x$kernel_phys_base_hex ($kernel_base_mb MB)"
echo "  这不是标准的 16MB (0x1000000)"
echo ""
echo "原因可能是："
echo "  1. 系统有大量物理内存，内核加载在更高位置"
echo "  2. NUMA 配置影响了内核加载位置"  
echo "  3. BIOS/UEFI 保留了低端内存"
echo "  4. 启用了特殊的内存配置"
echo ""
echo "DMA 攻击时使用的物理地址："
echo "  linux_banner:      0x$verify_banner_hex"
echo "  __x64_sys_getpid:  0x$getpid_phys_hex"
echo ""


