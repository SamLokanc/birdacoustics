#!/bin/bash

set -euo pipefail

# ----- Parse Arguments -----
# Flags:
#  -o : output. Takes path to output directory as an argument.
#  -i : input. Takes path to input directory as an argument.
#  -d : date. Takes date of recording as argument.
#  -t : number of threads. Takes ${SLURM_CPUS_PER_TASK} as argument.
while getopts "o:i:t:" flag; do
  case $flag in
    o) OUTPUT="$OPTARG" ;;
    i) INPUT="$OPTARG" ;;
    t) THREADS="$OPTARG" ;;
    \?) echo "ERROR: Invalid option: -$OPTARG, exiting..." >&2; exit 1 ;;
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
 --date file \
 --lat 49.250 \
 --lon -123.236 \
 --threads "${THREADS}" \
 --rtype csv
