#!/bin/bash
# shellcheck disable=SC2086

if [ -z "${1}" ];
then
	echo "Usage: ${0} IMAGE"
	exit 1
fi;

CONTAINER_ID=$(docker run \
	-d \
	--entrypoint=sh \
	"${1}" \
	-c 'sleep infinity'
)

echo "CONTAINER_ID: ${CONTAINER_ID}"

COMMANDS=(
	"img --help"
)

for c in "${COMMANDS[@]}";
do
	docker exec "${CONTAINER_ID}" ${c} > stdout.log 2> stderr.log
	r=$?
	if [ ${r} -ne 0 ];
	then
		echo "Failed to execute ${c}";
		cat stdout.log
		cat stderr.log
		exit ${r};
	fi;
done;

rm stdout.log stderr.log || true
exit 0
