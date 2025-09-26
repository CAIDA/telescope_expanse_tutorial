#!/usr/bin/bash

#cd into scratch directory
SLURM_JOB_ID="$(squeue -u $LOGNAME |grep $HOSTNAME | awk '{print $1}')"
cd "/scratch/${USER}/job_${SLURM_JOB_ID}"; 

#copy notebook to scratch directory
cp -r /home/magao/1_workspace/telescope_expanse_tutorial/* /scratch/${USER}/job_${SLURM_JOB_ID}/

#load ucsdnt s3 key into the environment 
source /expanse/lustre/projects/csd939/kmok/.ucsdnts3.key

#point to user-local spark binaries
export SPARK_HOME=${SPARK_HOME:-"/scratch/$USER/job_${SLURM_JOB_ID}/spark-3.2.1"}
export BASE_DIR=${BASE_DIR:-"/scratch/$USER/job_${SLURM_JOB_ID}/spark-3.2.1"}
export SPARK_LOCAL_DIRS=${SPARK_LOCAL_DIRS:-"/scratch/$USER/job_${SLURM_JOB_ID}/spark_scratch"}
export SPARK_CONF_DIR=${SPARK_CONF_DIR:-"$BASE_DIR/conf"}
export SPARK_WORKER_DIR=${SPARK_WORKER_DIR:-"$BASE_DIR/worker"}
export SPARK_LOG_DIR=${SPARK_LOG_DIR:-"$BASE_DIR/logs"}

# Set up dependencies + run Jupyterlab
python3.9 -m venv .venv;
. ./.venv/bin/activate;
pip install jupyter
jupyter-lab --port 9000 --no-browser
