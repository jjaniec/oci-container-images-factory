#!/bin/bash

#set -o nounset
# set -o verbose
set -o errexit
set -o pipefail

DOCKER=${DOCKER:-docker}

if [ "${#}" -ne 3 ];
then
	echo "Usage: ${0} <repository> <readme_file_abs_path> <description>"
	exit 1
fi;

REPOSITORY="${1}"
README_FILE_ABS_PATH="${2}"
DESCRIPTION="${3}"

${DOCKER} run \
	--rm \
	-t \
	-e DOCKER_USER="${DOCKERHUB_USER}" \
	-e DOCKER_PASS="${DOCKERHUB_PASS}" \
	-v "${README_FILE_ABS_PATH}:/mnt/README.md" \
	chko/docker-pushrm:latest \
	--short "${DESCRIPTION}" \
	--file "/mnt/README.md" \
	--debug \
	"${REPOSITORY}"
