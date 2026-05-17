#!/bin/bash
#SBATCH --time=0:30:00
#SBATCH --account=st-mgmitche-1
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=6
#SBATCH --mem=10G
#SBATCH --job-name=birdacoustics
#SBATCH -e slurm-%j.err
#SBATCH -o slurm-%j.out
#SBATCH --mail-user=samuel.lokanc@ubc.ca
#SBATCH --mail-type=ALL

# ----- Setup Scratch Directory -----
SCRATCH="${SCRATCH_DIR}"
IN="${SCRATCH}/data/processed"
OUT="${SCRATCH}/results"

# ----- Directory Existance Sanity Check -----
if [ ! -d "${SCRATCH}" ]; then
 echo "Scratch setup failed. Exiting..."
 exit 1
fi

if [ ! -d "${IN}" ]; then
 echo "Input directory does not exist. Exiting..."
 exit 1
fi

if [ ! -d "${OUT}" ]; then
 mkdir "${OUT}"
fi

# ----- Run Analysis -----
bash src/analyze_hawkears.sh \
 -i "${IN}" \
 -o "${OUT}" \
 -d 20260516

