#!/bin/bash
#SBATCH --time=0:30:00
#SBATCH --account=st-mgmitche-1
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=6
#SBATCH --mem=10G
#SBATCH --job-name=birdacoustics
#SBATCH -e slurm/%j.err
#SBATCH -o slurm/%j.out
#SBATCH --mail-user=samuel.lokanc@ubc.ca
#SBATCH --mail-type=ALL

set -euo pipefail

# ----- Set Directories -----
SCRATCH="${SCRATCH}"
IN="${SCRATCH}/data/processed"
OUT="${SCRATCH}/results"
OUT_SLURM="${SCRATCH}/slurm"

KALEIDOSCOPE="${PROJECT}/kaleidoscope/kaleidoscope-5.6.8.sif"
SETTINGS="${HOME}/birdacoustics/config/settings.ini"

# ----- Directory Existance Sanity Check -----
# Create slurm output directory if it does not already exist.
if [ ! -d "${OUT_SLURM}" ]; then
 echo "Creating slurm directory at ${OUT_SLURM}..." >&2
 mkdir "${OUT_SLURM}"
 echo "Done." >&2
fi

# Exit program if input directory does not exist.
if [ ! -d "${IN}" ]; then
 echo "Input directory does not exist. Exiting..." >&2
 exit 1
fi

# Create output directory if it does not already exist.
if [ ! -d "${OUT}" ]; then
 echo "Creating output directory at ${OUT}..." >&2
 mkdir "${OUT}"
 echo "Done." >&2
fi

# ----- Run File Conversion -----
# bash src/convert_kaleidoscope.sh \
#  -k "${KALEIDOSCOPE}" \
#  -s "${SETTINGS}"

# ----- Run Analysis -----
bash src/analyze_hawkears.sh \
 -i "${IN}" \
 -o "${OUT}" \
 -d 20260516

