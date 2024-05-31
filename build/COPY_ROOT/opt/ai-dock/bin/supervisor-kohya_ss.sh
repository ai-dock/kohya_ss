#!/bin/bash

trap cleanup EXIT

LISTEN_PORT=${KOHYA_PORT_LOCAL:-17860}
METRICS_PORT=${KOHYA_METRICS_PORT:-27860}
SERVICE_URL="${KOHYA_URL:-}"
QUICKTUNNELS=true

function cleanup() {
    kill $(jobs -p) > /dev/null 2>&1
    rm /run/http_ports/$PROXY_PORT > /dev/null 2>&1
}

function start() {
    if [[ ! -v KOHYA_PORT || -z $KOHYA_PORT ]]; then
        KOHYA_PORT=${KOHYA_PORT_HOST:-7860}
    fi
    PROXY_PORT=$KOHYA_PORT
    SERVICE_NAME="Kohya's GUI"
    
    file_content="$(
      jq --null-input \
        --arg listen_port "${LISTEN_PORT}" \
        --arg metrics_port "${METRICS_PORT}" \
        --arg proxy_port "${PROXY_PORT}" \
        --arg proxy_secure "${PROXY_SECURE,,}" \
        --arg service_name "${SERVICE_NAME}" \
        --arg service_url "${SERVICE_URL}" \
        '$ARGS.named'
    )"
    
    printf "%s" "$file_content" > /run/http_ports/$PROXY_PORT
    
    printf "Starting $SERVICE_NAME...\n"
    
    PLATFORM_FLAGS=
    if [[ $XPU_TARGET = "AMD_GPU" ]]; then
        PLATFORM_FLAGS="--use-rocm"
    fi

    BASE_FLAGS="--headless"
    
    # Delay launch until micromamba is ready
    if [[ -f /run/workspace_sync || -f /run/container_config ]]; then
        fuser -k -SIGTERM ${LISTEN_PORT}/tcp > /dev/null 2>&1 &
        wait -n
        /usr/bin/python3 /opt/ai-dock/fastapi/logviewer/main.py \
            -p $LISTEN_PORT \
            -r 5 \
            -s "${SERVICE_NAME}" \
            -t "Preparing ${SERVICE_NAME}" &
        fastapi_pid=$!
        
        while [[ -f /run/workspace_sync || -f /run/container_config ]]; do
            sleep 1
        done
        
        kill $fastapi_pid
        wait $fastapi_pid 2>/dev/null
    fi
    
    fuser -k -SIGKILL ${LISTEN_PORT}/tcp > /dev/null 2>&1 &
    wait -n
    
    FLAGS_COMBINED="${PLATFORM_FLAGS} ${BASE_FLAGS} $(cat /etc/kohya_ss_flags.conf)"
    printf "Starting %s...\n" "${SERVICE_NAME}"
    
    cd /opt/kohya_ss &&
    exec micromamba run -n kohya_ss -e LD_PRELOAD=libtcmalloc.so python kohya_gui.py \
        ${FLAGS_COMBINED} --server_port ${LISTEN_PORT}
}

start 2>&1