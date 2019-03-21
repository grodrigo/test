#!/bin/bash
if [ $# != 1 ]; then
    echo "usage: $0 <filename> <branch-prefix>"
    echo "e.g. $0 file.txt venv-"
    exit;
fi

#fetch and track remote branches
git branch -r | grep -v '\->' | while read remote; do git branch --track "${remote#origin/}" "$remote"; done

branches=`git for-each-ref --format='%(refname:short)' refs/heads/\*`
curr_branch=`git rev-parse --abbrev-ref HEAD`

filename=$1
branch_prefix=$2

is_file_in_repo=`git ls-files ${filename}`

if [ ! "$is_file_in_repo" ]; then
    echo "file not added in current branch"
    exit
fi

echo "Copy $filename in each 'venv-*' branch from $curr_branch"

##Bash >= version 3.2
read -r -p "Are you sure? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
then
    for branch in ${branches[@]}; do
        if [[ ${branch} != ${curr_branch} ]] && [[ ${branch} == ${branch_prefix}* ]]; then
            echo "Copying $filename in $branch from $curr_branch"
            git checkout "${branch}"
            git checkout "${curr_branch}" -- "$filename"
            git commit -am "Copy $filename in $branch from $curr_branch"
            git push
            echo "-----------------------------"
        fi
    done
    git checkout "${curr_branch}"
    echo "Done"
else
   echo "Bye"
fi
