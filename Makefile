VERSION = v1.3.5-beta

.PHONY: default source build build-32 build-64 chroot-32 chroot-64 compress clean cleanfull

default: compress

source: src/
src/:
	./dl.sh "$(VERSION)"

build-32: usdx/ultrastardx.x86
usdx/ultrastardx.x86: src/
	sudo linux32 ./setup.sh --i386

build-64: usdx/ultrastardx.x86_64
usdx/ultrastardx.x86_64: src/
	sudo ./setup.sh --amd64

chroot-32:
	sudo PATH=$$PATH:/bin:/sbin LC_ALL=C linux32 chroot chroots/*-i386 bash
chroot-64:
	sudo PATH=$$PATH:/bin:/sbin LC_ALL=C chroot chroots/*-amd64 bash

build: usdx/BUILD_DATE
usdx/BUILD_DATE: usdx/ultrastardx.x86 usdx/ultrastardx.x86_64
	@mkdir -p usdx/data/songs
	@cp -v launch.sh usdx/
	echo "`date -u +%FT%TZ`" > usdx/BUILD_DATE
	echo "$(VERSION)" > usdx/VERSION
	cp usdx/lib32/libs.txt libs32.txt
	cp usdx/lib64/libs.txt libs64.txt

compress: usdx-$(VERSION).tar.xz
usdx-$(VERSION).tar.xz: usdx/ultrastardx.x86 usdx/ultrastardx.x86_64 usdx/BUILD_DATE
	rm -f "./usdx-$(VERSION).tar.xz"
	cd usdx && tar cJf "../usdx-$(VERSION).tar.xz" .

clean:
	rm -rf usdx usdx-$(VERSION).tar.xz

cleanfull: clean
	sudo rm -rf chroots
	rm -rf src
