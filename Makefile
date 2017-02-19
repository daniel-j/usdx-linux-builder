VERSION = v1.3.5-beta

.PHONY: default source build build-32 build-64 compress clean cleanfull

default: compress

source: USDX-src.tar.gz
USDX-src.tar.gz:
	@echo "Downloading source code"
	curl -o "USDX-src.tar.gz" -L "https://github.com/UltraStar-Deluxe/USDX/archive/$(VERSION).tar.gz"

build-32: usdx/ultrastardx.x86
usdx/ultrastardx.x86: USDX-src.tar.gz
	sudo linux32 ./setup.sh --i386

build-64: usdx/ultrastardx.x86_64
usdx/ultrastardx.x86_64: USDX-src.tar.gz
	sudo ./setup.sh --amd64

build: usdx/BUILD_DATE
usdx/BUILD_DATE: usdx/ultrastardx.x86 usdx/ultrastardx.x86_64
	mkdir -p usdx/data/songs
	cp -v launch.sh usdx/
	echo "`date -u +%FT%TZ`" > usdx/BUILD_DATE
	echo "$(VERSION)" > usdx/VERSION

compress: usdx-$(VERSION).tar.xz
usdx-$(VERSION).tar.xz: usdx/ultrastardx.x86 usdx/ultrastardx.x86_64 usdx/BUILD_DATE
	cd usdx && tar cJf ../usdx-$(VERSION).tar.xz .

clean:
	rm -rf usdx usdx-$(VERSION).tar.xz

cleanfull: clean
	sudo rm -rf chroots
	rm -rf USDX-src.tar.gz
