#!/bin/bash

set -o nounset
set -o pipefail
# set -o errexit
# set -o xtrace

IMAGE_REPOSITORY="${1}"

ROOT_DIR_LOCATION_="${ROOT_DIR_LOCATION:-$(pwd)/../..}"
UTILS_DIR_LOCATION="${ROOT_DIR_LOCATION_}/utils"

# fetch ${__TEMPLATE_TOOL_NAME__} latest version
${__TEMPLATE_TOOL_NAME_CAPS__}_LATEST=$("${UTILS_DIR_LOCATION}/get-latest....sh")
echo "${__TEMPLATE_TOOL_NAME_CAPS__}_LATEST: ${${__TEMPLATE_TOOL_NAME_CAPS__}_LATEST}"

./build.sh "${IMAGE_REPOSITORY}" "${${__TEMPLATE_TOOL_NAME_CAPS__}_LATEST}"
