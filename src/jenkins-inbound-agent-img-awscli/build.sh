#!/bin/bash

set -o nounset
set -o pipefail
# set -o errexit
set -o xtrace

if [ "${#}" -ne 4 ]; then
	echo "Usage: ${0} <image_repository> <jenkins_inbound_agent_version> <img_version> <awscli_version>"
	exit 1
fi;

ROOT_DIR_LOCATION_="${ROOT_DIR_LOCATION:-$(pwd)/../..}"
UTILS_DIR_LOCATION="${ROOT_DIR_LOCATION_}/utils"

export REPOSITORY_DESCRIPTION="official jenkins/inbound-agent image w/ img&awscli pre-installed, built everyday by github-actions"
REPOSITORY_README_TPL_PATH="$(pwd)/README-containers.md.tpl"
REPOSITORY_README_PATH="$(pwd)/README-containers.md"

export IMAGE_REPOSITORY="${1}"
JENKINS_INBOUND_AGENT_VERSION="${2}"
IMG_VERSION="${3}"
AWSCLI_VERSION="${4}"

IMAGE_NAME=$(echo "${IMAGE_REPOSITORY}" | rev | cut -d '/' -f 1 | rev)
export IMAGE_NAME
export IMAGE_TAG="${JENKINS_INBOUND_AGENT_VERSION}-${IMG_VERSION}-${AWSCLI_VERSION}"

# Check if image with tag already exists on remote
set +o errexit
"${UTILS_DIR_LOCATION}/dockerhub-image-exists.sh" "${IMAGE_REPOSITORY}:${IMAGE_TAG}"
[ $? -ne 1 ] && exit 0
set -o errexit

IMG_PATH="./img"
AWSCLI_PATH="./awscli.tar.gz"

wget "https://github.com/genuinetools/img/releases/download/${IMG_VERSION}/img-linux-amd64"
mv "img-linux-amd64" "${IMG_PATH}"
chmod 0755 "${IMG_PATH}"

wget "https://github.com/aws/aws-cli/archive/refs/tags/${AWSCLI_VERSION}.tar.gz"
mv "${AWSCLI_VERSION}.tar.gz" "${AWSCLI_PATH}"

docker build \
	-t "${IMAGE_REPOSITORY}:${IMAGE_TAG}" \
	-f Dockerfile \
	--build-arg JENKINS_INBOUND_AGENT_VERSION="${JENKINS_INBOUND_AGENT_VERSION}" \
	--build-arg AWSCLI_VERSION="${AWSCLI_VERSION}" \
	.

docker tag "${IMAGE_REPOSITORY}:${IMAGE_TAG}" "${IMAGE_REPOSITORY}:latest"

make -C "${ROOT_DIR_LOCATION_}" jenkins-inbound-agent-img-awscli-tests
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

rm -rf "${IMG_PATH}"
