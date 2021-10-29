#!/bin/bash

set -o nounset
set -o pipefail
# set -o errexit
set -o xtrace

if [ "${#}" -ne 4 ]; then
	echo "Usage: ${0} <image_repository> <argocd_version> <helm_secrets_version> <sops_version>"
	exit 1
fi;

ROOT_DIR_LOCATION_="${ROOT_DIR_LOCATION:-$(pwd)/../..}"
TESTS_DIR_LOCATION="${ROOT_DIR_LOCATION_}/tests"
UTILS_DIR_LOCATION="${ROOT_DIR_LOCATION_}/utils"

IMAGE_REPOSITORY="${1}"
ARGOCD_VERSION="${2}"
HELM_SECRETS_VERSION="${3}"
SOPS_VERSION="${4}"

IMAGE_NAME=$(echo "${IMAGE_REPOSITORY}" | rev | cut -d '/' -f 1 | rev)
IMAGE_TAG="${ARGOCD_VERSION}-${HELM_SECRETS_VERSION}-${SOPS_VERSION}"

"${UTILS_DIR_LOCATION}/dockerhub-image-exists.sh" "${IMAGE_REPOSITORY}:${IMAGE_TAG}"
r=$?
if [ ${r} -eq 0 ];
then
	echo "Image with tag ${IMAGE_TAG} already exists, exiting"
	exit 0
elif [ ${r} -ne 22 ];
then
	echo "Unexpected error checking for image with tag ${IMAGE_TAG}, exiting"
	exit 1
fi;

SOPS_PATH="./sops"
HELM_SECRETS_PATH="./helm-secrets.tar.gz"

wget "https://github.com/mozilla/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux"
mv "sops-${SOPS_VERSION}.linux" "${SOPS_PATH}"
chmod 0755 "${SOPS_PATH}"

wget "https://github.com/jkroepke/helm-secrets/releases/download/${HELM_SECRETS_VERSION}/helm-secrets.tar.gz"

docker build \
	-t "${IMAGE_REPOSITORY}:${IMAGE_TAG}" \
	-f Dockerfile \
	--build-arg ARGOCD_VERSION="${ARGOCD_VERSION}" \
	.

docker tag "${IMAGE_REPOSITORY}:${IMAGE_TAG}" "${IMAGE_REPOSITORY}:latest"

"${TESTS_DIR_LOCATION}/${IMAGE_NAME}/test.sh" "${IMAGE_REPOSITORY}:${IMAGE_TAG}"
r=$?

if [ $r -eq 0 ];
then
	echo "Image with tag ${IMAGE_TAG} successfully built and tested"
else
	echo "Image with tag ${IMAGE_TAG} failed tests"
	exit 1
fi;

docker push "${IMAGE_REPOSITORY}:${IMAGE_TAG}"
docker push "${IMAGE_REPOSITORY}:latest"

rm -rf "${SOPS_PATH}" "${HELM_SECRETS_PATH}"
