# 终端命令记录

## 编译

```nasm
nasm -f bin boot.asm -o boot.bin
```

## 模拟

```bash
# qemu
qemu-system-i386 -fda boot.bin

#bochs
bochs -f bochsrc
```
