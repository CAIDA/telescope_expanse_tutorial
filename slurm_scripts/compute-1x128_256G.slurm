#!/bin/bash
#SBATCH --job-name=spark-pi
#SBATCH --partition=compute
#SBATCH --account=sds193
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=128
#SBATCH --mem-per-cpu=1900
#SBATCH --time=00:30:00
#SBATCH --output="joblogs/slurm-%A_%a.out"

REPO_DIR=/home/${USER}/telescope_expanse_tutorial

cd ${REPO_DIR}/slurm_scripts
/bin/bash launch-spark.sh
/bin/bash bootstrap_env.sh

# Launch Jupyter and sleep forever
#jupyter-lab --port 9000 --no-browser
sleep infinity
