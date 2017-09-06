#VERSION = v1.3.5-beta
VERSION = v2017.8.0

.PHONY: default source build build-32 build-64 run build-local run-local chroot-32 chroot-64 compress clean cleanfull

default: compress

source: src/
src/:
	./dl.sh "$(VERSION)"

build-32: usdx/ultrastardx.x86
usdx/ultrastardx.x86: src/
	sudo linux32 ./setup.sh --i386
	@cp -v launch.sh usdx/

build-64: usdx/ultrastardx.x86_64
usdx/ultrastardx.x86_64: src/
	sudo ./setup.sh --amd64
	@cp -v launch.sh usdx/

run:
	usdx/launch.sh

build-local: src/
	@mkdir -pv root
	@cp -v build.sh root
	@#rsync -rt --links ../USDX/. src/USDX --delete-after --update
	rsync -rt --links src root --delete-after --update
	cd root && ./build.sh lib
run-local:
	cd root/output && LD_LIBRARY_PATH=lib ./ultrastardx

chroot-32:
	sudo PATH=$$PATH:/bin:/sbin LC_ALL=C linux32 chroot chroots/*-i386 bash
chroot-64:
	sudo PATH=$$PATH:/bin:/sbin LC_ALL=C chroot chroots/*-amd64 bash

build: usdx/BUILD_DATE
usdx/BUILD_DATE: usdx/ultrastardx.x86 usdx/ultrastardx.x86_64
	echo "32-bit libs:" > libs.txt
	cat usdx/lib32/libs.txt >> libs.txt
	echo -e "\n64-bit libs:" >> libs.txt
	cat usdx/lib64/libs.txt >> libs.txt
	@mkdir -p usdx/data/songs
	@cp -v launch.sh usdx/
	@cp -v src/USDX/VERSION usdx/VERSION
	@cp -v libs.txt usdx/libs.txt
	@cp -v src/USDX/LICENSE usdx/
	@cp -v src/USDX/game/LICENSE.* usdx/
	echo "`date -u +%FT%TZ`" > usdx/BUILD_DATE

compress: usdx-$(VERSION).tar.xz
usdx-$(VERSION).tar.xz: usdx/ultrastardx.x86 usdx/ultrastardx.x86_64 usdx/BUILD_DATE
	rm -f "./usdx-$(VERSION).tar.xz"
	cd usdx && tar cJf "../usdx-$(VERSION).tar.xz" .

clean:
	rm -rf usdx usdx-$(VERSION).tar.xz

cleanfull: clean
	sudo rm -rf chroots
	rm -rf src root
