#!/bin/bash

set -ex

# https://apple.stackexchange.com/questions/83939/compare-multi-digit-version-numbers-in-bash/123408#123408
function version { echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'; }

DOCKER_IMAGE="lambci/lambda:build-python"
PKG_DIR="python"
PYTHON_VERSION=${1:-3.8}
PACKAGE_VERSION=$PYTHON_VERSION
PIP="pip"
ARCHITECTURE=${2:-"arm64"}
DOCKER_SUFFIX=""

rm -rf ${PKG_DIR} && mkdir -p ${PKG_DIR}

if [ $(version $PYTHON_VERSION) -ge $(version "3.9") ]; then
    DOCKER_IMAGE="public.ecr.aws/sam/build-python3.9:1.83.0"
    PIP="pip3"
    DOCKER_SUFFIX="-x86_64"
fi
if [ $(version $PYTHON_VERSION) -ge $(version "3.10") ]; then
    # DOCKER_IMAGE="public.ecr.aws/sam/build-python3.10:1.83.0"
    DOCKER_IMAGE="public.ecr.aws/sam/build-python3.10"
    PIP="pip3"
    DOCKER_SUFFIX="-$ARCHITECTURE"
fi

docker run -v $(pwd):/var/task ${DOCKER_IMAGE}${DOCKER_SUFFIX} \
${PIP} install -U pip wheels setuptools && \
${PIP} install -r requirements.txt -t ${PKG_DIR}

zip -r releases/aws-lambda-layer-${PACKAGE_VERSION}${DOCKER_SUFFIX}.zip python