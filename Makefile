REPOSITORY_ROOT =	jjaniec

argocd-helm-secrets-sops:
	cd src/argocd-helm-secrets-sops && ./build-latest.sh "${REPOSITORY_ROOT}/argocd-helm-secrets-sops"
argocd-helm-secrets-sops-tests:
	./tests/argocd-helm-secrets-sops/test.sh "jjaniec/argocd-helm-secrets-sops:latest"

img-docker-alias:
	cd src/img-docker-alias && ./build-latest.sh "${REPOSITORY_ROOT}/img-docker-alias"
img-docker-alias-tests:
	./tests/img-docker-alias/test.sh "jjaniec/img-docker-alias:latest"

all: argocd-helm-secrets-sops

clean:
	rm -rf ./**/*.tar.gz* ./**/sops

fclean: clean
	docker image rm --force $(shell docker image ls -a -q)

.PHONY: all clean fclean tests
