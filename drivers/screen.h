#ifndef SCREEN_H
#define SCREEN_H

// VGA文本模式显示，配置常量
#define VIDEO_ADDRESS 0xb8000
#define MAX_ROWS 25
#define MAX_COLS 80
#define WHITE_ON_BLACK 0x0f
#define RED_ON_WHITE 0xf4

// 屏幕 i/o 端口
// 控制寄存器索引端口（选择要操作的内部寄存器）
#define REG_SCREEN_CTRL 0x3d4
// 控制寄存器数据端口（读写选定寄存器的数据）
#define REG_SCREEN_DATA 0x3d5

// 公开的 kernel API
void clear_screen();
void kprint_at(char *message, int col, int row);
void kprint(char *message);
void kprint_backspace();

#endif
