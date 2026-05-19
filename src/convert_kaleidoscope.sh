#!/bin/bash

set -euo pipefail

# ----- Parse Arguments -----
# Flags:
#  -k : Path to Kaleidoscope.sif file
#  -s : Path to settings.ini file
while getopts "o:i:d:" flag; do
  case $flag in
    k) KALEIDOSCOPE="$OPTARG" ;;
    s) SETTINGS="$OPTARG" ;;
    \?) echo "Invalid option: -$OPTARG, exiting..." >&2; exit 1 ;;
  esac
done
shift $(( OPTIND - 1 ))

# ----- Run Kaleidoscope File Conversion -----
apptainer \
 exec KALEIDOSCOPE \
 kaleidoscope-cli \
 --batch SETTINGS
