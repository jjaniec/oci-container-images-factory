#!/bin/bash

if [ -z "$1" ];
then
	echo "Usage: $0 <repository/image-name>"
fi

REPOSITORY="${1}"

curl -L --fail "https://hub.docker.com/v2/repositories/${REPOSITORY}/tags/?page_size=1000" | \
	jq '.results | .[] | .name' -r | \
	sed 's/latest//' | \
	sort --version-sort | \
	tail -n 1
