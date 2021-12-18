#!/bin/bash

if [ -z "$1" ];
then
	echo "Usage: $0 <repository/image-name> [<regex_tags_filter>]"
fi

REPOSITORY="${1}"
TAG_FILTER="${2}"

VERSIONS=$(
	curl -L --fail "https://hub.docker.com/v2/repositories/${REPOSITORY}/tags/?page_size=1000" | \
		jq '.results | .[] | .name' -r | \
		sed 's/latest//'
)

if [ "${TAG_FILTER}" != "" ];
then
	VERSIONS=$(echo "${VERSIONS}" | grep -E "${TAG_FILTER}")
fi

LATEST_VERSION=$(echo "${VERSIONS}" | sort --version-sort | tail -n 1)
echo "${LATEST_VERSION}"
