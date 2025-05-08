#include <iostream>
#include <vector>   // std::vector を使用するためにインクルード
#include <numeric>  // std::iota (もし使うなら)
#include <algorithm> // std::for_each (もし使うなら)

int main() {
    int numerator = 1;       // 分子
    int denominator = 11;      // 分母
    int num_digits = 100;    // 計算する小数部の桁数
    int quotient;            // 商 (整数部および小数部の各桁)
    int remainder;           // 余り

    std::vector<int> decimal_digits; // 小数部の各桁を格納するベクター
    // 効率のために、あらかじめ領域を確保しておくことも可能です
    // decimal_digits.reserve(num_digits);

    // 整数部分の計算 (これは配列には格納せず、直接出力します)
    quotient = numerator / denominator;
    std::cout << quotient;
    std::cout << ".";

    // 小数部分の計算と配列への格納
    remainder = numerator % denominator; // 最初の余り

    for (int i = 0; i < num_digits; ++i) {
        remainder *= 10; // 余りを10倍して次の桁へ
        quotient = remainder / denominator;
        decimal_digits.push_back(quotient); // 計算した桁をベクターに追加
        remainder %= denominator; // 新しい余り

        // もし余りが0になったら、それ以上計算する必要はない
        if (remainder == 0) {
            break;
        }
    }

    // 配列 (ベクター) の内容を出力
    for (int digit : decimal_digits) { // C++11以降の範囲ベースforループ
        std::cout << digit;
    }
    // もしくは、従来のforループ:
    // for (size_t i = 0; i < decimal_digits.size(); ++i) {
    //     std::cout << decimal_digits[i];
    // }
    std::cout << std::endl;

    return 0;
}
