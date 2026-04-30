#include <sys/mman.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

int main(void){
    long pagesz = sysconf(_SC_PAGESIZE);

    /* 1. 取系统总内存 */
    long total_kb = 0;
    FILE *f = fopen("/proc/meminfo", "r");
    fscanf(f, "MemTotal: %ld kB\n", &total_kb);
    fclose(f);
    size_t total = total_kb * 1024;

    /* 2. 映射并真正『摸』一下，让内核把页装进 RAM */
    void *p = mmap(NULL, total, PROT_READ|PROT_WRITE,
                   MAP_PRIVATE|MAP_ANONYMOUS, -1, 0);
    if (p == MAP_FAILED) { perror("mmap"); return 1; }
    memset(p, 0, total);          // ← 关键：把页全部弄脏

    /* 3. 再询问 mincore */
    unsigned char *vec = calloc(total/pagesz, 1);
    if (!vec) { perror("calloc"); return 1; }
    if (mincore(p, total, vec) == -1) { perror("mincore"); return 1; }

    uint64_t base = UINT64_MAX, end = 0;
    for (uint64_t i = 0; i < total/pagesz; ++i) {
        if (vec[i] & 1) {
            uint64_t phys_est = i * pagesz;
            if (base == UINT64_MAX) base = phys_est;
            end = phys_est;
        }
    }
    if (base == UINT64_MAX)
        puts("No RAM pages detected (unexpected!)");
    else
        printf("DRAM window estimate: %#llx - %#llx\n",
               base, end + pagesz);
    return 0;
}