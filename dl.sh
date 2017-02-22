#!/bin/bash

set -e

mkdir -p src
cd src
echo "Downloading USDX"
mkdir -p "USDX"
curl -L "https://github.com/UltraStar-Deluxe/USDX/archive/$1.tar.gz" | tar -xz -C "USDX" --strip-components=1

echo "Downloading SDL2"
mkdir -p "SDL2"
curl -L "https://www.libsdl.org/release/SDL2-2.0.5.tar.gz" | tar -xz -C "SDL2" --strip-components=1

echo "Downloading SDL2_mixer"
mkdir -p "SDL2_mixer"
curl -L "https://www.libsdl.org/projects/SDL_mixer/release/SDL2_mixer-2.0.1.tar.gz" | tar -xz -C "SDL2_mixer" --strip-components=1

echo "Downloading SDL2_image"
mkdir -p "SDL2_image"
curl -L "https://www.libsdl.org/projects/SDL_image/release/SDL2_image-2.0.1.tar.gz" | tar -xz -C "SDL2_image" --strip-components=1

echo "Downloading SDL2_ttf"
mkdir -p "SDL2_ttf"
curl -L "https://www.libsdl.org/projects/SDL_ttf/release/SDL2_ttf-2.0.14.tar.gz" | tar -xz -C "SDL2_ttf" --strip-components=1

echo "Downloading SDL2_net"
mkdir -p "SDL2_net"
curl -L "https://www.libsdl.org/projects/SDL_net/release/SDL2_net-2.0.1.tar.gz" | tar -xz -C "SDL2_net" --strip-components=1

echo "Downloading SDL2_gfx"
mkdir -p "SDL2_gfx"
curl -L "http://www.ferzkopp.net/Software/SDL2_gfx/SDL2_gfx-1.0.3.tar.gz" | tar -xz -C "SDL2_gfx" --strip-components=1

echo "Downloading SMPEG"
svn export --force svn://svn.icculus.org/smpeg/tags/release_2_0_0 smpeg

echo "Downloading SQLite"
mkdir -p "sqlite"
curl -L "https://sqlite.org/2017/sqlite-autoconf-3170000.tar.gz" | tar -xz -C "sqlite" --strip-components=1

echo "Downloading Yasm"
mkdir -p "yasm"
curl -L "http://www.tortall.net/projects/yasm/releases/yasm-1.3.0.tar.gz" | tar -xz -C "yasm" --strip-components=1

echo "Downloading ffmpeg"
mkdir -p "ffmpeg"
curl -L "https://ffmpeg.org/releases/ffmpeg-2.8.11.tar.gz" | tar -xz -C "ffmpeg" --strip-components=1
# in case ffmpeg.org is offline:
#curl -L "https://github.com/FFmpeg/FFmpeg/archive/n2.8.11.tar.gz" | tar -xz -C "ffmpeg" --strip-components=1

echo "Downloading pcre"
mkdir -p "pcre"
curl -L "https://sourceforge.net/projects/pcre/files/pcre/8.40/pcre-8.40.tar.gz/download" | tar -xz -C "pcre" --strip-components=1

echo "Downloading PortAudio"
mkdir -p "portaudio"
curl -L "http://www.portaudio.com/archives/pa_stable_v190600_20161030.tgz" | tar -xz -C "portaudio" --strip-components=1

echo "Downloading Freetype"
mkdir -p "freetype"
curl -L "http://download.savannah.gnu.org/releases/freetype/freetype-2.7.1.tar.gz" | tar -xz -C "freetype" --strip-components=1

echo "Downloading libpng"
mkdir -p "libpng"
curl -L "https://sourceforge.net/projects/libpng/files/libpng16/1.6.28/libpng-1.6.28.tar.gz/download" | tar -xz -C "libpng" --strip-components=1

#	@echo "Downloading Lua"
#	@mkdir -p "$@"
#	@curl -L "https://www.lua.org/ftp/lua-5.3.4.tar.gz" | tar -xz -C "$@" --strip-components=1
