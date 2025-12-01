; 在实模式下，程序通过设置寄存器参数来指定要读取的磁盘位置，然后调用int 0x13来执行实际的读取操作
; 磁盘数据读取成功后，数据会被存入由 BX 寄存器指定的内存地址处,即KERNEL_OFFSET

disk_load:
    pusha   ; 压入顺序固定：DI → SI → BP → SP → BX → DX → CX → AX。

    push dx ; 再单独保存dx，因为我们要用dh和dl作为参数传递给int 0x13

    mov ah, 0x02 ; int 0x13是BIOS的磁盘中断服务, 功能号0x02是读取扇区
    mov al, dh   ; al，要读取的扇区数量，这里读取扇区数已经由dh给了al
    mov cl, 0x02  ; 0x01 是boot扇区, 0x02 是第一个可用扇区
    mov ch, 0x00 ; ch 柱面号取值范围0x0-0x3FF，即0-1023
    mov dh, 0x00 ; dh 盘面号(Head) 取值范围0x0-0xF，即0-15，这里dh重新设为0表示使用第0个盘面

    int 0x13      ; BIOS 中断调用以执行磁盘读取操作
    jc disk_error ; int 0x13 调用失败时，cpu会设置进位标志位（CF）为1，通过检查该标志位来检测错误

    pop dx
    cmp al, dh    ; BIOS 设置al为读取数量，与我们的请求数量dh进行比较
    jne sectors_error
    popa
    ret


disk_error:
    mov bx, DISK_ERROR
    call print
    call print_nl
    mov dh, ah ; ah = 错误代码, dl = 停止工作的驱动器号
    call print_hex ;之前写的打印十六进制数值的函数，dx用来存放要打印的数值
    jmp disk_loop

sectors_error:
    mov bx, SECTORS_ERROR
    call print

disk_loop:
    jmp $

DISK_ERROR: db "Disk read error", 0 ; 磁盘读取错误
SECTORS_ERROR: db "Incorrect number of sectors read", 0 ;读取扇区数量不正确
