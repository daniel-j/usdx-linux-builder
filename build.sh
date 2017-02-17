#!/bin/bash

mkdir -pv /USDX
cd /USDX
rm -rf USDX-*
tar -xf /USDX-src.tar.gz
cd USDX-*
pwd

./configure
make LDFLAGS="-O2 --sort-common --as-needed -z relro -shared-libgcc"
make DESTDIR="output" install

mkdir -p output/usr/local/lib

scan_libs() {
	local libs=$(objdump -x "$1" | awk '$1 == "NEEDED" { print $2 }' | grep -E -v 'libpthread|(libc[^_a-zA-Z0-9])|libasound|libglib|libgcc_s|libsystemd|ld-linux|libstdc')
	if [ -z "$libs" ]; then
		return
	fi
	local lddoutput=$(ldd "$1")
	#echo $3${1##*/}
	local indent="  $3"
	IFS=$'\n' # make newlines the only separator
	while read -r file
	do
		local filepath=$(echo "$lddoutput" | grep -F "$file" | awk '{print $3}')
		if [ -e "$filepath" ] && [ ! -e "output/usr/local/lib/$file" ]; then
			echo "$indent$file"
			cp "$filepath" "$2"
			scan_libs "$filepath" "$2" "$indent"
		fi
		if [ ! -e "$filepath" ]; then
			echo "$filepath not found"
		fi
	done <<< "$libs"
}
echo "Scanning and copying libraries..."
scan_libs game/ultrastardx output/usr/local/lib/

#IFS=$'\n' # make newlines the only separator
#for file in $(ldd output/usr/local/bin/ultrastardx | awk '{print $3}' | grep -w "so")
#do
#	cp -v "$file" output/usr/local/lib/
#done

#rm -f output/usr/local/lib/libglib*
#rm -f output/usr/local/lib/libasound*
