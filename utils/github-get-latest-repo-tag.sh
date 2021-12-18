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

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

VERSIONS=$(${SCRIPT_DIR}/github-get-repo-tags.sh ${@})
echo "${VERSIONS}" | head -n 1
