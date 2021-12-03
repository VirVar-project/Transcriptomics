Analysis of transcriptomics on SAGA
================
Marius Saltvedt
9/28/2021

-   [1 ](#section)
-   [2 ](#section-1)
-   [3 SAGA](#saga)
    -   [3.1 Common commands](#common-commands)
    -   [3.2 Cancelling jobs](#cancelling-jobs)
    -   [3.3 putting jobs on hold](#putting-jobs-on-hold)
    -   [3.4 Modules  
        ](#modules-)
    -   [3.5 Starting an interactive job on saga  
        ](#starting-an-interactive-job-on-saga-)
    -   [3.6 Creating alias on saga](#creating-alias-on-saga)
    -   [3.7 Change group affiliation on files  
        ](#change-group-affiliation-on-files-)

# 1 

# 2 

# 3 SAGA

## 3.1 Common commands

-   **login:** ssh <USERNAME@saga.sigma2.no>  

-   **Project folder:** /cluster/projects/nn9845k  
      
      

-   **Go to home directory:** `cd $HOME OR cd OR ~`  

-   **See allocated storage:** `dusage`  

-   **See CPU hours used/remaining:** `cost`  

-   **Work space:** `cd $USERWORK`  
    Personal allocated temporary space, deleted after 42 days  

-   **View computing nodes:** `freepe`  
    View computing nodes, see if there are free allocated spaces and
    view workload  

-   **View current CPU hours:** `qsumm`  

-   **Watch the queue system:** `squeue -u MyUsername` OR
    `squeue -j JobId`  
      

## 3.2 Cancelling jobs

    scancel JobId                # Cancel job with id JobId (as returned from sbatch)
    scancel --user=MyUsername    # Cancel all your jobs
    scancel --account=MyProject  # Cancel all jobs in MyProject

  

## 3.3 putting jobs on hold

    scontrol requeue JobId  # Requeue a running job. The job will be stopped, and its state changed to pending.

    scontrol hold JobId     # Hold a pending job. This prevents the queue system from starting the job. The job reason will be set to JobHeldUser.

    scontrol release JobId  # Release a held job. This allows the queue system to start the job.

    sbatch --hold JobScript # Submit a job and put it on hold immediately 

  

## 3.4 Modules 

`module avail` - to see available modules  
`module load` - load programs into memory  
`module purge` - unload all loaded programs  
`module list` - current loaded program  
  

## 3.5 Starting an interactive job on saga 

This helps avoiding to wait in queue and with this you can run as many
script as you want within that time limit and cpu hours.

    srun --account=nn9845k --mem-per-cpu=10G --time=10:00:00 --cpus-per-task=8 --pty bash -i

  

## 3.6 Creating alias on saga

-   In your home directory (where you start when you login to saga)
    type:

<!-- -->

    vim .bash_profile

  

-   Under `User specific environment and startup programs` you can add
    as many aliases as you want. Below you will find a few examples:

<!-- -->

    # .bash_profile

    # Get the aliases and functions
    if [ -f ~/.bashrc ]; then
            . ~/.bashrc
    fi

    # User specific environment and startup programs
    alias virvar='cd /cluster/projects/nn9845k'
    alias home='cd $home'
    alias work='cd $USERWORK'
    alias sq='squeue -u nis005'

    PATH=$PATH:$HOME/.local/bin:$HOME/bin

    export PATH

-   In the above example we can now use these aliases as commands. So
    when I type:  

    -   virvar, go to project folder
    -   home, go to home folder
    -   work, go to personal working environment
    -   sq, see jobs running  
          

## 3.7 Change group affiliation on files 

This will change the group affiliation on all the files in the project
fold. This is necessary to do if transferred files are still linked to
another project or person. You can see group affiliation by typing
`ls -l`.

    chgrp -R nn9845k /cluster/projects/nn9845k/

  
  
  
