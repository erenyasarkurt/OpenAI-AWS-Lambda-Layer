#!/bin/bash

set -ex

PKG_DIR="python"
VERSION=${1:-3.8}

rm -rf ${PKG_DIR} && mkdir -p ${PKG_DIR}

docker run --rm -v $(pwd):/foo -w /foo lambci/lambda:build-python${VERSION} \
pip install -r requirements.txt -t ${PKG_DIR}

zip -r releases/openai-aws-lambda-layer.zip python