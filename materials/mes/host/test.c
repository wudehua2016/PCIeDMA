#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <stdint.h>

#define MAX_CSV_LINES 500000


/**
 * read_csv_uint64 - 读取 CSV 文件里的一列 uint64_t
 * @path   : CSV 文件路径
 * @col    : 目标列序号（0 起始）
 * @count  : 输出参数，返回实际读到的条数
 * 返回：动态分配的 uint64_t 数组，调用者负责 free
 */
uint64_t *read_csv_uint64(const char *path, int col, int *count)
{
    FILE *fp = fopen(path, "r");
    if (!fp) {
        perror("fopen csv");
        *count = 0;
        return NULL;
    }

    uint64_t *buf = malloc(MAX_CSV_LINES * sizeof(uint64_t));
    if (!buf) {
        fclose(fp);
        *count = 0;
        return NULL;
    }

    char line[256];
    int  rows = 0;



    while (fgets(line, sizeof(line), fp) && rows < MAX_CSV_LINES) {
        line[strcspn(line, "\r\n")] = 0;

        char *saveptr = NULL;
        char *fld = strtok_r(line, ",", &saveptr);
        for (int i = 0; i < col && fld; ++i)
            fld = strtok_r(NULL, ",", &saveptr);

        if (!fld) continue;

        uint64_t val = strtoull(fld, NULL, 16);
        if (errno == EINVAL) continue;

        buf[rows++] = val;
    }

    fclose(fp);
    *count = rows;
    return buf;
}
/*
int main(){

    int csv_cnt = 0;
    uint64_t *csv_paddr = read_csv_uint64("./data.csv", 2, &csv_cnt);
    if (!csv_paddr || csv_cnt == 0) {
        fprintf(stderr, "failed to load CSV\n");
        return 1;
    }

    for (int i = 0; i < csv_cnt; ++i)
        printf("paddr[%d] = 0x%lx\n", i, csv_paddr[i]);
    printf("csv cnt :%d\n",csv_cnt);
    free(csv_paddr);   

}
*/