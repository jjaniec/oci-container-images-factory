ARG		ARGOCD_VERSION

FROM	argoproj/argocd:${ARGOCD_VERSION}

ADD		--chown=argocd:argocd ./helm-secrets.tar.gz /home/argocd/.local/share/helm/plugins
COPY	--chown=argocd:argocd ./sops /usr/bin/sops
