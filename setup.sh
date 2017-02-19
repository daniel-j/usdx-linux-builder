#!/bin/bash

set -e

repo="http://archive.ubuntu.com/ubuntu/"
release="xenial"

chroot_path="./chroots"
output_path="./usdx"

create_chroot() {
	release=$1
	arch=$2
	chroot_dir="${chroot_path}/${release}-${arch}"
	if [ ! -e ${chroot_dir} ]; then
		if ! type "debootstrap" > /dev/null 2>&1; then
			echo "Error: debootstrap is not installed"
			exit 1
		fi
		mkdir -p ${chroot_dir}
		echo ${release} ${chroot_dir} ${repo}
		debootstrap --arch=${arch} ${release} ${chroot_dir} ${repo}
	fi
}

configure_chroot() {
	chroot_dir=$1
	#mount proc ${chroot_dir}/proc -t proc
	#mount sysfs ${chroot_dir}/sys -t sysfs
	cp /etc/hosts ${chroot_dir}/etc/hosts
	cp /proc/mounts ${chroot_dir}/etc/mtab

	source_list=${chroot_dir}/etc/apt/sources.list
	echo "deb http://archive.ubuntu.com/ubuntu xenial main restricted universe multiverse" > $source_list

	chroot ${chroot_dir} apt-get update
	chroot ${chroot_dir} apt-get dist-upgrade -y || true
	chroot ${chroot_dir} apt-get install curl build-essential fpc libsdl2-dev libsdl2-image-dev libsdl2-image-2.0-0 libsdl2-2.0-0 libsdl2-mixer-2.0-0 libsdl2-mixer-dev libsdl2-net-2.0-0 libsdl2-net-dev libsdl2-ttf-2.0-0 libsdl2-ttf-dev libsdl2-gfx-1.0-0 libsdl2-gfx-dev ffmpeg libavdevice-dev libsqlite3-0 libsqlite3-dev libpcre3 libpcre3-dev ttf-dejavu ttf-freefont portaudio19-dev lua5.1-dev libpng16-16 libopencv-highgui-dev libprojectm-dev -y  || true
	cp build.sh ${chroot_dir}
	cp USDX-src.tar.gz ${chroot_dir}
}

run_chroot() {
	chroot_dir=$1
	chroot ${chroot_dir} ldconfig
	echo "Running build..."
	chroot ${chroot_dir} /build.sh $2
}

main() {
	if [[ $# == 0 ]]; then
		echo "Usage: $0 --i386 | --amd64"
		exit 1
	fi
	if [[ "$1" == "--i386" ]]; then
		arch="i386"
		libpath="lib32"
		suffix="x86"
	fi
	if [[ "$1" == "--amd64" ]]; then
		arch="amd64"
		libpath="lib64"
		suffix="x86_64"
	fi

	# Export /bin and /sbin to PATH as some systems no longer have it (Arch!)
	export PATH=$PATH:/bin:/sbin

	mkdir -p ${chroot_path}
	mkdir -p ${output_path}

	create_chroot ${release} ${arch}
	chroot_dir="${chroot_path}/${release}-${arch}"
	configure_chroot $chroot_dir
	run_chroot $chroot_dir $libpath

	rm -rf ${output_path}/${libpath} "${output_path}/ultrastardx.${suffix}"

	build_path="${chroot_dir}/USDX/USDX-*/output"
	mkdir -p ${output_path}/data

	mv -v ${build_path}/ultrastardx "${output_path}/ultrastardx.${suffix}"
	mv -v ${build_path}/lib ${output_path}/${libpath}
	cp -r ${build_path}/data/* ${output_path}/data
	rm -r ${build_path}/data

	chown $SUDO_UID:$SUDO_GID ${output_path} -R
}

main $@
