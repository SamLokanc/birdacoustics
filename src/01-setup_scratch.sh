#!/bin/bash

set -euo pipefail

SCRATCH_BASE="/scratch/st-mgmitche-1" #move alloc name to .env?

# ----- Parse Flags -----
# Flags:
#  -f : if set the script will setup the scratch directory
#       regardless of whether or not one from an earlier
#       date exists.
FORCE=0
while getopts "f" flag; do
 case $flag in
  f) FORCE=1 ;;
  \?) echo "ERROR: Invalid option, exiting..." >&2; exit 1;;
 esac
done
shift $(( OPTIND-1 ))

# ----- Scratch Directory Creation -----
# Check if no directory matching the pattern exists OR if the
# force flag (-f) was set. If true create the directory based on
# convention: in scratch/user/user_project_YYYYMMDD. If directory(ies)
# matching pattern already exists select the most recent one based on
# date in the file name.
if ( ! compgen -G "${SCRATCH_BASE}/${USER}/${USER}_birdacoustics_*" > /dev/null ) || (( FORCE )); then
 SCRATCH="${SCRATCH_BASE}/${USER}/${USER}_birdacoustics_$(date +%Y%m%d)"
 echo "Creating ${SCRATCH} ..." >&2
 mkdir "${SCRATCH}"
 echo "Done." >&2
else
 SCRATCH=$(
  compgen -G "${SCRATCH_BASE}/${USER}/${USER}_birdacoustics_*" |
  sort -t_ -k3 -r |
  head -n 1)
 echo "${SCRATCH} already exists." >&2
fi

# ----- Data and Results Directory Creation -----
# Check if the results directory exists. If it does not, create it.
if [[ ! -d  "${SCRATCH}/results" ]]; then
 echo "Creating results directory at ${SCRATCH}/results..." >&2
 mkdir "${SCRATCH}/results"
 echo "Done." >&2
fi

# Check if the data directory exists. If it does not, create it.
if [[ ! -d "${SCRATCH}/data" ]]; then
 echo "Creating data directory at ${SCRATCH}/data..." >&2
 mkdir "${SCRATCH}/data"
 echo "Done." >&2
fi

# ----- Sync Source Files -----
# Move all script files to the scratch directory since batch
# jobs need to be submitted from there.
rsync -a "${HOME}/birdacoustics/src" "${SCRATCH}/" >&2

# ----- Send SCRATCH to stdout -----
echo "${SCRATCH}"
