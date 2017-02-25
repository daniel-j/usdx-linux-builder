#!/bin/bash

set -e

root=$(pwd)

SRC="$root/src"
OUTPUT="$root/output"
export SHELL=/bin/bash
export PREFIX="$root/prefix"
export PATH="$PREFIX/bin:$PATH"
export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig:$PKG_CONFIG_PATH"

mkdir -pv "$PREFIX"

# multicore compilation
makearg="-j2"

if [ ! -e "$PREFIX/built_libs" ]; then
	rm -rf "$PREFIX"

	echo "Building libpng"
	cd "$SRC/libpng"
	./configure --prefix="$PREFIX" PKG_CONFIG_PATH="$PKG_CONFIG_PATH"  --disable-static
	make "$makearg"
	make install
	make distclean

	echo "Building FreeType"
	cd "$SRC/freetype"
	./configure --prefix="$PREFIX" PKG_CONFIG_PATH="$PKG_CONFIG_PATH" --disable-static
	make "$makearg"
	make install
	make distclean

	echo "Building SDL2"
	cd "$SRC/SDL2"
	bash ./autogen.sh
	mkdir -p build
	cd build
	../configure --prefix="$PREFIX" PKG_CONFIG_PATH="$PKG_CONFIG_PATH" \
		--enable-sdl-dlopen \
		--disable-arts --disable-esd --disable-nas \
		--enable-alsa --enable-pulseaudio-shared \
		--enable-video-wayland --enable-wayland-shared \
		--enable-x11-shared --enable-ibus --enable-fcitx --enable-ime \
		--disable-rpath
	make "$makearg"
	make install
	make distclean

	echo "Building SMPEG"
	cd "$SRC/smpeg"
	bash ./autogen.sh
	./configure --prefix="$PREFIX" --with-sdl-prefix="$PREFIX" CFLAGS="-Wno-narrowing" PKG_CONFIG_PATH="$PKG_CONFIG_PATH" --disable-static
	make "$makearg"
	make install
	make distclean

	echo "Building SDL2_mixer"
	cd "$SRC/SDL2_mixer"
	bash ./autogen.sh
	./configure --prefix="$PREFIX" --with-sdl-prefix="$PREFIX" PKG_CONFIG_PATH="$PKG_CONFIG_PATH" --disable-static --disable-music-mod --disable-music-midi
	make "$makearg"
	make install
	make distclean

	echo "Building SDL2_image"
	cd "$SRC/SDL2_image"
	bash ./autogen.sh
	./configure --prefix="$PREFIX" --with-sdl-prefix="$PREFIX" PKG_CONFIG_PATH="$PKG_CONFIG_PATH" --disable-static
	make "$makearg"
	make install
	make distclean

	echo "Building SDL2_ttf"
	cd "$SRC/SDL2_ttf"
	bash ./autogen.sh
	./configure --prefix="$PREFIX" --with-sdl-prefix="$PREFIX" PKG_CONFIG_PATH="$PKG_CONFIG_PATH" --disable-static
	make "$makearg"
	make install
	make distclean

	echo "Building SDL2_net"
	cd "$SRC/SDL2_net"
	bash ./autogen.sh
	./configure --prefix="$PREFIX" --with-sdl-prefix="$PREFIX" PKG_CONFIG_PATH="$PKG_CONFIG_PATH" --disable-static --disable-gui
	make "$makearg"
	make install
	make distclean

	echo "Building SDL2_gfx"
	cd "$SRC/SDL2_gfx"
	bash ./autogen.sh
	./configure --prefix="$PREFIX" --with-sdl-prefix="$PREFIX" PKG_CONFIG_PATH="$PKG_CONFIG_PATH" --disable-static
	make "$makearg"
	make install
	make distclean

	echo "Building SQLite"
	cd "$SRC/sqlite"
	./configure --prefix="$PREFIX" PKG_CONFIG_PATH="$PKG_CONFIG_PATH" --disable-static
	make "$makearg"
	make install
	make distclean

	echo "Building PortAudio"
	cd "$SRC/portaudio"
	./configure --prefix="$PREFIX" PKG_CONFIG_PATH="$PKG_CONFIG_PATH" --disable-static --enable-cxx
	make "$makearg"
	make install
	make distclean

	#	echo "Building PCRE"
	#	cd "$SRC/pcre"
	#	./configure --prefix="$PREFIX" PKG_CONFIG_PATH="$PKG_CONFIG_PATH" --disable-static --enable-utf --enable-unicode-properties
	#	make "$makearg"
	#	make install
	#	make distclean

	echo "Building Yasm"
	cd "$SRC/yasm"
	./configure --prefix="$PREFIX" PKG_CONFIG_PATH="$PKG_CONFIG_PATH" --disable-static
	make "$makearg"
	make install
	make distclean

	echo "Building FFMPEG"
	cd "$SRC/ffmpeg"
	./configure --prefix="$PREFIX" \
		--enable-gpl \
		--disable-static \
		--enable-shared \
		--disable-programs \
		--disable-doc \
		--disable-encoders \
		--disable-xlib \
		--disable-libxcb \
		--disable-libxcb-shm \
		--disable-libx264 \
		--disable-libx265 \
		--disable-indevs \
		--disable-outdevs \
		--enable-outdev=sdl
	make "$makearg"
	make install
	make distclean

	# echo "Building projectM"
	# cd "$SRC/projectm"
	# mkdir -p build
	# cd build
	# cmake \
	# 	-Wno-dev \
	# 	-DINCLUDE-PROJECTM-QT=0 \
	# 	-DINCLUDE-PROJECTM-PULSEAUDIO=0 \
	# 	-DINCLUDE-PROJECTM-LIBVISUAL=0 \
	# 	-DINCLUDE-PROJECTM-JACK=0 \
	# 	-DINCLUDE-PROJECTM-TEST=0 \
	# 	-DINCLUDE-PROJECTM-XMMS=0 \
	# 	-DCMAKE_INSTALL_PREFIX="$PREFIX" \
	# 	-DCMAKE_BUILD_TYPE=Release \
	# 	..
	# make
	# make install

	touch "$PREFIX/built_libs"
fi

echo "Building USDX"
cd "$SRC/USDX"
bash ./autogen.sh
./configure --prefix="$PREFIX" PKG_CONFIG_PATH="$PKG_CONFIG_PATH" # --with-libprojectM
sleep 1
# -rpath \\\$\$ORIGIN/$1
make LDFLAGS="-O2 --sort-common --as-needed -z relro -shared-libgcc" datadir="./data" prefix="" bindir="" INSTALL_DATADIR="./data"
rm -rf "$OUTPUT"
sleep 1
make DESTDIR="$OUTPUT/" datadir="/data" prefix="" bindir="" INSTALL_DATADIR="./data" install
make distclean

mkdir -p "$OUTPUT/lib"

scan_libs() {
	if [ ! -f "$1" ]; then return; fi
	local libs=$(objdump -x "$1" | awk '$1 == "NEEDED" { print $2 }' | grep -E -v '(libc[^_a-zA-Z0-9])|(libm[^_a-zA-Z0-9])|libpthread|(librt[^_a-zA-Z0-9])|(libdl[^_a-zA-Z0-9])|(libcrypt[^_a-zA-Z0-9])|(libutil[^_a-zA-Z0-9])|(libnsl[^_a-zA-Z0-9])|(libresolv[^_a-zA-Z0-9])|libasound|libglib|libgcc_s|libX11|ld-linux|(libstdc\+\+[^_a-zA-Z0-9])|(libz[^_a-zA-Z0-9])')
	if [ -z "$libs" ]; then return; fi
	local lddoutput=$(ldd "$1")
	#echo $3${1##*/}
	local indent="  $4"
	local IFS=$'\n'
	while read -r file
	do
		if [ -z "$file" ]; then continue; fi
		local filepath=$(echo "$lddoutput" | grep -F "$file" | awk '{print $3}')
		if [ -e "$filepath" ] && [ ! -e "$2/$file" ]; then
			echo "$indent$file"
			cp "$filepath" "$2/"
			scan_libs "$filepath" "$2" "" "$indent"
		fi
		if [ ! -e "$filepath" ]; then
			echo "$filepath not found"
		fi
	done <<< "$libs"

	# handle extras
	local IFS=' '
	while read -r file
	do
		if [ -z "$file" ]; then continue; fi
		local filepath="$PREFIX/lib/$file"
		if [ -e "$filepath" ] && [ ! -e "$2/$file" ]; then
			echo "$indent$file"
			cp "$filepath" "$2/"
			scan_libs "$filepath" "$2" "" "$indent"
		fi
		if [ ! -e "$filepath" ]; then
			echo "$filepath not found"
		fi
	done <<< "$3"
}

echo "Scanning and copying libraries..."
scan_libs "$OUTPUT/ultrastardx" "$OUTPUT/lib" | tee "$OUTPUT/lib/libs.txt"

# strip executable
strip -s "$OUTPUT/ultrastardx"
# strip libs
find "$OUTPUT/lib" -type f -name "*.so*" -exec strip -s {} \;
# remove rpath from libs
find "$OUTPUT/lib" -type f -name "*.so*" -exec chrpath --delete --keepgoing {} \;

#IFS=$'\n' # make newlines the only separator
#for file in $(ldd output/usr/local/bin/ultrastardx | awk '{print $3}' | grep -w "so")
#do
#	cp -v "$file" output/usr/local/lib/
#done

#rm -f output/usr/local/lib/libglib*
#rm -f output/usr/local/lib/libasound*
