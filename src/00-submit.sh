#!/bin/bash

set -euo pipefail

# ----- Set Scratch Directory -----
export SCRATCH=$(bash src/01-setup_scratch.sh)

# ----- Set Project Directory -----
export PROJECT="/arc/project/st-mgmitche-1/"


# ----- Directory Existance Sanity Check -----
# Check SCRATCH is defined. If it does not exit the program.
if [ ! -d "${SCRATCH}" ]; then
  echo "ERROR: Scratch setup failed. Exiting..." >&2
  exit 1
fi
# Check PROJECT exists. If not exit the program.
if [ ! -d "${PROJECT}" ]; then
  echo "ERROR: Project directory does not exist. Exiting..." >&2
  exit 1
fi

# ----- Submit Slurm Job -----
# This submits the slurm job from the scratch directory. This
# is necessary on UBC sockeye because you cannot submit slurm
# jobs from the home directory.
sbatch \
 --chdir="${SCRATCH}" \
 --export=ALL \
 "${SCRATCH}/src/02-run_job.slurm" "$@"
