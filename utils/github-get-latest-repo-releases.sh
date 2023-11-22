#!/bin/bash

# set -o pipefail
# set -o errexit
# set -o xtrace

function github_get_latest_repo_releases {
	if [ "${#}" -lt 1 ];
	then
		echo "Usage ${0} github_repository [count=1]"
		return
	fi

	REPOSITORY="${1}"
	COUNT="${2:-1}"

	if [ "${COUNT}" = "1" ];
	then
		LATEST_VERSION=$(
			curl -sL https://api.github.com/repos/"${REPOSITORY}"/releases/latest | \
				jq -r '.tag_name'
		)
		echo "${LATEST_VERSION}"
	else
		LATEST_VERSIONS=$(
			curl -sL https://api.github.com/repos/"${REPOSITORY}"/releases | \
				jq -r '.[].tag_name' | \
				head -n "${COUNT}"
		)
		echo "${LATEST_VERSIONS}"
	fi
}

if [ "${#}" -eq 2 ];
then
	github_get_latest_repo_releases ${@}
fi
