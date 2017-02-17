#!/bin/bash

mkdir -pv /USDX
cd /USDX
rm -rf USDX-*
tar -xf /USDX-src.tar.gz
cd USDX-*
pwd

./configure
make LDFLAGS="-O2 --sort-common --as-needed -z relro"
make DESTDIR="output" install

mkdir -p output/usr/local/lib

IFS=$'\n' # make newlines the only separator
for file in $(ldd output/usr/local/bin/ultrastardx | awk '{print $3}' | grep -w "so")
do
	cp -v "$file" output/usr/local/lib/
done

rm -f output/usr/local/lib/libglib*
rm -f output/usr/local/lib/libasound*
