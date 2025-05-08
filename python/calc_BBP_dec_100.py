from decimal import Decimal, getcontext, ROUND_DOWN

def calculate_pi_bbp_decimal(num_decimal_places):
    """
    BBPアルゴリズムとdecimalパッケージを使用して円周率を計算する。

    Args:
        num_decimal_places (int): 計算したい円周率の小数点以下の桁数。

    Returns:
        Decimal: 計算された円周率の値。
    """
    if not isinstance(num_decimal_places, int) or num_decimal_places < 0:
        raise ValueError("小数点以下の桁数は正の整数である必要があります。")

    # decimalコンテキストの精度を設定
    # 整数部1桁 + 目的の小数部の桁数 + 計算誤差や丸め誤差を考慮した余裕分 (例: 10桁)
    # BBPアルゴリズムの収束は速いため、この程度の余裕で十分です。
    precision = 1 + num_decimal_places + 10
    getcontext().prec = precision

    # BBP級数の計算項数
    # 必要な10進数の桁数よりも少し多めの項数を計算します。
    # 各項は1/16^kで減少するため、num_decimal_placesに近い項数で十分な精度が得られます。
    # 安全のため、 (目的の桁数 / log10(16)) + α 程度。
    # log10(16) は約1.2なので、num_decimal_places項程度でも良いが、少し余裕を持たせる。
    # ここでは num_decimal_places + 5 項とします。
    num_terms = num_decimal_places + 5 # または precision と同程度でも可

    pi_sum = Decimal(0)

    for k in range(num_terms):
        k_dec = Decimal(k) # ループ変数kをDecimal型に変換

        term1 = Decimal(4) / (Decimal(8) * k_dec + Decimal(1))
        term2 = Decimal(2) / (Decimal(8) * k_dec + Decimal(4))
        term3 = Decimal(1) / (Decimal(8) * k_dec + Decimal(5))
        term4 = Decimal(1) / (Decimal(8) * k_dec + Decimal(6))

        sum_in_parentheses = term1 - term2 - term3 - term4
        
        # 1 / (16^k) の計算
        # Decimal(16)**k_dec は非常に大きな数になる可能性があるため、
        # (1/16)**k_dec の方が数値的に安定する場合があるが、
        # getcontext().prec が適切に設定されていれば Decimal(16)**k_dec で問題ない。
        # もしくは、毎回16で割っていく方法も考えられる。
        # power_of_16 = Decimal(16)**k_dec
        # current_term = sum_in_parentheses / power_of_16
        
        # こちらの方が16^kが巨大になるのを避けられる
        if k == 0:
            inv_power_of_16 = Decimal(1)
        else:
            # 前回の値を利用して効率的に計算 (inv_power_of_16_prev / 16)
            # ループの最初に inv_power_of_16 = Decimal(1) とし、
            # ループ末尾で inv_power_of_16 /= Decimal(16) とする方がシンプル
            inv_power_of_16 = Decimal(1) / (Decimal(16)**k_dec)


        current_term = inv_power_of_16 * sum_in_parentheses
        pi_sum += current_term

    # 計算結果を指定された小数点以下の桁数に丸める (表示用)
    # '1e-N' は 10^(-N) を意味し、小数点以下N桁目を指定
    quantizer = Decimal('1e-' + str(num_decimal_places))
    # pi_display = pi_sum.quantize(quantizer, rounding=ROUND_DOWN) # 切り捨ての場合
    pi_display = pi_sum.quantize(quantizer) # デフォルトの丸め (ROUND_HALF_UP)
    
    return pi_display

if __name__ == "__main__":
    target_digits = 100
    
    print(f"BBPアルゴリズムと decimal パッケージを使用して円周率を計算します。")
    print(f"目標の小数点以下の桁数: {target_digits}桁")
    
    # 計算前のdecimalコンテキストの精度を表示 (参考)
    # print(f"初期のgetcontext().prec: {getcontext().prec}")

    pi_calculated = calculate_pi_bbp_decimal(target_digits)
    
    print(f"\n計算後のdecimalコンテキストの精度 (getcontext().prec): {getcontext().prec}")
    print(f"円周率 (小数点以下{target_digits}桁):")
    print(pi_calculated)

    # 既知の円周率と比較 (最初の数桁)
    # (Python 3.11以降では math.pi が高精度な場合があるが、ここではdecimalの結果を主とする)
    # import math
    # print(f"\n参考: math.pi = {math.pi}")
    
    # より多くの桁数での確認 (例: Python標準ライブラリで可能な限りの桁数)
    getcontext().prec = 105 # 例
    known_pi_long = Decimal("3.1415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170679")
    print(f"\n既知の円周率 (100桁以上、参考用):\n{known_pi_long}")
