# wt os

windows 下学习操作系统原理

## 环境

IDE，直接使用 vscode

nasm 汇编器

bochs 模拟器，官网直接下载最新稳定

git bash 用于执行命令

## 命令行

```sh
# boot第一阶段，主引导程序，限制512字节
nasm -f bin boot.asm -o boot.bin

# boot第二阶段，引导程序，位于软盘其他扇区
nasm -f bin boot2.asm -o WT.SYS

#生成空白软盘,dd是git bash内存复制命令
dd if=/dev/zero of=floppy.img bs=512 count=2880

# 主引导程序复制到扇区0
dd if=boot.bin of=floppy.img bs=512 count=1 seek=0 conv=notrunc

# 第二阶段引导程序复制到扇区19，FAT12从第19个扇区开始读取文件系统根目录区
dd if=WT.SYS of=floppy.img bs=512 seek=19 conv=notrunc

#bochs启动模拟
bochs -f bochsrc
```
