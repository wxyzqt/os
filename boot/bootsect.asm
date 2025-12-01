;引导扇区, 512字节, 16位实模式代码
[bits 16]
[org 0x7c00] ; BIOS会将引导扇区加载到内存地址0x7c00处并跳转到该地址执行

KERNEL_OFFSET equ 0x1000 ; 0x1000 = 4k, 内核将加载到此地址

mov [BOOT_DRIVE], dl ; 将BIOS提供的引导驱动器号保存到变量中
mov bp, 0x9000  ; 设置堆栈段地址为0x9000
mov sp, bp      ; 设置堆栈指针为0x9000

mov bx, MSG_REAL_MODE 
call print
call print_nl

call load_kernel ; 从磁盘读取内核
call switch_to_pm ; 禁用中断、加载全局描述表（GDT）等操作。最后跳转至BEGIN_PM段。
jmp $ ; 不会执行的无限循环，防止意外执行到未知区域

%include "boot/print.asm" ;打印字符串和换行
%include "boot/print_hex.asm" ; 打印十六进制数值
%include "boot/disk.asm"    ; 从磁盘加载数据
%include "boot/gdt.asm"     ; 全局描述表（GDT）定义
%include "boot/32bit_print.asm"  ; 32位保护模式下的打印功能
%include "boot/switch_pm.asm"   ; 切换到保护模式

[bits 16]
load_kernel:
    mov bx, MSG_LOAD_KERNEL
    call print
    call print_nl

    mov bx, KERNEL_OFFSET ; 从磁盘读取数据并存储在 0x1000 地址处
    mov dh, 31 ; 要读取的扇区数量
    mov dl, [BOOT_DRIVE] ; 使用引导驱动器号
    call disk_load
    ret

[bits 32]
BEGIN_PM:
    mov ebx, MSG_PROT_MODE
    call print_string_pm
    call KERNEL_OFFSET ; 控制权交给内核
    jmp $ ; 如果内核返回，则进入无限循环


BOOT_DRIVE db 0 ; 初始化引导驱动器变量，BIOS在启动时会将引导驱动器号放入dl寄存器
MSG_REAL_MODE db "Started in 16-bit Real Mode", 0
MSG_PROT_MODE db "Landed in 32-bit Protected Mode", 0
MSG_LOAD_KERNEL db "Loading kernel into memory", 0
MSG_RETURNED_KERNEL db "Returned from kernel. Error?", 0

; 填充引导扇区至512字节
times 510 - ($-$$) db 0
dw 0xaa55
