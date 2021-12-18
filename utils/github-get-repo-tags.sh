#!/bin/bash

set -o pipefail
set -o errexit
# set -o xtrace

if [ "${#}" -lt 1 ];
then
	echo "Usage ${0} github_repository [regex_filter]"
	exit 1
fi

REPOSITORY="${1}"
TAG_FILTER="${2}"

set -o nounset

VERSIONS=$(
	curl -sL https://api.github.com/repos/"${REPOSITORY}"/tags | \
		jq -r '.[].name'
)

if [ "${TAG_FILTER}" != "" ];
then
	VERSIONS=$(echo "${VERSIONS}" | grep -E "${TAG_FILTER}")
fi

LATEST_VERSION=$(echo "${VERSIONS}" | sort --version-sort -r | head -n 1)
echo "${LATEST_VERSION}"
