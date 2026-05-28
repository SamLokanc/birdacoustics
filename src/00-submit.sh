#!/bin/bash

set -euo pipefail

# ----- Parse Flags -----
# Flags:
#  -f : Force the creation of the scratch directory. Since
#       everything exists in the scratch directory this will
#       essentially force a new project instance to be created.
FORCE=0
while getopts "f" flag; do
 case $flag in
  f) FORCE=1 ;;
  \?) echo "ERROR: Invalid option, exiting..." >&2; exit 1;;
 esac
done
shift $(( OPTIND-1 ))

# ----- Set Scratch Directory -----
export SCRATCH_BASE="/scratch/st-mgmitche-1" #move alloc name to .env?
if [ "${FORCE}" -eq 1 ]; then
 export SCRATCH=$(bash src/01-setup_scratch.sh -f)
else
 export SCRATCH=$(bash src/01-setup_scratch.sh)
fi
unset SCRATCH_BASE

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
