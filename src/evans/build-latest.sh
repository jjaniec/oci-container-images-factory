#!/bin/bash

set -o nounset
set -o pipefail
# set -o errexit
# set -o xtrace

IMAGE_REPOSITORY="${1}"

ROOT_DIR_LOCATION_="${ROOT_DIR_LOCATION:-$(pwd)/../..}"
UTILS_DIR_LOCATION="${ROOT_DIR_LOCATION_}/utils"

# fetch evans latest version
EVANS_LATEST=$("${UTILS_DIR_LOCATION}/github-get-latest-repo-release.sh" "ktr0731/evans")
echo "EVANS_LATEST: ${EVANS_LATEST}"

./build.sh "${IMAGE_REPOSITORY}" "${EVANS_LATEST}"
