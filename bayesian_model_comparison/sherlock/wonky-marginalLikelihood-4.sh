#!/bin/bash
#
#all commands that start with SBATCH contain commands that are just used by SLURM for scheduling
#################
#set a job name
#SBATCH --job-name=mhtgen
#################
#a file for job output, you can check job progress
#SBATCH --output=out/fbt-gen.out
#################
# a file for errors from the job
#SBATCH --error=err/fbt-gen.err
#################
#time you think you need; default is one hour
#in minutes in this case, hh:mm:ss
#SBATCH --time=20:00:00
#################
#quality of service; think of it as job priority
#SBATCH --qos=normal
#################
#number of nodes you are requesting
#SBATCH --nodes=1
#################
#memory per node; default is 4000 MB per CPU
#SBATCH --mem=4000
#you could use --mem-per-cpu; they mean what we are calling cores
#################
#tasks to run per node; a "task" is usually mapped to a MPI processes.
# for local parallelism (OpenMP or threads), use "--ntasks-per-node=1 --cpus-per-task=16" instead
#SBATCH --ntasks-per-node=1
#################

#now run normal batch commands
~/webppl-github/webppl wonky-modelselec.wppl  --require wonkyutils --require webppl-json priorOnly number none $SLURM_ARRAY_TASK_ID