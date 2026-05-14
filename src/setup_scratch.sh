#!/bin/bash

# ----- Parse Flags -----
FORCE=0
while getopts "f" flag; do
 case $flag in
  f) FORCE=1 ;;
  \?) echo "Invalid option" ;;
 esac
done
shift $((OPTIND-1))

SCRATCH_BASE=/scratch/st-mgmitche-1 #move alloc name to .env?

# ----- Scratch Directory Creation -----
# Check if no directory matching the pattern exists OR if the
# force flag (-f) was set. If true create the directory based on
# convention: in scratch/user/user_project_YYYYMMDD. If directory(ies)
# matching pattern already exists select the most recent one based on
# date in the file name.
if (! compgen -G "${SCRATCH_BASE}/${USER}/${USER}_birdacoustics_*" > /dev/null) || (( FORCE )); then
 SCRATCH_DIR="${SCRATCH_BASE}/${USER}/${USER}_birdacoustics_$(date +%Y%m%d)"
 echo "Creating ${SCRATCH_DIR} ..."
 mkdir "${SCRATCH_DIR}"
 echo "Done."
else
 SCRATCH_DIR=$(
  compgen -G "${SCRATCH_BASE}/${USER}/${USER}_birdacoustics_*" |
  sort -t_ -k3 -r |
  head -n 1)
 echo "${SCRATCH_DIR} already exists."
fi
