#!/bin/bash

set -o nounset
set -o pipefail
# set -o errexit
# set -o xtrace

IMAGE_REPOSITORY="${1}"

ROOT_DIR_LOCATION_="${ROOT_DIR_LOCATION:-$(pwd)/../..}"
UTILS_DIR_LOCATION="${ROOT_DIR_LOCATION_}/utils"

AWSCLI_LATEST=$("${UTILS_DIR_LOCATION}/dockerhub-get-repository-latest-image.sh" "amazon/aws-cli" '^([0-9-]+[.]?)+$')
TERRAFORM_LATEST=$("${UTILS_DIR_LOCATION}/github-get-latest-repo-release.sh" "hashicorp/terraform")

echo "AWSCLI_LATEST: ${AWSCLI_LATEST}"
echo "TERRAFORM_LATEST: ${TERRAFORM_LATEST}"

./build.sh "${IMAGE_REPOSITORY}" "${AWSCLI_LATEST}" "${TERRAFORM_LATEST}"
