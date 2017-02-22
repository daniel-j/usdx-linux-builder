#!/bin/bash

set -e

root=$(pwd)

export SHELL=/bin/bash
export PREFIX="$root/prefix"
export PATH="$PREFIX/bin:$PATH"
export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig:$PKG_CONFIG_PATH"

mkdir -pv "$PREFIX"

build_deps=1

if [ "$build_deps" -eq 1 ]; then
	rm -rf "$PREFIX"

	echo "Building libpng"
	cd "$root/src/libpng"
	./configure --prefix="$PREFIX" PKG_CONFIG_PATH="$PKG_CONFIG_PATH"
	make -j4
	make install
	make distclean

	echo "Building FreeType"
	cd "$root/src/freetype"
	./configure --prefix="$PREFIX" PKG_CONFIG_PATH="$PKG_CONFIG_PATH"
	make -j4
	make install
	make distclean

	echo "Building SDL2"
	cd "$root/src/SDL2"
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
	make -j4
	make install
	make distclean

	echo "Building SMPEG"
	cd "$root/src/smpeg"
	bash ./autogen.sh
	./configure --prefix="$PREFIX" --with-sdl-prefix="$PREFIX" CFLAGS="-Wno-narrowing" PKG_CONFIG_PATH="$PKG_CONFIG_PATH"
	make -j4
	make install
	make distclean

	echo "Building SDL2_mixer"
	cd "$root/src/SDL2_mixer"
	bash ./autogen.sh
	./configure --prefix="$PREFIX" --with-sdl-prefix="$PREFIX" PKG_CONFIG_PATH="$PKG_CONFIG_PATH" --disable-music-mod --disable-music-midi
	make -j4
	make install
	make distclean

	echo "Building SDL2_image"
	cd "$root/src/SDL2_image"
	bash ./autogen.sh
	./configure --prefix="$PREFIX" --with-sdl-prefix="$PREFIX" PKG_CONFIG_PATH="$PKG_CONFIG_PATH"
	make -j4
	make install
	make distclean

	echo "Building SDL2_ttf"
	cd "$root/src/SDL2_ttf"
	bash ./autogen.sh
	./configure --prefix="$PREFIX" --with-sdl-prefix="$PREFIX" PKG_CONFIG_PATH="$PKG_CONFIG_PATH"
	make -j4
	make install
	make distclean

	echo "Building SDL2_net"
	cd "$root/src/SDL2_net"
	bash ./autogen.sh
	./configure --prefix="$PREFIX" --with-sdl-prefix="$PREFIX" PKG_CONFIG_PATH="$PKG_CONFIG_PATH" --disable-gui
	make -j4
	make install
	make distclean

	echo "Building SDL2_gfx"
	cd "$root/src/SDL2_gfx"
	bash ./autogen.sh
	./configure --prefix="$PREFIX" --with-sdl-prefix="$PREFIX" PKG_CONFIG_PATH="$PKG_CONFIG_PATH"
	make -j4
	make install
	make distclean

	echo "Building SQLite"
	cd "$root/src/sqlite"
	./configure --prefix="$PREFIX" PKG_CONFIG_PATH="$PKG_CONFIG_PATH"
	make -j4
	make install
	make distclean

	echo "Building PortAudio"
	cd "$root/src/portaudio"
	./configure --prefix="$PREFIX" PKG_CONFIG_PATH="$PKG_CONFIG_PATH"
	make -j4
	make install
	make distclean

	echo "Building PCRE"
	cd "$root/src/pcre"
	./configure --prefix="$PREFIX" PKG_CONFIG_PATH="$PKG_CONFIG_PATH" --enable-unicode-properties --enable-pcre16 --enable-pcre-32 --enable-jit --enable-utf
	make -j4
	make install
	make distclean

	echo "Building Yasm"
	cd "$root/src/yasm"
	./configure --prefix="$PREFIX" PKG_CONFIG_PATH="$PKG_CONFIG_PATH" --disable-rpath
	make -j4
	make install
	make distclean

	echo "Building FFMPEG"
	cd "$root/src/ffmpeg"
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
	make -j4
	make install
	make distclean
fi

echo "Building USDX"
cd "$root/src/USDX"
bash ./autogen.sh
./configure --prefix="$PREFIX" PKG_CONFIG_PATH="$PKG_CONFIG_PATH"
# -rpath \\\$\$ORIGIN/$1
make LDFLAGS="-O2 --sort-common --as-needed -z relro -shared-libgcc" datadir="./data" prefix="" bindir="" INSTALL_DATADIR="./data"
rm -rf "$root/output/"
make DESTDIR="$root/output/" datadir="/data" prefix="" bindir="" INSTALL_DATADIR="./data" install

mkdir -p "$root/output/lib"

scan_libs() {
	local libs=$(objdump -x "$1" | awk '$1 == "NEEDED" { print $2 }' | grep -E -v '(libc[^_a-zA-Z0-9])|(libm[^_a-zA-Z0-9])|libpthread|(librt[^_a-zA-Z0-9])|(libdl[^_a-zA-Z0-9])|(libcrypt[^_a-zA-Z0-9])|(libutil[^_a-zA-Z0-9])|(libnsl[^_a-zA-Z0-9])|(libresolv[^_a-zA-Z0-9])|libasound|libglib|libgcc_s|libX11|ld-linux|(libstdc\+\+[^_a-zA-Z0-9])')
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
		if [ -e "$filepath" ] && [ ! -e "$2/$file" ]; then
			echo "$indent$file"
			cp "$filepath" "$2/"
			scan_libs "$filepath" "$2" "$indent"
		fi
		if [ ! -e "$filepath" ]; then
			echo "$filepath not found"
		fi
	done <<< "$libs"
}
echo "Scanning and copying libraries..."
scan_libs game/ultrastardx "$root/output/lib" | tee "$root/output/lib/libs.txt"

#IFS=$'\n' # make newlines the only separator
#for file in $(ldd output/usr/local/bin/ultrastardx | awk '{print $3}' | grep -w "so")
#do
#	cp -v "$file" output/usr/local/lib/
#done

#rm -f output/usr/local/lib/libglib*
#rm -f output/usr/local/lib/libasound*
