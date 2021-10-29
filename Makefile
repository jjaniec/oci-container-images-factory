REPOSITORY_ROOT =	jjaniec

argocd-helm-secrets-sops:
	cd src/argocd-helm-secrets-sops && ./build-latest.sh "${REPOSITORY_ROOT}/argocd-helm-secrets-sops"

all: argocd-helm-secrets-sops

tests:
	./tests/argocd-helm-secrets-sops/test.sh "jjaniec/argocd-helm-secrets-sops:latest"

clean:
	rm -rf ./**/*.tar.gz* ./**/sops

fclean: clean
	docker image rm --force $(shell docker image ls -a -q)

.PHONY: all clean fclean tests
