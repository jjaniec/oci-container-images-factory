ARG		JENKINS_INBOUND_AGENT_VERSION

FROM	jenkins/inbound-agent:${JENKINS_INBOUND_AGENT_VERSION}

ARG		AWSCLI_VERSION

USER	root

RUN		apt-get update -yqq && apt-get install -yqq wget \
			make \
			build-essential \
			libssl-dev \
			zlib1g-dev \
			libbz2-dev \
			libreadline-dev \
			libsqlite3-dev \
			curl \
			llvm \
			libncurses5-dev \
			libncursesw5-dev \
			xz-utils \
			tk-dev \
			libffi-dev \
			liblzma-dev \
			sudo \
			libseccomp-dev \
			uidmap && \
			apt-get clean && rm -rf /var/lib/apt/lists/*

COPY	--chown=jenkins:jenkins ./img /usr/bin/img

RUN		ln -s /usr/bin/img /usr/local/bin/docker

RUN		echo "jenkins ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/jenkins

ENV		HOME /home/jenkins
ENV		PYENV_ROOT $HOME/.pyenv
ENV		PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH
RUN		git clone https://github.com/pyenv/pyenv.git $HOME/.pyenv
RUN		pyenv install 3.6.7 && pyenv global system 3.6.7 && pyenv rehash

RUN		pip3 install awscli

USER	jenkins

ENV		USER jenkins
