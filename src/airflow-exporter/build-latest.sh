#!/bin/bash

set -o nounset
set -o pipefail
# set -o errexit
# set -o xtrace

IMAGE_REPOSITORY="${1}"

ROOT_DIR_LOCATION_="${ROOT_DIR_LOCATION:-$(pwd)/../..}"
UTILS_DIR_LOCATION="${ROOT_DIR_LOCATION_}/utils"

AIRFLOW_LATEST=$("${UTILS_DIR_LOCATION}/dockerhub-get-repository-latest-image.sh" "apache/airflow" '^([0-9-]+[.]?)+$')

echo "AIRFLOW_LATEST: ${AIRFLOW_LATEST}"

./build.sh "${IMAGE_REPOSITORY}" "${AIRFLOW_LATEST}"
