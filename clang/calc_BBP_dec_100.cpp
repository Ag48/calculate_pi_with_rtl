#include <iostream>
#include <vector>
#include <string>
#include <cmath> // For pow, fmod, floor
#include <iomanip> // For std::fixed, std::setprecision (for printing double, not for calculation)
#include <numeric> // For std::accumulate (optional)

// Function to compute (base^exp) % mod
// Handles large exponents efficiently using modular exponentiation.
long long power_mod(long long base, long long exp, long long mod) {
    long long res = 1;
    base %= mod;
    while (exp > 0) {
        if (exp % 2 == 1) res = (static_cast<unsigned __int128>(res) * base) % mod;
        base = (static_cast<unsigned __int128>(base) * base) % mod;
        exp /= 2;
    }
    return res;
}

// Function to compute one term of the BBP formula sum for a given digit 'd' and 'j'
// S_j(d) = sum_{k=0 to d} (16^(d-k) mod (8k+j)) / (8k+j) +
//          sum_{k=d+1 to d+C} 16^(d-k) / (8k+j)
double bbp_series_term(int d, int j) {
    double sum = 0.0;

    // First part of the sum: k from 0 to d
    // This part uses integer arithmetic for precision of the numerator
    for (int k = 0; k <= d; ++k) {
        long long denominator = 8LL * k + j;
        long long num_mod = power_mod(16, d - k, denominator);
        sum += static_cast<double>(num_mod) / denominator;
        // Keep sum manageable by taking fractional part, though not strictly necessary
        // until the very end if double precision is sufficient.
        // For calculating a single hex digit, this sum can grow.
        // The typical BBP digit extraction takes the fractional part of the *final* sum.
    }

    // Second part of the sum: k from d+1 to d + C (e.g., C=15 for sufficient precision)
    // This part uses floating-point arithmetic.
    // The terms decrease rapidly.
    // C needs to be large enough so that 16^(-C) is small enough.
    // For one hex digit, 10-15 terms are usually sufficient.
    for (int k = d + 1; k <= d + 20; ++k) { // Increased terms for safety
        sum += pow(16.0, static_cast<double>(d - k)) / (8.0 * k + j);
    }
    return sum;
}

// Function to get the n-th hexadecimal digit of pi (0-indexed fractional part)
int get_nth_hex_digit_pi(int n) {
    double s1 = bbp_series_term(n, 1);
    double s4 = bbp_series_term(n, 4);
    double s5 = bbp_series_term(n, 5);
    double s6 = bbp_series_term(n, 6);

    double pi_val_at_n = 4.0 * s1 - 2.0 * s4 - s5 - s6;

    // Take the fractional part
    pi_val_at_n = pi_val_at_n - floor(pi_val_at_n);
    if (pi_val_at_n < 0) {
        pi_val_at_n += 1.0;
    }

    // Multiply by 16 and take the integer part to get the hex digit
    int hex_digit = static_cast<int>(floor(pi_val_at_n * 16.0));
    return hex_digit;
}

int main() {
    std::cout << "Calculating hexadecimal digits of Pi using BBP algorithm..." << std::endl;

    // We need about 84 hex digits for 100 decimal digits. Let's calculate 85.
    int num_hex_digits_to_calculate = 85;
    std::string hex_pi_fractional_part = "";

    for (int i = 0; i < num_hex_digits_to_calculate; ++i) {
        int digit = get_nth_hex_digit_pi(i);
        if (digit < 10) {
            hex_pi_fractional_part += static_cast<char>('0' + digit);
        } else {
            hex_pi_fractional_part += static_cast<char>('A' + (digit - 10));
        }
        if ((i + 1) % 10 == 0 || i == num_hex_digits_to_calculate - 1) {
             std::cout << "Calculated " << (i + 1) << " hex digits." << std::endl;
        }
    }

    std::cout << "\nPi (hexadecimal, fractional part): 0." << hex_pi_fractional_part << std::endl;
    std::cout << "3." << hex_pi_fractional_part << std::endl;

    return 0;
}
