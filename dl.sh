#!/bin/bash

set -e

mkdir -p src
cd src
echo "Downloading USDX"
mkdir -p "USDX"
curl -L "https://github.com/UltraStar-Deluxe/USDX/archive/$1.tar.gz" | tar -xz -C "USDX" --strip-components=1
# use fork
#curl -L "https://github.com/daniel-j/USDX/archive/master.tar.gz" | tar -xz -C "USDX" --strip-components=1
find "USDX" -type f -name "*.dll" -exec rm -f {} \;
