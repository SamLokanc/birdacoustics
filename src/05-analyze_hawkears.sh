#!/bin/bash

set -euo pipefail

# ----- Parse Arguments -----
# Flags:
#  -o : output. Takes path to output directory as an argument.
#  -i : input. Takes path to input directory as an argument.
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

# ----- Activate Python Environment -----
module load gcc python
source "${PROJECT}/acoustic_env/bin/activate"

# ----- Call Postprocessing Script -----
python src/06-process_outputs.py \
 -l "${OUTPUT}"/HawkEars_labels.csv \
 -r "${OUTPUT}"/HawkEars_rarities.csv \
 -g "${INPUT}"/gps.csv \
 -s results/out.csv
