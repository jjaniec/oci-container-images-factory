#!/bin/bash

set -o nounset
set -o pipefail
set -o errexit
# set -o xtrace

if [ "${#}" -ne 2 ]; then
	echo "Usage: ${0} <image_repository> <asdf_version>"
	exit 1
fi;

ROOT_DIR_LOCATION_="${ROOT_DIR_LOCATION:-$(pwd)/../..}"
UTILS_DIR_LOCATION="${ROOT_DIR_LOCATION_}/utils"

export REPOSITORY_DESCRIPTION="alpine rootless image bundling asdf-vm/asdf, built everyday by github-actions"
REPOSITORY_README_TPL_PATH="$(pwd)/README-containers.md.tpl"
REPOSITORY_README_PATH="$(pwd)/README-containers.md"

export IMAGE_REPOSITORY="${1}"
ASDF_VERSION="${2}"

IMAGE_NAME=$(echo "${IMAGE_REPOSITORY}" | rev | cut -d '/' -f 1 | rev)
export IMAGE_NAME
export IMAGE_TAG="${ASDF_VERSION}"

# Check if image with tag already exists on remote
set +o errexit
"${UTILS_DIR_LOCATION}/dockerhub-image-exists.sh" "${IMAGE_REPOSITORY}:${IMAGE_TAG}"
[ $? -ne 1 ] && exit 0
set -o errexit

echo "Building ${IMAGE_REPOSITORY}:${IMAGE_TAG}"
docker build \
	-t "${IMAGE_REPOSITORY}:${IMAGE_TAG}" \
	-f Dockerfile \
	--build-arg ASDF_VERSION="${ASDF_VERSION}" \
	.

docker tag "${IMAGE_REPOSITORY}:${IMAGE_TAG}" "${IMAGE_REPOSITORY}:latest"

set +o errexit

make -C "${ROOT_DIR_LOCATION_}" asdf-tests
r=$?
if [ $r -eq 0 ];
then
	echo "Image with tag ${IMAGE_TAG} successfully built and tested"
else
	echo "Image with tag ${IMAGE_TAG} failed tests"
	exit 1
fi;

set -o errexit

echo "Pushing ${IMAGE_REPOSITORY}:${IMAGE_TAG}"
docker push "${IMAGE_REPOSITORY}:${IMAGE_TAG}"
echo "Pushing ${IMAGE_REPOSITORY}:latest"
docker push "${IMAGE_REPOSITORY}:latest"

echo "Updating dockerhub repository description & readme"
DOCKERFILE_CONTENT="$(cat ./Dockerfile)" envsubst < "${REPOSITORY_README_TPL_PATH}" > "${REPOSITORY_README_PATH}"
"${UTILS_DIR_LOCATION}/dockerhub-set-repository-metadata.sh" "${IMAGE_REPOSITORY}" "${REPOSITORY_README_PATH}" "${REPOSITORY_DESCRIPTION}"
