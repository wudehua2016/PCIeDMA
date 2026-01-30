#define _GNU_SOURCE


#define NUM_HP          1000
#define CACHE_LINE_SIZE 64
#define HUGE_PAGE_SIZE  (2UL*1024*1024)
#define SHM_NAME "/my_shared_mem"
#define SHM_NAME_2 "/my_shared_mem2"
#define ARRAY_SIZE (1024)
#define HPATH "/dev/hugepages/my_pool"
#define SEM_NAME "/my_sync_semaphore" 
#define MAX_LINES       (NUM_HP * HUGE_PAGE_SIZE / CACHE_LINE_SIZE)
#define WRITER_FLAGS (ARRAY_SIZE+2)
#define READER_FLAGS (ARRAY_SIZE+1)
#define WRITER_TAGS 123456
#define READER_TAGS 1234567
#define TARGET_SET  (ARRAY_SIZE+3)
static inline uint64_t rdtsc(){
    unsigned int lo, hi;
    __asm__ __volatile__ ("rdtsc" : "=a"(lo), "=d"(hi));
    return ((uint64_t)hi << 32) | lo;
}

typedef struct {
    void  *vaddr;
    uint64_t paddr;
    uint32_t slice;
    uint32_t set;
} cline_t;







uint64_t p_addrs[22]={
    0x326608040,
0x325408040,
0x322208040,
0x321008040,
0x31ec08040,
0x31de08040,
0x31a808040,
0x319a08040,
0x317408040,
0x314608040,
0x313008040,
0x310208040,
0x30fc08040,
0x30ce08040,
0x30b808040,
0x301208040,
0x302008040,
0x308a08040,
0x167008040,
0x169e08040,
0x16ac08040
};

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



// 获取页大小
static size_t get_page_size() {
    return sysconf(_SC_PAGESIZE);
}
bool isrun = true;
bool istest = false;
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

void generate_client_id(char *client_id, size_t max_len) {
    snprintf(client_id, max_len, "reader_%d_%ld", getpid(), time(NULL));
}

//reader代码
static inline uint64_t rdtscfence(void) {
    uint64_t a, d;
    asm volatile("lfence; rdtsc" : "=a"(a), "=d"(d) :: "memory");
    return ((d << 32) | a);
}

static inline void maccess(void *p) {
    asm volatile("movq (%0), %%rax\n" : : "r"(p) : "rax", "memory");
}

static inline void clflush(void *p) {
    asm volatile("lfence;clflush %0;lfence;\n" : : "m"(*(volatile char *)p) : "memory");
}

static inline void wbinvd(void) {
    asm volatile("wbinvd" : : : "memory");
}
static inline int smaccess(void *p) {
    int value;
    asm volatile("lfence; mov (%1), %0; lfence\n" : "=r"(value) : "r"(p) : "memory");
    return value;
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
    if (sched_setaffinity(0, sizeof(cpu_set_t), &cpuset) == -1) {
        fprintf(stderr, "设置 CPU 亲和性失败: %s\n", strerror(errno));
        exit(1);
    }
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
                       MAP_SHARED | MAP_HUGETLB,
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
    int fd = open(SHM_NAME, O_CREAT | O_RDWR, 0666);
    cline_t *pool = malloc(MAX_LINES * sizeof(cline_t));
    int n = build(pool);
    if (fd < 0) { perror("open"); exit(1); }
    set_cpu_affinity(2);
    int target_set = 0;
    

        int printed = 0;
        uint64_t *target_addrs = malloc(n * sizeof(uint64_t));
        uint64_t *target_phy_addrs = malloc(n * sizeof(uint64_t));

        uint64_t pa = p_addrs[p];
        for (int i = 0; i < n ; i++) {
            if (pool[i].paddr == pa ) {
                target_addrs[printed] = pool[i].vaddr;
                target_phy_addrs[printed] = pool[i].paddr;
                printed++;
            }
        }

        
        int idx = 0;

        uint64_t test_addrs[printed];
        uint64_t test_index[printed];
        shared_array[0] = printed;
        uint64_t orig_tests[printed];
        for (int i = 0; i < printed; i++) {
            test_addrs[i] = target_addrs[i];
            test_index[i] = i;
            shared_array[i+1] = i;
            orig_tests[i] = i;
        }
        
        int test_num = printed;
        int swaped_index = 0;
        int true_num = 0;
        int test_times = 0;
        uint64_t increase = 0;
        int counter = 0;
   
       
            int index = 0;
            int64_t times[1000];

            for(int j = 0; j<1000;j++){
                uint64_t tmp = rand() % test_num;
                times[j] = test_addrs[tmp];
            }
            
            
            printf("\n");
            for(int j = 0; j<test_num;j++){
                clflush(test_addrs[j]);
            }
           wbinvd();
            

                for(int j = 0; j<1000;j++){

                    maccess(times[j]);
                }

            counter++;

            sleep(2);
            


    return 0;
}
