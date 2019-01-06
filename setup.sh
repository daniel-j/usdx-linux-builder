#!/bin/bash

set -e

repo="http://archive.ubuntu.com/ubuntu"
release="trusty"

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
	echo "deb $repo $release main restricted universe multiverse" > $source_list

	# Add fpc3 ppa
	echo "deb http://ppa.launchpad.net/ok2cqr/lazarus/ubuntu $release main" >> $source_list
	chroot ${chroot_dir} apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 13CA184A

	chroot ${chroot_dir} apt-get update
	chroot ${chroot_dir} apt-get dist-upgrade -y || true
	chroot ${chroot_dir} apt-get install -y git unzip || true
	# chroot ${chroot_dir} apt-get install -y \
	# 	fpc libpcre3 libpcre3-dev liblua5.1-dev libopencv-highgui-dev \
	# 	cmake ftgl-dev libglew-dev \
	# 	build-essential autoconf automake \
	# 	libtool libasound2-dev libpulse-dev libaudio-dev libx11-dev libxext-dev \
	# 	libxrandr-dev libxcursor-dev libxi-dev libxinerama-dev libxxf86vm-dev \
	# 	libxss-dev libgl1-mesa-dev libesd0-dev libdbus-1-dev libudev-dev \
	# 	libgles1-mesa-dev libgles2-mesa-dev libegl1-mesa-dev libibus-1.0-dev \
	# 	fcitx-libs-dev libsamplerate0-dev \
	# 	libwayland-dev libxkbcommon-dev ibus \
	# 	chrpath || true
	# cp build.sh ${chroot_dir}
	echo "Copying src to chroot..."
	rsync -rt --links src ${chroot_dir} --delete-after --update -P
	yes | chroot ${chroot_dir} /src/USDX/tools/travis/install.sh || true
}

run_chroot() {
	chroot_dir=$1
	chroot ${chroot_dir} ldconfig
	echo "Running build..."
	chroot ${chroot_dir} bash -c 'cd /src/USDX/dists/linux && make build' | tee build.$3.log
}

clean_chroot() {
	chroot_dir=$1
	chroot ${chroot_dir} bash -c 'cd /src/USDX/dists/linux && make clean'
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

	LC_ALL=C create_chroot ${release} ${arch}
	chroot_dir="${chroot_path}/${release}-${arch}"
	LC_ALL=C configure_chroot $chroot_dir
	LC_ALL=C run_chroot $chroot_dir $libpath $suffix

	mkdir -p ${output_path}

	rm -rf ${output_path}/${libpath} "${output_path}/ultrastardx.${suffix}"

	build_path="${chroot_dir}/src/USDX/dists/linux/output"
	mkdir -p ${output_path}/data

	mv -v ${build_path}/ultrastardx "${output_path}/ultrastardx.${suffix}"
	chmod -x ${build_path}/lib/*.so*
	mv -v ${build_path}/lib ${output_path}/${libpath}
	cp -r ${build_path}/data/* ${output_path}/data
	rm -r ${build_path}/data

	chown $SUDO_UID:$SUDO_GID ${output_path} -R

	LC_ALL=C clean_chroot $chroot_dir
}

main $@
