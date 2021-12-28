# ${IMAGE_NAME}

Latest: ![](https://img.shields.io/docker/v/jjaniec/${IMAGE_NAME}?arch=amd64&sort=date)
![](https://img.shields.io/docker/pulls/jjaniec/${IMAGE_NAME}.svg)

${REPOSITORY_DESCRIPTION}

[Github actions workflow](https://github.com/jjaniec/oci-container-images-factory/actions/workflows/${IMAGE_NAME}.yml)

The tag is formatted as follows: `[AWSCLI_VERSION]`

---

### Sources:

[This image](https://github.com/jjaniec/oci-container-images-factory/tree/master/src/${IMAGE_NAME})

terraform: [github](https://github.com/hashicorp/terraform)
awscli: [github](https://github.com/amazon/aws-cli [hub.docker.com](https://hub.docker.com/r/amazon/aws-cli)

---

```bash
docker run ${IMAGE_REPOSITORY}
```

Dockerfile:
```Dockerfile
${DOCKERFILE_CONTENT}
```
