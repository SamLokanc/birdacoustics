import pandas as pd
import argparse

# ----- Parse Arguments -----
# Arguments:
#  -h, --hawkears_output : takes in a string representing the
#                          file path of the hawkears output
parser = argparse.ArgumentParser()
parser.add_argument('-f', '--filename', required=True, type=str)
args = parser.parse_args()

# ----- Read in csv files -----
df = pd.read_csv(args.hawkears_output)

# ----- Process Datetimes -----
# Using regular expressions to extract the date and time of recording,
# converts to a string that will be easily readable by R's lubridate
# package.
extracted = df['filename'].str.extract(r'(\d{8})_(\d{6})_(\d{3})')
extracted.columns = ['date_str', 'time_str', 'seq']

df['timestamp'] = pd.to_datetime(
    extracted['date_str'] + extracted['time_str'],
    format='%Y%m%d%H%M%S'
).dt.strftime('%Y-%m-%dT%H:%M:%S')