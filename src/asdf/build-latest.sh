#!/bin/bash

set -o nounset
set -o pipefail
set -o errexit
# set -o xtrace

IMAGE_REPOSITORY="${1}"

ROOT_DIR_LOCATION_="${ROOT_DIR_LOCATION:-$(pwd)/../..}"
UTILS_DIR_LOCATION="${ROOT_DIR_LOCATION_}/utils"

# fetch asdf latest version
ASDF_LATEST=$("${UTILS_DIR_LOCATION}/github-get-latest-repo-tag.sh" asdf-vm/asdf)
echo "ASDF_LATEST: ${ASDF_LATEST}"

./build.sh "${IMAGE_REPOSITORY}" "${ASDF_LATEST}"
