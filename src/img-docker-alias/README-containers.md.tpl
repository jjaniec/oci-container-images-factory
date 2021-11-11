# ${IMAGE_NAME}

Latest: ![](https://img.shields.io/docker/v/jjaniec/${IMAGE_NAME}?arch=amd64&sort=date)
![](https://img.shields.io/docker/pulls/jjaniec/${IMAGE_NAME}.svg)

${REPOSITORY_DESCRIPTION}

[Github actions workflow](https://github.com/jjaniec/oci-container-images-factory/actions/workflows/${IMAGE_NAME}.yml)

The tag is formatted as follows: `[IMG_VERSION]`

---

### Sources:

[This image](https://github.com/jjaniec/oci-container-images-factory/tree/master/src/${IMAGE_NAME})

IMG: [github](https://github.com/genuinetools/img) [hub.docker.com](https://hub.docker.com/r/jess/img)

---

```bash
docker run --security-opt seccomp=unconfined --security-opt apparmor=unconfined ${IMAGE_REPOSITORY}
```

Dockerfile:
```Dockerfile
${DOCKERFILE_CONTENT}
```
