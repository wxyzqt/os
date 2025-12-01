gdt_start: ;  GDT 从空的8字节开始
    
    dd 0x0 ; 4 byte
    dd 0x0 ; 4 byte

; GDT 代码段
; 前2字节：段长度低16位
; 接下来2字节：段基址低16位
; 第5字节：段基址的16-23位
; 第6字节：访问权限标志
; 第7字节：段长度高4位 + 其他标志位
; 第8字节：段基址高8位
gdt_code: 
    dw 0xffff    
    dw 0x0       
    db 0x0       
    db 10011010b 
    db 11001111b 
    db 0x0       

; GDT 数据段，与代码段类似，标志位不同
gdt_data:
    dw 0xffff
    dw 0x0
    db 0x0
    db 10010010b
    db 11001111b
    db 0x0

gdt_end:

; GDT 描述符，用于 lgdt 指令加载 GDT
gdt_descriptor:
    dw gdt_end - gdt_start - 1 ; 16位的GDT大小限制值（总字节数减1）
    dd gdt_start ; 32位的GDT起始物理地址

; 常量定义
CODE_SEG equ gdt_code - gdt_start   ;代码段在GDT中的选择子偏移
DATA_SEG equ gdt_data - gdt_start   ;数据段在GDT中的选择子偏移
