#!/bin/bash

set -o nounset
set -o pipefail
set -o errexit
# set -o xtrace

if [ "${#}" -ne 3 ]; then
	echo "Usage: ${0} <image_repository> <awscli_version> <terraform_version>"
	exit 1
fi;

ROOT_DIR_LOCATION_="${ROOT_DIR_LOCATION:-$(pwd)/../..}"
UTILS_DIR_LOCATION="${ROOT_DIR_LOCATION_}/utils"

export REPOSITORY_DESCRIPTION="image bundling terraform and awscli, built everyday by github-actions"
REPOSITORY_README_TPL_PATH="$(pwd)/README-containers.md.tpl"
REPOSITORY_README_PATH="$(pwd)/README-containers.md"

export IMAGE_REPOSITORY="${1}"
AWSCLI_VERSION="${2}"
TERRAFORM_VERSION="${3}"

IMAGE_NAME=$(echo "${IMAGE_REPOSITORY}" | rev | cut -d '/' -f 1 | rev)
export IMAGE_NAME
export IMAGE_TAG="${TERRAFORM_VERSION}-${AWSCLI_VERSION}"

# Check if image with tag already exists on remote
set +o errexit
"${UTILS_DIR_LOCATION}/dockerhub-image-exists.sh" "${IMAGE_REPOSITORY}:${IMAGE_TAG}"
[ $? -ne 1 ] && exit 0
set -o errexit

TERRAFORM_PATH="./terraform"
TERRAFORM_VERSION_FMT="$(echo ${TERRAFORM_VERSION} | tr -d 'v')"
wget "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION_FMT}/terraform_${TERRAFORM_VERSION_FMT}_linux_amd64.zip"
unzip "terraform_${TERRAFORM_VERSION_FMT}_linux_amd64.zip"
ls "${TERRAFORM_PATH}" > /dev/null
chmod 0755 "${TERRAFORM_PATH}"

docker build \
	-t "${IMAGE_REPOSITORY}:${IMAGE_TAG}" \
	-f Dockerfile \
	--build-arg AWSCLI_VERSION="${AWSCLI_VERSION}" \
	--build-arg TERRAFORM_PATH="${TERRAFORM_PATH}" \
	.

docker tag "${IMAGE_REPOSITORY}:${IMAGE_TAG}" "${IMAGE_REPOSITORY}:latest"

set +o errexit

make -C "${ROOT_DIR_LOCATION_}" terraform-awscli-tests
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
