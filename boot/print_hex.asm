; 功能：将16位十六进制数值转换为可打印ASCII字符串并输出
; 16位十六进制数值指的是一个用16进制表示的、长度为16位二进制（即4位十六进制）的数字,例如0x1234
; 这里使用的通用寄存器AX、BX、CX、DX等都是16位寄存器

[bits 16]

print_hex:
    pusha

    mov cx, 0 ; 循环计数器初始化为0

hex_loop:
    cmp cx, 4 ; 循环4次，转换4个十六进制字符
    je end
    

    ; 将dx指向的16进制数值最后一位转换为 ASCII 码
    ; 数字0-9：加上0x30得到对应ASCII码
    ; 字母A-F：加上0x37得到对应ASCII码
    mov ax, dx ; ax累加器，用于运算
    and ax, 0x000f ; 通过掩码0x000f从0x1234得到0x0004
    add al, 0x30 ; 增加 0x30 得到对应的 ASCII 码
    cmp al, 0x39 ; 与0x39比较，判断是否大于9
    jle .step2 ; 小于或等于9，表示数字，直接跳转到step2
    add al, 7 ; 大于9，则加上7，得到对应的字母A-F的ASCII码

.step2:
    ; 确定字符串的正确位置，以便放置 ASCII 字符
    mov bx, HEX_OUT + 5 ; 指向字符串末尾的空位置
    sub bx, cx  ; 减去字符索引，找到正确的位置
    mov [bx], al ; 将al中的 ASCII 字符复制到由“bx”所指向的位置上。
    ror dx, 4 ; 循环右移4次， 0x1234 -> 0x4123 -> 0x3412 -> 0x2341 -> 0x1234

   
    inc cx   ; 索引自增，继续循环
    jmp hex_loop

end:
    
    mov bx, HEX_OUT ; print函数需要字符串的地址放在bx寄存器中
    call print

    popa
    ret

HEX_OUT:
    db '0x0000',0 ;这里其实是7个字节，字符串长度为6（包括0x前缀和4个0），第7个字节是字符串结束符0
