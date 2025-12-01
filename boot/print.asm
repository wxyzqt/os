; 打印字符的原理:比较字符，不为结束符0则打印字符，指针后移，继续比较打印
; while (string[i] != 0) { print string[i]; i++ }

print:
    pusha    ; 保存所有通用寄存器到栈

start:
    mov al, [bx] ; DS:BX，默认段为数据段DS，从bx指向的内存地址取一个字节到al
    cmp al, 0 
    je .done

    ; 借用BIOS中断打印字符
    mov ah, 0x0e ;对应 BIOS 0x10 中断的 "在Teletype模式下显示字符" 功能
    int 0x10 ; BIOS中断，打印al中的字符

    
    inc bx ; 递增指针，指向下一个字符
    jmp start

.done:
    popa
    ret   

; 打印换行符newline
print_nl:
    pusha    ; 保存所有通用寄存器到栈
    
    mov ah, 0x0e    ; BIOS teletype输出功能
    mov al, 0x0a ; 换行符(LF)
    int 0x10 ; 调用BIOS视频中断
    mov al, 0x0d  ; 回车符(CR)  
    int 0x10    ; 再次调用中断输出回车符
    
    popa  ; 从栈恢复所有通用寄存器
    ret ; 返回调用处
