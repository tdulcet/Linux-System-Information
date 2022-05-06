#!/bin/bash

# Teal Dulcet
# Outputs C/C++ data type information
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
#include <climits>
#include <cfloat>
#include <limits>
#include <cinttypes>
#include <iomanip>

using namespace std;

template <typename T>
string floattostring(T arg)
{
	ostringstream strm;
	typedef numeric_limits<T> dbl;
	strm.precision(dbl::digits10);
	strm << arg;
	return strm.str();
}

int main()
{
	const int width = 41;

	cout << "\nData Type\t\tSize (bytes)\n\n";
	cout << "bool:\t\t\t" << sizeof(bool) << "\n";
	cout << "char:\t\t\t" << sizeof(char) << "\n";
	cout << "wchar_t:\t\t" << sizeof(wchar_t) << "\n";
	cout << "short:\t\t\t" << sizeof(short) << "\n";
	cout << "int:\t\t\t" << sizeof(int) << "\n";
	cout << "long:\t\t\t" << sizeof(long) << "\n";
	cout << "long long:\t\t" << sizeof(long long) << "\n";
	cout << "unsigned long long:\t" << sizeof(unsigned long long) << "\n";
	// cout << "__int128:\t\t" << sizeof(__int128) << "\n";
	// cout << "unsigned __int128:\t" << sizeof(unsigned __int128) << "\n";
	cout << "intmax_t:\t\t" << sizeof(intmax_t) << "\n";
	cout << "uintmax_t:\t\t" << sizeof(uintmax_t) << "\n";
	cout << "float:\t\t\t" << sizeof(float) << "\n";
	cout << "double:\t\t\t" << sizeof(double) << "\n";
	cout << "long double:\t\t" << sizeof(long double) << "\n\n\n";
	
	cout << "Data Type\t\t" << left << setw(width) << "Minimum value" << setw(width) << "Maximum value" << "\n\n";
	cout << "char:\t\t\t" << right << setw(width) << CHAR_MIN << setw(width) << CHAR_MAX << "\n";
	cout << "wchar_t:\t\t" << setw(width) << WCHAR_MIN << setw(width) << WCHAR_MAX << "\n";
	cout << "short:\t\t\t" << setw(width) << SHRT_MIN << setw(width) << SHRT_MAX << "\n";
	cout << "int:\t\t\t" << setw(width) << INT_MIN << setw(width) << INT_MAX << "\n";
	cout << "long:\t\t\t" << setw(width) << LONG_MIN << setw(width) << LONG_MAX << "\n";
	cout << "long long:\t\t" << setw(width) << LLONG_MIN << setw(width) << LLONG_MAX << "\n";
	cout << "unsigned long long:\t" << setw(width) << 0 << setw(width) << ULLONG_MAX << "\n";
	cout << "intmax_t:\t\t" << setw(width) << INTMAX_MIN << setw(width) << INTMAX_MAX << "\n";
	cout << "uintmax_t:\t\t" << setw(width) << 0 << setw(width) << UINTMAX_MAX << "\n";
	cout << "float:\t\t\t" << setw(width) << floattostring(FLT_MIN) << setw(width) << floattostring(FLT_MAX) << "\n";
	cout << "double:\t\t\t" << setw(width) << floattostring(DBL_MIN) << setw(width) << floattostring(DBL_MAX) << "\n";
	cout << "long double:\t\t" << setw(width) << floattostring(LDBL_MIN) << setw(width) << floattostring(LDBL_MAX) << "\n\n\n";
	
	cout << "Data Type\t\tDecimal digits\tMantissa bits\n\n";
	cout << "float:\t\t\t" << FLT_DIG << "\t\t" << FLT_MANT_DIG << "\n";
	cout << "double:\t\t\t" << DBL_DIG << "\t\t" << DBL_MANT_DIG << "\n";
	cout << "long double:\t\t" << LDBL_DIG << "\t\t" << LDBL_MANT_DIG << "\n\n";
	
	return 0;
}
EOF

trap 'rm /tmp/types.cpp /tmp/types' EXIT
"$CXX" -std=c++11 -Wall -g -O3 /tmp/types.cpp -o /tmp/types
/tmp/types
