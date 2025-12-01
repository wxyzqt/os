#ifndef TYPE_H
#define TYPE_H

// 引入标准整数类型定义，以确保跨平台的一致性
// stdint.h 不属于运行时依赖库，因此可以安全地包含在内核代码中
#include <stdint.h>

// 定义低16位和高16位提取宏，用于地址操作
#define low_16(address) (uint16_t)((address) & 0xFFFF)
#define high_16(address) (uint16_t)(((address) >> 16) & 0xFFFF)

#endif
