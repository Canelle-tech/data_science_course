#!/bin/bash
REGION="global" # Keep this global.

# This makes sure that we are uploading our code from the proper path.
# Don't change this line.
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )


gcloud builds submit \
    --region=${REGION} \
    --config="${SCRIPT_DIR}/cloudbuild_backend_v1.yaml" \
    ${SCRIPT_DIR}/../

