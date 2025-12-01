[bits 16]
switch_to_pm:
    cli ; 禁用中断
    lgdt [gdt_descriptor] ; 加载全局描述表（GDT）
    mov eax, cr0
    or eax, 0x1 ; 将EAX寄存器的第0位（最低位）设置为1
    mov cr0, eax ; CR0寄存器的保护模式使能位被设置，启用保护模式
    jmp CODE_SEG:init_pm ; 远跳到保护模式代码段

[bits 32]
init_pm: ; 从这里开始执行32位保护模式代码
    mov ax, DATA_SEG ; 设置所有段寄存器为数据段选择子
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov ebp, 0x90000 ; 将栈更新至可用空间的最顶部
    mov esp, ebp

    call BEGIN_PM ; 调用保护模式下的入口点
