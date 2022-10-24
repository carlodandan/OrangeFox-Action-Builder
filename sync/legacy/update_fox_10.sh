#!/bin/bash
# ***************************************************************************************
# Script to update the Android 10 minimal manifest (with "repo sync")
# - Author:  DarthJabba9
# - Version: 006
# - Date:    02 November 2021
# ***************************************************************************************

# the branches we will be dealing with
FOX_BRANCH="fox_10.0"
DEVICE_BRANCH="android-10"

# print message and quit
abort() {
  echo "$@"
  exit
}

# Our starting point (Fox base dir)
BASE_DIR="$PWD"

# the saved location of the manifest directory upon successful sync and patch
SYNC_LOG="$BASE_DIR"/"$FOX_BRANCH"_"manifest.sav"
if [ -f $SYNC_LOG ]; then
   source $SYNC_LOG
fi

[ -z "$MANIFEST_DIR" ] && MANIFEST_DIR="$BASE_DIR/$FOX_BRANCH"

# help
if [ "$1" = "-h" -o "$1" = "--help"  -o "$1" = "help" ]; then
  echo "Script to update the $FOX_BRANCH build system"
  echo "Usage   = $0 [$FOX_BRANCH-manifest_directory]"
  echo "The default manifest directory is \"$MANIFEST_DIR\""
  exit 0
fi

# is the fox_10 manifest directory supplied from the command line?
if [ -n "$1" ]; then 
   MANIFEST_DIR="$1"
   [ "$1" = "." ] && MANIFEST_DIR="$PWD"
fi

# test whether it is valid
if [ ! -d $MANIFEST_DIR ]; then
   echo "- Invalid directory: \"$MANIFEST_DIR\""
   abort "Syntax = $0 <$FOX_BRANCH-manifest_directory>"
fi

cd $MANIFEST_DIR
[ "$?" != "0" ] && abort "- Invalid directory: $MANIFEST_DIR"

# some more rudimentary checks
echo "- Checking the directory ($MANIFEST_DIR) for validity"
if [ ! -d bootable/ -o ! -d external/ -o ! -d bionic/ -o ! -d system/ -o ! -d toolchain/ ]; then
   abort "- Invalid manifest directory: $MANIFEST_DIR"
fi
LOC="$PWD"
echo "- Done."

echo "- The build system to be updated is: \"$MANIFEST_DIR\""

# move the OrangeFox "bootable" directory
echo "- Backing up the OrangeFox recovery sources"
BOOTABLE_BACKUP="fox_bootable"
[ -d $BOOTABLE_BACKUP ] && rm -rf $BOOTABLE_BACKUP

mv bootable/ $BOOTABLE_BACKUP
[ "$?" != "0" ] && abort "- Error backing up the OrangeFox recovery sources"
echo "- Done."

# move the OrangeFox "device" trees
echo "- Backing up the OrangeFox device trees"
DEVICE_BACKUP="fox_devices"
[ -d $DEVICE_BACKUP ] && rm -rf $DEVICE_BACKUP

mv device/ $DEVICE_BACKUP
[ "$?" != "0" ] && { 
	echo "- Restoring the OrangeFox recovery sources ..."
	rm -rf bootable/
	mv $BOOTABLE_BACKUP bootable/
  	abort "- Error backing up the OrangeFox device trees"
}
echo "- Done."

# sync the twrp manifest
echo "- Updating the minimal manifest ..."
repo sync
echo "- Done."

echo "- Restoring the OrangeFox recovery sources ..."
# remove the TWRP bootable/ directory
rm -rf bootable/

# restore the OrangeFox bootable directory
mv $BOOTABLE_BACKUP bootable/
echo "- Done."

echo "- Restoring the OrangeFox device trees ..."
# remove the TWRP device/ directory
rm -rf device/

# restore the OrangeFox device directory
mv $DEVICE_BACKUP device/
echo "- Done."

# Update OrangeFox sources
echo "- Updating the OrangeFox recovery sources ..."
cd $LOC/bootable/recovery
git pull --recurse-submodules
echo "- Done."

# Update OrangeFox vendor tree
echo "- Updating the OrangeFox vendor tree ..."
cd $LOC/vendor/recovery
git pull
echo "- Done."

# Finished
echo "- Finished! You need to update your device tree(s) manually."
#
