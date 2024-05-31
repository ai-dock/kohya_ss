#!/bin/bash

trap cleanup EXIT

LISTEN_PORT=${TENSORBOARD_PORT_LOCAL:-16006}
METRICS_PORT=${TENSORBOARD_METRICS_PORT:-26006}
SERVICE_URL="${TENSORBOARD_URL:-}"
QUICKTUNNELS=true

function cleanup() {
    kill $(jobs -p) > /dev/null 2>&1
    rm /run/http_ports/$PROXY_PORT > /dev/null 2>&1
}

function start() {
    if [[ ! -v TENSORBOARD_PORT || -z $TENSORBOARD_PORT ]]; then
        TENSORBOARD_PORT=${TENSORBOARD_PORT_HOST:-6006}
    fi
    PROXY_PORT=$TENSORBOARD_PORT
    SERVICE_NAME="Tensorboard"
    
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
    
    printf "Starting %s...\n" "${SERVICE_NAME}"
    
    exec micromamba run -n kohya_ss -e LD_PRELOAD=libtcmalloc.so tensorboard \
        --port ${LISTEN_PORT} \
        --logdir /opt/kohya_ss/dataset
}

start 2>&1