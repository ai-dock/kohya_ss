#!/bin/bash
umask 002
branch=master

source /opt/ai-dock/etc/environment.sh
source /opt/ai-dock/bin/venv-set.sh kohya

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

"$KOHYA_VENV_PIP" install --no-cache-dir \
    -r requirements.txt
