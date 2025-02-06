#!/usr/bin/bash
SLURM_JOB_ID="$(squeue -u $LOGNAME |grep $HOSTNAME | awk '{print $1}')"
cd "/scratch/${USER}/job_${SLURM_JOB_ID}"; 
#load ucsdnt s3 key into the environment 
source /expanse/lustre/projects/csd939/kmok/.ucsdnts3.key

python3.9 -m venv .venv;
. ./.venv/bin/activate;
pip install jupyter
jupyter-lab --port 9000 --no-browser
