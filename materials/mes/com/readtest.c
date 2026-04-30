#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <errno.h>
#include <stdint.h>

#include "./common.h"

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

#define mfence()  __asm__ volatile("mfence;"); 
#define lfence()  __asm__ volatile("lfence;");

#define CACHE_LINE_SIZE 64
#define HUGE_PAGE_SIZE  (2UL*1024*1024)
#define NUM_HP          1000
#define MAX_LINES       (NUM_HP * HUGE_PAGE_SIZE / CACHE_LINE_SIZE)

typedef struct {
    void  *vaddr;
    uint64_t paddr;
    uint32_t slice;
    uint32_t set;
} cline_t;

/* 物理地址转换 */
/*static uint64_t v2p(void *v)
{
    int fd = open("/proc/self/pagemap", O_RDONLY);
    if (fd < 0) return 0;
    uint64_t ps = sysconf(_SC_PAGESIZE);
    uint64_t off = ((uint64_t)v / ps) * 8;
    uint64_t e = 0;
    pread(fd, &e, 8, off);
    close(fd);
    if (!(e & (1ULL << 63))) return 0;
    return (e & ((1ULL << 55) - 1)) * ps + ((uint64_t)v & (ps - 1));
}*/
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


static inline uint64_t measure_access_time(void *addr) {
    uint64_t start, end;
    uint32_t aux;
    
    _mm_lfence();
    start = __rdtscp(&aux);
    _mm_lfence();
    *(volatile char *)addr;
    _mm_lfence();
    end = __rdtscp(&aux);
    _mm_lfence();
    
    return end - start;
}

/* BDW-EP 20 slice / 1024 set */
static void hash_ep(uint64_t pa, uint32_t *slice, uint32_t *set)
{
    uint64_t line = pa >> 6;
    uint32_t s = (line ^ (line >> 10) ^ (line >> 15)) % 20;
    *slice = s;
    *set   = line & 0x3FF;
}


static void hash_bdw_ep(uint64_t paddr, uint32_t *slice, uint32_t *set)
{
    const uint64_t line = paddr >> 6;   // cache-line 索引

    /* 5 个 bit-field 异或，再模 20 */
    uint32_t h  = (line & 1) ^ ((line >> 1) & 1) ^ ((line >> 2) & 1) ^
                  ((line >> 3) & 1) ^ ((line >> 4) & 1);
    h |= ((line >> 5) & 1) << 1;
    h |= ((line >> 6) & 1) << 2;
    h |= ((line >> 7) & 1) << 3;
    h |= ((line >> 8) & 1) << 4;
    /* 折叠到 0-19 */
    uint32_t s = (h ^ (line >> 10) ^ (line >> 15) ^ (line >> 16)) % 20;

    *slice = s;
    *set   = line & 0x7FFF;   // 10 bit set
}


/* 真正拿大页 + 收集 */
static int build(cline_t *out,int fd)
{
    int got = 0;
    for (int i = 0; i < NUM_HP; ++i) {
        off_t file_offset = (off_t)i * HUGE_PAGE_SIZE;
        void *p = mmap(NULL, HUGE_PAGE_SIZE,
                       PROT_READ | PROT_WRITE,
                       MAP_SHARED | MAP_HUGETLB,
                       fd, file_offset);
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

void bind_memory_to_node(int node) {
    if (numa_available() == -1) {
        printf("NUMA not available!\n");
        return;
    }
    numa_set_localalloc();
    numa_run_on_node(node);
    printf("Bound process and memory allocation to NUMA node %d\n", node);
}

static inline uint64_t maccess(void *addr) {
    _mm_lfence();
    //*(volatile char *)addr;
    asm volatile("mov (%0), %%eax" :: "r"(addr) : "eax");
    _mm_lfence();
    return 0;
}

static inline void flush_cache_line(void *addr) {
    _mm_clflush(addr);
    _mm_mfence();
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

void bind_cpu(int cpu_id) {
    cpu_set_t mask;
    CPU_ZERO(&mask);
    CPU_SET(cpu_id, &mask);
    if (sched_setaffinity(0, sizeof(mask), &mask) != 0) {
        perror("sched_setaffinity");
        exit(1);
    }
    printf("Successfully bound to CPU %d\n", cpu_id);
}

int main(void)
{
    cline_t *pool = malloc(MAX_LINES * sizeof(cline_t));
    int fd = open(SHM_NAME, O_RDWR, 0666);
    if (fd < 0) { perror("open"); exit(1); }
    if (!pool) { perror("malloc"); return 1; }
    bind_memory_to_node(0);
    bind_cpu(3);
    int n = build(pool, fd);
    printf("collected %d cache-lines\n", n);
    if (n == 0) { free(pool); return 1; }

    for (int i = 0; i < 10 && i < n; i++) {
        printf("Line %d: vaddr=%p, paddr=0x%lx, slice=%u, set=%u\n",
            i, pool[i].vaddr, pool[i].paddr, pool[i].slice, pool[i].set);
    }

    /* 示范：打印 set-123 的前 20 条 */
    int printed = 0;
    uint64_t *target_addrs = malloc(n * sizeof(uint64_t));
    uint64_t *target_phy_addrs = malloc(n * sizeof(uint64_t));
    for (int i = 0; i < n ; i++) {
        if (pool[i].set == 85 ) {
            target_addrs[printed] = pool[i].vaddr;
            target_phy_addrs[printed] = pool[i].paddr;
            printed++;
        }
    }
    int csv_cnt = 0;
    csv_cnt = printed;
    uint64_t tga_index = 0;
    printf("phy: 0x%x\n",v2p(&tga_index));
    printf("--1************\n");
    for(int i = 0; i < printed; i++){
        printf("%d,0x%016llx,%p\n", i,
       (unsigned long long)target_phy_addrs[i],
       target_addrs[i]);
    }
    

    char mqtt_data[256];
    time_t rawtime;
    struct tm *timeinfo;
    time(&rawtime);
    timeinfo = localtime(&rawtime);
    uint64_t count = 0;
    volatile uint64_t targets_phys = v2p(&target_addrs[0]);
    //int times[n];
    int mode = 1;
    uint64_t input;
    snprintf(mqtt_data, sizeof(mqtt_data), 
            "start_to_run");
    simple_mqtt_publish("166.111.238.139", 1883, "wdh", "wdh123wdh", "test", mqtt_data);
    //scanf("%d", &input);
    sleep(6);
    int res_index = 0;
    int test_count = 0;
    while(true){

        //for (int t = 0 ;t <=1000;t++){
            for(int i=0;i<csv_cnt;i++){
                //if(i %2 ==0)
                    maccess((void *)(target_addrs[i]));
                //else
                //    flush_cache_line((void *)(target_addrs[i]));
            }
        //}

        

        //simple_mqtt_publish("166.111.238.139", 1883, "wdh", "wdh123wdh", "test", mqtt_data);
        printf("Published MQTT message: %d\n", test_count);
        sleep(5);//等待采集
        test_count ++;
    }
    snprintf(mqtt_data, sizeof(mqtt_data), 
            "wudehua_target_addr=%0llx=%02d%dXX%02d_%d_%d_%s", 
            targets_phys,
            timeinfo->tm_hour, csv_cnt, timeinfo->tm_sec,80,res_index,"mode=1");
    simple_mqtt_publish("166.111.238.139", 1883, "wdh", "wdh123wdh", "test", mqtt_data);
    free(pool);
    return 0;
}