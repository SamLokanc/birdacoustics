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
IN_RAW="${SCRATCH}/data/raw"
IN_PROCESSED="${SCRATCH}/data/processed"
OUT="${SCRATCH}/results"
OUT_SLURM="${SCRATCH}/slurm"
SETTINGS="${SCRATCH}/settings.ini"
KALEIDOSCOPE="${PROJECT}/kaleidoscope/kaleidoscope-5.6.8.sif"

# ----- Setup -----
# Create Kaleidoscope input directory if it does not exist.
echo "Checking if ${IN_RAW} exists..." >&2
if [ ! -d "${IN_RAW}" ]; then
 echo " Creating Kaleidoscope input directory at ${IN_RAW}..." >&2
 mkdir "${IN_RAW}"
 echo "  Done." >&2
else
 echo " Kaleidoscope input directory already exists." >&2
fi

# Create Hawkears input directory if it does not exist.
echo "Checking if ${IN_PROCESSED} exists..." >&2
if [ ! -d "${IN_PROCESSED}" ]; then
 echo " Creating HawkEars input directory at ${IN_RAW}..." >&2
 mkdir "${IN_PROCESSED}"
 echo "  Done." >&2
else
 echo " HawkEars input directory already exists." >&2
fi

# Exit program if kaleidoscope image cannot be found
echo "Checking if ${KALEIDOSCOPE} exists..." >&2
if [ ! -f "${KALEIDOSCOPE}" ]; then
 echo " ERROR: Kaleidoscope image does not exist at the specified path. Exiting..." >&2
 exit 1
else
 echo " kaleidoscope.sif exists." >&2
fi

# Write the settings.ini file if it cannot be found
echo "Checking if ${SETTINGS} exists..." >&2
if [ ! -f "${SETTINGS}" ]; then
 echo " Kaleidoscope settings file could not be found. Creating new..." >&2
 bash src/03-initialize_kaleidoscope.sh \
  -s "${SETTINGS}" \
  -i "${IN_RAW}" \
  -o "${IN_PROCESSED}"
 echo "  Done." >&2
else
 echo " settings.ini exists." >&2
fi

# Create slurm output directory if it does not already exist.
echo "Checking if ${OUT_SLURM} exists..." >&2
if [ ! -d "${OUT_SLURM}" ]; then
 echo " Creating slurm directory at ${OUT_SLURM}..." >&2
 mkdir "${OUT_SLURM}"
 echo "  Done." >&2
else
 echo " slurm/ already exists." >&2
fi

# Create output directory if it does not already exist.
echo "Checking if ${OUT} exists..."
if [ ! -d "${OUT}" ]; then
 echo " Creating output directory at ${OUT}..." >&2
 mkdir "${OUT}"
 echo "  Done." >&2
else
 echo " results/ already exists."
fi

# ----- Run File Conversion -----
#echo "Running file conversion..."
#bash src/04-convert_kaleidoscope.sh \
# -k "${KALEIDOSCOPE}" \
# -s "${SETTINGS}"
#echo " Done."

# ----- Run Analysis -----
#echo "Running HawkEars analysis..."
#bash src/05-analyze_hawkears.sh \
# -i "${IN}" \
# -o "${OUT}" \
# -d 20260516
#echo " Done."

