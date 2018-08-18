#!/usr/bin/env bash
#
# === .postinstall.sh ===
# Run after npm is done installing modules.

unset CDPATH  # To prevent unexpected `cd` behavior.

# --- Begin: STANDARD HELPER STUFF

kTHIS_NAME=${BASH_SOURCE##*/} # whatever is left after the last '/' in the script name
kTHIS_DIR=${BASH_SOURCE%/*} # BASH_SOURCE=kTHIS_DIR+kTHIS_NAME

die() { echo "$kTHIS_NAME: ${1:-"ABORTING due to unexpected error."}" 1>&2; exit ${2:-1}; }
dieSyntax() { echo "$kTHIS_NAME: ARGUMENT ERROR: ${1:-"Invalid argument(s) specified."} Use -h for help." 1>&2; exit 2; }

# --- Begin: THE SCRIPT

echo "$kTHIS_NAME started in $PWD, kTHIS_DIR=$kTHIS_DIR"
make
