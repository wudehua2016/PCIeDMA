# LLC Prober: PCIe DMA-based Cache Side-Channel Framework

This project implements a PCIe DMA-based probing framework for investigating hot regions in the CPU cache hierarchy. It leverages a custom Xilinx Zynq-7000 FPGA board to generate DMA TLP packets and measure their round-trip time (RTT), enabling microarchitectural reverse engineering and kernel physical address localization.

> **Disclaimer:** We use a custom FPGA board with a ported Linux kernel for our experiments.

---

## Table of Contents

- [Overview](#overview)
- [Hardware Setup](#hardware-setup)
- [Build Instructions](#build-instructions)
- [System Configuration](#system-configuration)
- [MQTT Server Setup](#mqtt-server-setup)
  - [Installing Mosquitto](#installing-mosquitto)
  - [Configuration](#configuration)
  - [Authentication Setup](#authentication-setup)
  - [Service Management](#service-management)
  - [Testing](#testing)
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

## MQTT Server Setup

This framework uses MQTT for remote coordination between the FPGA system and the target host, enabling automated experiment orchestration and data collection.

### Installing Mosquitto

We recommend **Eclipse Mosquitto** as the MQTT broker. Install it on the target host (or a dedicated coordination server):

**Ubuntu / Debian:**
```bash
# Add official Mosquitto repository
sudo apt-add-repository ppa:mosquitto-dev/mosquitto-ppa
sudo apt-get update

# Install broker and client tools
sudo apt-get install mosquitto mosquitto-clients
```

**RHEL / CentOS / Fedora:**
```bash
# Install EPEL repository (if not already installed)
sudo yum install epel-release

# Install Mosquitto
sudo yum install mosquitto mosquitto-clients
```

**Verify installation:**
```bash
mosquitto -v
```

### Configuration

Create a custom configuration file for the LLC Prober experiments:

```bash
sudo mkdir -p /etc/mosquitto/conf.d
sudo nano /etc/mosquitto/conf.d/llc_prober.conf
```

Add the following configuration:

```conf
# LLC Prober MQTT Configuration

# Standard MQTT listener
listener 1883 0.0.0.0

# WebSocket listener (optional, for web-based monitoring)
listener 9001 0.0.0.0
protocol websockets

# Disable anonymous access for security
allow_anonymous false

# Password file path
password_file /etc/mosquitto/pwfile

# Persistence settings
persistence true
persistence_location /var/lib/mosquitto/
persistence_file mosquitto.db

# Logging
log_dest file /var/log/mosquitto/mosquitto.log
log_type error
log_type warning
log_type information
log_timestamp true
log_timestamp_format %Y-%m-%d %H:%M:%S

# Connection limits
max_connections 100
max_inflight_messages 20
max_queued_messages 1000

# Message size limits (adjust based on experiment data size)
message_size_limit 65536
```

> **Note:** Mosquitto v2.0+ requires explicit listener configuration and disables anonymous access by default. The above configuration restores compatibility while maintaining security.

### Authentication Setup

Create password file and add users for FPGA system and target host:

```bash
# Create password file and add FPGA system user
sudo mosquitto_passwd -c /etc/mosquitto/pwfile fpga_system
# Enter password when prompted

# Add target host user
sudo mosquitto_passwd /etc/mosquitto/pwfile target_host
# Enter password when prompted

# Verify password file
sudo cat /etc/mosquitto/pwfile
```

**Example users:**
- `fpga_system` — FPGA board for publishing measurement data
- `target_host` — Target machine for receiving commands and publishing status
- `controller` — Experiment orchestration node

### Service Management

**Start and enable Mosquitto service:**
```bash
# Start the broker
sudo systemctl start mosquitto

# Enable auto-start on boot
sudo systemctl enable mosquitto

# Check service status
sudo systemctl status mosquitto
```

**Restart after configuration changes:**
```bash
sudo systemctl restart mosquitto
```

**View logs:**
```bash
# Real-time log monitoring
sudo tail -f /var/log/mosquitto/mosquitto.log

# Recent logs via journalctl
sudo journalctl -u mosquitto --no-pager -n 50
```

**Firewall configuration (if applicable):**
```bash
# Open MQTT port
sudo firewall-cmd --permanent --add-port=1883/tcp
sudo firewall-cmd --permanent --add-port=9001/tcp
sudo firewall-cmd --reload
```

### Testing

Verify MQTT broker functionality using Mosquitto client tools:

**Terminal 1 — Start subscriber:**
```bash
mosquitto_sub -h localhost -t "llc_prober/test" -u target_host -P <password> -v
```

**Terminal 2 — Publish test message:**
```bash
mosquitto_pub -h localhost -t "llc_prober/test" -u fpga_system -P <password> -m "MQTT connection established"
```

**Expected output in Terminal 1:**
```
llc_prober/test MQTT connection established
```

**Topic naming convention for experiments:**
- `llc_prober/command/<experiment_id>` — Control commands
- `llc_prober/data/<experiment_id>` — Measurement data from FPGA
- `llc_prober/status/<host_id>` — Host status updates
- `llc_prober/result/<experiment_id>` — Final experiment results

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
python3 ./ReEngineering0000.py

# On target host
cd host/
gcc -O2 -o mes_host eviction_set_hugepage.c
sudo ./mes_host
```

**Purpose:** Construct minimal eviction sets to map virtual addresses to LLC sets and slices.

### Case I: LLC Replacement Policy Reverse Engineering

```bash
cd materials/case_I/

# On FPGA system
cd fpga/
python3 ./ReEngineering0000.py

# On target host
cd host/
gcc -O2 -o replacement_probe reader_1.c
sudo ./replacement_probe
```

**Purpose:** Extract QLRU replacement policy parameters (hit promotion, miss insertion, randomness factors) by observing cache line residency evolution under controlled access patterns.

### Case II: LLC Hot Function Localization

```bash
cd materials/case_II/

# On FPGA system
cd fpga/
python3 ./ReEngineering0000.py

# On target host
# We use scripts to generate graphs, nothing needs to be modified
```

**Purpose:** Locate kernel hot functions (e.g., `sys_call_table` entries, frequently executed kernel code) by monitoring LLC occupancy changes during system activity.

### Figure 2: Data Reproduction

```bash
cd materials/figure2/fpga
python3 ReEngineering0000.py

# On target host

cd materials/figure2/host
gcc -O2 -o data_reproduction eviction_set_hugepage_v17.c
sudo ./data_reproduction
```

**Purpose:** Reproduce the latency differential measurements shown in Figure 2 of the paper, demonstrating cache-hit vs. cache-miss discrimination.

### Section 5.1: Evaluation

```bash
cd materials/5_1Section/

# On FPGA system
cd fpga/
python3 ReEngineering0000.py

# On target host
cd host/
gcc -O2 -o eval_main eviction_set_hugepage_v17.c
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
  booktitle={xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx},
  year={xxxx}
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
| MQTT broker connection refused | Verify Mosquitto service is running: `sudo systemctl status mosquitto` |
| MQTT authentication failure | Check username/password in `/etc/mosquitto/pwfile`; restart broker after changes |
| MQTT port blocked | Open firewall port 1883/tcp; verify with `netstat -tlnp \| grep 1883` |

---

## Contact

For questions regarding hardware setup or experiment reproduction, please open an issue in this repository or contact the authors.

---

*This project is provided for academic research purposes. The authors are not responsible for any misuse of this framework.*
