#!/bin/bash
#SBATCH --time=2:00:00
#SBATCH --account=st-mgmitche-1
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=20G
#SBATCH --job-name=birdacoustics_kaleidoscope
#SBATCH --nodelist=se007
#SBATCH --partition=skylake
#SBATCH -e slurm/%j.err
#SBATCH -o slurm/%j.out
#SBATCH --mail-user=samuel.lokanc@ubc.ca
#SBATCH --mail-type=ALL

echo "Writing new Kaleidoscope settings file at ${SETTINGS}..." >&2
bash src/03-initialize_kaleidoscope.sh \
 -s "${SETTINGS}" \
 -i "${IN_RAW}" \
 -o "${IN_PROCESSED}" \
 -t "${SLURM_CPUS_PER_TASK}"
echo "  Done." >&2

echo "Running file conversion..." >&2
bash src/04-convert_kaleidoscope.sh \
  -k "${KALEIDOSCOPE}" \
  -s "${SETTINGS}" \
  -l "${LICENSE}"
echo "  Done." >&2
