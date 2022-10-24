#!/bin/bash
#
# Sample trivial build script
#

# the branches we will be dealing with
FOX_BRANCH="fox_10.0"

# quit with a message
abort() {
  echo "$@"
  exit 1
}

# help
show_help() {
  echo "Sample script for building OrangeFox with the $FOX_BRANCH build system"
  echo "Usage    = $0 <device_codename> [-c]"
  echo "Arguments:"
  echo "	 device_codename (required)"
  echo "	 -c (make a clean build) (optional)"
  echo "Example  = $0 miatoll"
  exit 0
}

if [ "$1" = "-h" -o "$1" = "--help" ]; then
   show_help;
fi

# Our starting point (Fox base dir)
BASE_DIR="$PWD"

# the saved location of the manifest directory upon successful sync and patch
SYNC_LOG="$BASE_DIR"/"$FOX_BRANCH"_"manifest.sav"
if [ -f $SYNC_LOG ]; then
   source $SYNC_LOG
fi

# default directory for the new manifest (amend this to match your situation)
[ -z "$MANIFEST_DIR" ] && MANIFEST_DIR="$BASE_DIR/$FOX_BRANCH"

# check for the manifest directory
[ ! -d "$MANIFEST_DIR" ] && abort "Invalid manifest directory: \"$MANIFEST_DIR\""

# device codename (must be the first argument)
device="$1"
[ -z "$device" ] && show_help

# check for the device tree
F=$(find "$MANIFEST_DIR/device" -name "$device")
if [ -z "$F" ]; then
   abort "There is no device tree for \"$device\""
else
   echo "Device tree for $device: \"$F\""
fi

# exports
export OUT_DIR=$BASE_DIR/BUILDS/"$device"
export ALLOW_MISSING_DEPENDENCIES=true
export FOX_USE_TWRP_RECOVERY_IMAGE_BUILDER=1
export LC_ALL="C"
export FOX_BUILD_DEVICE="$device"
export FOX_BUILD_LOG_FILE=$BASE_DIR/"$device"_"build.log"

cd $MANIFEST_DIR

# clean build?
if [ "$2" = "-c" -o "$2" = "--clean" ]; then
   make clean
   [ -d $OUT_DIR ] && rm -rf $OUT_DIR
fi

# use ccache?
export USE_CCACHE=1
export CCACHE_EXEC=/usr/bin/ccache
ccache -M 20G; # 20GB cache

# prepare to build
mkdir -p $OUT_DIR

# start building
START=$(date)
. build/envsetup.sh
lunch omni_"$device"-eng
mka recoveryimage
STOP=$(date)

# report
cd $BASE_DIR
echo "Start time=$START"
echo "End time  =$STOP"
exit 0
# --- #
