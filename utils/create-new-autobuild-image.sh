#!/bin/bash

set -o errexit
set -o pipefail
set -o xtrace
# set -o nounset

if [ ${#} -ne 2 ];
then
	echo "Usage: ${0} TEMPLATE_IMAGE_NAME TEMPLATE_PRINCIPAL_TOOL_NAME"
	exit 1
fi;

TEMPLATE_IMAGE_NAME="${1}"
TEMPLATE_TOOL_NAME="${2}"
TEMPLATE_TOOL_NAME_CAPS="$(echo ${TEMPLATE_TOOL_NAME} | tr '[:lower:]' '[:upper:]')"

ROOT_DIR_LOCATION=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"/.."

for directory in src tests;
do
	mkdir -p "${ROOT_DIR_LOCATION}/${directory}/${TEMPLATE_IMAGE_NAME}"

	for i in "${ROOT_DIR_LOCATION}"/"${directory}"/template/*;
	do
		file_name="$(echo ${i} | rev | cut -d '/' -f 1 | rev)"
		echo "Import ${file_name}"
		cat "${i}" | \
			sed "s/\${__TEMPLATE_IMAGE_NAME__}/${TEMPLATE_IMAGE_NAME}/g" | \
			sed "s/\${__TEMPLATE_TOOL_NAME__}/${TEMPLATE_TOOL_NAME}/g" | \
			sed "s/\${__TEMPLATE_TOOL_NAME_CAPS__}/${TEMPLATE_TOOL_NAME_CAPS}/g" \
			> "${ROOT_DIR_LOCATION}/${directory}/${TEMPLATE_IMAGE_NAME}/${file_name}"
	done;
done;

chmod +x "${ROOT_DIR_LOCATION}/src/${TEMPLATE_IMAGE_NAME}/"{build-latest.sh,build.sh}
chmod +x "${ROOT_DIR_LOCATION}/tests/${TEMPLATE_IMAGE_NAME}/check_path.sh"
