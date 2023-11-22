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

ROOT_DIR_LOCATION_="${ROOT_DIR_LOCATION:-$(pwd)/../}"
UTILS_DIR_LOCATION="${ROOT_DIR_LOCATION_}/utils"

REPOSITORY_README_TPL_PATH="$(pwd)/README-containers.md.tpl"
REPOSITORY_README_PATH="$(pwd)/README-containers.md"

if ! command -v trivy;
then
	echo "Trivy not installed, downloading"
	wget https://github.com/aquasecurity/trivy/releases/download/v0.47.0/trivy_0.47.0_Linux-64bit.deb
	sudo dpkg -i trivy_0.47.0_Linux-64bit.deb
	trivy version
fi;

if ! command -v copa && [ ! -f "./copa" ];
then
	echo "Copacetic not installed, downloading"
	wget "${COPACETIC_DOWNLOAD_URL}"
	tar -xvf "./copa_0.5.1_${OS}_${ARCH}.tar.gz"
	./copa -v
fi;

source ${UTILS_DIR_LOCATION}/github-get-latest-repo-releases.sh

for r in $(yq eval -o=j image-patchlist.yaml | jq -cr '.repositories[]'); do
	name=$(echo $r | jq -r '.name' -)
	source_type=$(echo $r | jq -r '.source_type' -)
	source_repository=$(echo $r | jq -r '.source_repository' -)
	patch_latest_releases_count=$(echo $r | jq -r '.patch_latest_releases_count' -)
	release_releases_tag_grep_regexp=$(echo $r | jq -r '.release_releases_tag_grep_regexp' -)
	additional_fixed_tags=$(echo $r | jq -r '.additional_fixed_tags' -)
	patch_latest_tag=$(echo $r | jq -r '.patch_latest_tag' -)
	generate_ots_dockerhub_readme=$(echo $r | jq -r '.generate_ots_dockerhub_readme' -)

	repository_prefix=""

	echo "Prepare ${name} repository for patching"
	if [ "${source_type}" = "dockerhub" ];
	then
		latest_tags=$(../utils/dockerhub-get-repository-latest-images.sh "${source_repository}" "${patch_latest_releases_count}" "${release_releases_tag_grep_regexp}")
		repository_prefix="docker.io/"
	elif [ "${source_type}" = "ghcr" ];
	then
		echo "github_get_latest_repo_releases ${source_repository} ${patch_latest_releases_count}"
		latest_tags=$(github_get_latest_repo_releases "${source_repository}" "${patch_latest_releases_count}" | grep -E "${release_releases_tag_grep_regexp}")
		repository_prefix="ghcr.io/"
	else
		echo "Unknown source_type: ${source_type}"
		continue
	fi

	export REPOSITORY_DESCRIPTION="Mirror of ${repository_prefix}${source_repository} with latest releases patched everyday for security updates"

	set +o errexit
	IFS=$'\n'
	for tag in $latest_tags
	do
		echo "Patching ${repository_prefix}${source_repository}:${tag} -> jjaniec/${name}:${tag}"
		trivy image \
			--vuln-type os \
			-f json \
			--scanners vuln \
			--ignore-unfixed \
			--output result.json \
			"${repository_prefix}${source_repository}:${tag}"
		if [ $? -ne 0 ];
		then
			echo "Trivy failed to scan ${repository_prefix}${source_repository}:${tag}"
			continue
		fi;
		./copa patch \
			-i "${repository_prefix}${source_repository}:${tag}" \
			-f table \
			-r result.json
		docker tag "${repository_prefix}${source_repository}:${tag}-patched" "jjaniec/${name}:${tag}"
		trivy image \
			--vuln-type os \
			-f table \
			--scanners vuln \
			--ignore-unfixed \
			--output trivy-result.table \
			"jjaniec/${name}:${tag}"
		cat trivy-result.table >> trivy-reports-merged.txt
		set +o nounset
		if [ "${ENABLE_PUSH}" = "true" ];
		then
			docker push "jjaniec/${name}:${tag}"
		fi;
		set -o nounset
	done;

	set -o errexit
	if [ "${generate_ots_dockerhub_readme}" = "true" ];
	then
		IMAGE_NAME="${name}" \
		SOURCE_REPOSIRORY="${source_repository}" \
		PATCHED_TAGS="${latest_tags}" \
		CURRENT_DATE="$(date)" \
			envsubst < "${REPOSITORY_README_TPL_PATH}" > "${REPOSITORY_README_PATH}"
		cat trivy-reports-merged.txt >> "${REPOSITORY_README_PATH}"
		echo '```' >> "${REPOSITORY_README_PATH}"
		rm trivy-reports-merged.txt
		${UTILS_DIR_LOCATION}/dockerhub-set-repository-metadata.sh "docker.io/jjaniec/${name}" "${REPOSITORY_README_PATH}" "${REPOSITORY_DESCRIPTION}"
	fi;

	docker image prune -a -f
	docker container prune -f
done
