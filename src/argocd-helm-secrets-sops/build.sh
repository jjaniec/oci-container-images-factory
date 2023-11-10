#!/bin/bash

set -o nounset
set -o pipefail
# set -o errexit
# set -o xtrace

if [ "${#}" -ne 4 ]; then
	echo "Usage: ${0} <image_repository> <argocd_version> <helm_secrets_version> <sops_version>"
	exit 1
fi;

ROOT_DIR_LOCATION_="${ROOT_DIR_LOCATION:-$(pwd)/../..}"
UTILS_DIR_LOCATION="${ROOT_DIR_LOCATION_}/utils"

export REPOSITORY_DESCRIPTION="official argocd image w/ a helm-secrets & sops pre-installed, built everyday by github-actions"
REPOSITORY_README_TPL_PATH="$(pwd)/README-containers.md.tpl"
REPOSITORY_README_PATH="$(pwd)/README-containers.md"

export IMAGE_REPOSITORY="${1}"
ARGOCD_VERSION="${2}"
HELM_SECRETS_VERSION="${3}"
SOPS_VERSION="${4}"

IMAGE_NAME=$(echo "${IMAGE_REPOSITORY}" | rev | cut -d '/' -f 1 | rev)
export IMAGE_NAME
export IMAGE_TAG="${ARGOCD_VERSION}-${HELM_SECRETS_VERSION}-${SOPS_VERSION}"

# Check if image with tag already exists on remote
set +o errexit
"${UTILS_DIR_LOCATION}/dockerhub-image-exists.sh" "${IMAGE_REPOSITORY}:${IMAGE_TAG}"
[ $? -ne 1 ] && exit 0
set -o errexit

SOPS_PATH="./sops"
HELM_SECRETS_PATH="./helm-secrets.tar.gz"

wget "https://github.com/mozilla/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux.amd64"
mv "sops-${SOPS_VERSION}.linux.amd64" "${SOPS_PATH}"
chmod 0755 "${SOPS_PATH}"

wget "https://github.com/jkroepke/helm-secrets/releases/download/${HELM_SECRETS_VERSION}/helm-secrets.tar.gz"

docker build \
	-t "${IMAGE_REPOSITORY}:${IMAGE_TAG}" \
	-f Dockerfile \
	--build-arg ARGOCD_VERSION="${ARGOCD_VERSION}" \
	.

docker tag "${IMAGE_REPOSITORY}:${IMAGE_TAG}" "${IMAGE_REPOSITORY}:latest"

make -C "${ROOT_DIR_LOCATION_}" argocd-helm-secrets-sops-tests
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

DOCKERFILE_CONTENT="$(cat ./Dockerfile)" envsubst < "${REPOSITORY_README_TPL_PATH}" > "${REPOSITORY_README_PATH}"
"${UTILS_DIR_LOCATION}/dockerhub-set-repository-metadata.sh" "${IMAGE_REPOSITORY}" "${REPOSITORY_README_PATH}" "${REPOSITORY_DESCRIPTION}"

rm -rf "${SOPS_PATH}" "${HELM_SECRETS_PATH}"
