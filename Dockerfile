ARG DOCKER_REPO="localhost"

FROM ${DOCKER_REPO}/python:3.8.8-slim-buster AS base

# Build ARGs
ARG BOT_USER="nobody"
ARG BOT_GROUP="nogroup"
ARG BOT_HOME_DIR="/srv"
ARG APP_DIR="${BOT_HOME_DIR}/app"

# Export ARGs as ENV vars so they can be shared among steps
ENV BOT_USER="${BOT_USER}" \
    BOT_GROUP="${BOT_GROUP}" \
    BOT_HOME_DIR="${BOT_HOME_DIR}" \
    APP_DIR="${APP_DIR}" \
    DEBIAN_FRONTEND=noninteractive \
    APT_OPTS="-q=2 --no-install-recommends --yes"

# Prepare a directory to run with an unprivileged user
RUN chown -cR "${BOT_USER}:${BOT_GROUP}" ${BOT_HOME_DIR} && \
    usermod -d ${BOT_HOME_DIR} ${BOT_USER}

################################################################################

FROM base AS builder-deps

# Install build dependencies
RUN apt-get ${APT_OPTS} update && \
    apt-get ${APT_OPTS} install \
    build-essential \
    procps  \
    libtiff5-dev \
    libjpeg62-turbo-dev \
    zlib1g-dev \
    libfreetype6-dev \
    liblcms2-dev \
    libwebp-dev \
    tcl8.6-dev \
    tk8.6-dev \
    python3-tk

################################################################################

FROM builder-deps AS builder

# Build the code as unprivileged user
#USER ${BOT_USER}
WORKDIR ${BOT_HOME_DIR}
COPY src ${APP_DIR}/
COPY tools ${APP_DIR}/tools
COPY requirements.txt ${APP_DIR}/
RUN python3 -m venv .venv && \
#    source .venv/bin/activate && \
    .venv/bin/python3 -m pip install --requirement ${APP_DIR}/requirements.txt && \
    cd ${APP_DIR}/ && \
    chown -cR ${BOT_USER}:${BOT_GROUP} ${BOT_HOME_DIR} && \
    rm -rf ${BOT_HOME_DIR}/.cache

################################################################################

FROM base AS app

# Address the pip warning regarding PATH
ENV PATH="${PATH}:${BOT_HOME_DIR}/.local/bin"

# Import built code from previous step
COPY --from=builder ${BOT_HOME_DIR} ${BOT_HOME_DIR}

# Adjust privileges
RUN chown -R "${BOT_USER}:${BOT_GROUP}" ${BOT_HOME_DIR} && \
    usermod -d ${BOT_HOME_DIR} ${BOT_USER} && \
    chmod +x ${APP_DIR}/tools/entrypoint.sh

# Set up to run as an unprivileged user
USER ${BOT_USER}
WORKDIR ${APP_DIR}
ENTRYPOINT ["./tools/entrypoint.sh"]
