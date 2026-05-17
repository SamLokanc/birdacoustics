#!/bin/bash
SCRATCH=$(bash ~/birdacoustics/src/setup_scratch.sh)

if [ -z "$SCRATCH" ]; then
  echo "Scratch setup failed. Exiting..."
  exit 1
fi

sbatch --chdir="${SCRATCH}" --export=ALL,SCRATCH_DIR="${SCRATCH}" "${SCRATCH}/src/run_job.slurm" "$@"

