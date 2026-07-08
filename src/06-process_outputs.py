import pandas as pd
import argparse
import re

# ----- Parse Arguments -----
# Arguments:
#  -l, --labels_csv : takes in a string representing the
#                     file path of the generic hawkears 
#                     csv output
#  -r, --rarities_csv : takes in a string representing the
#                       file path of the rarities hawkears
#                       csv output
#  -g, --gps_csv : takes in a string representing the file 
#                  path of the gps kaleidoscope csv output
#  -s, --save_path : takes in a string representing the path
#                    for the final output to be saved
parser = argparse.ArgumentParser()
parser.add_argument('-l', '--labels_csv', required=True, type=str)
parser.add_argument('-r', '--rarities_csv', required=True, type=str)
parser.add_argument('-g', '--gps_csv', required=True, type=str)
parser.add_argument('-s', '--save_path', required=True, type=str)
args = parser.parse_args()

# ----- Read in csv files -----
labels = pd.read_csv(args.labels_csv)
rarities = pd.read_csv(args.rarities_csv)
gps = (
    pd.read_csv(
        args.gps_csv,
        names=['date','time','latitude','NA','longitude','EW','filename','label'], 
        header=0,
        usecols=['latitude', 'longitude', 'filename']
    ).dropna()
)

# ----- Format gps df -----
# 1) make filename column consistent with rarities and labels
#    dfs
# 2) make longitude column accurate to reflect west of prime
#    meridian
gps['filename'] = (
    gps['filename']
    .str.replace(r'_\d+_', '_', n=1, regex=True) + '.wav'
)
gps['longitude'] = gps['longitude'] * -1

# ----- Merge labels and rarities dfs -----
# Add a rare column to indicate whether the observation is rare,
# concatenate dfs, sort by filename first, then by start time.
labels['rare'] = False
rarities['rare'] = True

all_labels = (
    pd.concat([labels, rarities])
    .reset_index(drop=True)
    .sort_values(by=['filename', 'start_time'])
)

# ----- Add gps Coordinates to all_labels -----
# Perform a left merge on the gps and all_labels dfs.
all_labels_gps = pd.merge(
    left=all_labels, 
    right=gps,
    how='left',
    on='filename'
)

# ----- Process Datetimes -----
# Using regular expressions to extract the date and time of recording,
# converts to a string that will be easily readable by R's lubridate
# package.
extracted = all_labels_gps['filename'].str.extract(r'^(.*?)_(\d{8})_(\d{6})_(\d{3})')
extracted.columns = ['recorder_id', 'date_str', 'time_str', 'seq']

all_labels_gps['recorder_id'] = extracted['recorder_id']
all_labels_gps['timestamp'] = pd.to_datetime(
    extracted['date_str'] + extracted['time_str'],
    format='%Y%m%d%H%M%S'
).dt.strftime('%Y-%m-%dT%H:%M:%S')

# ----- Write all_labels_gps to Output Directory -----
all_labels_gps.to_csv(args.save_path)
