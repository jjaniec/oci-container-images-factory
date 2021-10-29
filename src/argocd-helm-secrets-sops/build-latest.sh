#!/bin/bash

set -o nounset
set -o pipefail
# set -o errexit
# set -o xtrace

IMAGE_REPOSITORY="${1}"

ROOT_DIR_LOCATION_="${ROOT_DIR_LOCATION:-$(pwd)/../..}"
UTILS_DIR_LOCATION="${ROOT_DIR_LOCATION_}/utils"

ARGOCD_LATEST=$("${UTILS_DIR_LOCATION}/dockerhub-get-repository-latest-image.sh" "argoproj/argocd")
HELM_SECRETS_LATEST=$(curl -sL https://api.github.com/repos/jkroepke/helm-secrets/releases/latest | jq -r '.assets[].browser_download_url' | cut -d '/' -f 8 | head -n 1)
SOPS_LATEST=$(curl -sL https://api.github.com/repos/mozilla/sops/releases/latest | jq -r '.assets[].browser_download_url' | cut -d '/' -f 8 | head -n 1)

echo "ARGOCD_LATEST: ${ARGOCD_LATEST}"
echo "HELM_SECRETS_LATEST: ${HELM_SECRETS_LATEST}"
echo "SOPS_LATEST: ${SOPS_LATEST}"

./build.sh "${IMAGE_REPOSITORY}" "${ARGOCD_LATEST}" "${HELM_SECRETS_LATEST}" "${SOPS_LATEST}"
