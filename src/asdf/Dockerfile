FROM	alpine

ARG		ASDF_VERSION

USER	root

RUN		apk add --update --no-cache --upgrade \
			git \
			curl \
			gnupg \
			bash \
			sudo \
			grep # Same error without upgrading grep when adding a plugin https://github.com/jish/pre-commit/issues/265#issuecomment-423303192

RUN		addgroup -S asdfgrp && \
			addgroup -S sudo && \
			adduser -S asdfuser -G asdfgrp -s /bin/ash && \
			adduser asdfuser sudo

RUN		echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER	asdfuser

WORKDIR /home/asdfuser

RUN		git clone https://github.com/asdf-vm/asdf.git .asdf --branch ${ASDF_VERSION}

ENV		PATH	$PATH:/home/asdfuser/.asdf/bin

CMD			[]
ENTRYPOINT	[ "asdf" ]
