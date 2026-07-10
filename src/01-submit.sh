#!/bin/bash

set -euo pipefail

# ----- Parse Flags -----
# Flags:
#  -k : Run kaleidoscope job.
#  -w : Run Hawkears job.
#  -p : Project name used to locate the scratch directory
#       (default: birdacoustics). Must match what was used
#       with 01-setup_scratch.sh.
#  -t : Threshold config value.
#  -e : Email address for Slurm job notifications.
RUN_KAL=0
RUN_HAWK=0
PROJECT_NAME="birdacoustics"
EMAIL=""
while getopts "kwp:t:e:" flag; do
 case $flag in
  k) RUN_KAL=1 ;;
  w) RUN_HAWK=1 ;;
  p) PROJECT_NAME="$OPTARG" ;;
  t) THRESHOLD="$OPTARG" ;;
  e) EMAIL="$OPTARG" ;;
  \?) echo "ERROR: Invalid option, exiting..." >&2; exit 1;;
 esac
done
shift $(( OPTIND-1 ))

# ----- Locate Scratch Directory -----
# This script expects setup_scratch.sh to have already been run.
# It picks the most recent matching directory, same convention
# used by the setup script.
SCRATCH_BASE="/scratch/st-mgmitche-1"
if ! compgen -G "${SCRATCH_BASE}/${USER}/${USER}_${PROJECT_NAME}_*" > /dev/null; then
 echo "ERROR: No scratch directory found for project '${PROJECT_NAME}'." >&2
 echo " Run src/00-setup_scratch.sh first." >&2
 exit 1
fi
export SCRATCH=$(
 compgen -G "${SCRATCH_BASE}/${USER}/${USER}_${PROJECT_NAME}_*" |
 sort -t_ -k3 -r |
 head -n 1)

# ----- Set Project Directory -----
export PROJECT="/arc/project/st-mgmitche-1"

# ----- Set Path Variables -----
export IN_RAW="${SCRATCH}/data/raw"
export IN_PROCESSED="${SCRATCH}/data/processed"
export OUT="${SCRATCH}/results"
export SETTINGS="${SCRATCH}/settings.ini"
export KALEIDOSCOPE="${PROJECT}/kaleidoscope/kaleidoscope-5.6.8.sif"
export LICENSE="${SCRATCH_BASE}/.kaleidoscope"
export HAWKEARS_CONFIG="${PROJECT}/.hawkears_models/yaml/default.yaml"

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
echo "Results will be available at ${OUT}"
fi
