ARG		AWSCLI_VERSION

FROM	amazon/aws-cli:${AWSCLI_VERSION}

ARG		TERRAFORM_PATH

COPY	${TERRAFORM_PATH} /usr/local/bin/terraform

RUN		yum update -yqq && \
			yum install -yqq git && \
			yum clean packages && \
			rm -rf /var/cache/yum
