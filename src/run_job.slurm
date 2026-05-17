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

# ----- Setup Scratch Directory -----
SCRATCH="${SCRATCH_DIR}"
IN="${SCRATCH}/data/processed"
OUT="${SCRATCH}/results"
OUT_SLURM="${SCRATCH}/slurm"

# ----- Directory Existance Sanity Check -----
if [ ! -d "${IN}" ]; then
 echo "Input directory does not exist. Exiting..." >&2
 exit 1
fi

if [ ! -d "${OUT}" ]; then
 echo "Creating output directory at ${OUT}..." >&2
 mkdir "${OUT}"
 echo "Done." >&2
fi

if [ ! -d "${OUT_SLURM}" ]; then
 echo "Creating slurm directory at ${OUT_SLURM}..." >&2
 mkdir "${OUT_SLURM}"
 echo "Done." >&2
fi

# ----- Run Analysis -----
bash src/analyze_hawkears.sh \
 -i "${IN}" \
 -o "${OUT}" \
 -d 20260516

