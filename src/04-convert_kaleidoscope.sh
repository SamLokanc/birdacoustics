#!/bin/bash

set -euo pipefail

# ----- Parse Arguments -----
# Flags:
#  -k : Path to Kaleidoscope.sif file
#  -s : Path to settings.ini file
while getopts "k:s:" flag; do
  case $flag in
    k) KALEIDOSCOPE="$OPTARG" ;;
    s) SETTINGS="$OPTARG" ;;
    \?) echo "ERROR: Invalid option: -$OPTARG, exiting..." >&2; exit 1 ;;
  esac
done
shift $(( OPTIND - 1 ))

# ----- Load Apptainer and gcc Modules -----
module load gcc/9.4.0 apptainer/1.3.1

# ----- Run Kaleidoscope File Conversion -----
apptainer \
 exec \
 --bind /scratch/st-mgmitche-1/$USER/.kaleidoscope:/home/$USER/.kaleidoscope \
 "${KALEIDOSCOPE}" \
 kaleidoscope-cli \
 --accept-license \
 --batch "${SETTINGS}"
