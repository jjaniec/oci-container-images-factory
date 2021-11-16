#!/bin/bash
# shellcheck disable=SC2086
# shellcheck disable=SC2016
set -o xtrace

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
	"airflow db init"
	'airflow webserver & export JOB_PID=$! && echo "${JOB_PID}" && sleep 20 && ls "/proc/${JOB_PID}"; r=$?; kill "${JOB_PID}"; exit ${r}'
	'airflow webserver & export JOB_PID=$! && sleep 2 && [ $(curl -v -o -I -L -s -w "%{http_code}" http://localhost:8080) -eq 200 ]; r=$?; kill "${JOB_PID}"; exit ${r}'
	'airflow webserver & export JOB_PID=$! && sleep 2 && [ $(curl -v -o -I -L -s -w "%{http_code}" http://localhost:8080/admin/metrics) -eq 200 ]; r=$?; kill "${JOB_PID}"; exit ${r}'
)

r=0
for c in "${COMMANDS[@]}";
do
	docker exec "${CONTAINER_ID}" sh -c "${c}" > stdout.log 2> stderr.log
	r=$?
	if [ ${r} -ne 0 ];
	then
		echo "Failed to execute ${c}";
		cat stdout.log
		cat stderr.log
		break ;
	fi;
done;

rm stdout.log stderr.log || true
docker kill "${CONTAINER_ID}"
exit "${r}"
