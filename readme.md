# wt os

windows 下学习操作系统原理

不需要太复杂的虚拟机，不需要专业的汇编或 c 的 IDE，不需要准备硬件设备。

## 环境

IDE，直接使用 vscode

nasm 汇编器，下载即可

bochs 模拟器，官网直接下载最新稳定版本

mtools 主要使用 mcopy，复制文件到软盘

git bash 用于执行命令

## 命令行

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

#bochs启动模拟
bochs -f bochsrc
```
