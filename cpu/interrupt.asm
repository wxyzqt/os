; isr.c中申明的isr0到isr31和irq0到irq15的汇编实现
[extern isr_handler]
[extern irq_handler]

;ISR 公用代码段
isr_common_stub:
    ; 保存cpu状态
	pusha ; edi,esi,ebp,esp,ebx,edx,ecx,eax 压栈
	mov ax, ds ; ds寄存器保存到eax低16位
	push eax ; 保存数据段寄存器
	mov ax, 0x10  ; 0x10 是内核数据段在全局描述符表（GDT）中的索引值
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	push esp ; registers_t *r
    ; 调用c中的isr_handler函数
    cld ; 遵循系统 V 应用程序接口规范的 C 代码要求在函数入口处明确设置 DF 位
	call isr_handler
	
    ;恢复cpu状态
	pop eax  ; pop esp 到 eax，并丢弃
    pop eax  ; pop eax 恢复ds
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	popa
	add esp, 8 ; 清理推送的错误代码和推送的中断服务程序编号
	iret ; 一次性返回5个数据: CS, EIP, EFLAGS, SS, and ESP

; 常见的中断请求代码，与中断服务程序代码相同
; 差异部分加了注释
irq_common_stub:
    pusha 
    mov ax, ds
    push eax
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    push esp
    cld
    call irq_handler ; 调用irq_handler
    pop ebx  ; 使用了ebx
    pop ebx  ;
    mov ds, bx
    mov es, bx
    mov fs, bx
    mov gs, bx
    popa
    add esp, 8
    iret 
	
; 无法得知是哪个中断请求触发了此次操作
; 所以对于每一次中断需要设置一个不同的处理程序
; 有些中断会将错误代码压入栈中，而其他中断则不会这样做
; 我们将设置一个虚拟的错误代码来表示那些没有错误代码的中断

; 申明为全局
global isr0
global isr1
global isr2
global isr3
global isr4
global isr5
global isr6
global isr7
global isr8
global isr9
global isr10
global isr11
global isr12
global isr13
global isr14
global isr15
global isr16
global isr17
global isr18
global isr19
global isr20
global isr21
global isr22
global isr23
global isr24
global isr25
global isr26
global isr27
global isr28
global isr29
global isr30
global isr31
; IRQs
global irq0
global irq1
global irq2
global irq3
global irq4
global irq5
global irq6
global irq7
global irq8
global irq9
global irq10
global irq11
global irq12
global irq13
global irq14
global irq15

; 0: Divide By Zero Exception，除以零异常
isr0:
    push byte 0
    push byte 0
    jmp isr_common_stub

; 1: Debug Exception，调试异常
isr1:
    push byte 0
    push byte 1
    jmp isr_common_stub

; 2: Non Maskable Interrupt Exception，不可屏蔽中断异常
isr2:
    push byte 0
    push byte 2
    jmp isr_common_stub

; 3: Int 3 Exception，中断 3 异常
isr3:
    push byte 0
    push byte 3
    jmp isr_common_stub

; 4: INTO Exception，INTO 异常情况
; into指令用于在EFLAGS寄存器溢出标志（OF）被设置时触发一个中断
isr4:
    push byte 0
    push byte 4
    jmp isr_common_stub

; 5: Out of Bounds Exception，越界异常
isr5:
    push byte 0
    push byte 5
    jmp isr_common_stub

; 6: Invalid Opcode Exception，无效指令异常
isr6:
    push byte 0
    push byte 6
    jmp isr_common_stub

; 7: Coprocessor Not Available Exception，协处理器不可用异常
isr7:
    push byte 0
    push byte 7
    jmp isr_common_stub

; 8: Double Fault Exception (With Error Code!)，双重错误异常（附带错误代码！）
isr8:
    push byte 8
    jmp isr_common_stub

; 9: Coprocessor Segment Overrun Exception，协处理器段溢出异常
isr9:
    push byte 0
    push byte 9
    jmp isr_common_stub

; 10: Bad TSS Exception (With Error Code!)，严重 TSS 异常（附带错误代码！）
isr10:
    push byte 10
    jmp isr_common_stub

; 11: Segment Not Present Exception (With Error Code!)，段不存在异常（附带错误代码！）
isr11:
    push byte 11
    jmp isr_common_stub

; 12: Stack Fault Exception (With Error Code!)，栈错误异常（附带错误代码！）
isr12:
    push byte 12
    jmp isr_common_stub

; 13: General Protection Fault Exception (With Error Code!)，通用保护故障异常（附带错误代码！）
isr13:
    push byte 13
    jmp isr_common_stub

; 14: Page Fault Exception (With Error Code!)，页面故障异常（附错误代码！）
isr14:
    push byte 14
    jmp isr_common_stub

; 15: Reserved Exception，保留例外情况
isr15:
    push byte 0
    push byte 15
    jmp isr_common_stub

; 16: Floating Point Exception，浮点异常
isr16:
    push byte 0
    push byte 16
    jmp isr_common_stub

; 17: Alignment Check Exception，对齐检查异常
isr17:
    push byte 0
    push byte 17
    jmp isr_common_stub

; 18: Machine Check Exception，机器检查异常
isr18:
    push byte 0
    push byte 18
    jmp isr_common_stub

; 19: Reserved，保留
isr19:
    push byte 0
    push byte 19
    jmp isr_common_stub

; 20: Reserved
isr20:
    push byte 0
    push byte 20
    jmp isr_common_stub

; 21: Reserved
isr21:
    push byte 0
    push byte 21
    jmp isr_common_stub

; 22: Reserved
isr22:
    push byte 0
    push byte 22
    jmp isr_common_stub

; 23: Reserved
isr23:
    push byte 0
    push byte 23
    jmp isr_common_stub

; 24: Reserved
isr24:
    push byte 0
    push byte 24
    jmp isr_common_stub

; 25: Reserved
isr25:
    push byte 0
    push byte 25
    jmp isr_common_stub

; 26: Reserved
isr26:
    push byte 0
    push byte 26
    jmp isr_common_stub

; 27: Reserved
isr27:
    push byte 0
    push byte 27
    jmp isr_common_stub

; 28: Reserved
isr28:
    push byte 0
    push byte 28
    jmp isr_common_stub

; 29: Reserved
isr29:
    push byte 0
    push byte 29
    jmp isr_common_stub

; 30: Reserved
isr30:
    push byte 0
    push byte 30
    jmp isr_common_stub

; 31: Reserved
isr31:
    push byte 0
    push byte 31
    jmp isr_common_stub

; IRQ handlers
irq0:
	push byte 0
	push byte 32
	jmp irq_common_stub

irq1:
	push byte 1
	push byte 33
	jmp irq_common_stub

irq2:
	push byte 2
	push byte 34
	jmp irq_common_stub

irq3:
	push byte 3
	push byte 35
	jmp irq_common_stub

irq4:
	push byte 4
	push byte 36
	jmp irq_common_stub

irq5:
	push byte 5
	push byte 37
	jmp irq_common_stub

irq6:
	push byte 6
	push byte 38
	jmp irq_common_stub

irq7:
	push byte 7
	push byte 39
	jmp irq_common_stub

irq8:
	push byte 8
	push byte 40
	jmp irq_common_stub

irq9:
	push byte 9
	push byte 41
	jmp irq_common_stub

irq10:
	push byte 10
	push byte 42
	jmp irq_common_stub

irq11:
	push byte 11
	push byte 43
	jmp irq_common_stub

irq12:
	push byte 12
	push byte 44
	jmp irq_common_stub

irq13:
	push byte 13
	push byte 45
	jmp irq_common_stub

irq14:
	push byte 14
	push byte 46
	jmp irq_common_stub

irq15:
	push byte 15
	push byte 47
	jmp irq_common_stub

