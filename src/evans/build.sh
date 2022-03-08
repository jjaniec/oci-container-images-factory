#!/bin/bash

set -o nounset
set -o pipefail
set -o errexit
set -o xtrace

if [ "${#}" -ne 2 ]; then
	echo "Usage: ${0} <image_repository> <evans_version>"
	exit 1
fi;

ROOT_DIR_LOCATION_="${ROOT_DIR_LOCATION:-$(pwd)/../..}"
UTILS_DIR_LOCATION="${ROOT_DIR_LOCATION_}/utils"

export REPOSITORY_DESCRIPTION="Alpine image bundling evans binary, built everyday by github-actions"
REPOSITORY_README_TPL_PATH="$(pwd)/README-containers.md.tpl"
REPOSITORY_README_PATH="$(pwd)/README-containers.md"

export IMAGE_REPOSITORY="${1}"
EVANS_VERSION="${2}"

IMAGE_NAME=$(echo "${IMAGE_REPOSITORY}" | rev | cut -d '/' -f 1 | rev)
export IMAGE_NAME
export IMAGE_TAG="${EVANS_VERSION}"

# Check if image with tag already exists on remote
set +o errexit
"${UTILS_DIR_LOCATION}/dockerhub-image-exists.sh" "${IMAGE_REPOSITORY}:${IMAGE_TAG}"
[ $? -ne 1 ] && exit 0
set -o errexit

EVANS_PATH="./evans"
wget "https://github.com/ktr0731/evans/releases/download/${EVANS_VERSION}/evans_linux_amd64.tar.gz"
tar -vxf ./evans_linux_amd64.tar.gz
mv "./evans" "${EVANS_PATH}" || true

docker build \
	-t "${IMAGE_REPOSITORY}:${IMAGE_TAG}" \
	-f Dockerfile \
	--build-arg EVANS_PATH="${EVANS_PATH}" \
	.

docker tag "${IMAGE_REPOSITORY}:${IMAGE_TAG}" "${IMAGE_REPOSITORY}:latest"

set +o errexit

make -C "${ROOT_DIR_LOCATION_}" evans-tests
r=$?
if [ $r -eq 0 ];
then
	echo "Image with tag ${IMAGE_TAG} successfully built and tested"
else
	echo "Image with tag ${IMAGE_TAG} failed tests"
	exit 1
fi;

set -o errexit

docker push "${IMAGE_REPOSITORY}:${IMAGE_TAG}"
docker push "${IMAGE_REPOSITORY}:latest"

DOCKERFILE_CONTENT="$(cat ./Dockerfile)" envsubst < "${REPOSITORY_README_TPL_PATH}" > "${REPOSITORY_README_PATH}"
"${UTILS_DIR_LOCATION}/dockerhub-set-repository-metadata.sh" "${IMAGE_REPOSITORY}" "${REPOSITORY_README_PATH}" "${REPOSITORY_DESCRIPTION}"
