#!/bin/bash
#SBATCH --partition=gpu
#SBATCH --gpus=1
#SBATCH --time=5:00:00
#SBATCH --account=st-mgmitche-1-gpu
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=60G
#SBATCH --job-name=birdacoustics_hawkears
#SBATCH -e slurm/%j.err
#SBATCH -o slurm/%j.out
#SBATCH --mail-user=samuel.lokanc@ubc.ca
#SBATCH --mail-type=ALL

echo "Running HawkEars analysis..." >&2
bash src/05-analyze_hawkears.sh \
 -i "${IN_PROCESSED}" \
 -o "${OUT}" \
 -t "${SLURM_CPUS_PER_TASK}"
echo "  Done." >&2
