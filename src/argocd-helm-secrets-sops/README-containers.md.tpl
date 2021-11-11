# ${IMAGE_NAME}

Latest: ![](https://img.shields.io/docker/v/jjaniec/${IMAGE_NAME}?arch=amd64&sort=date)
![](https://img.shields.io/docker/pulls/jjaniec/${IMAGE_NAME}.svg)

${REPOSITORY_DESCRIPTION}

[Github actions workflow](https://github.com/jjaniec/oci-container-images-factory/actions/workflows/${IMAGE_NAME}.yml)

The tag is formatted as follows: `[ARGOCD_VERSION]-[HELM_SECRETS_VERSION]-[SOPS_VERSION]`

---

### Sources:

[This image](https://github.com/jjaniec/oci-container-images-factory/tree/master/src/${IMAGE_NAME})

ArgoCD: [github](https://github.com/argoproj/argo-cd) [hub.docker.com](https://hub.docker.com/r/argoproj/argocd)

Helm-Secrets: [github](https://github.com/jkroepke/helm-secrets)

Sops: [github](https://github.com/mozilla/sops)

---

Dockerfile:
```Dockerfile
${DOCKERFILE_CONTENT}
```
