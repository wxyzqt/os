#include "string.h"
#include <stdint.h>

// 以下函数采用K&R 的实现方式，便于理解
// 现代C库中通常使用ANSIC的实现方式

// 整数转字符串
void int_to_ascii(int n, char str[])
{
    int i, sign;
    if ((sign = n) < 0)
    {
        n = -n;
    }

    i = 0;
    do
    {
        str[i++] = n % 10 + '0';
    } while ((n /= 10) > 0);

    if (sign < 0)
    {
        str[i++] = '-';
    }
    str[i] = '\0';

    reverse(str);
}

// 16进制转字符串
void hex_to_ascii(int n, char str[])
{
    append(str, '0');
    append(str, 'x');
    char zeros = 0;

    int32_t tmp;
    int i;
    for (i = 28; i >= 0; i -= 4)
    {
        tmp = (n >> i) & 0xF;
        if (tmp == 0 && zeros == 0 && i > 0)
        {
            continue;
        }
        zeros = 1;
        if (tmp >= 0xA)
        {
            append(str, tmp - 0xA + 'a');
        }
        else
        {
            append(str, tmp + '0');
        }
    }
}

// 字符串反转
void reverse(char s[])
{
    int c, i, j;
    for (i = 0, j = strlen(s) - 1; i < j; i++, j--)
    {
        c = s[i];
        s[i] = s[j];
        s[j] = c;
    }
}

// 计算字符串长度
int strlen(char s[])
{
    int i = 0;
    while (s[i] != '\0')
        ++i;
    return i;
}

// 字符串追加字符
void append(char s[], char n)
{
    int len = strlen(s);
    s[len] = n;
    s[len + 1] = '\0';
}

// 删除字符串最后一个字符
void backspace(char s[])
{
    int len = strlen(s);
    s[len - 1] = '\0';
}

// 字符串比较
int strcmp(char s1[], char s2[])
{
    int i;
    for (i = 0; s1[i] == s2[i]; i++)
    {
        if (s1[i] == '\0')
            return 0;
    }
    return s1[i] - s2[i];
}
