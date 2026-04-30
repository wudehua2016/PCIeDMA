# 系统调用与内核函数映射表

## x86-64 Linux 系统调用对应的内核函数

### 1. 进程/线程信息类

#### `getpid` - 获取进程ID
```
系统调用号: 39
内核函数调用链:
  entry_SYSCALL_64                    # 系统调用入口
  └─> do_syscall_64                   # 系统调用分发
      └─> __x64_sys_getpid            # x86-64系统调用包装
          └─> __se_sys_getpid
              └─> __do_sys_getpid
                  └─> task_tgid_vnr   # 获取进程ID的核心函数

重要的内核函数:
- entry_SYSCALL_64        (arch/x86/entry/entry_64.S)
- __x64_sys_getpid        (kernel/sys.c)
- task_tgid_vnr           (kernel/pid.c)
```

#### `getuid` - 获取用户ID
```
系统调用号: 102
内核函数:
  entry_SYSCALL_64
  └─> do_syscall_64
      └─> __x64_sys_getuid
          └─> from_kuid_munged      # 获取UID
              └─> current_uid       # 访问当前进程凭证

重要的内核函数:
- __x64_sys_getuid        (kernel/sys.c)
- current_uid             (kernel/cred.c)
```

#### `getgid` - 获取组ID
```
系统调用号: 104
内核函数:
  entry_SYSCALL_64
  └─> do_syscall_64
      └─> __x64_sys_getgid
          └─> from_kgid_munged
              └─> current_gid

重要的内核函数:
- __x64_sys_getgid        (kernel/sys.c)
- current_gid             (kernel/cred.c)
```

#### `gettid` - 获取线程ID
```
系统调用号: 186
内核函数:
  entry_SYSCALL_64
  └─> do_syscall_64
      └─> __x64_sys_gettid
          └─> task_pid_vnr          # 获取线程PID

重要的内核函数:
- __x64_sys_gettid        (kernel/sys.c)
- task_pid_vnr            (kernel/pid.c)
```

#### `getppid` - 获取父进程ID
```
系统调用号: 110
内核函数:
  entry_SYSCALL_64
  └─> do_syscall_64
      └─> __x64_sys_getppid
          └─> task_tgid_vnr         # 访问父进程

重要的内核函数:
- __x64_sys_getppid       (kernel/sys.c)
```

---

### 2. 文件操作类

#### `open` - 打开文件
```
系统调用号: 2 (或使用 openat: 257)
内核函数调用链:
  entry_SYSCALL_64
  └─> do_syscall_64
      └─> __x64_sys_open
          └─> do_sys_open
              └─> do_sys_openat2
                  ├─> getname           # 从用户空间复制文件名
                  ├─> get_unused_fd_flags # 分配文件描述符
                  ├─> do_filp_open      # 打开文件的核心
                  │   ├─> path_openat
                  │   │   ├─> link_path_walk  # 路径解析
                  │   │   ├─> lookup_fast     # 快速查找(dentry cache)
                  │   │   └─> do_last         # 最后的打开操作
                  │   └─> vfs_open
                  └─> fd_install         # 安装文件描述符

重要的内核函数:
- __x64_sys_open          (fs/open.c)
- do_sys_openat2          (fs/open.c)
- do_filp_open            (fs/namei.c)
- path_openat             (fs/namei.c)
- link_path_walk          (fs/namei.c)
- vfs_open                (fs/open.c)
```

#### `close` - 关闭文件
```
系统调用号: 3
内核函数:
  entry_SYSCALL_64
  └─> do_syscall_64
      └─> __x64_sys_close
          └─> __close_fd
              ├─> pick_file         # 从fd表中移除
              └─> filp_close        # 关闭文件
                  └─> fput          # 释放文件引用

重要的内核函数:
- __x64_sys_close         (fs/open.c)
- __close_fd              (fs/file.c)
- filp_close              (fs/open.c)
- fput                    (fs/file_table.c)
```

#### `read` - 读取文件
```
系统调用号: 0
内核函数调用链:
  entry_SYSCALL_64
  └─> do_syscall_64
      └─> __x64_sys_read
          └─> ksys_read
              └─> vfs_read          # VFS层读取
                  ├─> rw_verify_area
                  ├─> __vfs_read
                  │   └─> file->f_op->read  # 文件系统特定的read
                  └─> fsnotify_access

重要的内核函数:
- __x64_sys_read          (fs/read_write.c)
- ksys_read               (fs/read_write.c)
- vfs_read                (fs/read_write.c)
- __vfs_read              (fs/read_write.c)
```

#### `write` - 写入文件
```
系统调用号: 1
内核函数:
  entry_SYSCALL_64
  └─> do_syscall_64
      └─> __x64_sys_write
          └─> ksys_write
              └─> vfs_write         # VFS层写入
                  ├─> rw_verify_area
                  ├─> __vfs_write
                  │   └─> file->f_op->write
                  └─> fsnotify_modify

重要的内核函数:
- __x64_sys_write         (fs/read_write.c)
- ksys_write              (fs/read_write.c)
- vfs_write               (fs/read_write.c)
```

#### `stat` - 获取文件状态
```
系统调用号: 4 (或 newfstatat: 262)
内核函数:
  entry_SYSCALL_64
  └─> do_syscall_64
      └─> __x64_sys_newstat
          └─> vfs_stat
              ├─> user_path_at      # 路径解析
              │   └─> filename_lookup
              │       └─> path_lookupat
              └─> vfs_getattr       # 获取属性
                  └─> inode->i_op->getattr

重要的内核函数:
- __x64_sys_newstat       (fs/stat.c)
- vfs_stat                (fs/stat.c)
- vfs_getattr             (fs/stat.c)
- filename_lookup         (fs/namei.c)
```

#### `fstat` - 通过fd获取文件状态
```
系统调用号: 5
内核函数:
  entry_SYSCALL_64
  └─> do_syscall_64
      └─> __x64_sys_newfstat
          └─> vfs_fstat
              ├─> fdget             # 从fd获取file结构
              └─> vfs_getattr

重要的内核函数:
- __x64_sys_newfstat      (fs/stat.c)
- vfs_fstat               (fs/stat.c)
```

#### `lseek` - 移动文件指针
```
系统调用号: 8
内核函数:
  entry_SYSCALL_64
  └─> do_syscall_64
      └─> __x64_sys_lseek
          └─> ksys_lseek
              └─> vfs_llseek        # VFS层seek
                  └─> file->f_op->llseek

重要的内核函数:
- __x64_sys_lseek         (fs/read_write.c)
- vfs_llseek              (fs/read_write.c)
```

#### `access` - 检查文件权限
```
系统调用号: 21
内核函数:
  entry_SYSCALL_64
  └─> do_syscall_64
      └─> __x64_sys_access
          └─> do_faccessat
              ├─> user_path_at
              └─> inode_permission  # 权限检查
                  └─> do_inode_permission

重要的内核函数:
- __x64_sys_access        (fs/open.c)
- do_faccessat            (fs/open.c)
- inode_permission        (fs/namei.c)
```

---

### 3. 时间相关类

#### `clock_gettime` - 获取时间
```
系统调用号: 228
内核函数:
  entry_SYSCALL_64
  └─> do_syscall_64
      └─> __x64_sys_clock_gettime
          └─> common_clock_gettime
              └─> posix_get_monotonic_timespec  # 根据时钟类型
                  └─> ktime_get_ts64

重要的内核函数:
- __x64_sys_clock_gettime (kernel/time/posix-timers.c)
- common_clock_gettime    (kernel/time/posix-timers.c)
- ktime_get_ts64          (kernel/time/timekeeping.c)

注意: 这个syscall通常会使用vDSO优化，可能不进入内核！
```

#### `gettimeofday` - 获取当前时间
```
系统调用号: 96
内核函数:
  entry_SYSCALL_64
  └─> do_syscall_64
      └─> __x64_sys_gettimeofday
          └─> do_gettimeofday
              └─> ktime_get_real_ts64

重要的内核函数:
- __x64_sys_gettimeofday  (kernel/time/time.c)
- ktime_get_real_ts64     (kernel/time/timekeeping.c)

注意: 也可能使用vDSO优化
```

---

### 4. 内存管理类

#### `brk` - 改变数据段大小
```
系统调用号: 12
内核函数:
  entry_SYSCALL_64
  └─> do_syscall_64
      └─> __x64_sys_brk
          └─> __do_sys_brk
              └─> do_brk_flags      # 扩展/收缩堆
                  ├─> find_vma      # 查找VMA
                  ├─> do_munmap     # 如果收缩
                  └─> do_brk_munmap_flags

重要的内核函数:
- __x64_sys_brk           (mm/mmap.c)
- do_brk_flags            (mm/mmap.c)
- find_vma                (mm/mmap.c)
```

#### `mmap` - 内存映射
```
系统调用号: 9
内核函数调用链:
  entry_SYSCALL_64
  └─> do_syscall_64
      └─> __x64_sys_mmap
          └─> ksys_mmap_pgoff
              └─> vm_mmap_pgoff
                  └─> do_mmap        # 核心mmap实现
                      ├─> get_unmapped_area  # 找空闲地址
                      ├─> mmap_region        # 创建VMA
                      │   ├─> vma_merge      # 尝试合并VMA
                      │   ├─> vm_area_alloc  # 分配VMA结构
                      │   └─> call_mmap      # 调用文件系统mmap
                      └─> may_expand_vm

重要的内核函数:
- __x64_sys_mmap          (arch/x86/kernel/sys_x86_64.c)
- do_mmap                 (mm/mmap.c)
- mmap_region             (mm/mmap.c)
- get_unmapped_area       (mm/mmap.c)
```

#### `munmap` - 取消内存映射
```
系统调用号: 11
内核函数:
  entry_SYSCALL_64
  └─> do_syscall_64
      └─> __x64_sys_munmap
          └─> __vm_munmap
              └─> do_munmap         # 核心实现
                  ├─> find_vma      # 查找VMA
                  ├─> __split_vma   # 分割VMA
                  └─> unmap_region  # 释放映射
                      └─> unmap_vmas
                          └─> unmap_page_range

重要的内核函数:
- __x64_sys_munmap        (mm/mmap.c)
- do_munmap               (mm/mmap.c)
- unmap_region            (mm/mmap.c)
```

#### `mprotect` - 修改内存保护
```
系统调用号: 10
内核函数:
  entry_SYSCALL_64
  └─> do_syscall_64
      └─> __x64_sys_mprotect
          └─> do_mprotect_pkey
              ├─> find_vma          # 查找VMA
              ├─> vma_merge         # 尝试合并
              └─> change_protection # 修改页表保护位
                  └─> change_pte_range

重要的内核函数:
- __x64_sys_mprotect      (mm/mprotect.c)
- do_mprotect_pkey        (mm/mprotect.c)
- change_protection       (mm/mprotect.c)
```

---

### 5. 系统信息类

#### `uname` - 获取系统信息
```
系统调用号: 63
内核函数:
  entry_SYSCALL_64
  └─> do_syscall_64
      └─> __x64_sys_newuname
          └─> copy_to_user      # 复制内核utsname到用户空间

重要的内核函数:
- __x64_sys_newuname      (kernel/sys.c)
```

#### `getcwd` - 获取当前工作目录
```
系统调用号: 79
内核函数:
  entry_SYSCALL_64
  └─> do_syscall_64
      └─> __x64_sys_getcwd
          └─> getcwd_common
              └─> d_path            # 构建路径字符串
                  └─> prepend_path

重要的内核函数:
- __x64_sys_getcwd        (fs/d_path.c)
- d_path                  (fs/d_path.c)
```

#### `chdir` - 改变当前目录
```
系统调用号: 80
内核函数:
  entry_SYSCALL_64
  └─> do_syscall_64
      └─> __x64_sys_chdir
          └─> ksys_chdir
              ├─> user_path_at      # 解析路径
              └─> set_fs_pwd        # 设置当前目录

重要的内核函数:
- __x64_sys_chdir         (fs/open.c)
- ksys_chdir              (fs/open.c)
```

---

### 6. 目录操作类

#### `mkdir` - 创建目录
```
系统调用号: 83
内核函数:
  entry_SYSCALL_64
  └─> do_syscall_64
      └─> __x64_sys_mkdir
          └─> do_mkdirat
              ├─> user_path_create  # 路径解析
              └─> vfs_mkdir         # VFS层创建
                  └─> inode->i_op->mkdir

重要的内核函数:
- __x64_sys_mkdir         (fs/namei.c)
- do_mkdirat              (fs/namei.c)
- vfs_mkdir               (fs/namei.c)
```

#### `rmdir` - 删除目录
```
系统调用号: 84
内核函数:
  entry_SYSCALL_64
  └─> do_syscall_64
      └─> __x64_sys_rmdir
          └─> do_rmdir
              ├─> user_path_at
              └─> vfs_rmdir
                  └─> inode->i_op->rmdir

重要的内核函数:
- __x64_sys_rmdir         (fs/namei.c)
- vfs_rmdir               (fs/namei.c)
```

---

### 7. IPC类

#### `socket` - 创建套接字
```
系统调用号: 41
内核函数:
  entry_SYSCALL_64
  └─> do_syscall_64
      └─> __x64_sys_socket
          └─> __sys_socket
              └─> sock_create       # 创建socket
                  ├─> __sock_create
                  │   └─> pf->create    # 协议族的create
                  └─> sock_map_fd       # 映射到fd

重要的内核函数:
- __x64_sys_socket        (net/socket.c)
- sock_create             (net/socket.c)
- sock_map_fd             (net/socket.c)
```

#### `pipe` - 创建管道
```
系统调用号: 22
内核函数:
  entry_SYSCALL_64
  └─> do_syscall_64
      └─> __x64_sys_pipe
          └─> do_pipe2
              ├─> create_pipe_files # 创建管道文件
              ├─> get_unused_fd_flags
              └─> fd_install

重要的内核函数:
- __x64_sys_pipe          (fs/pipe.c)
- do_pipe2                (fs/pipe.c)
- create_pipe_files       (fs/pipe.c)
```

---

## 查找这些函数的方法

### 1. 查看 /proc/kallsyms
```bash
# 查看所有内核符号
sudo cat /proc/kallsyms | grep sys_getpid

# 查看特定函数的地址
sudo cat /proc/kallsyms | grep -E "entry_SYSCALL_64|do_syscall_64"
```

### 2. 使用 ftrace 追踪
```bash
# 启用函数追踪
echo function > /sys/kernel/debug/tracing/current_tracer
echo 1 > /sys/kernel/debug/tracing/tracing_on

# 追踪特定进程
echo $PID > /sys/kernel/debug/tracing/set_ftrace_pid

# 查看追踪结果
cat /sys/kernel/debug/tracing/trace
```

### 3. 使用 perf 追踪
```bash
# 记录系统调用
sudo perf record -e 'syscalls:sys_enter_*' -a sleep 1

# 记录内核函数调用
sudo perf record -e cycles:k -g ./syscall_trigger -s getpid -c 1000

# 查看报告
sudo perf report
```

---

## 对侧信道攻击的意义

### 高价值目标函数：
1. **entry_SYSCALL_64** - 所有syscall的入口，容易检测
2. **do_syscall_64** - 系统调用分发器
3. **path_lookupat** / **link_path_walk** - 路径解析，频繁访问
4. **do_mmap** / **mmap_region** - 内存管理核心
5. **vfs_read** / **vfs_write** - VFS层操作

这些函数会加载到LLC中，可以通过Prime+Probe检测！












# 查看哪些进程在使用 HugePages
grep -e AnonHugePages /proc/*/smaps | awk '{if($2>4){print $0}}' | awk -F "/" '{print $3}' | sort -u | xargs ps -p

# 或者更详细的查看
for pid in $(ls /proc | grep -E '^[0-9]+$'); do
    if [ -f /proc/$pid/smaps ]; then
        huge=$(grep -s "^AnonHugePages:" /proc/$pid/smaps | awk '{sum+=$2} END {print sum}')
        if [ "$huge" -gt 0 ]; then
            echo "PID $pid: $huge kB - $(cat /proc/$pid/cmdline | tr '\0' ' ')"
        fi
    fi
done