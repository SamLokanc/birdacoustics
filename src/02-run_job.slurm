#!/bin/bash
#SBATCH --time=1:00:00
#SBATCH --account=st-mgmitche-1
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=20G
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

# Write the settings.ini file. Do this no matter if it already exists.
echo "Writing new Kaleidoscope settings file at ${SETTINGS}..." >&2
bash src/03-initialize_kaleidoscope.sh \
 -s "${SETTINGS}" \
 -i "${IN_RAW}" \
 -o "${IN_PROCESSED}" \
 -t "${SLURM_CPUS_PER_TASK}"
echo "  Done." >&2

# ----- Run File Conversion -----
echo "Running file conversion..." >&2
bash src/04-convert_kaleidoscope.sh \
 -k "${KALEIDOSCOPE}" \
 -s "${SETTINGS}" \
echo " Done." >&2

# ----- Run Analysis -----
echo "Running HawkEars analysis..." >&2
bash src/05-analyze_hawkears.sh \
 -i "${IN_PROCESSED}" \
 -o "${OUT}" \
 -d 20260516 \
 -t "${SLURM_CPUS_PER_TASK}"
echo " Done." >&2

