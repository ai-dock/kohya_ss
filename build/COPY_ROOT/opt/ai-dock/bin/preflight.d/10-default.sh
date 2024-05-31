#!/bin/false
# This file will be sourced in init.sh

function preflight_main() {
    preflight_copy_notebook
    preflight_update_kohya_ss
    printf "%s" "${KOHYA_FLAGS}" > /etc/kohya_ss_flags.conf
}

function preflight_copy_notebook() {
    if micromamba env list | grep 'jupyter' > /dev/null 2>&1;  then
        if [[ ! -f "${WORKSPACE}kohya.ipynb" ]]; then
            cp /usr/local/share/ai-dock/kohya.ipynb ${WORKSPACE}
        fi
    fi
}

function preflight_update_kohya_ss() {
    if [[ ${AUTO_UPDATE,,} == "true" ]]; then
        /opt/ai-dock/bin/update-kohya_ss.sh
    else
        printf "Skipping auto update (AUTO_UPDATE != true)"
    fi
}

preflight_main "$@"