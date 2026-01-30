// common.h
#ifndef COMMON_H
#define COMMON_H

#include <stdint.h>
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







uint64_t p_addrs[20]={
    0x327600000,
    0x324400000,
    0x323200000,
    0x320000000,
    0x31fc00000,
    0x31ce00000,
    0x31b800000,
    0x318a00000,
    0x316400000,
    0x315600000,
    0x312000000,
    0x311200000,
    0x30ec00000,
    0x30de00000,
    0x30a800000,
    0x2fe200000,
    0x303000000,
    0x166000000,
    0x168e00000,
    0x170600000/*,
0x173400000,
0x174200000,
0x179e00000,
0x17ac00000,
0x17da00000,
0x181a00000,
0x182800000,
0x17e800000,
0x185e00000,
0x186c00000,
0x188200000,
0x18b000000,
0x18c600000,
0x18f400000,
0x190a00000,
0x194e00000,
0x199200000,
0x19a000000,
0x16f800000,
0x19e400000,
0x1a1800000,
0x1a2a00000,
0x1a5c00000,
0x1a8000000,
0x1ab200000,
0x1a6e00000,
0x1ac400000,
0x1b0800000,
0x1b3a00000,
0x1b4c00000,
1b7e00000,
1b9000000,
1ba200000,
1bd400000,
1be600000,
1c1c00000,
19d600000,
1c2e00000,
1c5800000,
1c6a00000,
1cc000000,
304600000*/
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
