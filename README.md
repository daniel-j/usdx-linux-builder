UltraStar Deluxe Linux builder
==============================

This script builds [UltraStar Deluxe](https://github.com/Ultrastar-Deluxe/USDX) in Ubuntu chroots for both x86 and x86_64. It copies the required dynamic libraries and outputs a distro-independent package that can be extracted and launched.

You can install the game using this build through [Lutris](https://lutris.net) here: https://lutris.net/games/ultrastar-deluxe/

How to use
----------

First you need to install a few dependencies:

`chroot debootstrap curl`

To build the game, run `make`.

This will download the version of the game specified in the Makefile, and then proceeds to set up chroots and compile the game. It then compresses it to a file. It requires about 5GB free space.

To just download the source code, run `make USDX-src.tar.gz`.

When the source is downloaded you can rebuild the game for 32-bit or 64-bit by running `sudo ./setup.sh --i386` or `sudo ./setup.sh --amd64`.

To clean up, run `make clean`. This will only remove the built compressed file and build dir.

To do a complete clean, run `make cleanfull`. This will delete the chroots and downloaded sourcecode, along with the built game. Run this when you want to free disk space.

`build.sh` is copied into the chroot and it is what builds the game and gathers libraries. `launch.sh` is copied to the game dir after build and it is what you use to launch the game.
