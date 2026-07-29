#!/bin/bash

set -euo pipefail

# ----- Parse Flags -----
# Flags:
#  -f : if set the script will setup the scratch directory
#       regardless of whether or not one from an earlier
#       date exists.
#  -p : project name used in the scratch directory naming
#       convention (default: birdacoustics).
OUT_NAME="out.csv"
while getopts "c:a:p:d:o:" flag; do
 case $flag in
  c) CWL="$OPTARG" ;;
  a) ALLOC_NAME="$OPTARG" ;;
  p) PROJECT_NAME="$OPTARG" ;;
  d) DATE="$OPTARG" ;;
  o) OUT_NAME="$OPTARG" ;;
  \?) echo "ERROR: Invalid option, exiting..." >&2; exit 1;;
 esac
done
shift $(( OPTIND-1 ))

scp "${CWL}"@sockeye.arc.ubc.ca:/scratch/"${ALLOC_NAME}"/"${CWL}"/"${CWL}"_"${PROJECT_NAME}"_"${DATE}"/results/out.csv data/"${OUT_NAME}".csv