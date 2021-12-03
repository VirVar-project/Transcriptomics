Analysis of transcriptomics on SAGA
================
Marius Saltvedt
9/28/2021

-   [1 GIT](#git)
    -   [1.1 Clone git repository](#clone-git-repository)
    -   [1.2 Removing previous commits](#removing-previous-commits)

# 1 GIT

## 1.1 Clone git repository

-   Go to github and find the repository you want to dowload/clone.
    Click on the green `Code` button and copy HHTPS link and paste it as
    below:

<!-- -->

    git clone https://github.com/krabberod/VirVar_transcriptomes.git

## 1.2 Removing previous commits

-   <https://www.youtube.com/watch?v=lVpLoUecZYY>

-   Clone git repository in the Github app.

-   In the Terminal window move or `cd` to git folder.
    e.g. Documents/Github/Transcriptomics.

-   Remove the two last commits. Change number if you want to remove
    more/less

<!-- -->

    git reset --soft HEAD~2

  

-   Then force push this commit to the relevant branch (in our example
    its the `main` branch)

<!-- -->

    git push origin +main --force

  

-   OR <https://sethrobertson.github.io/GitFixUm/fixup.html>  
      

-   **Removing an entire commit**  
    I call this operation “cherry-pit” since it is the inverse of a
    “cherry-pick”. You must first identify the SHA of the commit you
    wish to remove. You can do this using gitk –date-order or using git
    log –graph –decorate –oneline You are looking for the 40 character
    SHA-1 hash ID (or the 7 character abbreviation). Yes, if you know
    the “^” or “\~” shortcuts you may use those.

<!-- -->

    git rebase -p --onto SHA^ SHA

-   Obviously replace “SHA” with the reference you want to get rid of.
    The “^” in that command is literal.

-   However, please be warned. If some of the commits between SHA and
    the tip of your branch are merge commits, it is possible that git
    rebase -p will be unable to properly recreate them. Please inspect
    the resulting merge topology gitk –date-order HEAD ORIG_HEAD and
    contents to ensure that git did want you wanted. If it did not,
    there is not really any automated recourse. You can reset back to
    the commit before the SHA you want to get rid of, and then
    cherry-pick the normal commits and manually re-merge the “bad”
    merges. Or you can just suffer with the inappropriate topology
    (perhaps creating fake merges git merge –ours otherbranch so that
    subsequent development work on those branches will be properly
    merged in with the correct merge-base).
