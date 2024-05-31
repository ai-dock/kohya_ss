# For build automation - Allows building from any ai-dock base image
# Use a *cuda*base* image as default because pytorch brings the libs
ARG IMAGE_BASE="ghcr.io/ai-dock/python:3.10-cuda-12.1.1-runtime-22.04"
FROM ${IMAGE_BASE}

LABEL org.opencontainers.image.source https://github.com/ai-dock/kohya_ss
LABEL org.opencontainers.image.description "Kohya's GUI docker images for use in GPU cloud and local environments. Includes AI-Dock base for authentication and improved user experience."
LABEL maintainer="Rob Ballantyne <rob@dynamedia.uk>"

ARG PYTHON_VERSION="3.10"
ENV PYTHON_VERSION="${PYTHON_VERSION}"

ARG PYTORCH_VERSION="2.1.2"
ENV PYTORCH_VERSION="${PYTORCH_VERSION}"

ARG KOHYA_TAG
ENV KOHYA_TAG=${KOHYA_TAG}

ENV IMAGE_SLUG="kohya_ss"
ENV OPT_SYNC=kohya_ss

# Copy early so we can use scripts in the build - Changes to these files will invalidate the cache and cause a rebuild.
COPY --chown=0:1111 ./COPY_ROOT/ /

# Use build scripts to ensure we can build all targets from one Dockerfile in a single layer.
# Don't put anything heavy in here - We can use multi-stage building above if necessary.

ARG IMAGE_BASE
RUN set -eo pipefail && /opt/ai-dock/bin/build/layer0/init.sh | tee /var/log/build.log

# Must be set after layer0
ENV MAMBA_DEFAULT_ENV=kohya_ss
ENV MAMBA_DEFAULT_RUN="micromamba run -n ${MAMBA_DEFAULT_ENV}"

# Copy overrides and models into later layers for fast rebuilds
COPY --chown=0:1111 ./COPY_ROOT_EXTRA/ /
RUN set -eo pipefail && /opt/ai-dock/bin/build/layer1/init.sh | tee -a /var/log/build.log

# Keep init.sh as-is and place additional logic in /opt/ai-dock/bin/preflight.sh
CMD ["init.sh"]
