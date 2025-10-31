;********************
; operating systems
; use git bash

;nasm生成bin文件
;nasm -f bin boot.asm -o boot.bin

;生成空白软盘
;dd if=/dev/zero of=floppy.img bs=512 count=2880

;写入引导扇区
;dd if=boot.bin of=floppy.img bs=512 count=1 conv=notrunc

;bochs启动模拟
;bochs -f bochsrc
;********************

bits 16     ;real mode

org 0x7c00  ;load bios at there

start: jmp loader

;********************
;OEM parameter block
;bpb:BIOS parameter block
;********************

bpbOEM        db	"wtOS----"	;OEM name 8 bytes

bpbBytesPerSector    dw	512             ;bytes per sector
bpbSectorsPerCluster db	1               ;sectors per cluster
bpbReserverdSectors  dw	1               ;reserved sectors
bpbNumberOfFATs      db	2               ;number of FATs
bpbRootEntries       dw	224             ;number of root directory entries
bpbTotalSectors      dw	2880            ;total sectors
bpbMedia             db	0xf0            ;media descriptor
bpbSectorsPerFAT     dw	9               ;sectors per FAT
bpbSectorsPerTrack   dw	18              ;sectors per track
bpbHeadsPerCylinder  dw	2               ;number of heads
bpbTotalSectorsBig   dd	0               ;total sectors if > 65535
bsDriveNumber        db	0               ;drive number
bsUnused             db	0               ;reserved
bsExtendedBootSignature db	0x29    ;extended boot signature
bsSerialNumber       dd	0xa0a1a2a3      ;volume serial number
bsVolumeLabel        db	"wtOS Volume"   ;volume label 11 bytes
bsFileSystem         db	"FAT12   "      ;file system type 8 bytes

msg	db	"*****Welcome to wt operating system*****", 0		; the string to print

;********************
;print string
; DS=>SI: 0terminated string
;********************

print_string:
        lodsb              ; load next byte from string from SI to AL
        or al, al           ; Does AL=0?
        jz  print_done      ; null terminator found*bail out
        mov ah, 0x0e         ; Nope*Print the character
        int 0x10
        jmp print_string    ;Repeat until null terminator found

print_done:
        ret

;***************
;bootloader entry point
;***************
loader:
        xor ax, ax          ;initialize data segment
        mov ds, ax          ; data segment = 0
        mov es, ax          ; extra segment = 0

        mov si, msg
        call print_string

        xor ax, ax
        int 0x12             ;get memory size in KB

        cli                  ; Clear all Interrupts
        hlt                  ; halt the system   


times 510 - ($-$$) db 0      ;512 bytes

db 0x55, 0xaa                ;boot signiture