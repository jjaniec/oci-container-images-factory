#!/bin/bash

if [ -z "$1" ];
then
	echo "Usage: $0 <repository/image-name> [count=1] [<regex_tags_filter>]"
fi

REPOSITORY="${1}"
COUNT="${2:-1}"
TAG_FILTER="${3}"

VERSIONS=$(
	curl -L --fail "https://hub.docker.com/v2/repositories/${REPOSITORY}/tags/?page_size=1000" | \
		jq '.results | .[] | .name' -r | \
		sed 's/latest//'
)

if [ "${TAG_FILTER}" != "" ];
then
	VERSIONS=$(echo "${VERSIONS}" | grep -E "${TAG_FILTER}")
fi

LATEST_VERSION=$(echo "${VERSIONS}" | sort --version-sort | tail -n "${COUNT}")
echo "${LATEST_VERSION}"
