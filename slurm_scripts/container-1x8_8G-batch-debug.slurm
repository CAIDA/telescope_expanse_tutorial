#!/bin/bash -e
#SBATCH --job-name=CAIDAGOCONTAINER
#SBATCH --partition=debug
#SBATCH --account=csd939
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=1000
#SBATCH --time=00:10:00
#SBATCH --output="joblogs/slurm-%A_%a.out"

module load slurm
module load cpu/0.15.4
module load singularitypro

SLURM_JOB_ID="$(squeue -u $LOGNAME |grep $HOSTNAME | awk '{print $1}')"
JOB_OUTPUT_DIR=/expanse/lustre/projects/csd939/${USER}/golang_container_output
mkdir -p $JOB_OUTPUT_DIR
SCRATCH_DIR="/scratch/${USER}/job_${SLURM_JOB_ID}"

singularity exec --env-file /expanse/lustre/projects/csd939/kmok/.ucsdnts3.env \
    --bind /expanse/lustre/projects/csd939/${USER}/golang_container_output:/output,/tmp,/scratch \
    /expanse/lustre/projects/csd939/kmok/shared_data/expanse-uscdnt-golang.sif \
    /go/bin/ucsdntexample -o /output -c 100 -e "2025-01-25T02:59:59Z"
