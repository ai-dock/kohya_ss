#!/bin/false

source /opt/ai-dock/etc/environment.sh

build_common_main() {
    # Nothing to do
    :
}

build_common_install_kohya_ss() {
    # Get latest tag from GitHub if not provided
    if [[ -z $KOHYA_BUILD_REF ]]; then
        export KOHYA_BUILD_REF="$(curl -s https://api.github.com/repos/bmaltais/kohya_ss/tags | \
            jq -r '.[0].name')"
        env-store KOHYA_BUILD_REF
    fi

    cd /opt
    git clone --recursive https://github.com/bmaltais/kohya_ss
    cd /opt/kohya_ss
    git checkout "$KOHYA_BUILD_REF"
    printf "\n%s\n" '#myTensorButton, #myTensorButtonStop {display:none!important;}' >> assets/style.css
    "$KOHYA_VENV_PIP" install --no-cache-dir \
        tensorboard \
        -r requirements.txt
}

build_common_run_tests() {
    installed_pytorch_version=$("$KOHYA_VENV_PYTHON" -c "import torch; print(torch.__version__)")
    if [[ "$installed_pytorch_version" != "$PYTORCH_VERSION"* ]]; then
        echo "Expected PyTorch ${PYTORCH_VERSION} but found ${installed_pytorch_version}\n"
        exit 1
    fi
}

build_common_main "$@"