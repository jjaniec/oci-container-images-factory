#!/bin/bash

set -o nounset
set -o pipefail
# set -o errexit
# set -o xtrace

IMAGE_REPOSITORY="${1}"

ROOT_DIR_LOCATION_="${ROOT_DIR_LOCATION:-$(pwd)/../..}"
UTILS_DIR_LOCATION="${ROOT_DIR_LOCATION_}/utils"

JENKINS_INBOUND_AGENT_LATEST=$("${UTILS_DIR_LOCATION}/dockerhub-get-repository-latest-image.sh" "jenkins/inbound-agent" '^([0-9-]+[.]?)+$')
IMG_LATEST=$(curl -sL https://api.github.com/repos/genuinetools/img/releases/latest | jq -r '.assets[].browser_download_url' | cut -d '/' -f 8 | head -n 1)
AWSCLI_LATEST=$(curl -sL https://api.github.com/repos/aws/aws-cli/tags | jq -r '.[].name' | head -n 1)

echo "JENKINS_INBOUND_AGENT_LATEST: ${JENKINS_INBOUND_AGENT_LATEST}"
echo "IMG_LATEST: ${IMG_LATEST}"
echo "AWSCLI_LATEST: ${AWSCLI_LATEST}"

./build.sh "${IMAGE_REPOSITORY}" "${JENKINS_INBOUND_AGENT_LATEST}" "${IMG_LATEST}" "${AWSCLI_LATEST}"
