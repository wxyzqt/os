# 定义构建目录
BUILD_DIR = build

# 源文件查找
C_SOURCES = $(wildcard kernel/*.c drivers/*.c cpu/*.c libc/*.c)
HEADERS = $(wildcard kernel/*.h drivers/*.h cpu/*.h libc/*.h)

# 将源文件路径转换为构建目录下的目标文件路径
OBJ = $(addprefix $(BUILD_DIR)/, $(C_SOURCES:.c=.o) cpu/interrupt.o)

# 交叉编译器设置
CC = i686-elf-gcc
GDB = i686-elf-gdb
CFLAGS = -g -ffreestanding -Wall -Wextra -fno-exceptions -m32

# 主目标：操作系统镜像
$(BUILD_DIR)/os-image.bin: $(BUILD_DIR)/boot/bootsect.bin $(BUILD_DIR)/entry.bin
	@mkdir -p $(dir $@)
	cat $^ > $@

# 内核入口二进制文件
$(BUILD_DIR)/entry.bin: $(BUILD_DIR)/boot/kernel_entry.o $(OBJ)
	@mkdir -p $(dir $@)
	i686-elf-ld -o $@ -Ttext 0x1000 $^ --oformat binary

# 调试用的带符号文件
$(BUILD_DIR)/entry.elf: $(BUILD_DIR)/boot/kernel_entry.o $(OBJ)
	@mkdir -p $(dir $@)
	i686-elf-ld -o $@ -Ttext 0x1000 $^ 

# 伪目标
.PHONY: qemu bochs debug clean

# QEMU 模拟器运行
qemu: $(BUILD_DIR)/os-image.bin
	qemu-system-i386 -fda $<

# Bochs 模拟器运行
bochs: $(BUILD_DIR)/os-image.bin
	bochs -f bochsrc

# 调试目标
debug: $(BUILD_DIR)/os-image.bin $(BUILD_DIR)/entry.elf
	qemu-system-i386 -s -fda $< -d guest_errors,int &
	${GDB} -ex "target remote localhost:1234" -ex "symbol-file $(BUILD_DIR)/entry.elf"

# C 源文件编译规则
$(BUILD_DIR)/%.o: %.c ${HEADERS}
	@mkdir -p $(dir $@)
	${CC} ${CFLAGS} -c $< -o $@

# 汇编文件编译规则（.o 文件）
$(BUILD_DIR)/%.o: %.asm
	@mkdir -p $(dir $@)
	nasm -f elf -o $@ $<

# 汇编文件编译规则（.bin 文件）
$(BUILD_DIR)/%.bin: %.asm
	@mkdir -p $(dir $@)
	nasm -f bin -o $@ $<

# 清理构建文件
clean:
	rm -rf $(BUILD_DIR)