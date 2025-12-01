#include "screen.h"
#include "../cpu/ports.h"
#include "../libc/mem.h"
#include <stdint.h>

/* 私有函数 */
int get_cursor_offset();
void set_cursor_offset(int offset);
int print_char(char c, int col, int row, char attr);
int get_offset(int col, int row);
int get_offset_row(int offset);
int get_offset_col(int offset);

// 内核公开函数

// 在指定位置打印一条消息
// 如果 col 和 row 值为负数，将使用当前偏移量
void kprint_at(char *message, int col, int row)
{
    // 如果列号或行号为负数，则设置光标位置
    int offset;
    if (col >= 0 && row >= 0)
        offset = get_offset(col, row);
    else
    {
        offset = get_cursor_offset();
        row = get_offset_row(offset);
        col = get_offset_col(offset);
    }

    // 遍历消息并打印出来
    int i = 0;
    while (message[i] != 0)
    {
        offset = print_char(message[i++], col, row, WHITE_ON_BLACK);
        // 计算下一次迭代的行/列位置
        row = get_offset_row(offset);
        col = get_offset_col(offset);
    }
}

void kprint(char *message)
{
    kprint_at(message, -1, -1);
}

void kprint_backspace()
{
    int offset = get_cursor_offset() - 2;
    int row = get_offset_row(offset);
    int col = get_offset_col(offset);
    print_char(0x08, col, row, WHITE_ON_BLACK);
}

// 内核私有函数

// 内核的最核心打印功能，可直接访问视频内存
// 若"col"和"row"均为负值，则将在当前光标位置进行打印
// 若"attr"为零，则默认“白字黑背景”的显示效果
// 返回下一个字符的偏移量
// 将视频光标设置到返回的偏移量处
int print_char(char c, int col, int row, char attr)
{
    uint8_t *vidmem = (uint8_t *)VIDEO_ADDRESS;
    if (!attr)
        attr = WHITE_ON_BLACK;

    // 错误控制：若坐标不正确，则打印出一个红色的“E”字符
    if (col >= MAX_COLS || row >= MAX_ROWS)
    {
        vidmem[2 * (MAX_COLS) * (MAX_ROWS)-2] = 'E';
        vidmem[2 * (MAX_COLS) * (MAX_ROWS)-1] = RED_ON_WHITE;
        return get_offset(col, row);
    }

    int offset;
    if (col >= 0 && row >= 0)
        offset = get_offset(col, row);
    else
        offset = get_cursor_offset();

    if (c == '\n')
    {
        row = get_offset_row(offset);
        offset = get_offset(0, row + 1);
    }
    else if (c == 0x08)
    { // 处理退格键
        vidmem[offset] = ' ';
        vidmem[offset + 1] = attr;
    }
    else
    {
        vidmem[offset] = c;
        vidmem[offset + 1] = attr;
        offset += 2;
    }

    // 检查偏移量是否超出屏幕尺寸，并进行滚动操作
    if (offset >= MAX_ROWS * MAX_COLS * 2)
    {
        int i;
        for (i = 1; i < MAX_ROWS; i++)
        {
            memory_copy((uint8_t *)(get_offset(0, i) + VIDEO_ADDRESS),
                        (uint8_t *)(get_offset(0, i - 1) + VIDEO_ADDRESS),
                        MAX_COLS * 2);
        }

        // 清除最后一行
        char *last_line = (char *)(get_offset(0, MAX_ROWS - 1) + (uint8_t *)VIDEO_ADDRESS);
        for (i = 0; i < MAX_COLS * 2; i++)
            last_line[i] = 0;

        offset -= 2 * MAX_COLS;
    }

    set_cursor_offset(offset);
    return offset;
}

int get_cursor_offset()
{
    // 利用 VGA 接口获取当前光标的位置
    // 请求获取光标偏移量的高位字节（数据 14）
    // 请求低字节（数据 15）
    port_byte_out(REG_SCREEN_CTRL, 14);
    int offset = port_byte_in(REG_SCREEN_DATA) << 8; // 高位字节左移 8 位
    port_byte_out(REG_SCREEN_CTRL, 15);
    offset += port_byte_in(REG_SCREEN_DATA);
    return offset * 2; // 位置 * 字符单元格的大小
}

void set_cursor_offset(int offset)
{
    // 与get_cursor_offset类似，但这里不是读取数据，而是进行数据写入操作
    offset /= 2;
    port_byte_out(REG_SCREEN_CTRL, 14);
    port_byte_out(REG_SCREEN_DATA, (uint8_t)(offset >> 8));
    port_byte_out(REG_SCREEN_CTRL, 15);
    port_byte_out(REG_SCREEN_DATA, (uint8_t)(offset & 0xff));
}

void clear_screen()
{
    int screen_size = MAX_COLS * MAX_ROWS;
    int i;
    uint8_t *screen = (uint8_t *)VIDEO_ADDRESS;

    for (i = 0; i < screen_size; i++)
    {
        screen[i * 2] = ' ';
        screen[i * 2 + 1] = WHITE_ON_BLACK;
    }
    set_cursor_offset(get_offset(0, 0));
}

int get_offset(int col, int row) { return 2 * (row * MAX_COLS + col); }
int get_offset_row(int offset) { return offset / (2 * MAX_COLS); }
int get_offset_col(int offset) { return (offset - (get_offset_row(offset) * 2 * MAX_COLS)) / 2; }
