Analysis of transcriptomics on SAGA
================
Marius Saltvedt
9/28/2021

-   [1 NeLS](#nels)

# 1 NeLS

1.  Start with loging into nels website
2.  Hold you mouse over your name in upper left corner
3.  Click on Connection details
4.  Click on Download key
5.  Place key in any folder on you computer and navigate there through
    terminal
6.  login using ID from nels (Same place you downloaded key)
7.  ssh -i <u150d@nelstor0.cbu.uib.no.key> <u150d@nelstor0.cbu.uib.no>

-   **Transferring files to personal space in NeLS:**  
    scp -i <u150d@nelstor0.cbu.uib.no.key> file-to-send-to-nels
    <u150d@nelstor0.cbu.uib.no>:Personal/

-   **Transfering files to another remote server example:**  
    scp -r \* -i <u150d@nelstor0.cbu.uib.no.key>
    210126_A00943.B.Project_Sandaa-RNA1-2020-12-04
    <USERNAME@saga.sigma2.no>:/cluster/projects/nn9845k/UiB_Sandaa_VirVar_Marine_phytoplankton_NGS_2020/
