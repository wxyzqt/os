
bits 16             ; 16位实模式
org 0x7C00          ; BIOS加载引导扇区到0x7C00

start:
    ; 设置段寄存器
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    ; 清屏
    mov ax, 0x0003
    int 0x10

    ; 显示消息
    mov si, msg
    call print_string

    ; 无限循环
    jmp $

print_string:
    ; 打印以0结尾的字符串
    mov ah, 0x0E
.loop:
    lodsb
    test al, al
    jz .done
    int 0x10
    jmp .loop
.done:
    ret

msg db 'Hello, OS World!', 0

; 引导扇区填充
times 510-($-$$) db 0
dw 0xAA55         ; 引导扇区标识