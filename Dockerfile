FROM debian:buster-20220328-slim

ENV KUBECTL_VERSION="v1.23.0"
ENV HELM_VERSION=3.7.1
ENV HELM_BASE_URL="https://get.helm.sh"
ENV PYTHONUNBUFFERED=1

# Install deps
RUN apt-get update && apt-get install -y coreutils ca-certificates curl gnupg wget git lsb-release

# Install python
RUN apt-get install -y python3 python3-dev python3-pip

RUN ln -sf python3 /usr/bin/python
RUN pip3 install --no-cache --upgrade pip setuptools

# Install pre-commit
RUN pip3 install --no-cache --upgrade --ignore-installed pre-commit

# Install npm
RUN apt-get install -y nodejs npm yarn

# Install docker
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
RUN echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

RUN apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin


# Install kubectl
ADD https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl /usr/local/bin/kubectl

ENV HOME=/config

RUN set -x && \
    chmod +x /usr/local/bin/kubectl && \
    \
    # Create non-root user (with a randomly chosen UID/GUI).
    adduser kubectl -Du 2342 -h /config && \
    \
    # Basic check it works.
    kubectl version --client

# Install helm
RUN case `uname -m` in \
        x86_64) ARCH=amd64; ;; \
        armv7l) ARCH=arm; ;; \
        aarch64) ARCH=arm64; ;; \
        ppc64le) ARCH=ppc64le; ;; \
        s390x) ARCH=s390x; ;; \
        *) echo "un-supported arch, exit ..."; exit 1; ;; \
    esac && \
    wget ${HELM_BASE_URL}/helm-v${HELM_VERSION}-linux-${ARCH}.tar.gz -O - | tar -xz && \
    mv linux-${ARCH}/helm /usr/bin/helm && \
    chmod +x /usr/bin/helm && \
    rm -rf linux-${ARCH}

RUN chmod +x /usr/bin/helm

# Clean up
RUN apt-get clean all