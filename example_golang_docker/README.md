# Running your docker container on Expanse
This example shows you how to create a singularity container to execute a simple analysis code implemented in Golang. The code directly streams UCSD-NT pcap files from CAIDA's Swift object storage (via S3).

## Step 1: Implement your analysis
We implemented a simple Golang package with example code for accessing UCSD-NT's pcaps (Github repo: https://github.com/CAIDA/goucsdnt).
In the `cmd` folder, we created two examples --- `analyzepcaps3` and `ucsdntpcaplist`.
`analyzepcaps3` reads pcaps between two given timestamps and counts the number of packets that matching the Mirai malware signature from each source IP address. We will run this example in this tutorial.
`ucsdntpcaplist` lists the files available on the storage container. You can use this script to test your connectivity to our storage cluster.

## Step 2: Prepare the Docker image
### 2.1 Implement your Dockerfile
This directory offers a simple Dockerfile example. This example clone our sample code from github, install necessary golang dependency, and build the code into binary.
### 2.2 Create an image repository on Docker Hub
[Docker Hub](https://hub.docker.com) is a public marketplace for hosting Docker images. After you created (and signed in) your account, 
 1. Select **Create repository**
 2. On the **Create repository** page, enter the following information:
	-   **Repository name**  -  `expanse-uscdnt-golang`
	-   **Short description**  - feel free to enter a description if you'd like
	-   **Visibility**  - select  **Public**  to allow others to pull your customized to-do app
In this tutorial, we will push our image into this repository.
### 2.3 Build the docker image locally
As SDSC Expanse does not install Docker and provide `sudo` to users, you have to build the image on your local machine. Install [docker](https://docs.docker.com/engine/install/) if necessary.
`docker build -t <your docker hub username>/<your dockerhub repo>:<tag> .`
For example, 
`docker build  -t caidaricky/expanse-uscdnt-golang:0.1.3 .`
### 2.4 Push the image to Docker Hub
You upload the built image to Docker hub. Note that free account only allow you to have one private image. As your image is public, everyone can pull and inspect your code and credentials (if you leave them into the image). **Do not put any credentials/keys into the image. Import them in runtime.**
To push your image:
`docker push <your docker hub username>/<your dockerhub repo>:<tag>`
For this tutorial:
`docker push caidaricky/expanse-uscdnt-golang:0.1.3`

## Step 3: Build singularity image (on your machine)
### 3.1 Install singularity
For debian/Ubuntu, generate the command using the following web page
https://neuro.debian.net/install_pkg.html?p=singularity-container
For example, on Ubuntu 20.04
```
$ wget -O- http://neuro.debian.net/lists/focal.us-ca.full | sudo tee /etc/apt/sources.list.d/neurodebian.sources.list
$ sudo apt-key adv --recv-keys --keyserver hkps://keyserver.ubuntu.com 0xA5D32F012649A5A9
$ sudo apt-get update
$ sudo apt-get install singularity-container
```
### 3.2 Build singularity image from your dockerhub image
Singularity supports converting docker images directly from Docker Hub using this command. Singularity image uses file extension `.sif`.
`sudo singularity build <singularity_image_name>.sif docker://<path to your dockerhub image>`
Our example: 
`sudo singularity build expanse-uscdnt-golang.sif docker://caidaricky/expanse-uscdnt-golang:0.1.3`

### 3.3 Transfer the image to Expanse
You can use the Lustre storage on SDSC Expanse to store your image. 
For example, we uploaded the image we built to this project's folder.
`scp expanse-uscdnt-golang.sif expanse:/expanse/lustre/projects/csd939/kmok/shared_data/`

## Step 4. Execute the singularity image
Similar to FlowTuple batch analysis, we use slurm to schedule the execution of the image. We prepared a sample script (`slurm_scipts/container-1x8_8G-batch-debug.slurm` ). To schedule this job, run
`sbatch container-1x8_8G-batch-debug.slurm`
After the job is executed, you will be able to find the results in the output directory.
`/expanse/lustre/projects/csd939/<your username>/golang_container_output`
