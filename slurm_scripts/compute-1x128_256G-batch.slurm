#!/bin/bash
#SBATCH --job-name=spark-pi
#SBATCH --partition=compute
#SBATCH --account=csd939
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=128
#SBATCH --mem-per-cpu=1900
#SBATCH --time=00:30:00
#SBATCH --output="joblogs/slurm-%A_%a.out"

SLURM_JOB_ID="$(squeue -u $LOGNAME |grep $HOSTNAME | awk '{print $1}')"
JOB_DIR=/scratch/${USER}/job_${SLURM_JOB_ID}
REPO_DIR=/home/${USER}/telescope_expanse_tutorial
cd ${REPO_DIR}/slurm_scripts

/bin/bash launch-spark.sh
/bin/bash bootstrap_env.sh

#load ucsdnt s3 key into the environment 
source /expanse/lustre/projects/csd939/kmok/.ucsdnts3.key

# PYSPARK_PYTHON=./venv/bin/python 
# PYSPARK_DRIVER_PYTHON=./venv/bin/python 

batch_script="${REPO_DIR}/example_ft_batch/count-dstnet.py"

# Submit batch job
/scratch/${USER}/job_${SLURM_JOB_ID}/spark-3.2.1/bin/spark-submit \
--conf spark.pyspark.driver.python=${JOB_DIR}/.venv/bin/python \
--conf spark.pyspark.python=${JOB_DIR}/.venv/bin/python \
--packages org.apache.spark:spark-avro_2.12:3.2.1,org.apache.hadoop:hadoop-aws:3.3.1,com.amazonaws:aws-java-sdk-bundle:1.12.262 "$batch_script"
