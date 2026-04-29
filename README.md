# LLC Prober: PCIe DMA-based Cache Side-Channel Framework

This project implements a PCIe DMA-based probing framework for investigating hot regions in the CPU cache hierarchy. It leverages a custom Xilinx Zynq-7000 FPGA board to generate DMA TLP packets and measure their round-trip time (RTT), enabling microarchitectural reverse engineering and kernel physical address localization.

> **Disclaimer:** We use a custom FPGA board with a ported Linux kernel for our experiments.

---

## Table of Contents

- [Overview](#overview)
- [Hardware Setup](#hardware-setup)
- [Build Instructions](#build-instructions)
- [System Configuration](#system-configuration)
- [Reproducing Experiments](#reproducing-experiments)
  - [MES: Minimal Eviction Set Construction](#mes-minimal-eviction-set-construction)
  - [Case I: LLC Replacement Policy Reverse Engineering](#case-i-llc-replacement-policy-reverse-engineering)
  - [Case II: LLC Hot Function Localization](#case-ii-llc-hot-function-localization)
  - [Figure 2: Data Reproduction](#figure-2-data-reproduction)
  - [Section 5.1: Evaluation](#section-51-evaluation)
- [Directory Structure](#directory-structure)
- [Target Host Compilation](#target-host-compilation)
- [Citation](#citation)

---

## Overview

The LLC Prober framework exploits the **Intel Data Direct I/O (DDIO)** mechanism, which routes PCIe device memory accesses through the **Last-Level Cache (LLC)**. By measuring the latency differential between cache-hit and cache-miss paths, our custom FPGA-based DMA device can infer cache occupancy states without allocating new cache lines (non-allocating reads), thereby eliminating self-pollution.

Key capabilities:
- **Minimal Eviction Set (MES)** construction for LLC set mapping
- **LLC replacement policy** reverse engineering (QLRU parameter extraction)
- **Kernel hot function** localization via progressive offset scanning
- **KASLR bypass** through cache residency analysis

---

## Hardware Setup

### FPGA Board
- **Device:** Xilinx Zynq-7000 series FPGA (custom board)
- **Function:** PCIe DMA endpoint capable of:
  - Generating configurable DMA TLP packets
  - High-precision round-trip time (RTT) measurement
  - Non-allocating read operations

### Target Machine Requirements
- Intel processor with **DDIO support** (tested on Intel Xeon E5-2680 v4)
- PCIe slot for FPGA board insertion
- Linux kernel with hugepage and MSR support
- `gcc` compiler for host-side C code

---

## Build Instructions

### FPGA Bitstream

1. Open **Vivado 2022** and import the design from the `hardware/` directory.
2. Run synthesis and implementation.
3. Generate the bitstream and download it to the FPGA board.
4. Flash the custom Linux kernel image to the board.
5. Load the PCIe DMA driver on the FPGA system:
   ```bash
   insmod pcie_dma_driver.ko
   ```

### Target Host Driver

No additional driver is required for the target machine. The FPGA device appears as a standard PCIe DMA endpoint once inserted.

---

## System Configuration

Before running any experiments on the **target host**, apply the following system configurations to ensure stable and reproducible measurements:

```bash
# 1. Allocate 2000 2MB hugepages for contiguous physical memory
sudo bash -c 'echo 2000 > /proc/sys/vm/nr_hugepages'
cat /proc/meminfo | grep HugePages

# 2. Mount hugetlbfs (2MB pages)
sudo mkdir -p /mnt/hugetlbfs
sudo mount -t hugetlbfs none /mnt/hugetlbfs
sudo mount -t hugetlbfs none /mnt/hugetlbfs -o pagesize=2MB
sudo touch /dev/hugepages/my_pool

# 3. Disable Intel Turbo Boost for frequency stability
sudo bash -c 'echo 1 > /sys/devices/system/cpu/intel_pstate/no_turbo'

# 4. Set CPU governor to performance mode
sudo bash -c 'echo performance > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor'

# 5. Disable hardware prefetchers via MSR
sudo modprobe msr
sudo wrmsr -a 0x1a4 0xf
```

> **Note:** The MSR write (`0x1a4 = 0xf`) disables L1 prefetchers, L2 prefetchers, and adjacent cache line prefetching. This is critical for clean cache state measurements.

---

## Reproducing Experiments

All experiment materials are located in the `materials/` directory. Each experiment contains two subdirectories:
- **`fpga/`**: Scripts to be executed on the **FPGA system** (Zynq-7000)
- **`host/`**: C source code to be compiled and executed on the **target machine**
- **`host/server/`**: Additional server-side scripts (for MES experiments)

### MES: Minimal Eviction Set Construction

```bash
cd materials/mes/

# On FPGA system
cd fpga/
./run_mes_probe.sh

# On target host
cd host/
gcc -O2 -o mes_host mes_host.c
sudo ./mes_host
```

**Purpose:** Construct minimal eviction sets to map virtual addresses to LLC sets and slices.

### Case I: LLC Replacement Policy Reverse Engineering

```bash
cd materials/case_I/

# On FPGA system
cd fpga/
./run_replacement_probe.sh

# On target host
cd host/
gcc -O2 -o replacement_probe replacement_probe.c
sudo ./replacement_probe
```

**Purpose:** Extract QLRU replacement policy parameters (hit promotion, miss insertion, randomness factors) by observing cache line residency evolution under controlled access patterns.

### Case II: LLC Hot Function Localization

```bash
cd materials/case_II/

# On FPGA system
cd fpga/
./run_hotfunc_probe.sh

# On target host
cd host/
gcc -O2 -o hotfunc_probe hotfunc_probe.c
sudo ./hotfunc_probe
```

**Purpose:** Locate kernel hot functions (e.g., `sys_call_table` entries, frequently executed kernel code) by monitoring LLC occupancy changes during system activity.

### Figure 2: Data Reproduction

```bash
cd materials/figure2/
python3 reproduce_figure2.py
```

**Purpose:** Reproduce the latency differential measurements shown in Figure 2 of the paper, demonstrating cache-hit vs. cache-miss discrimination.

### Section 5.1: Evaluation

```bash
cd materials/5_1Section/

# On FPGA system
cd fpga/
./run_evaluation.sh

# On target host
cd host/
gcc -O2 -o eval_main eval_main.c
sudo ./eval_main
```

**Purpose:** Comprehensive evaluation of the LLC Prober's efficacy in KASLR bypass and kernel address space scanning.

---

## Directory Structure

```
.
├── hardware/               # Vivado 2022 project files
│   ├── import_design.tcl
│   ├── constraints/
│   └── src/
├── materials/              # Experiment reproduction scripts
│   ├── mes/                # Minimal Eviction Set construction
│   │   ├── fpga/           # FPGA-side scripts
│   │   ├── host/           # Target host C code
│   │   └── host/server/    # Server-side scripts
│   ├── case_I/             # LLC replacement policy reverse engineering
│   │   ├── fpga/
│   │   └── host/
│   ├── case_II/            # LLC hot function localization
│   │   ├── fpga/
│   │   └── host/
│   ├── figure2/            # Figure 2 data reproduction
│   └── 5_1Section/         # Evaluation (Section 5.1)
│       ├── fpga/
│       └── host/
├── README.md               # This file
└── LICENSE
```

---

## Target Host Compilation

All target host C code can be compiled with standard `gcc`:

```bash
gcc -O2 -o <output_name> <source_file>.c
```

No external dependencies are required. The code uses standard Linux system calls and `/dev/mem` or hugepage mappings for physical memory access.

**Recommended flags:**
```bash
gcc -O2 -Wall -Wextra -o probe probe.c
```

---

## Citation

If you use this framework in your research, please cite our work:

```bibtex
@inproceedings{llcprober2026,
  title={LLC Prober: Exploiting Intel DDIO for Cache Side-Channel Attacks via PCIe DMA},
  author={...},
  booktitle={ACM Conference on Computer and Communications Security (CCS)},
  year={2026}
}
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `nr_hugepages` allocation fails | Ensure sufficient free RAM; try reducing the number or rebooting |
| PCIe device not detected | Check `lspci` output; verify FPGA bitstream is loaded |
| High latency variance | Disable Turbo Boost and set performance governor; ensure no background load |
| Permission denied on `/dev/mem` | Run with `sudo` or adjust `/proc/sys/kernel/printk` and kernel boot parameters |
| MSR write fails | Load `msr` kernel module: `sudo modprobe msr` |

---

## Contact

For questions regarding hardware setup or experiment reproduction, please open an issue in this repository or contact the authors.

---

*This project is provided for academic research purposes. The authors are not responsible for any misuse of this framework.*
