# This script should be sourced from a slurm script.
# It installs a local Spark cluster and starts it on every node.
# Limitation: two parallel jobs might cause issues, since the $base_dir is shared.
# A single job with multiple nodes should work fine.

module purge
module load slurm
module load cpu/0.15.4
module load spark/3.2.1
module load hadoop

SLURM_JOB_ID="$(squeue -u $LOGNAME |grep $HOSTNAME | awk '{print $1}')"

# base_dir=/expanse/lustre/scratch/$USER/temp_project/spark-3.2.1
base_dir="/scratch/${USER}/job_${SLURM_JOB_ID}/spark-3.2.1"

if [ ! -d "$base_dir" ]; then
  mkdir -p "$base_dir"
  cp -r /cm/shared/apps/spack/cpu/opt/spack/linux-centos8-zen/gcc-8.3.1/spark-3.2.1-bin-hadoop3.2/* "$base_dir"

  # Download external modules and store them to job's scratch space
  # Check version compatibility before downloading
  ext_jars="$base_dir/ext_jars"
  if [ ! -e "${ext_jars}/hadoop-aws-3.3.1.jar" ]; then
    wget -P "$ext_jars" https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.3.1/hadoop-aws-3.3.1.jar
  fi
  if [ ! -e "${ext_jars}/aws-java-sdk-bundle-1.11.901.jar" ]; then
    wget -P "$ext_jars" https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.11.901/aws-java-sdk-bundle-1.11.901.jar
  fi
fi

# Setup non-default Spark diretories
export SPARK_CONF_DIR=$base_dir/conf
export SPARK_WORKER_DIR=$base_dir/worker
export SPARK_LOG_DIR=$base_dir/logs

# Local scratch space is faster for caching
export SPARK_LOCAL_DIRS="/scratch/${USER}/job_${SLURM_JOB_ID}/spark_scratch"

SPARK_WORKER_CORES="$SLURM_CPUS_ON_NODE"
SPARK_WORKER_MEMORY="$(( $SPARK_WORKER_CORES * $SLURM_MEM_PER_CPU ))M"

# Generate spark-env.sh configuration
spark_env="$SPARK_CONF_DIR/spark-env.sh"
echo "SPARK_LOG_DIR=$SPARK_LOG_DIR" > "$spark_env"
echo "SPARK_WORKER_DIR=$SPARK_WORKER_DIR" >> "$spark_env"
echo "SPARK_LOCAL_DIRS=$SPARK_LOCAL_DIRS" >> "$spark_env"
echo "SLURM_MEM_PER_CPU=$SLURM_MEM_PER_CPU" >> "$spark_env"
echo "SPARK_WORKER_CORES=$SPARK_WORKER_CORES" >> "$spark_env"
echo "SPARK_WORKER_MEMORY=$SPARK_WORKER_MEMORY" >> "$spark_env"
echo "SPARK_MASTER_WEBUI_PORT=4020" >> "$spark_env"

# The Python versions need to match, and need to be exported for the workers to pick it up
echo "export PYSPARK_PYTHON=/usr/bin/python3.9" >> "$spark_env"
echo "export PYSPARK_DRIVER_PYTHON=/usr/bin/python3.9" >> "$spark_env"

# Add hostname to list of available workers
scontrol show hostname "$SLURM_JOB_NODELIST" > "$SPARK_CONF_DIR/workers"

# Generate spark-defaults.conf
conf="$SPARK_CONF_DIR/spark-defaults.conf"
echo "spark.default.parallelism $(( $SLURM_CPUS_PER_TASK * $SLURM_NTASKS ))" > "$conf"
echo "spark.submit.deployMode client" >> "$conf"
echo "spark.master spark://$(hostname):7077" >> "$conf"
echo "spark.cores.max $(( $SLURM_CPUS_PER_TASK * $SLURM_NTASKS ))" >> "$conf"
echo "spark.executor.cores $SLURM_CPUS_PER_TASK" >> "$conf"
echo "spark.executor.memory $(( $SLURM_CPUS_PER_TASK * $SLURM_MEM_PER_CPU ))M" >> "$conf"

### LAUNCH ###

# Set two additional variables needed for execution
export JAVA_HOME=/cm/shared/apps/spack/cpu/opt/spack/linux-centos8-zen/gcc-8.3.1/openjdk-11.0.2-k5ezeyjgjeqmehyvrmmpymaguuf2qzsk
export SPARK_HOME="$base_dir"

"$SPARK_HOME/sbin/start-all.sh"

. wait-worker.sh
