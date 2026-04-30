// common.h
#ifndef COMMON_H
#define COMMON_H

#include <stdint.h>

#define SHM_NAME "/dev/hugepages/my_pool"
#define ARRAY_SIZE (1024*1024)
#define HPATH "/mnt/huge/my_huge_mem"

static inline uint64_t rdtsc(){
    unsigned int lo, hi;
    __asm__ __volatile__ ("rdtsc" : "=a"(lo), "=d"(hi));
    return ((uint64_t)hi << 32) | lo;
}

#endif
