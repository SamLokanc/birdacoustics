#!/bin/bash

SCRATCH_BASE="/scratch/st-mgmitche-1" #move alloc name to .env?

# ----- Parse Flags -----
# Flags:
#  -f : if set the script will setup the scratch directory
#       regardless of whether or not one from an earlier
#       date exists.
#  -h : indicates that the scratch directory should include
#       the hawkears container and module files.
FORCE=0
while getopts "fh" flag; do
 case $flag in
  f )
    FORCE=1 ;;
  \? )
     echo "Invalid option, exiting..." 
     exit 1;;
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
 SCRATCH_DIR="${SCRATCH_BASE}/${USER}/${USER}_birdacoustics_$(date +%Y%m%d)"
 echo "Creating ${SCRATCH_DIR} ..."
 mkdir -p "${SCRATCH_DIR}"
 echo "Done."
else
 SCRATCH_DIR=$(
  compgen -G "${SCRATCH_BASE}/${USER}/${USER}_birdacoustics_*" |
  sort -t_ -k3 -r |
  head -n 1)
 echo "${SCRATCH_DIR} already exists."
fi

