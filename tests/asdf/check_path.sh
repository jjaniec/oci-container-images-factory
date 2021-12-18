#!/bin/bash
# shellcheck disable=SC2086

# set -o verbose

if [ -z "${1}" ];
then
	echo "Usage: ${0} IMAGE"
	exit 1
fi;

CONTAINER_ID=${CONTAINER_ID:-$(docker run \
	-td \
	--entrypoint=sleep \
	"${1}" infinity
)}

echo "CONTAINER_ID: ${CONTAINER_ID}"

COMMANDS=(
	"asdf"
	"asdf version"
	"asdf plugin add python"
	"sudo apk add gcc g++ make libffi-dev openssl-dev build-base jpeg-dev zlib-dev"
	"asdf install python 3.7.10"
	"asdf global python 3.7.10"
	"asdf exec python --version"
)

r=0
for c in "${COMMANDS[@]}";
do
	echo -n "Executing ${c} ... "
	docker exec "${CONTAINER_ID}" ${c} > stdout.log 2> stderr.log
	r=$?
	if [ ${r} -ne 0 ];
	then
		echo "KO"
		echo "Command ${c} returned ${r}";
		cat stdout.log
		cat stderr.log
		docker kill "${CONTAINER_ID}"
		exit ${r}
	fi;
	echo "OK"
done

rm stdout.log stderr.log || true
docker kill "${CONTAINER_ID}"
exit ${r}
