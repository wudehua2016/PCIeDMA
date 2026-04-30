#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <unistd.h>
#include "comm.h"
#include <errno.h>
#include <sched.h>
#include <string.h>
#include <stdint.h>
#include <sys/types.h>
#include <sys/stat.h>

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <x86intrin.h>
#include <stdbool.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <errno.h>
#include <time.h>
#include <sched.h>
#include <numa.h>
#include <numaif.h>
#include "./csv_reader.h"
#include <fcntl.h>  
#include <math.h>
#include <stdint.h> 
#include <stdlib.h> 
#include <stdio.h>   
#include <stdbool.h>
#include <signal.h>
#include <unistd.h>

bool isrun = true;
static inline uint64_t rdtscfence(void) {
    uint64_t a, d;
    asm volatile("lfence; rdtsc" : "=a"(a), "=d"(d) :: "memory");
    return ((d << 32) | a);
}


void generate_client_id(char *client_id, size_t max_len) {
    snprintf(client_id, max_len, "writer_%d_%ld", getpid(), time(NULL));
}
static inline void maccess(void *p) {
    asm volatile("lfence;movq (%0), %%rax;lfence;lfence\n" : : "r"(p) : "rax", "memory");
}

static inline void clflush(void *p) {
    asm volatile("lfence;clflush %0;lfence;\n" : : "m"(*(volatile char *)p) : "memory");
}

static inline int smaccess(void *p) {
    int value;
    asm volatile("lfence; mov (%1), %0; lfence\n" : "=r"(value) : "r"(p) : "memory");
    return value;
}

// 获取页大小
static size_t get_page_size() {
    return sysconf(_SC_PAGESIZE);
}

// 获取虚拟地址对应的物理地址
uint64_t get_physical_address(void *virt_addr) {
    int pagemap_fd;
    uint64_t entry;
    uint64_t phys_addr = 0;
    size_t page_size = get_page_size();
    
    // 计算页号和页内偏移
    uintptr_t vaddr = (uintptr_t)virt_addr;
    uint64_t page_num = vaddr / page_size;
    uint64_t page_offset = vaddr % page_size;
    
    // 打开 /proc/self/pagemap
    pagemap_fd = open("/proc/self/pagemap", O_RDONLY);
    if (pagemap_fd < 0) {
        fprintf(stderr, "无法打开 /proc/self/pagemap: %s\n", strerror(errno));
        fprintf(stderr, "提示: 可能需要 root 权限或设置 CAP_SYS_ADMIN 能力\n");
        return 0;
    }
    
    // 定位到对应的页表项
    if (lseek(pagemap_fd, page_num * sizeof(uint64_t), SEEK_SET) == -1) {
        fprintf(stderr, "lseek 失败: %s\n", strerror(errno));
        close(pagemap_fd);
        return 0;
    }
    
    // 读取页表项
    if (read(pagemap_fd, &entry, sizeof(uint64_t)) != sizeof(uint64_t)) {
        fprintf(stderr, "读取 pagemap 失败: %s\n", strerror(errno));
        close(pagemap_fd);
        return 0;
    }
    
    close(pagemap_fd);
    
    // 检查页是否在内存中（第63位）
    if (!(entry & (1ULL << 63))) {
        fprintf(stderr, "页不在内存中\n");
        return 0;
    }
    
    // 提取物理页号（0-54位）
    uint64_t phys_page_num = entry & ((1ULL << 55) - 1);
    
    // 计算完整的物理地址
    phys_addr = (phys_page_num * page_size) + page_offset;
    
    return phys_addr;
}


int simple_mqtt_publish(const char *host, int port,
                        const char *username, const char *password,
                        const char *topic, const char *message)
{
    int sockfd = socket(AF_INET, SOCK_STREAM, 0);
    if (sockfd < 0) {
        fprintf(stderr, "Socket创建失败: %s\n", strerror(errno));
        return -1;
    }

    struct sockaddr_in serv_addr = {0};
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_port   = htons(port);
    if (inet_pton(AF_INET, host, &serv_addr.sin_addr) <= 0) {
        fprintf(stderr, "地址转换失败\n");
        close(sockfd);
        return -1;
    }

    if (connect(sockfd, (struct sockaddr *)&serv_addr, sizeof(serv_addr)) < 0) {
        fprintf(stderr, "连接MQTT代理失败: %s\n", strerror(errno));
        close(sockfd);
        return -1;
    }

    int id_len   = 8;
    int user_len = strlen(username);
    int pass_len = strlen(password);

    int payload_len = (2 + id_len) + (2 + user_len) + (2 + pass_len);
    int rem_len     = 10 + payload_len;

    int connect_len = 1 + 1 + rem_len;
    unsigned char *conn = malloc(connect_len);
    int p = 0;

    conn[p++] = 0x10;
    conn[p++] = rem_len;

    memcpy(&conn[p], "\x00\x04MQTT\x04\xc0\x00\x3c", 10);
    p += 10;

    conn[p++] = 0;
    conn[p++] = id_len;
    memcpy(&conn[p], "testclnt", id_len);
    p += id_len;

    conn[p++] = (user_len >> 8) & 0xFF;
    conn[p++] = user_len & 0xFF;
    memcpy(&conn[p], username, user_len);
    p += user_len;

    conn[p++] = (pass_len >> 8) & 0xFF;
    conn[p++] = pass_len & 0xFF;
    memcpy(&conn[p], password, pass_len);
    p += pass_len;

    if (send(sockfd, conn, connect_len, 0) < 0) {
        fprintf(stderr, "发送CONNECT失败: %s\n", strerror(errno));
        free(conn);
        close(sockfd);
        return -1;
    }
    free(conn);

    unsigned char connack[4];
    if (recv(sockfd, connack, 4, 0) != 4 || connack[0] != 0x20 || connack[3] != 0) {
        fprintf(stderr, "MQTT连接被拒绝\n");
        close(sockfd);
        return -1;
    }

    int tlen = strlen(topic);
    int mlen = strlen(message);
    int rem  = 2 + tlen + mlen;
    unsigned char *pub = malloc(2 + rem);
    int idx = 0;
    pub[idx++] = 0x30;
    pub[idx++] = rem;
    pub[idx++] = (tlen >> 8) & 0xFF;
    pub[idx++] = tlen & 0xFF;
    memcpy(&pub[idx], topic, tlen);
    idx += tlen;
    memcpy(&pub[idx], message, mlen);
    idx += mlen;

    if (send(sockfd, pub, idx, 0) < 0) {
        fprintf(stderr, "发送PUBLISH失败: %s\n", strerror(errno));
        free(pub);
        close(sockfd);
        return -1;
    }


    free(pub);
    close(sockfd);
    return 0;
}

// 消息回调函数类型
typedef void (*mqtt_message_callback)(const char *topic, const char *message, int message_len);

int simple_mqtt_subscribe(const char *host, int port,
                          const char *username, const char *password,
                          const char *topic,
                          mqtt_message_callback callback,
                          int timeout_seconds)
{
    int sockfd = socket(AF_INET, SOCK_STREAM, 0);
    if (sockfd < 0) {
        fprintf(stderr, "Socket创建失败: %s\n", strerror(errno));
        return -1;
    }

    // 设置接收超时
    struct timeval tv;
    tv.tv_sec = timeout_seconds;
    tv.tv_usec = 0;
    setsockopt(sockfd, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv));

    struct sockaddr_in serv_addr = {0};
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_port   = htons(port);
    if (inet_pton(AF_INET, host, &serv_addr.sin_addr) <= 0) {
        fprintf(stderr, "地址转换失败\n");
        close(sockfd);
        return -1;
    }

    if (connect(sockfd, (struct sockaddr *)&serv_addr, sizeof(serv_addr)) < 0) {
        fprintf(stderr, "连接MQTT代理失败: %s\n", strerror(errno));
        close(sockfd);
        return -1;
    }

    // 发送CONNECT包（与publish相同）
    char client_id[32];
    generate_client_id(client_id, sizeof(client_id));
    int id_len   = strlen(client_id);
    int user_len = strlen(username);
    int pass_len = strlen(password);

    int payload_len = (2 + id_len) + (2 + user_len) + (2 + pass_len);
    int rem_len     = 10 + payload_len;

    int connect_len = 1 + 1 + rem_len;
    unsigned char *conn = malloc(connect_len);
    int p = 0;

    conn[p++] = 0x10;
    conn[p++] = rem_len;

    memcpy(&conn[p], "\x00\x04MQTT\x04\xc0\x00\x3c", 10);
    p += 10;

    conn[p++] = 0;
    conn[p++] = id_len;
    memcpy(&conn[p], client_id, id_len);
    p += id_len;

    conn[p++] = (user_len >> 8) & 0xFF;
    conn[p++] = user_len & 0xFF;
    memcpy(&conn[p], username, user_len);
    p += user_len;

    conn[p++] = (pass_len >> 8) & 0xFF;
    conn[p++] = pass_len & 0xFF;
    memcpy(&conn[p], password, pass_len);
    p += pass_len;

    if (send(sockfd, conn, connect_len, 0) < 0) {
        fprintf(stderr, "发送CONNECT失败: %s\n", strerror(errno));
        free(conn);
        close(sockfd);
        return -1;
    }
    free(conn);

    // 接收CONNACK
    unsigned char connack[4];
    if (recv(sockfd, connack, 4, 0) != 4 || connack[0] != 0x20 || connack[3] != 0) {
        fprintf(stderr, "MQTT连接被拒绝\n");
        close(sockfd);
        return -1;
    }

    // 构造SUBSCRIBE包
    int tlen = strlen(topic);
    int sub_rem = 2 + 2 + tlen + 1; // 包ID(2) + 主题长度(2) + 主题 + QoS(1)
    unsigned char *sub = malloc(2 + sub_rem);
    int idx = 0;
    sub[idx++] = 0x82; // SUBSCRIBE包类型，QoS=1
    sub[idx++] = sub_rem;
    sub[idx++] = 0x00; // 包ID高字节
    sub[idx++] = 0x01; // 包ID低字节
    sub[idx++] = (tlen >> 8) & 0xFF;
    sub[idx++] = tlen & 0xFF;
    memcpy(&sub[idx], topic, tlen);
    idx += tlen;
    sub[idx++] = 0x00; // QoS 0

    if (send(sockfd, sub, idx, 0) < 0) {
        fprintf(stderr, "发送SUBSCRIBE失败: %s\n", strerror(errno));
        free(sub);
        close(sockfd);
        return -1;
    }
    free(sub);

    // 接收SUBACK
    unsigned char suback[5];
    if (recv(sockfd, suback, 5, 0) != 5 || suback[0] != 0x90) {
        fprintf(stderr, "订阅失败\n");
        close(sockfd);
        return -1;
    }

   // printf("成功订阅主题: %s\n", topic);

    // 循环接收消息
    unsigned char buffer[4096];
    int msg_count = 0;
    
    while (1) {
        int n = recv(sockfd, buffer, 2, 0);
        if (n <= 0) {
            if (n == 0) {
                printf("连接已关闭\n");
            } else if (errno == EAGAIN || errno == EWOULDBLOCK) {
                printf("接收超时\n");
            } else {
                fprintf(stderr, "接收失败: %s\n", strerror(errno));
            }
            break;
        }

        unsigned char msg_type = buffer[0];
        unsigned char rem_len = buffer[1];

        // 只处理PUBLISH消息
        if ((msg_type & 0xF0) == 0x30) {
            unsigned char *payload = malloc(rem_len);
            int received = 0;
            while (received < rem_len) {
                n = recv(sockfd, payload + received, rem_len - received, 0);
                if (n <= 0) break;
                received += n;
            }

            if (received != rem_len) {
                fprintf(stderr, "消息接收不完整\n");
                free(payload);
                continue;
            }

            // 解析主题长度
            int topic_len = (payload[0] << 8) | payload[1];
            
            // 提取主题
            char *recv_topic = malloc(topic_len + 1);
            memcpy(recv_topic, payload + 2, topic_len);
            recv_topic[topic_len] = '\0';

            // 提取消息内容
            int msg_len = rem_len - 2 - topic_len;
            char *recv_msg = malloc(msg_len + 1);
            memcpy(recv_msg, payload + 2 + topic_len, msg_len);
            recv_msg[msg_len] = '\0';

            // 调用回调函数
            if (callback) {
                callback(recv_topic, recv_msg, msg_len);
            }

            msg_count++;
            
            free(recv_topic);
            free(recv_msg);
            free(payload);
            break;
        }
    }

    close(sockfd);
    return msg_count;
}

// 使用示例
void on_message(const char *topic, const char *message, int message_len)
{
    isrun = true;
   // printf("收到消息 [%s]: %s\n", topic, message);
}



// 打印共享内存数组的物理地址信息
void print_physical_address_info(void *shared_array, size_t array_size) {
    printf("\n=== 物理地址信息 ===\n");
    
    // 获取起始地址的物理地址
    uint64_t start_phys = get_physical_address(shared_array);
    if (start_phys == 0) {
        printf("警告: 无法获取物理地址，可能需要 root 权限\n");
        printf("请使用 sudo 运行程序或添加 CAP_SYS_ADMIN 能力:\n");
        printf("  sudo setcap cap_sys_admin+ep %s\n", "your_program");
        return;
    }
    
    printf("虚拟地址范围: %p - %p\n", 
           shared_array, 
           (char*)shared_array + array_size);
    printf("起始物理地址: 0x%lx\n", start_phys);
    
    // 打印前几个元素的物理地址（用于验证连续性） 0x176ecf000
    printf("\n前10个元素的物理地址:\n");
    for (int i = 0; i < 10 && i < ARRAY_SIZE; i++) {
        void *elem_addr = &((int*)shared_array)[i];
        uint64_t elem_phys = get_physical_address(elem_addr);
        if (elem_phys != 0) {
            printf("  [%d] 虚拟: %p -> 物理: 0x%lx\n", i, elem_addr, elem_phys);
        }
    }
    
    // 检查页边界
    size_t page_size = get_page_size();
    printf("\n页大小: %zu 字节\n", page_size);
    printf("共享内存占用页数: %zu\n", (array_size + page_size - 1) / page_size);
    
    // 打印每个页的物理地址
    printf("\n各页的物理地址:\n");
    for (size_t offset = 0; offset < array_size; offset += page_size) {
        void *page_addr = (char*)shared_array + offset;
        uint64_t page_phys = get_physical_address(page_addr);
        if (page_phys != 0) {
            printf("  页 %zu: 虚拟 %p -> 物理 0x%lx\n", 
                   offset / page_size, page_addr, page_phys);
        }
    }
    
    printf("===================\n\n");
}

// 设置 CPU 亲和性
void set_cpu_affinity(int cpu) {
    cpu_set_t cpuset;
    CPU_ZERO(&cpuset);
    CPU_SET(cpu, &cpuset);
    
    printf("尝试设置CPU亲和性到CPU %d\n", cpu);
    printf("系统CPU核心数: %ld\n", sysconf(_SC_NPROCESSORS_ONLN));
    
    if (sched_setaffinity(0, sizeof(cpu_set_t), &cpuset) == -1) {
        fprintf(stderr, "设置 CPU 亲和性失败 (CPU %d): %s\n", cpu, strerror(errno));
        
        // 尝试获取当前允许的CPU集合
        cpu_set_t current_cpuset;
        if (sched_getaffinity(0, sizeof(cpu_set_t), &current_cpuset) == 0) {
            printf("当前允许的CPU: ");
            for (int i = 0; i < CPU_SETSIZE; i++) {
                if (CPU_ISSET(i, &current_cpuset)) {
                    printf("%d ", i);
                }
            }
            printf("\n");
        }
        exit(1);
    }
    printf("CPU亲和性设置成功\n");
}

static uint64_t v2p(void *v)
{
    static int fd = -1;
    if (fd < 0) {
        fd = open("/proc/self/pagemap", O_RDONLY);
        if (fd < 0) {
            perror("open pagemap");
            return 0;
        }
    }
    
    // 使用 4KB 作为 pagemap 的索引单位（这是内核的设计）
    uint64_t page_size = 4096;  // pagemap 总是以 4KB 为单位
    uint64_t vaddr = (uint64_t)v;
    uint64_t offset = (vaddr / page_size) * sizeof(uint64_t);
    
    uint64_t entry = 0;
    if (pread(fd, &entry, sizeof(entry), offset) != sizeof(entry)) {
        perror("pread pagemap");
        return 0;
    }
    
    // 检查页是否存在
    if (!(entry & (1ULL << 63))) {
        fprintf(stderr, "Page not present for addr %p\n", v);
        return 0;
    }
    
    // 提取物理页帧号（PFN）
    uint64_t pfn = entry & ((1ULL << 55) - 1);
    
    // 计算物理地址：PFN * page_size + 页内偏移
    uint64_t paddr = (pfn * page_size) + (vaddr & (page_size - 1));
    
    return paddr;
}

static int build(cline_t *out)
{
    int got = 0;
    int fd = open(HPATH, O_RDWR, 0666);
    for (int i = 0; i < NUM_HP; ++i) {
        void *p = mmap(NULL, HUGE_PAGE_SIZE,
                       PROT_READ | PROT_WRITE,
                       MAP_SHARED |  MAP_HUGETLB,
                       fd, i*HUGE_PAGE_SIZE);
        if (p == MAP_FAILED) {
            fprintf(stderr, "HP %d mmap: %s\n", i, strerror(errno));
            continue;
        }
        /* 轻轻碰一下，让内核真的给页 */
        memset(p, 0, HUGE_PAGE_SIZE);

        /* 每 64 B 一条 */
        for (uint64_t off = 0; off < HUGE_PAGE_SIZE; off += CACHE_LINE_SIZE) {
            void *v = (char *)p + off;
            uint64_t pa = v2p(v);
            if (!pa) continue;
            uint32_t slice, set;
            hash_bdw_ep(pa, &slice, &set);
            out[got].vaddr = v;
            out[got].paddr = pa;
            out[got].slice = slice;
            out[got].set   = set;
            got++;
        }
    }
    return got;
}


int main() {
    int printed = 0;
    
    // 1. 先设置CPU亲和性
    int fd = open(SHM_NAME, O_RDWR, 0666);
    cline_t *pool = malloc(MAX_LINES * sizeof(cline_t));
    int n = build(pool);
    if (fd < 0) { perror("open"); exit(1); }
    set_cpu_affinity(0);

    

    
    // 2. 打开或创建共享内存对象
    //int fd = open(HPATH, O_CREAT | O_RDWR, 0666);
    //int fd = open(HPATH, O_RDWR, 0666);
    if (fd == -1) {
        fprintf(stderr, "shm_open 失败: %s\n", strerror(errno));
        exit(1);
    }
    printf("共享内存打开成功, fd = %d\n", fd);
    int target_set = 0;
    size_t shm_size = (ARRAY_SIZE+5) * sizeof(uint64_t);
    uint64_t *shared_array = mmap(NULL, shm_size,
                                PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    // 3. 设置共享内存大小
        
        if (ftruncate(fd, shm_size) == -1) {
            fprintf(stderr, "ftruncate 失败: %s\n", strerror(errno));
            close(fd);
            exit(1);
        }
        printf("共享内存大小设置为 %zu 字节\n", shm_size);
    // 4. 映射共享内存
        
        if (shared_array == MAP_FAILED) {
            fprintf(stderr, "mmap 失败: %s\n", strerror(errno));
            close(fd);
            exit(1);
        }
        printf("共享内存映射成功, 地址 = %p\n", shared_array);
        
        // 5. 初始化共享内存（可选，但建议做）
        memset(shared_array, 0, shm_size);
        uint64_t *target_addrs = malloc(n * sizeof(uint64_t));
        uint64_t *target_phy_addrs = malloc(n * sizeof(uint64_t));
    while(1){
        
        printf("111...%d\n",target_set);
        printed = 0;
        target_set = 513;
        for (int i = 0; i < n ; i++) {
            if (pool[i].set == target_set ) {
                target_addrs[printed] = pool[i].vaddr;
                target_phy_addrs[printed] = pool[i].paddr;
                printed++;
            }
        }
        
        printf("共享内存初始化完成\n");
        for (int i = 0; i < printed; i++) {
            printf("%p,\n",
                target_phy_addrs[i]);
        }
        
        // 打印物理地址信息
        print_physical_address_info(shared_array, shm_size);
        
        // 6. 主循环
        int counter = 0;
        printf("开始读取循环...\n");
        volatile int ss = 0;

        void* test_addrs[printed];
        void* access_addrs[printed];
        for (int i = 0; i < printed; i++) {
            test_addrs[i] = (void*)target_addrs[i];
            access_addrs[i] = (void*)target_addrs[i];
        }
        
        uint64_t test_num = printed;
        uint64_t increase = 1;
        //shared_array[READER_FLAGS] = READER_TAGS; 
        //shared_array[WRITER_FLAGS] = WRITER_TAGS;
        while (1) {
            //shared_array[WRITER_FLAGS] = increase;
            //printf("Waiting for writer to update to %lu...\n", increase);
            while(shared_array[WRITER_FLAGS] != increase){
                //shared_array[READER_FLAGS] = increase;
                //printf("Waiting for writer:%d...\n", shared_array[WRITER_FLAGS]);
                // printf("1111111-shared_array[WRITER_FLAGS]:%d,paddr:%lx\n", shared_array[WRITER_FLAGS],v2p((void*)&shared_array[WRITER_FLAGS]) );
                if(target_set != shared_array[TARGET_SET]){
                    break;
                }
                
            }
            //printf("11111111\n");
            

            test_num = shared_array[0];
            
            for(int i = 0; i<test_num;i++){            
                test_addrs[i] = (void*)target_addrs[shared_array[i+1]];
                
            }
            for(int j = 0; j<test_num;j++){
                access_addrs[j] = test_addrs[j];
            }

            for(int j = 0; j<test_num;j++){
                uint64_t jt = rand() % (j + 1);
                uint64_t tmp = access_addrs[j]; access_addrs[j] = access_addrs[jt]; access_addrs[jt] = tmp;
            }
            //printf("222...\n");
            for(int j = 0; j<test_num;j++){
                clflush(access_addrs[j]);
            }
            for(int im = 0; im < 1000; im++){
                for (int i = 0; i < test_num; i++) {

                    smaccess(access_addrs[i]);
        
                }
            }
            
            counter++;
            //simple_mqtt_publish("166.111.238.139", 1883, "wdh", "wdh123wdh", "test", "sadfasfd");
            //simple_mqtt_subscribe("166.111.238.139", 1883,
            //                 "wdh", "wdh123wdh",
            //                 "test",
            //                 on_message,
            //                 30);

            
            
            shared_array[READER_FLAGS] = increase;
            //printf("222\n");
            increase ++;
            if(target_set != shared_array[TARGET_SET]){
                printf("target_set changed:%d->%d\n", target_set, shared_array[TARGET_SET]);
                
                break;
            }
        }
        uint64_t paddrs[test_num];
        for(int i = 0; i < test_num; i++){
            paddrs[i] = v2p((void*)test_addrs[i]);

        }
        const char filename[25];
        snprintf(filename, sizeof(filename), "./data_writer_%d.csv", target_set);
        //write_csv_uint64(filename,0, paddrs, test_num);
        target_set = shared_array[TARGET_SET];
        //sleep(10);
    }
    // 7. 清理（虽然这里永远不会执行到）
    //munmap(shared_array, shm_size);
    //close(fd);
    //shm_unlink(SHM_NAME);
    return 0;
}