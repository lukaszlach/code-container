FROM codercom/code-server AS su-exec
USER root
RUN curl -o /usr/local/bin/su-exec.c https://raw.githubusercontent.com/ncopa/su-exec/master/su-exec.c && \
    apt-get update && \
    apt-get install -y --no-install-recommends gcc libc-dev && \
    gcc -Wall \
        /usr/local/bin/su-exec.c -o /usr/local/bin/su-exec && \
    chown root:root /usr/local/bin/su-exec && \
    chmod 0755 /usr/local/bin/su-exec

FROM codercom/code-server
USER root
COPY --from=su-exec /usr/local/bin/su-exec /su-exec

# Docker
ARG DOCKER_COMPOSE_VERSION=1.24.0
RUN apt-get update && \
    apt-get install -y \
        apt-transport-https ca-certificates curl gnupg-agent software-properties-common figlet && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - && \
    add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
       $(lsb_release -cs) \
       stable" && \
    apt-get update && \
    apt-get install -y docker-ce-cli && \
    curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose && \
    curl -L "https://raw.githubusercontent.com/docker/compose/${DOCKER_COMPOSE_VERSION}/contrib/completion/bash/docker-compose" -o /etc/bash_completion.d/docker-compose && \
    curl -L "https://raw.githubusercontent.com/nicferrier/docker-bash-completion/master/docker-complete" -o /etc/bash_completion.d/docker && \
    apt-get install -y \
        bash bash-completion \
        curl wget \
        make git jq htop gettext strace \
        iproute2 bind9-host iputils-ping socat \
        tldr && \
    rm -rf /var/lib/apt/lists/*
# Kubernetes
RUN curl -sSfL https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl -o /usr/bin/kubectl && \
    chmod +x /usr/bin/kubectl

ENTRYPOINT ["bash", "/entrypoint.sh"]
CMD ["--allow-http", "--no-auth"]
COPY entrypoint.sh completion.sh welcome.sh /