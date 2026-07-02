#!/bin/bash

set -euo pipefail

# ----- Parse Flags -----
# Flags:
#  -f : if set the script will setup the scratch directory
#       regardless of whether or not one from an earlier
#       date exists.
#  -p : project name used in the scratch directory naming
#       convention (default: birdacoustics).
FORCE=0
PROJECT_NAME="birdacoustics"
while getopts "fp:" flag; do
 case $flag in
  f) FORCE=1 ;;
  p) PROJECT_NAME="$OPTARG" ;;
  \?) echo "ERROR: Invalid option, exiting..." >&2; exit 1;;
 esac
done
shift $(( OPTIND-1 ))

# ----- Set Scratch Base Directory -----
export SCRATCH_BASE="/scratch/st-mgmitche-1"

# ----- Scratch Directory Creation -----
# Check if no directory matching the pattern exists OR if the
# force flag (-f) was set. If true create the directory based on
# convention: in scratch/user/user_project_YYYYMMDD. If directory(ies)
# matching pattern already exists select the most recent one based on
# date in the file name.
echo "Checking if Scratch directory exists..." >&2
if ( ! compgen -G "${SCRATCH_BASE}/${USER}/${USER}_${PROJECT_NAME}_*" > /dev/null ) || (( FORCE )); then
 SCRATCH="${SCRATCH_BASE}/${USER}/${USER}_${PROJECT_NAME}_$(date +%Y%m%d)"
 echo " Creating ${SCRATCH} ..." >&2
 mkdir "${SCRATCH}"
 echo "  Done." >&2
else
 SCRATCH=$(
  compgen -G "${SCRATCH_BASE}/${USER}/${USER}_${PROJECT_NAME}_*" |
  sort -t_ -k3 -r |
  head -n 1)
 echo " ${SCRATCH} already exists." >&2
fi

# ----- Data and Results Directory Creation -----
# Check if the results directory exists. If it does not, create it.
echo "Checking if results directory exists..." >&2
if [[ ! -d  "${SCRATCH}/results" ]]; then
 echo " Creating results directory at ${SCRATCH}/results..." >&2
 mkdir "${SCRATCH}/results"
 echo "  Done." >&2
else
 echo " Results directory already exists." >&2
fi

# Check if the data directory exists. If it does not, create it.
echo "Checking if data directory exists..." >&2
if [[ ! -d "${SCRATCH}/data" ]]; then
 echo " Creating data directory at ${SCRATCH}/data..." >&2
 mkdir "${SCRATCH}/data"
 echo "  Done." >&2
else
 echo " Data directory already exists." >&2
fi

# Check if raw data directory exists. If it does not create it.
echo "Checking if raw data directory exists..." >&2
if [[ ! -d "${SCRATCH}/data/raw" ]]; then
 echo " Creating raw data directory at ${SCRATCH}/data/raw..." >&2
 mkdir "${SCRATCH}/data/raw"
 echo "  Done." >&2
else
 echo " Raw data directory already exists." >&2
fi

# Check if processed data directory exists. If it does not create it.
echo "Checking if processed data directory exists..." >&2
if [[ ! -d "${SCRATCH}/data/processed" ]]; then
 echo " Creating processed data directory at ${SCRATCH}/data/processed..." >&2
 mkdir "${SCRATCH}/data/processed"
 echo "  Done." >&2
else
 echo " Processed data directory already exists." >&2
fi

# Check if slurm directory exists. If it does not create it.
echo "Checking if slurm log directory exists..." >&2
if [[ ! -d "${SCRATCH}/slurm" ]]; then
 echo " Creating slurm log directory at ${SCRATCH}/slurm..." >&2
 mkdir "${SCRATCH}/slurm"
 echo "  Done." >&2
else
 echo " Slurm log directory already exists." >&2
fi

# ----- Sync Source Files -----
# Move all script files to the scratch directory since batch
# jobs need to be submitted from there.
rsync -a "${HOME}/birdacoustics/src" "${SCRATCH}/" >&2

# ----- Print Path to Import Data to -----
echo $'\nBefore submitting the job you should:'
echo "- Import .w4v files to ${SCRATCH}/data/raw"
echo " OR"
echo "- Import .wav files to ${SCRATCH}/data/processed"
