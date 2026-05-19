#!/bin/bash

set -euo pipefail

# ----- Setup Scratch Directory and Export -----
export SCRATCH=$(bash src/setup_scratch.sh)

# ----- Directory Existance Sanity Check -----
# Check SCRATCH is defined. If it does not exit the program.
if [ -z "${SCRATCH}" ]; then
  echo "Scratch setup failed. Exiting..."
  exit 1
fi

# ----- Submit Slurm Job -----
# This submits the slurm job from the scratch directory. This
# is necessary on UBC sockeye because you cannot submit slurm
# jobs from the home directory. It also exports SCRATCH as 
# so that it can be used in child scripts.
sbatch \
 --chdir="${SCRATCH}" \
 --export=ALL\
 "${SCRATCH}/src/run_job.slurm" "$@"

