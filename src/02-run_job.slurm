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
SETTINGS="${SCRATCH}/settings.ini"
KALEIDOSCOPE="${PROJECT}/kaleidoscope/kaleidoscope-5.6.8.sif"

# ----- Setup -----
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

