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
  f )
    FORCE=1 ;;
  \? )
     echo "Invalid option, exiting..." >&2
     exit 1;;
 esac
done
shift $(( OPTIND-1 ))

# ----- Helper Function -----
make_dir_if_absent() {
 local dir="$1"
 if [[ ! -d "$dir" ]]; then
  echo "Creating ${dir} ..." >&2
  mkdir "$dir"
  echo "Done." >&2
 fi
}

# ----- Scratch Directory Creation -----
# Check if no directory matching the pattern exists OR if the
# force flag (-f) was set. If true create the directory based on
# convention: in scratch/user/user_project_YYYYMMDD. If directory(ies)
# matching pattern already exists select the most recent one based on
# date in the file name.
if ( ! compgen -G "${SCRATCH_BASE}/${USER}/${USER}_birdacoustics_*" > /dev/null ) || (( FORCE )); then
 SCRATCH_DIR="${SCRATCH_BASE}/${USER}/${USER}_birdacoustics_$(date +%Y%m%d)"
 echo "Creating ${SCRATCH_DIR} ..." >&2
 mkdir "${SCRATCH_DIR}"
 echo "Done." >&2
else
 SCRATCH_DIR=$(
  compgen -G "${SCRATCH_BASE}/${USER}/${USER}_birdacoustics_*" |
  sort -t_ -k3 -r |
  head -n 1)
 echo "${SCRATCH_DIR} already exists." >&2
fi

# ----- Data and Results Directory Creation -----
make_dir_if_absent "${SCRATCH_DIR}/results"
make_dir_if_absent "${SCRATCH_DIR}/data" #this may move depending on if data gets imported to /scratch or /project

# ----- Sync Source Files -----
rsync -av "${HOME}/birdacoustics/src" "${SCRATCH_DIR}/" >&2

# ----- Send SCRATCH_DIR to stdout -----
echo "${SCRATCH_DIR}"
