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
module load intel-oneapi-compilers/2023.1.0 python/3.11.6
source "${PROJECT}/acoustics_env/bin/activate"

# ----- Analyze File -----
hawkears analyze \
 -i "${INPUT}" \
 -o "${OUTPUT}" \
 --cfg "${HAWKEARS_CONFIG}" \
 --date file \
 --lat 49.250 \
 --lon -123.236 \
 --threads "${THREADS}" \
 --rtype csv

# ----- Call Postprocessing Script -----
#python src/06-process_outputs.py \
# -l "${OUTPUT}"/HawkEars_labels.csv \
# -r "${OUTPUT}"/HawkEars_rarities.csv \
# -g "${INPUT}"/gps.csv \
# -s "${OUTPUT}"/out.csv

# ----- Clean Processed Data Directory -----
#rm -rf "${SCRATCH}/data/processed/*"
