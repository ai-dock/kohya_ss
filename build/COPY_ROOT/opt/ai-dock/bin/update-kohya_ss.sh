#!/bin/bash
umask 002
branch=master

if [[ -n "${KOHYA_BRANCH}" ]]; then
    branch="${KOHYA_BRANCH}"
fi

# -b flag has priority
while getopts b: flag
do
    case "${flag}" in
        b) branch="$OPTARG";;
    esac
done

printf "Updating Kohya's GUI (${branch})...\n"

cd /opt/kohya_ss
git fetch --tags
git checkout ${branch}
git pull
git submodule update --recursive

micromamba run -n koya_ss ${PIP_INSTALL} -r requirements.txt
