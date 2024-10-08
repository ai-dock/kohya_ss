# For build automation - Allows building from any ai-dock base image
# Use a *cuda*base* image as default because pytorch brings the libs
ARG IMAGE_BASE="ghcr.io/ai-dock/python:3.10-v2-cuda-12.1.1-base-22.04"
FROM ${IMAGE_BASE}

LABEL org.opencontainers.image.source https://github.com/ai-dock/kohya_ss
LABEL org.opencontainers.image.description "Kohya's GUI docker images for use in GPU cloud and local environments. Includes AI-Dock base for authentication and improved user experience."
LABEL maintainer="Rob Ballantyne <rob@dynamedia.uk>"

ENV KOHYA_VENV=$VENV_DIR/kohya
ENV KOHYA_VENV_PYTHON=$KOHYA_VENV/bin/python
ENV KOHYA_VENV_PIP=$KOHYA_VENV/bin/pip

ENV IMAGE_SLUG="kohya_ss"
ENV OPT_SYNC=kohya_ss

ARG PYTHON_VERSION="3.10"
ENV PYTHON_VERSION="${PYTHON_VERSION}"

# Prepare kohya_ss environment
ARG PYTORCH_VERSION="2.3.0"
ENV PYTORCH_VERSION="${PYTORCH_VERSION}"
COPY --chown=0:1111 ./COPY_ROOT_0/ /
ARG IMAGE_BASE
RUN set -eo pipefail && /opt/ai-dock/bin/build/layer0/init.sh | tee /var/log/build.log

# Install Kohya_ss
ARG KOHYA_BUILD_REF
ENV KOHYA_BUILD_REF=${KOHYA_BUILD_REF}
COPY --chown=0:1111 ./COPY_ROOT_1/ /
RUN set -eo pipefail && /opt/ai-dock/bin/build/layer1/init.sh | tee -a /var/log/build.log

# Copy overrides and models into later layers for fast rebuilds
COPY --chown=0:1111 ./COPY_ROOT_99/ /

#RUN set -eo pipefail && /opt/ai-dock/bin/build/layer99/init.sh | tee -a /var/log/build.log

ENV PYTHON_DEFAULT_VENV=kohya

# Keep init.sh as-is and place additional logic in /opt/ai-dock/bin/preflight.sh
CMD ["init.sh"]
