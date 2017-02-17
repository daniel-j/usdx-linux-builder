VERSION = v1.3.5-beta

.PHONY: default clean cleanfull

default: usdx-$(VERSION).tar.xz

USDX-src.tar.gz:
	curl -o "USDX-src.tar.gz" -L "https://github.com/UltraStar-Deluxe/USDX/archive/$(VERSION).tar.gz"

usdx/ultrastardx.x86: USDX-src.tar.gz
	sudo ./setup.sh --i386
usdx/ultrastardx.x86_64: USDX-src.tar.gz
	sudo ./setup.sh --amd64

usdx-$(VERSION).tar.xz: usdx/ultrastardx.x86 usdx/ultrastardx.x86_64
	echo "`date -u +%FT%TZ`" > usdx/BUILD_DATE
	echo "$(VERSION)" > usdx/VERSION
	cd usdx && tar cJfv ../usdx-$(VERSION).tar.xz .

clean:
	rm -rf usdx usdx-$(VERSION).tar.xz

cleanfull: clean
	sudo rm -rf chroots
	rm -rf USDX-src.tar.gz