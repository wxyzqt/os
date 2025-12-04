# 终端命令记录

## 编译

```sh
# boot第一阶段，主引导程序，限制512字节
nasm -f bin boot.asm -o boot.bin

# boot第二阶段，引导程序，位于软盘其他扇区
nasm -f bin stage2.asm -o WT.SYS

#生成空白软盘,dd是git bash内存复制命令
dd if=/dev/zero of=floppy.img bs=512 count=2880

# 主引导程序内存复制到扇区0
dd if=boot.bin of=floppy.img bs=512 count=1 seek=0 conv=notrunc

# 将第二阶段引导程序复制到软盘，mcopy复制文件时会同时在FAT12的根目录区创建目录项
# mcopy 是 mtools 工具包的命令
mcopy -i floppy.img WT.SYS ::
```

## 模拟

```bash
# qemu
qemu-system-i386 -fda floppy.img

#bochs
bochs -f bochsrc
```
