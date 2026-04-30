#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/syscall.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <time.h>
#include <errno.h>
#include <signal.h>
#include <sys/mman.h>
#include <sys/socket.h>
#include <sys/utsname.h>

// 全局标志，用于优雅退出
volatile sig_atomic_t keep_running = 1;

void signal_handler(int signo) {
    keep_running = 0;
    printf("\n收到信号，正在退出...\n");
}

// ========== 系统调用触发函数 ==========

// 1. getpid - 获取进程ID
void trigger_getpid() {
    printf("SYS_getpid:%d,PID: %d\n", SYS_getpid,syscall(SYS_getpid));
    syscall(SYS_getpid);
}

// 2. getuid - 获取用户ID
void trigger_getuid() {
    syscall(SYS_getuid);
}

// 3. getgid - 获取组ID
void trigger_getgid() {
    syscall(SYS_getgid);
}

// 4. gettid - 获取线程ID
void trigger_gettid() {
    syscall(SYS_gettid);
}

// 5. getppid - 获取父进程ID
void trigger_getppid() {
    syscall(SYS_getppid);
}

// 6. open - 打开文件
void trigger_open() {
    int fd = open("/dev/null", O_RDONLY);
    if (fd >= 0) close(fd);
}

// 7. close - 关闭文件描述符
void trigger_close() {
    int fd = open("/dev/null", O_RDONLY);
    if (fd >= 0) {
        close(fd);
    }
}

// 8. read - 读取数据
void trigger_read() {
    char buf[1];
    int fd = open("/dev/zero", O_RDONLY);
    if (fd >= 0) {
        read(fd, buf, 1);
        close(fd);
    }
}

// 9. write - 写入数据
void trigger_write() {
    char buf[1] = {0};
    int fd = open("/dev/null", O_WRONLY);
    if (fd >= 0) {
        write(fd, buf, 1);
        close(fd);
    }
}

// 10. stat - 获取文件状态
void trigger_stat() {
    struct stat st;
    stat("/dev/null", &st);
}

// 11. fstat - 通过文件描述符获取文件状态
void trigger_fstat() {
    struct stat st;
    int fd = open("/dev/null", O_RDONLY);
    if (fd >= 0) {
        fstat(fd, &st);
        close(fd);
    }
}

// 12. lseek - 移动文件指针
void trigger_lseek() {
    int fd = open("/dev/null", O_RDONLY);
    if (fd >= 0) {
        lseek(fd, 0, SEEK_SET);
        close(fd);
    }
}

// 13. access - 检查文件访问权限
void trigger_access() {
    access("/dev/null", R_OK);
}

// 14. clock_gettime - 获取时间
void trigger_clock_gettime() {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
}

// 15. gettimeofday - 获取当前时间
void trigger_gettimeofday() {
    struct timeval tv;
    gettimeofday(&tv, NULL);
}

// 16. brk - 改变数据段大小
void trigger_brk() {
    void *current = sbrk(0);
    brk(current);
}

// 17. mmap - 内存映射
void trigger_mmap() {
    void *addr = mmap(NULL, 4096, PROT_READ | PROT_WRITE,
                     MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    if (addr != MAP_FAILED) {
        munmap(addr, 4096);
    }
}

// 18. munmap - 取消内存映射
void trigger_munmap() {
    void *addr = mmap(NULL, 4096, PROT_READ | PROT_WRITE,
                     MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    if (addr != MAP_FAILED) {
        munmap(addr, 4096);
    }
}

// 19. mprotect - 修改内存保护
void trigger_mprotect() {
    void *addr = mmap(NULL, 4096, PROT_READ | PROT_WRITE,
                     MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    if (addr != MAP_FAILED) {
        mprotect(addr, 4096, PROT_READ);
        munmap(addr, 4096);
    }
}

// 20. uname - 获取系统信息
void trigger_uname() {
    struct utsname buf;
    uname(&buf);
}

// 21. getcwd - 获取当前工作目录
void trigger_getcwd() {
    char buf[256];
    getcwd(buf, sizeof(buf));
}

// 22. chdir - 改变当前目录（不实际改变）
void trigger_chdir() {
    char cwd[256];
    getcwd(cwd, sizeof(cwd));
    chdir(cwd);  // 切换到当前目录（无副作用）
}

// 23. mkdir + rmdir - 创建和删除目录
void trigger_mkdir_rmdir() {
    mkdir("/tmp/test_dir_12345", 0755);
    rmdir("/tmp/test_dir_12345");
}

// 24. socket - 创建套接字
void trigger_socket() {
    int fd = socket(AF_INET, SOCK_STREAM, 0);
    if (fd >= 0) close(fd);
}

// 25. pipe - 创建管道
void trigger_pipe() {
    int pipefd[2];
    if (pipe(pipefd) == 0) {
        close(pipefd[0]);
        close(pipefd[1]);
    }
}

// ========== 系统调用定义表 ==========

typedef struct {
    const char *name;
    const char *description;
    void (*func)(void);
} syscall_entry_t;

syscall_entry_t syscall_table[] = {
    {"getpid",          "获取进程ID",              trigger_getpid},
    {"getuid",          "获取用户ID",              trigger_getuid},
    {"getgid",          "获取组ID",                trigger_getgid},
    {"gettid",          "获取线程ID",              trigger_gettid},
    {"getppid",         "获取父进程ID",            trigger_getppid},
    {"open",            "打开文件",                trigger_open},
    {"close",           "关闭文件",                trigger_close},
    {"read",            "读取文件",                trigger_read},
    {"write",           "写入文件",                trigger_write},
    {"stat",            "获取文件状态",            trigger_stat},
    {"fstat",           "获取文件状态(fd)",        trigger_fstat},
    {"lseek",           "移动文件指针",            trigger_lseek},
    {"access",          "检查文件权限",            trigger_access},
    {"clock_gettime",   "获取时间",                trigger_clock_gettime},
    {"gettimeofday",    "获取当前时间",            trigger_gettimeofday},
    {"brk",             "改变数据段",              trigger_brk},
    {"mmap",            "内存映射",                trigger_mmap},
    {"munmap",          "取消内存映射",            trigger_munmap},
    {"mprotect",        "修改内存保护",            trigger_mprotect},
    {"uname",           "获取系统信息",            trigger_uname},
    {"getcwd",          "获取当前目录",            trigger_getcwd},
    {"chdir",           "改变目录",                trigger_chdir},
    {"mkdir_rmdir",     "创建/删除目录",           trigger_mkdir_rmdir},
    {"socket",          "创建套接字",              trigger_socket},
    {"pipe",            "创建管道",                trigger_pipe},
    {NULL, NULL, NULL}
};

// ========== 辅助函数 ==========

void print_usage(const char *prog) {
    printf("用法: %s [选项]\n\n", prog);
    printf("选项:\n");
    printf("  -l              列出所有可用的系统调用\n");
    printf("  -s <name>       调用指定的系统调用\n");
    printf("  -c <count>      重复调用次数 (默认: 无限循环)\n");
    printf("  -d <usec>       每次调用间隔(微秒) (默认: 0)\n");
    printf("  -a              依次调用所有系统调用\n");
    printf("  -h              显示此帮助信息\n\n");
    printf("示例:\n");
    printf("  %s -s getpid                    # 持续调用 getpid\n", prog);
    printf("  %s -s open -c 1000              # 调用 open 1000次\n", prog);
    printf("  %s -s read -c 1000 -d 1000      # 调用 read 1000次，每次间隔1ms\n", prog);
    printf("  %s -a -c 100                    # 依次调用所有系统调用100次\n", prog);
}

void list_syscalls() {
    printf("可用的系统调用:\n");
    printf("%-20s %s\n", "名称", "描述");
    printf("----------------------------------------\n");
    
    for (int i = 0; syscall_table[i].name != NULL; i++) {
        printf("%-20s %s\n", 
               syscall_table[i].name, 
               syscall_table[i].description);
    }
}

syscall_entry_t* find_syscall(const char *name) {
    for (int i = 0; syscall_table[i].name != NULL; i++) {
        if (strcmp(syscall_table[i].name, name) == 0) {
            return &syscall_table[i];
        }
    }
    return NULL;
}

// ========== 主函数 ==========

int main(int argc, char *argv[]) {
    char *syscall_name = NULL;
    int count = -1;  // -1 表示无限循环
    int delay_usec = 0;
    int call_all = 0;
    
    // 设置信号处理
    signal(SIGINT, signal_handler);
    signal(SIGTERM, signal_handler);
    
    // 解析命令行参数
    int opt;
    while ((opt = getopt(argc, argv, "ls:c:d:ah")) != -1) {
        switch (opt) {
            case 'l':
                list_syscalls();
                return 0;
            case 's':
                syscall_name = optarg;
                break;
            case 'c':
                count = atoi(optarg);
                break;
            case 'd':
                delay_usec = atoi(optarg);
                break;
            case 'a':
                call_all = 1;
                break;
            case 'h':
            default:
                print_usage(argv[0]);
                return 0;
        }
    }
    
    // 验证参数
    if (!call_all && !syscall_name) {
        printf("错误: 必须指定 -s 或 -a 选项\n\n");
        print_usage(argv[0]);
        return 1;
    }
    
    if (call_all) {
        // 依次调用所有系统调用
        printf("依次调用所有系统调用");
        if (count > 0) printf(" (每个调用 %d 次)", count);
        printf("\n");
        printf("按 Ctrl+C 停止\n\n");
        
        int iteration = 0;
        while (keep_running && (count < 0 || iteration < count)) {
            for (int i = 0; syscall_table[i].name != NULL && keep_running; i++) {
                syscall_table[i].func();
                
                if ((iteration * 25 + i + 1) % 100 == 0) {
                    printf("\r已调用: %d 次", iteration * 25 + i + 1);
                    fflush(stdout);
                }
                
                if (delay_usec > 0) {
                    usleep(delay_usec);
                }
            }
            iteration++;
        }
        printf("\n完成!\n");
        
    } else {
        // 调用指定的系统调用
        syscall_entry_t *entry = find_syscall(syscall_name);
        if (!entry) {
            printf("错误: 未知的系统调用 '%s'\n", syscall_name);
            printf("使用 -l 查看所有可用的系统调用\n");
            return 1;
        }
        
        printf("正在调用: %s (%s)\n", entry->name, entry->description);
        if (count > 0) {
            printf("次数: %d\n", count);
        } else {
            printf("次数: 无限循环 (按 Ctrl+C 停止)\n");
        }
        if (delay_usec > 0) {
            printf("间隔: %d 微秒\n", delay_usec);
        }
        printf("\n开始执行...\n");
        
        int i = 0;
        while (keep_running && (count < 0 || i < count)) {
            entry->func();
            i++;
            
            // 每1000次显示一次进度
            if (i % 1000 == 0) {
                printf("\r已调用: %d 次", i);
                fflush(stdout);
            }
            
            if (delay_usec > 0) {
                usleep(delay_usec);
            }
        }
        
        printf("\n完成! 总共调用 %d 次\n", i);
    }
    
    return 0;
}