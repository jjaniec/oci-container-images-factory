#!/bin/bash

set -o nounset
set -o pipefail
set -o errexit
# set -o xtrace
# set -o verbose

OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m | tr '[:upper:]' '[:lower:]')
ARCH="amd64"

COPACETIC_VERSION="0.5.1"
COPACETIC_DOWNLOAD_URL="https://github.com/project-copacetic/copacetic/releases/download/v${COPACETIC_VERSION}/copa_${COPACETIC_VERSION}_${OS}_${ARCH}.tar.gz"

DIRECTORY="${1}"
IMAGE_REPOSITORY="${2}"
MAKEFILE_TEST_IMAGE_INSTRUCTION="${3}"

ROOT_DIR_LOCATION_="${ROOT_DIR_LOCATION:-$(pwd)}"
UTILS_DIR_LOCATION="${ROOT_DIR_LOCATION_}/utils"

if ! command -v trivy;
then
	echo "Trivy not installed, downloading"
	wget https://github.com/aquasecurity/trivy/releases/download/v0.47.0/trivy_0.47.0_Linux-64bit.deb
	sudo dpkg -i trivy_0.47.0_Linux-64bit.deb
	trivy version
fi;

if ! command -v copa;
then
	echo "Copacetic not installed, downloading"
	wget "${COPACETIC_DOWNLOAD_URL}"
	tar -xvf "./copa_0.5.1_${OS}_${ARCH}.tar.gz"
	./copa -v
fi;

if [ ! -f "${DIRECTORY}/patch-taglist.txt" ];
then
	echo "${DIRECTORY}/patch-taglist.txt not found, skipping"
	exit 0
fi;

while read tag;
do
	echo "Patching ${IMAGE_REPOSITORY}:${tag}"
	set +o errexit
	trivy image \
		--vuln-type os \
		-f json \
		--scanners vuln \
		--ignore-unfixed \
		--output result.json \
		"${IMAGE_REPOSITORY}:${tag}"
	./copa patch \
		-i "docker.io/${IMAGE_REPOSITORY}:${tag}" \
		--debug \
		-f table \
		-r result.json

	# Only tag to test image, do not update latest tag on remote repo as we want to keep latest versions instaed
	set -o errexit
	docker tag "${IMAGE_REPOSITORY}:${tag}-patched" "${IMAGE_REPOSITORY}:latest"
	make "${MAKEFILE_TEST_IMAGE_INSTRUCTION}"

	# If tests passed, generate a table format output for readme, and push patched image
	trivy image \
		--vuln-type os \
		-f table \
		--scanners vuln \
		--ignore-unfixed \
		--output trivy-result.table \
		"${IMAGE_REPOSITORY}:${tag}-patched"
	cat trivy-result.table

	set +o nounset
	if [ "${ENABLE_PUSH}" = "true" ];
	then
		# Update ${tag} floating tag to latest patched image with same versions
		docker tag "${IMAGE_REPOSITORY}:${tag}-patched" "${IMAGE_REPOSITORY}:${tag}"
		docker push "${IMAGE_REPOSITORY}:${tag}"
	fi;
	set -o nounset
done < "${DIRECTORY}/patch-taglist.txt"
