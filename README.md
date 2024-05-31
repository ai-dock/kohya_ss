[![Docker Build](https://github.com/ai-dock/kohya_ss/actions/workflows/docker-build.yml/badge.svg)](https://github.com/ai-dock/kohya_ss/actions/workflows/docker-build.yml)

# Stable Diffusion WebUI Docker Image

Run [Kohya's GUI](https://github.com/bmaltais/kohya_ss) in a docker container locally or in the cloud.

>[!NOTE]  
>These images do not bundle models or third-party configurations. You should use a [provisioning script](https://github.com/ai-dock/base-image/wiki/4.0-Running-the-Image#provisioning-script) to automatically configure your container. You can find examples in `config/provisioning`.

## Documentation

All AI-Dock containers share a common base which is designed to make running on cloud services such as [vast.ai](https://link.ai-dock.org/vast.ai) and [runpod.io](https://link.ai-dock.org/template) as straightforward and user friendly as possible.

Common features and options are documented in the [base wiki](https://github.com/ai-dock/base-image/wiki) but any additional features unique to this image will be detailed below.


#### Version Tags

The `:latest` tag points to `:latest-cuda`

Tags follow these patterns:

##### _CUDA_
- `:cuda-[x.x.x]-[base|runtime]-[ubuntu-version]`

- `:latest-cuda` &rarr; `:cuda-11.8.0-base-22.04`

##### _ROCm_
- `:rocm-[x.x.x]-runtime-[ubuntu-version]`

- `:latest-rocm` &rarr; `:rocm-5.7-runtime-22.04`

##### _CPU_
- `:cpu-ubuntu-[ubuntu-version]`

- `:latest-cpu` &rarr; `:cpu-22.04` 

Browse [here](https://github.com/ai-dock/stable-diffusion-webui/pkgs/container/stable-diffusion-webui) for an image suitable for your target environment.

Supported Python versions: `3.10`

Supported Platforms: `NVIDIA CUDA`, `AMD ROCm`

## Additional Environment Variables

| Variable                 | Description |
| ------------------------ | ----------- |
| `AUTO_UPDATE`            | Update Kohya_ss on startup (default `false`) |
| `KOHYA_BRANCH`           | Kohya_ss branch/commit hash for auto update. (default `master`) |
| `KOHYA_FLAGS`            | Startup flags |
| `KOHYA_PORT_HOST`        | Kohya's GUI port (default `7860`) |
| `KOHYA_URL`              | Override `$DIRECT_ADDRESS:port` with URL for Kohya's GUI |

See the base environment variables [here](https://github.com/ai-dock/base-image/wiki/2.0-Environment-Variables) for more configuration options.

### Additional Micromamba Environments

| Environment    | Packages |
| -------------- | ----------------------------------------- |
| `kohya`        | Kohya's GUI and dependencies |

This micromamba environment will be activated on shell login.

See the base micromamba environments [here](https://github.com/ai-dock/base-image/wiki/1.0-Included-Software#installed-micromamba-environments).


## Additional Services

The following services will be launched alongside the [default services](https://github.com/ai-dock/base-image/wiki/1.0-Included-Software) provided by the base image.

### Kohya's GUI

The service will launch on port `7860` unless you have specified an override with `KOHYA_PORT`.

You can set startup flags by using variable `KOHYA_FLAGS`.

To manage this service you can use `supervisorctl [start|stop|restart] kohya`.

>[!NOTE]
>All services are password protected by default. See the [security](https://github.com/ai-dock/base-image/wiki#security) and [environment variables](https://github.com/ai-dock/base-image/wiki/2.0-Environment-Variables) documentation for more information.


## Pre-Configured Templates

**Vast.​ai**

- [Kohya's GUI:latest-cuda](https://link.ai-dock.org/template-vast-kohya_ss)

- [Kohya's GUI:latest-rocm](https://link.ai-dock.org/template-vast-kohya_ss-rocm)

---

_The author ([@robballantyne](https://github.com/robballantyne)) may be compensated if you sign up to services linked in this document. Testing multiple variants of GPU images in many different environments is both costly and time-consuming; This helps to offset costs_