#ifndef PORTS_H
#define PORTS_H

#include <stdint.h>

// x86硬件和历史,决定了1个字等于2字节

// 从指定端口读取一个字节
unsigned char port_byte_in(uint16_t port);

// 向指定端口写入一个字节
void port_byte_out(uint16_t port, uint8_t data);

// 从指定端口读取一个字(16位)
unsigned short port_word_in(uint16_t port);

// 向指定端口写入一个字(16位)
void port_word_out(uint16_t port, uint16_t data);

#endif
