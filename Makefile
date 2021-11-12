REPOSITORY_ROOT =	jjaniec

all: argocd-helm-secrets-sops airflow-exporter img-docker-alias jenkins-inbound-agent-img-awscli

argocd-helm-secrets-sops:
	cd src/argocd-helm-secrets-sops && ./build-latest.sh "${REPOSITORY_ROOT}/argocd-helm-secrets-sops"
argocd-helm-secrets-sops-tests:
	./tests/argocd-helm-secrets-sops/check_path.sh "jjaniec/argocd-helm-secrets-sops:latest"

airflow-exporter:
	cd src/airflow-exporter && ./build-latest.sh "${REPOSITORY_ROOT}/airflow-exporter"
airflow-exporter-tests:
	./tests/airflow-exporter/check_path.sh "jjaniec/airflow-exporter:latest"
	./tests/airflow-exporter/metrics_exists.sh "jjaniec/airflow-exporter:latest"

img-docker-alias:
	cd src/img-docker-alias && ./build-latest.sh "${REPOSITORY_ROOT}/img-docker-alias"
img-docker-alias-tests:
	./tests/img-docker-alias/check_path.sh "jjaniec/img-docker-alias:latest"
	./tests/img-docker-alias/pull_image.sh "jjaniec/img-docker-alias:latest"

jenkins-inbound-agent-img-awscli:
	cd src/jenkins-inbound-agent-img-awscli && ./build-latest.sh "${REPOSITORY_ROOT}/jenkins-inbound-agent-img-awscli"
jenkins-inbound-agent-img-awscli-tests:
	./tests/jenkins-inbound-agent-img-awscli/check_path.sh "jjaniec/jenkins-inbound-agent-img-awscli:latest"
	./tests/jenkins-inbound-agent-img-awscli/pull_image.sh "jjaniec/jenkins-inbound-agent-img-awscli:latest"

clean:
	rm -rf ./**/helm-secrets.tar.gz.* ./**/*.tar.gz* ./**/sops*

fclean: clean
	docker image rm --force $(shell docker image ls -a -q)

.PHONY: all clean fclean tests
