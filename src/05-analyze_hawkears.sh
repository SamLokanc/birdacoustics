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
module load intel-oneapi-compilers/2023.1.0 python/3.11.6 cuda/11.8.0
source "${PROJECT}/acoustics_env/bin/activate"

# ----- Create Necessary Temp Cache Directories -----
export MPLCONFIGDIR=/tmp/matplotlib-$SLURM_JOB_ID
export LIBROSA_CACHE_DIR=/tmp/librosa-$SLURM_JOB_ID
export XDG_CACHE_HOME=/tmp/xdg-$SLURM_JOB_ID

mkdir -p $MPLCONFIGDIR $LIBROSA_CACHE_DIR $XDG_CACHE_HOME

# ----- Analyze File -----
hawkears analyze \
 -i "${INPUT}" \
 -o "${OUTPUT}" \
 --date file \
 --lat "${LAT}" \
 --lon "${LON}" \
 --threads "${THREADS}" \
 --rtype csv \
 --label names \
 --min_score "${THRESHOLD}"

# ----- Call Postprocessing Script -----
python src/06-process_outputs.py \
 -l "${OUTPUT}"/scores.csv \
 -r "${OUTPUT}"/rarities.csv \
 -g "${INPUT}"/gps.csv \
 -s "${OUTPUT}"/out.csv
