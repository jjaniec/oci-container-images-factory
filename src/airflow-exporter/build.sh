#!/bin/bash

set -o nounset
set -o pipefail
# set -o errexit
# set -o xtrace

if [ "${#}" -ne 2 ]; then
	echo "Usage: ${0} <image_repository> <airflow_version>"
	exit 1
fi;

ROOT_DIR_LOCATION_="${ROOT_DIR_LOCATION:-$(pwd)/../..}"
UTILS_DIR_LOCATION="${ROOT_DIR_LOCATION_}/utils"

export REPOSITORY_DESCRIPTION="official apache/airflow image w/ airflow-exporter pre-installed, built everyday by github-actions"
REPOSITORY_README_TPL_PATH="$(pwd)/README-containers.md.tpl"
REPOSITORY_README_PATH="$(pwd)/README-containers.md"

export IMAGE_REPOSITORY="${1}"
AIRFLOW_VERSION="${2}"

IMAGE_NAME=$(echo "${IMAGE_REPOSITORY}" | rev | cut -d '/' -f 1 | rev)
export IMAGE_NAME
export IMAGE_TAG="${AIRFLOW_VERSION}"

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

docker build \
	-t "${IMAGE_REPOSITORY}:${IMAGE_TAG}" \
	-f Dockerfile \
	--build-arg AIRFLOW_VERSION="${AIRFLOW_VERSION}" \
	.

docker tag "${IMAGE_REPOSITORY}:${IMAGE_TAG}" "${IMAGE_REPOSITORY}:latest"

make -C "${ROOT_DIR_LOCATION_}" "${IMAGE_NAME}"-tests
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
