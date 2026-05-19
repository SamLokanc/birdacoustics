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

# ----- Set Paths -----
IN="${SCRATCH}/data/processed"
OUT="${SCRATCH}/results"
OUT_SLURM="${SCRATCH}/slurm"
KALEIDOSCOPE="${PROJECT}/kaleidoscope/kaleidoscope-5.6.8.sif"
SETTINGS="${HOME}/birdacoustics/config/settings.ini"

# ----- Path Existance Sanity Check -----
# Exit program if input directory does not exist.
if [ ! -d "${IN}" ]; then
 echo "ERROR: Input directory does not exist. Exiting..." >&2
 exit 1
fi

# Exit program if kaleidoscope image cannot be found
if [ ! -f "${KALEIDOSCOPE}" ]; then
 echo "ERROR: Kaleidoscope image does not exist at the specified path. Exiting..." >&2
 exit 1
fi

# Exit programs if kaleidoscope config cannot be found
if [ ! -f "${SETTINGS}" ]; then
 echo "ERROR: Kaleidoscope settings file does not exist at the specified path. Exiting..." >&2
 exit 1
fi

# Create slurm output directory if it does not already exist.
if [ ! -d "${OUT_SLURM}" ]; then
 echo "Creating slurm directory at ${OUT_SLURM}..." >&2
 mkdir "${OUT_SLURM}"
 echo "Done." >&2
fi

# Create output directory if it does not already exist.
if [ ! -d "${OUT}" ]; then
 echo "Creating output directory at ${OUT}..." >&2
 mkdir "${OUT}"
 echo "Done." >&2
fi

# ----- Run File Conversion -----
# bash src/03-convert_kaleidoscope.sh \
#  -k "${KALEIDOSCOPE}" \
#  -s "${SETTINGS}"

# ----- Run Analysis -----
bash src/04-analyze_hawkears.sh \
 -i "${IN}" \
 -o "${OUT}" \
 -d 20260516

