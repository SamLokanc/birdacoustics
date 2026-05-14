#!/bin/bash

SCRATCH_BASE=/scratch/st-mgmitche-1 #move alloc name to .env?

if compgen -G "${SCRATCH_BASE}/${USER}/${USER}_birdacoustics_*" > /dev/null; then
 SCRATCH_DIR=$(
  compgen -G "/scratch/st-mgmitche-1/slokanc/slokanc_birdacoustics_*" |
  sort -t_ -k3 -r |
  head -n 1)
else
 SCRATCH_DIR="${SCRATCH_BASE}/${USER}/${USER}_birdacoustics_$(date +%Y%m%d)"
 mkdir "${SCRATCH_DIR}"
fi

echo "${SCRATCH_DIR}"

