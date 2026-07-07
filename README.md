# birdacoustics
## Project Overview

Birds serve as great bioindicators since they occupy a wide range of habitats and their populations respond quickly to environmental change (Kułaga, 2019). It is therefore advantageous to monitor bird populations since they allow for the quick detection of environmental stresses over the entire ecosystem. Detecting these changes is imperitive to measure the impacts of our own development on ecosystems as well as evaluate any measures being taken to remedy our harms. 

This project aims to leverage the use of acoustic data in the monitoring of bird populations, particularly through the use of HawkEars, a machine learning-based approach for acoustic classification of avian species (Huus, 2025). Affiliated with the University of British Columbia, the data for this project comes from acoustic recorders placed in the greater Vancouver area. The scripts contained herein act as an end-to-end pipeline to process raw acoustic recordings, generate insights, and display valuable information in a digestible format, the ultimate goal of which is to contribute to sustainable development and preserving ecosystem health.

## Workflow

Below is a table containing all the scripts (within in the `src/` directory) and their corresponding utility in the pipeline.
| Script | Description |
| --- | --- |
| `00-setup_scratch.sh` | Either creates or finds an existing scratch directory of the format `.../<user>/<user>_<project_name>_<YYYYMMDD>` |
| `01-submit.sh` | Point of entry for job submission. Submits Hawkears and/or Kaleidoscope jobs to the cluster. |
| `02a-run_kaleidoscope.slurm` | Executes the kaleidoscope relevant scripts |
| `02b-run_hawkears.slurm` | Executes the Hawkears relevant scripts |
| `03-initialize_kaleidoscope.sh` | Creates the `settings.ini` file required for Kaleidoscope to run the batch conversion. |
| `04-convert_kaleidoscope.sh`| Uses the `Kaleidoscope` apptainer to batch convert input files (.w4v) to a consistent (.wav) format |
| `05-analyze_hawkears.sh` | Loads `HawkEars` as a module and then runs an analysis. |
| `06-process_outputs.py` | Does final processing of the Kaleidoscope/Hawkears outputs. Extracts datetimes, attaches gps coordinates, saves .csv file |

## Prerequisites / Setup
This data pipeline is intended to be run on an ARC computing cluster environment that uses the SLURM workload manager. More specifically, it is intended to run on the University of British Columbia's [Sockeye computing cluster](https://arc.ubc.ca/compute-storage/ubc-arc-sockeye). Clone this repository by navigating to your home directory on the computing cluster and entering one of the following commands:

### Cloning the Repo
If you have an ssh key set up on the cluster (**recommended for security** [see this guide here](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)),

```bash
cd ~ && git clone git@github.com:SamLokanc/birdacoustics.git && cd birdacoustics
```

Otherwise you can run:

```bash
cd ~ && git clone https://github.com/SamLokanc/birdacoustics.git && cd birdacoustics
```

### Kaleidoscope License
An active Kaleidoscope license exists on sockeye for the `se007` node. Kaleidoscope limits the amount of active licenses by device, meaning that the license can only be activated on one compute node. This can significantly impact the amount of time required by the SLURM workload manager to allocate reseources to run a job.

If the the job fails because of an inactive kaleidoscope license you will have to manually reactivate it.

## Usage

### Scratch Directory Set-up
Due to memory and job submission constraints on Sockeye cluster, the pipeline requires a scratch directory for data to be stored in and jobs to be submitted from. In order to set up the scratch directory run the following command from within the cloned repo:

```bash
./src/00-setup_scratch.sh -p <project name>
```

Note that the project name is only used for naming the scratch directory. This should be descriptive to allow for easier file navigation.

### Importing Data
Once the scratch directory is set up you can import acoustic data using your desired method. Note that the pipeline was designed to work on either `.w4v` or `.wav` files. If your acoustic files are in the `.w4v` format, import them to the `data/raw` subdirectory within the scratch directory, then run the analysis using both the Kaleidoscope and HawkEars options in the next step. If your acoustic files are in the `.wav` format, import them to the `data/processed` subdirectory within the scratch direrctory, then run the analysis using only the HawkEars option in the next step.

Note that in order for the analysis pipeline to succeed the names of these files need to contain an 8 digit number representing the date (in YYYYMMDD format) and a 6 digit number representing the start time (in HHMMSS format). This information is pulled directly from the file name and used by HawkEars for classification.

### Submitting Jobs
To submit the Kaleidoscope and/or HawkEars Jobs required to run this analysis simply run the following command:

```bash
./src/01-submit.sh -p <project name> -k -w -t <threshold cutoff value> -e <email address>
```

Note that the `-k` and `-w` arguments specify whether to run the Kaleidoscope and HawkEars portions onf the analysis pipeline respectively. The project name supplied to the. `-p` argument needs to be consistent with the one provided in the scratch directory setup step. `-t` specifies the confidence trheshold cutoff value that HawkEars will use for preliminary results filtering (the default value is 0.8). Finally, an email address can be supplied via the `-e` argument; this email will be used to provide updates on the status of the slurm job (when it is submitted, if it fails, and when it completes)

Then wait for the submitted job to finish.

## References
Huus, J., Kelly, K. G., Bayne, E. M., & Knight, E. C. (2025). HawkEars: A regional, high-performance avian acoustic classifier. Ecological Informatics, 87, 103122.

Kułaga, K., & Budka, M. (2019). Bird species detection by an observer and an autonomous sound recorder in two different environments: Forest and farmland. PLoS One, 14(2), e0211970.
