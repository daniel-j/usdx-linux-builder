VERSION = v1.3.5-beta

.PHONY: default source build build-32 build-64 clean cleanfull

default: build

source: USDX-src.tar.gz
USDX-src.tar.gz:
	@echo "Downloading source code"
	curl -o "USDX-src.tar.gz" -L "https://github.com/UltraStar-Deluxe/USDX/archive/$(VERSION).tar.gz"

build-32: usdx/ultrastardx.x86
usdx/ultrastardx.x86: source
	sudo ./setup.sh --i386

build-64: usdx/ultrastardx.x86_64
usdx/ultrastardx.x86_64: source
	sudo ./setup.sh --amd64

build: usdx-$(VERSION).tar.xz
usdx-$(VERSION).tar.xz: build-32 build-64
	echo "`date -u +%FT%TZ`" > usdx/BUILD_DATE
	echo "$(VERSION)" > usdx/VERSION
	cd usdx && tar cJfv ../usdx-$(VERSION).tar.xz .

clean:
	rm -rf usdx usdx-$(VERSION).tar.xz

cleanfull: clean
	sudo rm -rf chroots
	rm -rf USDX-src.tar.gz
