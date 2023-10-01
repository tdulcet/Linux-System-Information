#!/bin/bash

# Teal Dulcet
# Outputs C/C++ datatype information
# wget https://raw.github.com/tdulcet/Linux-System-Information/master/typeinfo.sh -qO - | bash -s --
# ./typeinfo.sh

set -e

if [[ $# -ne 0 ]]; then
	echo "Usage: $0" >&2
	exit 1
fi

# Check if on Linux
if ! echo "$OSTYPE" | grep -iq "linux"; then
	echo "Error: This script must be run on Linux." >&2
	exit 1
fi

if ! command -v g++ >/dev/null; then
	echo "Error: This script requires the GNU C compiler" >&2
	echo "On Ubuntu and Debian run: 'sudo apt-get update -y' and 'sudo apt-get install build-essential -y'" >&2
	exit 1
fi

if [[ -n "$CXX" ]] && ! command -v "$CXX" >/dev/null; then
	echo "Error: $CXX is not installed." >&2
	exit 1
fi

CXX=${CXX:-g++}

cat << EOF > /tmp/types.cpp
#include <iostream>
#include <sstream>
#include <cmath>
#include <climits>
#include <cfloat>
#include <limits>
#include <cinttypes>
#include <iomanip>

using namespace std;

template <typename T>
string outputbase(const T number)
{
	const short base = 10;
	typename make_unsigned<T>::type anumber = number;
	anumber = number < 0 ? -anumber : anumber;

	string str;

	do
	{
		char digit = anumber % base;

		digit += '0';

		str = digit + str;

		anumber /= base;

	} while (anumber > 0);

	if (number < 0)
		str = '-' + str;

	return str;
}

template <typename T>
string floattostring(T arg)
{
	ostringstream strm;
	strm.precision(numeric_limits<T>::max_digits10);
	strm << arg;
	return strm.str();
}

template <typename T>
T maxint()
{
	T max_bit = scalbn(T(1), numeric_limits<T>::digits - 1);
	return max_bit + (max_bit - 1);
}

int main()
{
	constexpr int width = DECIMAL_DIG + 19;

	cout << "\nData Type\t\tSize (bytes)\n\n";
	cout << "bool:\t\t\t" << sizeof(bool) << '\n';
	cout << "char:\t\t\t" << sizeof(char) << '\n';
	cout << "signed char:\t\t" << sizeof(signed char) << '\n';
	cout << "unsigned char:\t\t" << sizeof(unsigned char) << '\n';
	cout << "wchar_t:\t\t" << sizeof(wchar_t) << '\n';
	// cout << "char8_t:\t\t" << sizeof(char8_t) << '\n';
	cout << "char16_t:\t\t" << sizeof(char16_t) << '\n';
	cout << "char32_t:\t\t" << sizeof(char32_t) << '\n';
	cout << "short:\t\t\t" << sizeof(short) << '\n';
	cout << "unsigned short:\t\t" << sizeof(unsigned short) << '\n';
	cout << "int:\t\t\t" << sizeof(int) << '\n';
	cout << "unsigned int:\t\t" << sizeof(unsigned int) << '\n';
	cout << "long:\t\t\t" << sizeof(long) << '\n';
	cout << "unsigned long:\t\t" << sizeof(unsigned long) << '\n';
	cout << "long long:\t\t" << sizeof(long long) << '\n';
	cout << "unsigned long long:\t" << sizeof(unsigned long long) << '\n';
	cout << "__int16_t:\t\t" << sizeof(__int16_t) << '\n';
	cout << "__uint16_t:\t\t" << sizeof(__uint16_t) << '\n';
	cout << "__int32_t:\t\t" << sizeof(__int32_t) << '\n';
	cout << "__uint32_t:\t\t" << sizeof(__uint32_t) << '\n';
	cout << "__int64_t:\t\t" << sizeof(__int64_t) << '\n';
	cout << "__uint64_t:\t\t" << sizeof(__uint64_t) << '\n';
#ifdef __SIZEOF_INT128__
	cout << "__int128_t:\t\t" << sizeof(__int128_t) << '\n';
	cout << "__uint128_t:\t\t" << sizeof(__uint128_t) << '\n';
	cout << "__int128:\t\t" << sizeof(__int128) << '\n';
	cout << "unsigned __int128:\t" << sizeof(unsigned __int128) << '\n';
#endif
	cout << "intmax_t:\t\t" << sizeof(intmax_t) << '\n';
	cout << "uintmax_t:\t\t" << sizeof(uintmax_t) << '\n';
	cout << "float:\t\t\t" << sizeof(float) << '\n';
	cout << "double:\t\t\t" << sizeof(double) << '\n';
	cout << "long double:\t\t" << sizeof(long double) << '\n';
	cout << "\n\n";
	
	cout << "Data Type\t\t" << left << setw(width) << "Minimum value" << setw(width) << "Maximum value" << "\n\n";
	cout << "char:\t\t\t" << right << setw(width) << CHAR_MIN << setw(width) << CHAR_MAX << '\n';
	cout << "signed char:\t\t" << right << setw(width) << SCHAR_MIN << setw(width) << SCHAR_MAX << '\n';
	cout << "unsigned char:\t\t" << right << setw(width) << 0 << setw(width) << UCHAR_MAX << '\n';
	cout << "wchar_t:\t\t" << setw(width) << WCHAR_MIN << setw(width) << WCHAR_MAX << '\n';
	// cout << "char8_t:\t\t" << setw(width) << 0 << setw(width) << UCHAR_MAX << '\n';
	cout << "char16_t:\t\t" << setw(width) << 0 << setw(width) << UINT_LEAST16_MAX << '\n';
	cout << "char32_t:\t\t" << setw(width) << 0 << setw(width) << UINT_LEAST32_MAX << '\n';
	cout << "short:\t\t\t" << setw(width) << SHRT_MIN << setw(width) << SHRT_MAX << '\n';
	cout << "unsigned short:\t\t" << setw(width) << 0 << setw(width) << USHRT_MAX << '\n';
	cout << "int:\t\t\t" << setw(width) << INT_MIN << setw(width) << INT_MAX << '\n';
	cout << "unsigned int:\t\t" << setw(width) << 0 << setw(width) << UINT_MAX << '\n';
	cout << "long:\t\t\t" << setw(width) << LONG_MIN << setw(width) << LONG_MAX << '\n';
	cout << "unsigned long:\t\t" << setw(width) << 0 << setw(width) << ULONG_MAX << '\n';
	cout << "long long:\t\t" << setw(width) << LLONG_MIN << setw(width) << LLONG_MAX << '\n';
	cout << "unsigned long long:\t" << setw(width) << 0 << setw(width) << ULLONG_MAX << '\n';
	cout << "__int16_t :\t\t" << setw(width) << numeric_limits<__int16_t>::min() << setw(width) << numeric_limits<__int16_t>::max() << '\n';
	cout << "__uint16_t :\t\t" << setw(width) << numeric_limits<__uint16_t>::min() << setw(width) << numeric_limits<__uint16_t>::max() << '\n';
	cout << "__int32_t :\t\t" << setw(width) << numeric_limits<__int32_t>::min() << setw(width) << numeric_limits<__int32_t>::max() << '\n';
	cout << "__uint32_t :\t\t" << setw(width) << numeric_limits<__uint32_t>::min() << setw(width) << numeric_limits<__uint32_t>::max() << '\n';
	cout << "__int64_t :\t\t" << setw(width) << numeric_limits<__int64_t>::min() << setw(width) << numeric_limits<__int64_t>::max() << '\n';
	cout << "__uint64_t :\t\t" << setw(width) << numeric_limits<__uint64_t>::min() << setw(width) << numeric_limits<__uint64_t>::max() << '\n';
#ifdef __SIZEOF_INT128__
	cout << "__int128_t:\t\t" << setw(width) << outputbase(numeric_limits<__int128_t>::min()) << setw(width) << outputbase(numeric_limits<__int128_t>::max()) << '\n';
	cout << "__uint128_t:\t\t" << setw(width) << outputbase(numeric_limits<__uint128_t>::min()) << setw(width) << outputbase(numeric_limits<__uint128_t>::max()) << '\n';
	cout << "__int128:\t\t" << setw(width) << outputbase(numeric_limits<__int128>::min()) << setw(width) << outputbase(numeric_limits<__int128>::max()) << '\n';
	cout << "unsigned __int128:\t" << setw(width) << outputbase(numeric_limits<unsigned __int128>::min()) << setw(width) << outputbase(numeric_limits<unsigned __int128>::max()) << '\n';
#endif
	cout << "intmax_t:\t\t" << setw(width) << INTMAX_MIN << setw(width) << INTMAX_MAX << '\n';
	cout << "uintmax_t:\t\t" << setw(width) << 0 << setw(width) << UINTMAX_MAX << '\n';
	cout << "float:\t\t\t" << setw(width) << floattostring(FLT_MIN) << setw(width) << floattostring(FLT_MAX) << '\n';
	cout << "double:\t\t\t" << setw(width) << floattostring(DBL_MIN) << setw(width) << floattostring(DBL_MAX) << '\n';
	cout << "long double:\t\t" << setw(width) << floattostring(LDBL_MIN) << setw(width) << floattostring(LDBL_MAX) << '\n';
	cout << "\n\n";
	
	cout << "Data Type\t\tDecimal digits\tMaximum Decimal digits\tMantissa bits\tMaximum integer\n\n";
	cout << "float:\t\t\t" << FLT_DIG << "\t\t" << FLT_DECIMAL_DIG << "\t\t\t" << FLT_MANT_DIG << "\t\t" << floattostring(maxint<float>()) << '\n';
	cout << "double:\t\t\t" << DBL_DIG << "\t\t" << DBL_DECIMAL_DIG << "\t\t\t" << DBL_MANT_DIG << "\t\t" << floattostring(maxint<double>()) << '\n';
	cout << "long double:\t\t" << LDBL_DIG << "\t\t" << LDBL_DECIMAL_DIG << "\t\t\t" << LDBL_MANT_DIG << "\t\t" << floattostring(maxint<long double>()) << '\n';
	cout << '\n';
	
	return 0;
}
EOF

trap 'rm /tmp/types{.cpp,}' EXIT
"$CXX" -std=gnu++17 -Wall -g -O3 /tmp/types.cpp -o /tmp/types
/tmp/types
