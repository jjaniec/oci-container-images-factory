#!/bin/bash
# shellcheck disable=SC2086

if [ -z "${1}" ];
then
	echo "Usage: ${0} IMAGE"
	exit 1
fi;

CONTAINER_ID=$(docker run \
	--entrypoint=sh \
	-td \
	"${1}" \
	-c 'sleep infinity'
)

echo "CONTAINER_ID: ${CONTAINER_ID}"

COMMANDS=(
	"git -C /tmp clone https://github.com/cloudposse/terraform-aws-ec2-instance.git"
	"terraform -chdir=/tmp/terraform-aws-ec2-instance init"
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
docker kill "${CONTAINER_ID}"
exit 0
