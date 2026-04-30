#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <errno.h>
#include <stdlib.h>

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

    /* 计算各字段长度 */
    int id_len   = 8;                 // "testclnt"
    int user_len = strlen(username);
    int pass_len = strlen(password);

    /* 可变头 = 协议名(6) + 协议级别(1) + 连接标志(1) + 保活(2) = 10 字节 */
    /* 载荷   = 客户端ID(2+id) + 用户名(2+user) + 密码(2+pass)        */
    int payload_len = (2 + id_len) + (2 + user_len) + (2 + pass_len);
    int rem_len     = 10 + payload_len;

    /* 固定头 1 字节 + 剩余长度 1 字节（本例 <128，直接写） */
    int connect_len = 1 + 1 + rem_len;
    unsigned char *conn = malloc(connect_len);
    int p = 0;

    /* 固定头 */
    conn[p++] = 0x10;       // CONNECT
    conn[p++] = rem_len;    // 剩余长度

    /* 可变头 */
    memcpy(&conn[p], "\x00\x04MQTT\x04\xc0\x00\x3c", 10);  // 协议名/级别/标志/保活
    p += 10;
    /* 连接标志 0xc0 = 用户名(1<<7) | 密码(1<<6) 置位 */

    /* 载荷 */
    /* 客户端ID */
    conn[p++] = 0;
    conn[p++] = id_len;
    memcpy(&conn[p], "testclnt", id_len);
    p += id_len;

    /* 用户名 */
    conn[p++] = (user_len >> 8) & 0xFF;
    conn[p++] = user_len & 0xFF;
    memcpy(&conn[p], username, user_len);
    p += user_len;

    /* 密码 */
    conn[p++] = (pass_len >> 8) & 0xFF;
    conn[p++] = pass_len & 0xFF;
    memcpy(&conn[p], password, pass_len);
    p += pass_len;

    /* 发送 CONNECT */
    if (send(sockfd, conn, connect_len, 0) < 0) {
        fprintf(stderr, "发送CONNECT失败: %s\n", strerror(errno));
        free(conn);
        close(sockfd);
        return -1;
    }
    free(conn);

    /* 收 CONNACK */
    unsigned char connack[4];
    if (recv(sockfd, connack, 4, 0) != 4 || connack[0] != 0x20 || connack[3] != 0) {
        fprintf(stderr, "MQTT连接被拒绝（用户名/密码错误或服务器拒绝）\n");
        close(sockfd);
        return -1;
    }

    /* 拼装 PUBLISH （与原代码相同） */
    int tlen = strlen(topic);
    int mlen = strlen(message);
    int rem  = 2 + tlen + mlen;
    unsigned char *pub = malloc(2 + rem);
    int idx = 0;
    pub[idx++] = 0x30;          // PUBLISH QoS0
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

    printf("MQTT消息发布成功: %s -> %s\n", topic, message);
    free(pub);
    close(sockfd);
    return 0;
}

/* 简单测试
gcc mqtt_auth.c -o mqtt_auth
./mqtt_auth 127.0.0.1 1883 wdh 123456 my/topic "hello with auth"
*/