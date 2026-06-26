#!/bin/bash

set -euo pipefail

# ----- Parse Flags -----
# Flags:
#  -f : Force the creation of the scratch directory. Since
#       everything exists in the scratch directory this will
#       essentially force a new project instance to be created.
#  -k : Run kaleidoscope job.
#  -w : Run Hawkears job.
FORCE=0
RUN_KAL=0
RUN_HAWK=0
EMAIL=""
while getopts "fkwt:e:" flag; do
 case $flag in
  f) FORCE=1 ;;
  k) RUN_KAL=1 ;;
  w) RUN_HAWK=1 ;;
  t) THRESHOLD="$OPTARG" ;;
  e) EMAIL="$OPTARG" ;;
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
export PROJECT="/arc/project/st-mgmitche-1"

# ----- Set Path Variables -----
export IN_RAW="${SCRATCH}/data/raw"
export IN_PROCESSED="${SCRATCH}/data/processed"
export OUT="${SCRATCH}/results"
export SETTINGS="${SCRATCH}/settings.ini"
export KALEIDOSCOPE="${PROJECT}/kaleidoscope/kaleidoscope-5.6.8.sif"
export LICENSE="${SCRATCH}/.kaleidoscope"

# ----- Set Config Variables -----
export THRESHOLD

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

# ----- Submit Slurm Jobs -----
# Based on the arguments provided will run either the
# kaleidoscope batch file conversion, Hawkears acoustic
# analysis, or both. When both are specified the Hawkears
# job is dependent on the kaleidoscope job finishing first.
KAL_JOBID=""

if [[ "${RUN_KAL}" -eq 1 ]]; then
 KAL_JOBID=$(sbatch \
  --chdir="${SCRATCH}" \
  --export=ALL \
  --parsable \
  ${EMAIL:+--mail-user "${EMAIL}"} \
  "${SCRATCH}/src/02a-run_kaleidoscope.slurm"
 )
 echo "Submitted Kaleidoscope job: ${KAL_JOBID}" >&2
fi

if [[ "${RUN_HAWK}" -eq 1 ]]; then
 HAWK_SBATCH_ARGS=(
  --chdir="${SCRATCH}"
  --export=ALL
  --parsable
  ${EMAIL:+--mail-user "${EMAIL}"}
 )

 if [[ -n "${KAL_JOBID}" ]]; then
  HAWK_SBATCH_ARGS+=(--dependency=afterok:${KAL_JOBID})
 fi

 HAWK_JOBID=$(sbatch \
  "${HAWK_SBATCH_ARGS[@]}" \
  "${SCRATCH}/src/02b-run_hawkears.slurm"
 )

 if [[ -n "${KAL_JOBID}" ]]; then
  echo "Submitted Hawkears job: ${HAWK_JOBID} (waiting on ${KAL_JOBID})" >&2
 else
  echo "Submitted Hawkears job: ${HAWK_JOBID}" >&2
 fi
fi
