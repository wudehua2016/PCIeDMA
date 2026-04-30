#include <stdio.h>

int main() {
    int input;

    printf("请输入一个整数（1-3）：");
    scanf("%d", &input);

    switch (input) {
        case 1:
            printf("你输入的是 1，输出：Hello!\n");
            break;
        case 2:
            printf("你输入的是 2，输出：World!\n");
            break;
        case 3:
            printf("你输入的是 3，输出：C is awesome!\n");
            break;
        default:
            printf("输入不在 1-3 范围内，输出：Goodbye!\n");
            break;
    }

    return 0;
}