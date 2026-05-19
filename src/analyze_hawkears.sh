#!/bin/bash

set -euo pipefail

# ----- Parse Arguments -----
# Flags:
#  -o : output. Takes path to output directory as an argument.
#  -i : input. Takes path to input directory as an argument.
#  -d : date. Takes date of recording as argument.
while getopts "o:i:d:" flag; do
  case $flag in
    o) OUTPUT="$OPTARG" ;;
    i) INPUT="$OPTARG" ;;
    d) DATE="$OPTARG" ;;
    \?) echo "Invalid option: -$OPTARG, exiting..." >&2; exit 1 ;;
  esac
done
shift $(( OPTIND - 1 ))

# ----- Load Hawkears Module -----
module use "${PROJECT}/software/modulefiles"
module load "hawkers/1.0"

# ----- Analyze File -----
analyze.py \
 -i "${INPUT}" \
 -o "${OUTPUT}" \
 -m 0 \
 --date "${DATE}" \
 --lat 49.250 \
 --lon -123.236 \
 --threads 6 \
 --rtype csv
