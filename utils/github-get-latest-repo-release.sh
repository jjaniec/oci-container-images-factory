#!/bin/bash

set -o pipefail
set -o errexit
# set -o xtrace

if [ "${#}" -lt 1 ];
then
	echo "Usage ${0} github_repository"
	exit 1
fi

REPOSITORY="${1}"

set -o nounset

LATEST_VERSION=$(
	curl -sL https://api.github.com/repos/"${REPOSITORY}"/releases/latest | \
		jq -r '.tag_name'
)

echo "${LATEST_VERSION}"
