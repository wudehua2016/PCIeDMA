// common.h
#ifndef COMMON_H
#define COMMON_H

#include <stdint.h>
#define NUM_HP          2000
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







uint64_t p_addrs[42]={
0x7a8a00580,
0x7a6400580,
0x7a5600580,
0x7a2000580,
0x7a1200580,
0x79ee00580,
0x79dc00580,
0x79aa00580,
0x799800580,
0x797600580,
0x794400580,
0x793200580,
0x790000580,
0x78fe00580,
0x78cc00580,
0x78ba00580,
0x788800580,
0x786600580,
0x785400580,
0x782200580,
0x781000580,
0x7d3400580,
0x7d0600580,
0x7cf800580,
0x7cca00580,
0x7cbc00580,
0x7c8e00580,
0x7c6000580,
0x7c5200580,
0x7c2400580,
0x7c1600580,
0x7bec00580,
0x7bde00580,
0x7ba800580,
0x7b9a00580,
0x7b7400580,
0x7b4600580,
0x7b3000580,
0x7b0200580,
0x7afc00580,
0x7ace00580,
0x7ab800580,
};

static void hash_bdw_ep(uint64_t paddr, uint32_t *slice, uint32_t *set)
{
    uint32_t o0, o1, o2, o3;
    uint32_t slice_id;
    
    #define GET_BIT(addr, bit) (((addr) >> (bit)) & 1)
    
    o0 = GET_BIT(paddr, 6) ^ GET_BIT(paddr, 10) ^ GET_BIT(paddr, 12) ^ 
         GET_BIT(paddr, 14) ^ GET_BIT(paddr, 16) ^ GET_BIT(paddr, 17) ^ 
         GET_BIT(paddr, 18) ^ GET_BIT(paddr, 20) ^ GET_BIT(paddr, 22) ^ 
         GET_BIT(paddr, 24) ^ GET_BIT(paddr, 25) ^ GET_BIT(paddr, 26) ^ 
         GET_BIT(paddr, 27) ^ GET_BIT(paddr, 28) ^ GET_BIT(paddr, 30) ^ 
         GET_BIT(paddr, 32) ^ GET_BIT(paddr, 33);
    
    o1 = GET_BIT(paddr, 7) ^ GET_BIT(paddr, 11) ^ GET_BIT(paddr, 13) ^ 
         GET_BIT(paddr, 15) ^ GET_BIT(paddr, 17) ^ GET_BIT(paddr, 19) ^ 
         GET_BIT(paddr, 20) ^ GET_BIT(paddr, 21) ^ GET_BIT(paddr, 22) ^ 
         GET_BIT(paddr, 23) ^ GET_BIT(paddr, 24) ^ GET_BIT(paddr, 26) ^ 
         GET_BIT(paddr, 28) ^ GET_BIT(paddr, 29) ^ GET_BIT(paddr, 31) ^ 
         GET_BIT(paddr, 33);
    
    o2 = GET_BIT(paddr, 8) ^ GET_BIT(paddr, 12) ^ GET_BIT(paddr, 13) ^ 
         GET_BIT(paddr, 16) ^ GET_BIT(paddr, 19) ^ GET_BIT(paddr, 22) ^ 
         GET_BIT(paddr, 23) ^ GET_BIT(paddr, 26) ^ GET_BIT(paddr, 27) ^ 
         GET_BIT(paddr, 30) ^ GET_BIT(paddr, 31);
    
    o3 = GET_BIT(paddr, 9) ^ GET_BIT(paddr, 12) ^ GET_BIT(paddr, 16) ^ 
         GET_BIT(paddr, 17) ^ GET_BIT(paddr, 19) ^ GET_BIT(paddr, 21) ^ 
         GET_BIT(paddr, 22) ^ GET_BIT(paddr, 23) ^ GET_BIT(paddr, 25) ^ 
         GET_BIT(paddr, 26) ^ GET_BIT(paddr, 27) ^ GET_BIT(paddr, 29) ^ 
         GET_BIT(paddr, 31) ^ GET_BIT(paddr, 32);
    
    slice_id = (o3 << 3) | (o2 << 2) | (o1 << 1) | o0;
    *slice = slice_id;
    *set = (paddr >> 6) & 0x7FFF;
    
    #undef GET_BIT
}
#endif
