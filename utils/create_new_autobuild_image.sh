#!/bin/bash

set -o errexit
set -o pipefail
set -o xtrace
# set -o nounset

if [ ${#} -ne 2 ];
then
	echo "Usage: ${0} TEMPLATE_IMAGE_NAME TEMPLATE_TOOL_NAME"
	exit 1
fi;

TEMPLATE_IMAGE_NAME="${1}"
TEMPLATE_TOOL_NAME="${2}"
TEMPLATE_TOOL_NAME_CAPS="$(echo ${TEMPLATE_TOOL_NAME} | tr '[:lower:]' '[:upper:]')"

ROOT_DIR_LOCATION="${ROOT_DIR_LOCATION:-$PWD/..}"

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

# mkdir -p "${ROOT_DIR_LOCATION}"/src/"${TEMPLATE_IMAGE_NAME}"
# mkdir -p "${ROOT_DIR_LOCATION}"/tests/"${TEMPLATE_IMAGE_NAME}"

# # cp -R "${ROOT_DIR_LOCATION}/src/template" "${ROOT_DIR_LOCATION}/src/${TEMPLATE_IMAGE_NAME}"
# # cp -R "${ROOT_DIR_LOCATION}/tests/template" "${ROOT_DIR_LOCATION}/tests/${TEMPLATE_IMAGE_NAME}"

# for i in "${ROOT_DIR_LOCATION}"/src/template/*;
# do
# 	file_name="$(echo ${i} | rev | cut -d '/' -f 1 | rev)"
# 	echo "Import ${file_name}"
# 	cat "${i}" | \
# 		sed "s/\${__TEMPLATE_IMAGE_NAME__}/${TEMPLATE_IMAGE_NAME}/g" | \
# 		sed "s/\${__TEMPLATE_TOOL_NAME__}/${TEMPLATE_TOOL_NAME}/g" | \
# 		sed "s/\${__TEMPLATE_TOOL_NAME_CAPS__}/${TEMPLATE_TOOL_NAME_CAPS}/g" \
# 		> "${ROOT_DIR_LOCATION}/src/${TEMPLATE_IMAGE_NAME}/${file_name}"
# done;

# for i in "${ROOT_DIR_LOCATION}"/tests/template/*;
# do
# 	file_name="$(echo ${i} | rev | cut -d '/' -f 1 | rev)"
# 	echo "Import ${file_name}"
# 	cat "${i}" | \
# 		sed "s/\${__TEMPLATE_IMAGE_NAME__}/${TEMPLATE_IMAGE_NAME}/g" | \
# 		sed "s/\${__TEMPLATE_TOOL_NAME__}/${TEMPLATE_TOOL_NAME}/g" | \
# 		sed "s/\${__TEMPLATE_TOOL_NAME_CAPS__}/${TEMPLATE_TOOL_NAME_CAPS}/g" \
# 		> "${ROOT_DIR_LOCATION}/tests/${TEMPLATE_IMAGE_NAME}/${file_name}"
# done;
