#!/bin/sh
# Launch script for UltraStar Deluxe
# Questions to David Gow, see http://davidgow.net/gamecode/launch-script.html
# Set $DEBUGGER to launch the app with a debugger.

# Change to game directory
GAMEPATH="`readlink -f "$0"`"
cd "`dirname "$GAMEPATH"`"

# What architecture are we running?
MACHINE=`uname -m`
if [ "$MACHINE" = "x86_64" ]
then
	# Set path to libraries and binary (64 bit)
	BIN=./ultrastardx.x86_64
	LIBPATH=./lib64
else
	# Default to x86. If it's not x86, it might be able to emulate it.
	BIN=./ultrastardx.x86
	LIBPATH=./lib32
fi

# Run the game, (optionally) with the debugger
LD_LIBRARY_PATH="$LIBPATH:$LD_LIBRARY_PATH" $DEBUGGER $BIN $@

# Get the game's exit code, and return it.
e=$?
exit $e
