#include <stdio.h>

int main() {
    int numerator = 1;       // 分子
    int denominator = 11;      // 分母
    int num_digits = 100;    // 計算する小数部の桁数
    int quotient;            // 商
    int remainder;           // 余り

    // 整数部分の計算と出力
    quotient = numerator / denominator;
    printf("%d", quotient);
    printf(".");

    // 小数部分の計算
    remainder = numerator % denominator; // 最初の余り

    for (int i = 0; i < num_digits; i++) {
        remainder *= 10; // 余りを10倍して次の桁へ
        quotient = remainder / denominator;
        printf("%d", quotient);
        remainder %= denominator; // 新しい余り

        // もし余りが0になったら、それ以上計算する必要はない
        if (remainder == 0) {
            break;
        }
    }
    printf("\n");

    return 0;
}
