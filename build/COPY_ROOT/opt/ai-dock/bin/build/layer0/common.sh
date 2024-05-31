#!/bin/false

source /opt/ai-dock/etc/environment.sh

build_common_main() {
    build_common_create_env
    build_common_install_jupyter_kernels
}

build_common_create_env() {
    apt-get update
    $APT_INSTALL \
        libgl1-mesa-glx \
        libtcmalloc-minimal4

    ln -sf $(ldconfig -p | grep -Po "libtcmalloc_minimal.so.\d" | head -n 1) \
        /lib/x86_64-linux-gnu/libtcmalloc.so
    
    micromamba create -n kohya_ss
    micromamba run -n kohya_ss mamba-skel
    micromamba install -n kohya_ss -y \
        python="${PYTHON_VERSION}" \
        ipykernel \
        ipywidgets \
        nano
    micromamba run -n kohya_ss install-pytorch -v "$PYTORCH_VERSION"
}

build_common_install_jupyter_kernels() {
    micromamba install -n kohya_ss -y \
        ipykernel \
        ipywidgets
    
    kernel_path=/usr/local/share/jupyter/kernels
    
    # Add the often-present "Python3 (ipykernel) as a kohya_ss alias"
    rm -rf ${kernel_path}/python3
    dir="${kernel_path}/python3"
    file="${dir}/kernel.json"
    cp -rf ${kernel_path}/../_template ${dir}
    sed -i 's/DISPLAY_NAME/'"Python3 (ipykernel)"'/g' ${file}
    sed -i 's/PYTHON_MAMBA_NAME/'"kohya_ss"'/g' ${file}
    
    dir="${kernel_path}/kohya_ss"
    file="${dir}/kernel.json"
    cp -rf ${kernel_path}/../_template ${dir}
    sed -i 's/DISPLAY_NAME/'"Kohya's GUI"'/g' ${file}
    sed -i 's/PYTHON_MAMBA_NAME/'"kohya_ss"'/g' ${file}
}

build_common_install_kohya_ss() {
    # Get latest tag from GitHub if not provided
    if [[ -z $KOHYA_TAG ]]; then
        export KOHYA_TAG="$(curl -s https://api.github.com/repos/bmaltais/kohya_ss/tags | \
            jq -r '.[0].name')"
        env-store KOHYA_TAG
    fi

    cd /opt
    git clone --recursive https://github.com/bmaltais/kohya_ss
    cd /opt/kohya_ss
    git checkout "$KOHYA_TAG"
    printf "\n%s\n" '#myTensorButton, #myTensorButtonStop {display:none!important;}' >> assets/style.css
    micromamba run -n kohya_ss $PIP_INSTALL -r requirements.txt
}

build_common_run_tests() {
    installed_pytorch_version=$(micromamba run -n kohya_ss python -c "import torch; print(torch.__version__)")
    if [[ "$installed_pytorch_version" != "$PYTORCH_VERSION"* ]]; then
        echo "Expected PyTorch ${PYTORCH_VERSION} but found ${installed_pytorch_version}\n"
        exit 1
    fi
}

build_common_main "$@"