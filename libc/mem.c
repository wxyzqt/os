#include "mem.h"

void memory_copy(uint8_t *source, uint8_t *dest, int nbytes)
{
    int i;
    for (i = 0; i < nbytes; i++)
    {
        *(dest + i) = *(source + i);
    }
}

// 将指定内存区域填充为特定值
void memory_set(uint8_t *dest, uint8_t val, uint32_t len)
{
    uint8_t *temp = (uint8_t *)dest;
    for (; len != 0; len--)
        *temp++ = val;
}

// 内核从0x1000开始分配内存
uint32_t free_mem_addr = 0x10000; // 硬编码，64k

// 实现过程就是指向一段不断扩大的可用内存区域的指针

// 这里需要重写，逻辑漏洞
uint32_t kmalloc(size_t size, int align, uint32_t *phys_addr)
{
    // 页面4k对齐，对应0x1000
    if (align == 1 && (free_mem_addr & 0xFFFFF000))
    {
        free_mem_addr &= 0xFFFFF000;
        free_mem_addr += 0x1000;
    }
    /* Save also the physical address */
    if (phys_addr)
    {
        *phys_addr = free_mem_addr;
    }

    uint32_t ret = free_mem_addr;
    free_mem_addr += size; // 增加分配的内存大小
    return ret;
}
