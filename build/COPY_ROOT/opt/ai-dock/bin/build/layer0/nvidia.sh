#!/bin/false

build_nvidia_main() {
    build_nvidia_install_kohya_ss
    build_common_run_tests
    build_nvidia_run_tests
}

build_nvidia_install_kohya_ss() {
    micromamba run -n kohya_ss ${PIP_INSTALL} \
        nvidia-ml-py3
    
    micromamba install -n kohya_ss -c xformers -y \
        xformers \
        pytorch=${PYTORCH_VERSION} \
        pytorch-cuda="$(cut -d '.' -f 1,2 <<< "${CUDA_VERSION}")"

    build_common_install_kohya_ss
    cd /opt/kohya_ss
    micromamba run -n kohya_ss $PIP_INSTALL tensorflow tensorboard tensorrt==10.0.1 \
        -r requirements_linux_docker.txt
    
    ln -s /opt/micromamba/envs/kohya_ss/lib/python${PYTHON_VERSION}/site-packages/tensorrt_libs/libnvinfer.so.10 \
        /opt/micromamba/envs/kohya_ss/lib/libnvinfer.so
    ln -s /opt/micromamba/envs/kohya_ss/lib/python${PYTHON_VERSION}/site-packages/tensorrt_libs/libnvinfer_plugin.so.10 \
        /opt/micromamba/envs/kohya_ss/lib/libnvinfer_plugin.so
}

build_nvidia_run_tests() {
    installed_pytorch_cuda_version=$(micromamba run -n kohya_ss python -c "import torch; print(torch.version.cuda)")
    if [[ "$CUDA_VERSION" != "$installed_pytorch_cuda"* ]]; then
        echo "Expected PyTorch CUDA ${CUDA_VERSION} but found ${installed_pytorch_cuda}\n"
        exit 1
    fi
}

build_nvidia_main "$@"