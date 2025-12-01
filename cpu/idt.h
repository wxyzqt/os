#ifndef IDT_H
#define IDT_H

#include <stdint.h>

// 内核代码段
#define KERNEL_CS 0x08

/* How every interrupt gate (handler) is defined */
typedef struct
{
    uint16_t low_offset; // 处理函数地址的低 16 位
    uint16_t sel;        // 内核代码段选择子
    uint8_t always0;
    /* 标志位：
     * Bit 7: 中断功能已启用 (1)
     * Bits 6-5: 调用特权级，0 = 内核级别， 3 = 用户级别
     * Bit 4: 中断门类型，0 = 中断门，1 = 陷阱门
     * Bits 3-0: 二进制 1110 = 十进制 14 = 32位中断门 */
    uint8_t flags;
    uint16_t high_offset; // 处理函数地址的高 16 位
} __attribute__((packed)) idt_gate_t;

// 指向中断处理程序数组的指针
// 由汇编指令"lidt"读取
typedef struct
{
    uint16_t limit;
    uint32_t base;
} __attribute__((packed)) idt_register_t;

#define IDT_ENTRIES 256

void set_idt_gate(int n, uint32_t handler);
void set_idt();

#endif
