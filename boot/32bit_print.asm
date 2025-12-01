[bits 32] ; 保护模式

; 定义常量
VIDEO_MEMORY equ 0xb8000
WHITE_OB_BLACK equ 0x0f ; 字符属性：白色字符，黑色背景

print_string_pm:
    pusha
    mov edx, VIDEO_MEMORY

.print_string_pm_loop:
    mov al, [ebx] ; ebx是内存地址，[ebx]是取值，取出一个字符
    mov ah, WHITE_OB_BLACK

    cmp al, 0 ; 检查是否为结束符
    je .print_string_pm_done

    mov [edx], ax ; 存储字符和属性到视频内存，ax = ah + al
    add ebx, 1 ; 下一个字符
    add edx, 2 ; 下一个视频内存位置（每个字符占2字节）

    jmp .print_string_pm_loop

.print_string_pm_done:
    popa
    ret
