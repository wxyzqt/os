#include "idt.h"
#include "type.h"

idt_gate_t idt[IDT_ENTRIES];
idt_register_t idt_reg;

void set_idt_gate(int n, uint32_t handler)
{
    idt[n].low_offset = low_16(handler);
    idt[n].sel = KERNEL_CS;
    idt[n].always0 = 0;
    idt[n].flags = 0x8E;
    idt[n].high_offset = high_16(handler);
}

void set_idt()
{
    idt_reg.base = (uint32_t)&idt;
    // -1 是因为从0开始访问，8*256 字节的表最后一个字节的偏移量是2047
    idt_reg.limit = IDT_ENTRIES * sizeof(idt_gate_t) - 1;

    // 加载IDT寄存器
    asm volatile("lidtl (%0)" : : "r"(&idt_reg));
}
