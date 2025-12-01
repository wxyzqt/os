#include "timer.h"
#include "isr.h"
#include "ports.h"
#include "../libc/function.h"

uint32_t tick = 0;

static void timer_callback(registers_t *regs)
{
    tick++;
    UNUSED(regs);
}

void init_timer(uint32_t freq)
{
    // 注册中断处理程序
    register_interrupt_handler(IRQ0, timer_callback);

    // 获取 PIT 值：硬件时钟频率为 1193180 赫兹
    uint32_t divisor = 1193180 / freq;
    uint8_t low = (uint8_t)(divisor & 0xFF);
    uint8_t high = (uint8_t)((divisor >> 8) & 0xFF);

    // 发送命令字节
    port_byte_out(0x43, 0x36);
    port_byte_out(0x40, low);
    port_byte_out(0x40, high);
}
