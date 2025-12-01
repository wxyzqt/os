#include "ports.h"

// 从指定端口读取一个字节
uint8_t port_byte_in(uint16_t port)
{
    uint8_t result;
    // c语言内联汇编,默认采用AT&T语法:
    // 与我们在boot中使用的asm语法有所不同

    // asm(汇编模板 : 输出操作数 : 输入操作数)
    asm("in %%dx, %%al" : "=a"(result) : "d"(port));
    return result;
}

// 向指定端口写入一个字节
void port_byte_out(uint16_t port, uint8_t data)
{
    // 注意这里有volatile关键字,告诉编译器不要优化这条指令
    // 编译器优化可能会修改删除或者重排序指令,而io端口操作修改了硬件状态，优化可能会破坏硬件

    // 这里有两个参数，用逗号分隔，第一个是数据寄存器al，第二个是端口寄存器dx
    // 注意到::了吗？，没有输出，类似与for循环的::跳参语法
    asm volatile("out %%al, %%dx" : : "a"(data), "d"(port));
}

// 从指定端口读取一个字
uint16_t port_word_in(uint16_t port)
{
    uint16_t result;
    asm("in %%dx, %%ax" : "=a"(result) : "d"(port));
    return result;
}

// 向指定端口写入一个字
void port_word_out(uint16_t port, uint16_t data)
{
    asm volatile("out %%ax, %%dx" : : "a"(data), "d"(port));
}
