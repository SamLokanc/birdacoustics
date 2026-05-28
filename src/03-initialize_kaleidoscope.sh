#!/bin/bash
set -euo pipefail

# ----- Parse Arguments -----
# Flags:
#  -s : Path to settings.ini file
#  -i : Path to the input directory
#  -o : Path to the output directory
while getopts "s:i:o:" flag; do
  case $flag in
    s) SETTINGS="$OPTARG" ;;
    i) IN="$OPTARG" ;;
    o) OUT="$OPTARG" ;;
    \?) echo "ERROR: Invalid option: -$OPTARG, exiting..." >&2; exit 1 ;;
  esac
done
shift $(( OPTIND - 1 ))


# ----- Write settings.ini File -----
cat > "${SETTINGS}" <<EOF
version=5.6.8

[global]
mode=1
threads=6

[input]
directory="${IN}"
subdirs=1
MetaForm=Default Project Form

[input/wac]
enable=0

[input/wav]
enable=1

[output]
directory="${OUT}"
channelsel=0
noise=0

[output/wav]
enable1=1
compress=0
split=0
EOF
