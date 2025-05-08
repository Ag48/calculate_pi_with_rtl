from decimal import Decimal, getcontext

# 計算精度を100桁に設定 (有効桁数)
getcontext().prec = 100

# Decimalオブジェクトを作成
a = Decimal('0.1')
b = Decimal('0.2')
c = Decimal('1')
d = Decimal('11')

# 計算
div_val = c / d

# print(f"a + b = {sum_val}")
print(f"{div_val}")
