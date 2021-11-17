# ${IMAGE_NAME}

Latest: ![](https://img.shields.io/docker/v/jjaniec/${IMAGE_NAME}?arch=amd64&sort=date)
![](https://img.shields.io/docker/pulls/jjaniec/${IMAGE_NAME}.svg)

${REPOSITORY_DESCRIPTION}

[Github actions workflow](https://github.com/jjaniec/oci-container-images-factory/actions/workflows/${IMAGE_NAME}.yml)

The tag is formatted as follows: `[JENKINS_INBOUND_AGENT_VERSION]-[IMG_VERSION]-[AWSCLI_VERSION]`

---

### Sources:

[This image](https://github.com/jjaniec/oci-container-images-factory/tree/master/src/${IMAGE_NAME})

Jenkins inbound agent: [github](https://github.com/jenkinsci/docker-inbound-agent) [hub.docker.com](https://hub.docker.com/r/jenkins/inbound-agent)

IMG: [github](https://github.com/genuinetools/img) [hub.docker.com](https://hub.docker.com/r/jess/img)

awscli: [github](https://github.com/aws/aws-cli)

---

Dockerfile:
```Dockerfile
${DOCKERFILE_CONTENT}
```
