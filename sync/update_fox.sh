#!/bin/bash
# ***************************************************************************************
# - Example script to sync updates to the minimal build system and OrangeFox sources
# - There is very little error checking 
# - Author:  DarthJabba9
# - Version: generic:002
# - Date:    13 December 2021
# ***************************************************************************************

# the version number of this script
SCRIPT_VERSION="20211213";

# Our starting point (Fox base dir)
BASE_DIR="$PWD";

# manifest directory
MANIFEST_DIR="";

# print a message and terminate with errorcode 1
abort() {
  echo "$@";
  exit 1;
}

# help
help_screen() {
  echo "Example script to sync updates to the minimal build system and OrangeFox sources";
  echo "Usage = $0 <arguments>";
  echo "Arguments:";
  echo "    -h, -H, --help 			print this help screen and quit";
  echo "    -d, -D, --debug 			debug mode: print each command being executed";
  echo "    -p, -P, --path <absolute_path>	root of the minimal manifest";
  echo "";
  echo "Examples:";
  echo "    $0 --path ~/OrangeFox_11";
  echo "    $0 --path ~/OrangeFox/9.0 --debug";
  echo "";
  echo "- You must supply an *absolute* path for the '--path' switch";
  exit 0;
}

# process the command line arguments
Process_CMD_Line() {
    echo "$0, v$SCRIPT_VERSION";

   if [ -z "$1" ]; then
      help_screen;
   fi

   echo "- Example script to sync updates to the minimal build system and OrangeFox sources";

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
             # path
                -p | -P | --path)
                        shift;
                        [ -n "$1" ] && MANIFEST_DIR=$1;
                ;;
                *)
                        help_screen;
                ;;
        esac
     shift
   done

   [ -z "$MANIFEST_DIR" ] && help_screen;
   [ ! -d "$MANIFEST_DIR/bootable/" -o ! -d "$MANIFEST_DIR/build/" -o ! -d "$MANIFEST_DIR/external/"  ] && abort "- Invalid manifest directory: \"$MANIFEST_DIR\"";

   echo "- Starting the script ...";
   echo "- The working directory is: \"$BASE_DIR\"";
   echo "- The manifest root directory is: \"$MANIFEST_DIR\"";
}

# Execute the update
DoUpdate() {
local recovery=$MANIFEST_DIR/bootable/recovery;
local vendor=$MANIFEST_DIR/vendor/recovery;

  if [ ! -d "$recovery" ]; then
     abort "- Invalid recovery directory: \"$recovery\". Quitting."
  elif [ ! -d "$vendor" ]; then
     abort "- Invalid vendor directory: \"$vendor\". Quitting."
  fi
  
  # manifest
  echo "- Updating the build manifest...";
  echo "- You can ignore all errors relating to \"android_bootable_recovery\" or \"bootable/recovery\", etc ...";
  cd $MANIFEST_DIR && repo sync;
  
  # recovery sources
  cd $recovery && git pull --recurse-submodules;

  # vendor tree
  echo "- Updating the OrangeFox vendor tree ...";
  cd $vendor && git pull;
  
  # finish
  echo "- Finished.";
  cd $BASE_DIR;
  exit 0;
}

# main()
Process_CMD_Line "$@";
DoUpdate;
#
