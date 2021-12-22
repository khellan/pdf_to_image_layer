#!/bin/sh

# Prepare and package native binaries for use in lambdas

PROFILE=${1:-default}
PYTHON_VERSION=3.9

# Use a work directory to avoid polluting our source code.
mkdir tmp_work_dir
cd tmp_work_dir
mkdir {bin,lib}
cp ../install.sh .
cp ../requirements.txt .
docker run \
    -v "$PWD":/var/task \
    "public.ecr.aws/sam/build-python${PYTHON_VERSION}" \
    /bin/sh install.sh ${PYTHON_VERSION}

# Package layer
zip -r9 pdf_to_image.zip \
    bin/pdftocairo bin/pdfinfo bin/pdftoppm \
    lib/lib* \
    python 

# Deploy layer to AWS
aws --profile ${PROFILE} --region eu-central-1 lambda publish-layer-version \
    --layer-name pdf_to_image \
    --description "Poppler binaries" \
    --zip-file fileb://pdf_to_image.zip \
    --compatible-runtimes "python3.9"