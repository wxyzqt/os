global _start;
[bits 32]

_start:
    [extern kernel_main] ; 定义调用点，其名称与kernel.c中的函数名称相同
    call kernel_main ; 调用 C 函数。链接器知道该函数在内存中的存放位置
    jmp $   ; 无限循环，防止执行到未知区域
