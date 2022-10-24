#!/bin/bash
# ***************************************************************************************
# - Script to set up things for building OrangeFox with a minimal build system
# - Syncs the relevant twrp minimal manifest, and patches it for building OrangeFox
# - Pulls in the OrangeFox recovery sources and vendor tree
# - Author:  DarthJabba9
# - Version: generic:014
# - Date:    08 September 2022
#
# 	* Changes for v007 (20220430)  - make it clear that fox_12.1 is not ready
# 	* Changes for v008 (20220708)  - fox_12.1 is now ready
# 	* Changes for v009 (20220708A) - try to cherry-pick the system vold stuff from gerrit
# 	* Changes for v010 (20220708B) - move the cherry-pick call
# 	* Changes for v011 (20220731)  - update the system vold patchset number to 10
# 	* Changes for v012 (20220806)  - update the system vold patchset number to 12
# 	* Changes for v013 (20220803)  - try to ensure that the submodules are updated
# 	* Changes for v014 (20220908)  - don't apply the system vold patch: it is no longer needed
#
# ***************************************************************************************

# the version number of this script
SCRIPT_VERSION="20220908";

# the base version of the current OrangeFox
FOX_BASE_VERSION="R11.1";

# Our starting point (Fox base dir)
BASE_DIR="$PWD";

# default directory for the new manifest
MANIFEST_DIR="";

# functions to set up things for each supported manifest branch
do_fox_121() {
	BASE_VER=12;
	FOX_BRANCH="fox_12.1";
	FOX_DEF_BRANCH="fox_12.1";
	TWRP_BRANCH="twrp-12.1";
	DEVICE_BRANCH="android-12.1";
	test_build_device="miatoll"; # the device whose tree we can clone for compiling a test build
	MIN_MANIFEST="https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git";
	[ -z "$MANIFEST_DIR" ] && MANIFEST_DIR="$BASE_DIR/$FOX_DEF_BRANCH";
	echo "-- NOTE: the \"$FOX_BRANCH\" branch is still work-in-progress, and will stay for some time at the Beta stage. Treat it as such.";
}

do_fox_110() {
	BASE_VER=11;
	FOX_BRANCH="fox_11.0";
	FOX_DEF_BRANCH="fox_11.0";
	TWRP_BRANCH="twrp-11";
	DEVICE_BRANCH="android-11";
	test_build_device="vayu"; # the device whose tree we can clone for compiling a test build
	MIN_MANIFEST="https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git";
	[ -z "$MANIFEST_DIR" ] && MANIFEST_DIR="$BASE_DIR/$FOX_DEF_BRANCH";
	echo "-- NOTE: the \"$FOX_BRANCH\" branch is still BETA as far as Virtual A/B (\"VAB\") devices are concerned. Treat it as such.";
}

do_fox_100() {
	BASE_VER=10;
	FOX_BRANCH="fox_10.0";
	FOX_DEF_BRANCH="fox_10.0";
	TWRP_BRANCH="twrp-10.0-deprecated";
	DEVICE_BRANCH="android-10";
	test_build_device="miatoll";
	MIN_MANIFEST="https://github.com/minimal-manifest-twrp/platform_manifest_twrp_omni.git";
	[ -z "$MANIFEST_DIR" ] && MANIFEST_DIR="$BASE_DIR/$FOX_DEF_BRANCH";
}

do_fox_90() {
	BASE_VER=9;
	FOX_BRANCH="fox_9.0";
	FOX_DEF_BRANCH="fox_9.0";
	TWRP_BRANCH="twrp-9.0";
	DEVICE_BRANCH="android-9.0";
	test_build_device="mido";
	MIN_MANIFEST="https://github.com/minimal-manifest-twrp/platform_manifest_twrp_omni.git";
	[ -z "$MANIFEST_DIR" ] && MANIFEST_DIR="$BASE_DIR/$FOX_DEF_BRANCH";
}

do_fox_81() {
	BASE_VER=8;
	FOX_BRANCH="fox_9.0";
	FOX_DEF_BRANCH="fox_8.1";
	TWRP_BRANCH="twrp-8.1";
	DEVICE_BRANCH="android-8.1";
	test_build_device="kenzo";
	MIN_MANIFEST="https://github.com/minimal-manifest-twrp/platform_manifest_twrp_omni.git";
	[ -z "$MANIFEST_DIR" ] && MANIFEST_DIR="$BASE_DIR/$FOX_DEF_BRANCH";
}

do_fox_71() {
	BASE_VER=6;
	FOX_BRANCH="fox_9.0";
	FOX_DEF_BRANCH="fox_7.1";
	TWRP_BRANCH="twrp-7.1";
	DEVICE_BRANCH="android-7.1";
	test_build_device="hermes";
	MIN_MANIFEST="https://github.com/minimal-manifest-twrp/platform_manifest_twrp_omni.git";
	[ -z "$MANIFEST_DIR" ] && MANIFEST_DIR="$BASE_DIR/$FOX_DEF_BRANCH";
}

do_fox_60() {
	BASE_VER=6;
	FOX_BRANCH="fox_9.0";
	FOX_DEF_BRANCH="fox_6.0";
	TWRP_BRANCH="twrp-6.0";
	DEVICE_BRANCH="android-6.0";
	test_build_device="klte";
	MIN_MANIFEST="https://github.com/minimal-manifest-twrp/platform_manifest_twrp_omni.git";
	[ -z "$MANIFEST_DIR" ] && MANIFEST_DIR="$BASE_DIR/$FOX_DEF_BRANCH";
}

# help
help_screen() {
  echo "Script to set up things for building OrangeFox with a twrp minimal manifest";
  echo "Usage = $0 <arguments>";
  echo "Arguments:";
  echo "    -h, -H, --help 			print this help screen and quit";
  echo "    -d, -D, --debug 			debug mode: print each command being executed";
  echo "    -s, -S, --ssh <'0' or '1'>		set 'USE_SSH' to '0' or '1'";
  echo "    -p, -P, --path <absolute_path>	sync the minimal manifest into the directory '<absolute_path>'";
  echo "    -b, -B, --branch <branch>		get the minimal manifest for '<branch>'";
  echo "    	'<branch>' must be one of the following branches:";
  echo "    		12.1";
  echo "    		11.0";
  echo "    		10.0";
  echo "    		9.0";
  echo "    		8.1";
  echo "    		7.1";
  echo "    		6.0";
  echo "Examples:";
  echo "    $0 --branch 12.1 --path ~/OrangeFox_12.1";
  echo "    $0 --branch 11.0 --path ~/OrangeFox_11.0";
  echo "    $0 --branch 10.0 --path ~/OrangeFox_10 --ssh 1";
  echo "    $0 --branch 9.0 --path ~/OrangeFox/9.0 --debug";
  echo "";
  echo "- You *MUST* supply an *ABSOLUTE* path for the '--path' switch";
  exit 0;
}

#######################################################################
# test the command line arguments
Process_CMD_Line() {
   if [ -z "$1" ]; then
      help_screen;
   fi

   while (( "$#" )); do

        case "$1" in
            # debug mode - show some verbose outputs
                -d | -D | --debug)
                        set -o xtrace;
                ;;
             # help
                -h | -H | --help)
                        help_screen;
                ;;
             # ssh
                -s | -S | --ssh)
                        shift;
                        [ "$1" = "0" -o "$1" = "1" ] && USE_SSH=$1 || USE_SSH=0;
                ;;
             # path
                -p | -P | --path)
                        shift;
                        [ -n "$1" ] && MANIFEST_DIR=$1;
                ;;
             # branch
                -b | -B | --branch)
                	shift;
                 	if [ "$1" = "12.1" ]; then do_fox_121;
               			elif [ "$1" = "11.0" ]; then do_fox_110;
               			elif [ "$1" = "10.0" ]; then do_fox_100;
                		elif [ "$1" = "9.0" ]; then do_fox_90;
                		elif [ "$1" = "8.1" ]; then do_fox_81;
                		elif [ "$1" = "7.1" ]; then do_fox_71;
                		elif [ "$1" = "6.0" ]; then do_fox_60;
                	else
                  	   	echo "Invalid branch \"$1\". Read the help screen below.";
                  	   	echo "";
                  	   	help_screen;
                	fi
                ;;

        esac
     shift
   done

   # do we have all the necessary branch information?
   if [ -z "$FOX_BRANCH" -o -z "$TWRP_BRANCH" -o -z "$DEVICE_BRANCH" -o -z "$FOX_DEF_BRANCH" ]; then
   	echo "No branch has been specified. Read the help screen below.";
   	echo "";
   	help_screen;
   fi

  # do we have a manifest directory?
  if [ -z "$MANIFEST_DIR" ]; then
   	echo "No path has been specified for the manifest. Read the help screen below.";
   	echo "";
   	help_screen;
  fi
}
#######################################################################

# print message and quit
abort() {
  echo "$@";
  exit 1;
}

# update the environment after processing the command line
update_environment() {
  # where to log the location of the manifest directory upon successful sync and patch
  SYNC_LOG="$BASE_DIR"/"$FOX_DEF_BRANCH"_"manifest.sav";

  # by default, don't use SSH for the "git clone" commands; to use SSH, you can also export USE_SSH=1 before starting
  [ -z "$USE_SSH" ] && USE_SSH="0";

  # the "diff" file that will be used to patch the original manifest
  PATCH_FILE="$BASE_DIR/patches/patch-manifest-$FOX_DEF_BRANCH.diff";

  # the directory in which the patch of the manifest will be executed
  MANIFEST_BUILD_DIR="$MANIFEST_DIR/build";
}

# init the script, ensure we have the patch file, and create the manifest directory
init_script() {
  echo "-- Starting the script ...";
  [ ! -f "$PATCH_FILE" ] && abort "-- I cannot find the patch file: $PATCH_FILE - quitting!";

  echo "-- The new build system will be located in \"$MANIFEST_DIR\"";
  mkdir -p $MANIFEST_DIR;
  [ "$?" != "0" -a ! -d $MANIFEST_DIR ] && {
    abort "-- Invalid directory: \"$MANIFEST_DIR\". Quitting.";
  }
}

# repo init and repo sync
get_twrp_minimal_manifest() {
  cd $MANIFEST_DIR;
  echo "-- Initialising the $TWRP_BRANCH minimal manifest repo ...";
  repo init --depth=1 -u $MIN_MANIFEST -b $TWRP_BRANCH;
  [ "$?" != "0" ] && {
   abort "-- Failed to initialise the minimal manifest repo. Quitting.";
  }
  echo "-- Done.";

  echo "-- Syncing the $TWRP_BRANCH minimal manifest repo ...";
  repo sync;
  [ "$?" != "0" ] && {
   abort "-- Failed to Sync the minimal manifest repo. Quitting.";
  }
  echo "-- Done.";
}

# patch the build system for OrangeFox
patch_minimal_manifest() {
   echo "-- Patching the $TWRP_BRANCH minimal manifest for building OrangeFox for native $DEVICE_BRANCH devices ...";
   cd $MANIFEST_BUILD_DIR;
   patch -p1 < $PATCH_FILE;
   [ "$?" = "0" ] && echo "-- The $TWRP_BRANCH minimal manifest has been patched successfully" || abort "-- Failed to patch the $TWRP_BRANCH minimal manifest! Quitting.";

   # save location of manifest dir
   echo "#" &> $SYNC_LOG;
   echo "MANIFEST_DIR=$MANIFEST_DIR" >> $SYNC_LOG;
   echo "#" >> $SYNC_LOG;
}

# get the qcom/twrp common stuff
clone_common() {
   cd $MANIFEST_DIR/;

   if [ ! -d "device/qcom/common" ]; then
   	echo "-- Cloning qcom common ...";
	git clone https://github.com/TeamWin/android_device_qcom_common -b $DEVICE_BRANCH device/qcom/common;
   fi

   if [ ! -d "device/qcom/twrp-common" ]; then
   	echo "-- Cloning twrp-common ...";
   	git clone https://github.com/TeamWin/android_device_qcom_twrp-common -b $DEVICE_BRANCH device/qcom/twrp-common;
   fi
}

# get the OrangeFox recovery sources
clone_fox_recovery() {
local URL="";
local BRANCH=$FOX_BRANCH;
   if [ "$USE_SSH" = "0" ]; then
      URL="https://gitlab.com/OrangeFox/bootable/Recovery.git";
   else
      URL="git@gitlab.com:OrangeFox/bootable/Recovery.git";
   fi

   mkdir -p $MANIFEST_DIR/bootable;
   [ ! -d $MANIFEST_DIR/bootable ] && {
      echo "-- Invalid directory: $MANIFEST_DIR/bootable";
      return;
   }

   cd $MANIFEST_DIR/bootable/;
   [ -d recovery/ ] && {
      echo  "-- Moving the TWRP recovery sources to /tmp";
      rm -rf /tmp/recovery;
      mv recovery /tmp;
   }

   echo "-- Pulling the OrangeFox recovery sources ...";
   git clone --recurse-submodules $URL -b $BRANCH recovery;
   [ "$?" = "0" ] && echo "-- The OrangeFox sources have been cloned successfully" || echo "-- Failed to clone the OrangeFox sources!";

   # check that the themes are correctly downloaded
   if [ ! -f recovery/gui/theme/portrait_hdpi/ui.xml ]; then
      	echo "-- Themes not found! Trying again to pull the themes ...";
   	if [ "$USE_SSH" = "0" ]; then
      	   URL="https://gitlab.com/OrangeFox/misc/theme.git";
   	else
      	   URL="git@gitlab.com:OrangeFox/misc/theme.git";
   	fi
      	[ -d recovery/gui/theme ] && rm -rf recovery/gui/theme;
      	git clone $URL recovery/gui/theme;
      	[ "$?" = "0" ] && echo "-- The themes have been cloned successfully" || echo "-- Failed to clone the themes!";
   fi

   # ensure that the submodules are updated
   if [ -d $MANIFEST_DIR/bootable/recovery/gui/theme ]; then
      cd $MANIFEST_DIR/bootable/recovery/;
      git submodule foreach --recursive git pull origin master;
      cd $MANIFEST_DIR/bootable/;
   fi

   # cleanup /tmp/recovery/
   echo  "-- Cleaning up the TWRP recovery sources from /tmp";
   rm -rf /tmp/recovery;

   # create the directory for Xiaomi device trees
   mkdir -p $MANIFEST_DIR/device/xiaomi;
}

# get the OrangeFox vendor
clone_fox_vendor() {
local URL="";
local BRANCH=$FOX_BRANCH;
   [ "$BASE_VER" -lt 10 ] && BRANCH="master"; # less than fox_10.0 use the "master" branch
   
   if [ "$USE_SSH" = "0" ]; then
      URL="https://gitlab.com/OrangeFox/vendor/recovery.git";
   else
      URL="git@gitlab.com:OrangeFox/vendor/recovery.git";
   fi

   echo "-- Preparing for cloning the OrangeFox vendor tree ...";
   rm -rf $MANIFEST_DIR/vendor/recovery;
   mkdir -p $MANIFEST_DIR/vendor;
   [ ! -d $MANIFEST_DIR/vendor ] && {
      echo "-- Invalid directory: $MANIFEST_DIR/vendor";
      return;
   }

   cd $MANIFEST_DIR/vendor;
   echo "-- Pulling the OrangeFox vendor tree ...";
   git clone $URL -b $BRANCH recovery;
   [ "$?" = "0" ] && echo "-- The OrangeFox vendor tree has been cloned successfully" || echo "-- Failed to clone the OrangeFox vendor tree!";
}

# get the OrangeFox busybox sources
clone_fox_busybox() {
local URL="";
local BRANCH="android-9.0";
   [ "$BASE_VER" != "9" ] && return; # only clone busybox for 9.0

   if [ "$USE_SSH" = "0" ]; then
      URL="https://gitlab.com/OrangeFox/external/busybox.git";
   else
      URL="git@gitlab.com:OrangeFox/external/busybox.git";
   fi

   echo "-- Preparing for cloning the OrangeFox busybox sources ...";
   cd $MANIFEST_DIR/external;
   echo "-- Pulling the OrangeFox busybox sources ...";
   git clone $URL -b $BRANCH busybox;
   [ "$?" = "0" ] && echo "-- The OrangeFox busybox sources have been cloned successfully" || echo "-- Failed to clone the OrangeFox busybox sources!";
}

# get device trees
get_device_tree() {
local DIR=$MANIFEST_DIR/device/xiaomi;
   mkdir -p $DIR;
   cd $DIR;
   [ "$?" != "0" ] && {
      abort "-- get_device_tree() - Invalid directory: $DIR";
   }

   # test device
   local URL=git@gitlab.com:OrangeFox/device/"$test_build_device".git;
   [ "$USE_SSH" = "0" ] && URL=https://gitlab.com/OrangeFox/device/"$test_build_device".git;
   echo "-- Pulling the $test_build_device device tree ...";
   git clone $URL -b "$FOX_DEF_BRANCH" "$test_build_device";

   # done
   if [ -d "$test_build_device" -a -d "$test_build_device/recovery" ]; then
      echo "-- Finished fetching the OrangeFox $test_build_device device tree.";
   else
      abort "-- get_device_tree() - could not fetch the OrangeFox $test_build_device device tree.";
   fi
}

# [temporary fix - WiP] cherry-pick system/vold stuff from the twrp gerrit;
# will require amending if the patch set changes on gerrit (which will definitely happen sooner or later)
cherry_picks() {
  [ "$BASE_VER" != "12" ] && return; # this is for fox_12.1 only

  echo "You need to cherry-pick this commit into system/vold/: https://gerrit.twrp.me/c/android_system_vold/+/5540";
  echo "I will try to do so now. If any errors occur, then you should abort the cherry-pick and then do it manually.";

  local patchset=12; # the current patch set number
  cd $MANIFEST_DIR/system/vold/;
  git fetch https://gerrit.twrp.me/android_system_vold refs/changes/40/5540/$patchset && git cherry-pick FETCH_HEAD;

  echo ""
  echo "Every time you run 'repo sync', you must also cherry-pick this commit into system/vold/: https://gerrit.twrp.me/c/android_system_vold/+/5540";
}

# test build
test_build() {
   # clone the device tree
   get_device_tree;

   # proceed with the test build
   export FOX_VERSION="$FOX_BASE_VERSION"_"$FOX_DEF_BRANCH";
   export LC_ALL="C";
   export FOX_BUILD_TYPE="Alpha";
   export ALLOW_MISSING_DEPENDENCIES=true;
   export FOX_BUILD_DEVICE="$test_build_device";
   export OUT_DIR=$BASE_DIR/BUILDS/"$test_build_device";

   cd $BASE_DIR/;
   mkdir -p $OUT_DIR;

   cd $MANIFEST_DIR/;
   echo "-- Compiling a test build for device \"$test_build_device\". This will take a *VERY* long time ...";
   echo "-- Start compiling: ";
   . build/envsetup.sh;

   # what are we lunching (AOSP or Omni)>
   if [ "$BASE_VER" -gt 10 ]; then
   	lunch twrp_"$test_build_device"-eng;
   else
   	lunch omni_"$test_build_device"-eng;
   fi

   # build for the device
   # are we building for a virtual A/B (VAB) device? (default is "no")
   local FOX_VAB_DEVICE=0;
   if [ "$FOX_VAB_DEVICE" = "1" ]; then
   	mka adbd bootimage;
   else
   	mka adbd recoveryimage;
   fi

   # any results?
   ls -all $(find "$OUT_DIR" -name "OrangeFox-*");
}

# do all the work!
WorkNow() {
    echo "$0, v$SCRIPT_VERSION";

    local START=$(date);

    Process_CMD_Line "$@";

    update_environment;

    init_script;

    get_twrp_minimal_manifest;

    patch_minimal_manifest;

    clone_common;

    clone_fox_recovery;

    clone_fox_vendor;

    clone_fox_busybox;

    # cherry_picks; # 20220908 - comment this out: no longer needed

    # test_build; # comment this out - don't do a test build by default

    local STOP=$(date);
    echo "-- Stop time =$STOP";
    echo "-- Start time=$START";
    echo "-- Now, clone your device trees to the correct locations!";
    exit 0;
}

# --- main() ---
WorkNow "$@";
# --- end main() ---
