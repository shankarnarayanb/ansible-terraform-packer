FROM alpine:3.10.0

ARG TERRAFORM_VERSION="0.12.26"
ARG ANSIBLE_VERSION="2.9.9"
ARG PACKER_VERSION="1.5.4"

LABEL maintainer="Shankar Balakrishna <Shankarnarayanb@gmail.com>"
LABEL ansible_version=${ANSIBLE_VERSION}
LABEL terraform_version=${TERRAFORM_VERSION}
LABEL packer_version=${PACKER_VERSION}


RUN echo "====> Setting up the environment for the build dependencies <====" && \
    apk --update add --no-cache curl python3 \
    openssl \
    ca-certificates && \
    echo "====> Setting up the evirtual dependencies <====" && \
    apk --update add --virtual .build-deps \
    python3-dev \
    git \ 
    py-pip\
    libffi-dev \
    py-paramiko \
    git \
    unzip \
    curl \
    py-dateutil \
    py-httplib2 \
    py-pip \
    openssh-client \
    sshpass \
    openssl-dev \
    build-base && \
    echo "====> Installing Ansible  <====" && \
    pip install ansible==${ANSIBLE_VERSION} && \
    echo "===> Initializing Ansible inventory by adding localhost to hosts file..." && \
    mkdir -p /etc/ansible && \
    echo 'localhost' > /etc/ansible/hosts && \
    echo "===> Installing Terraform and Packer..." && \
    echo "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" && \
    curl -LO https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    echo "https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip" && \
    curl -LO https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip && \
    unzip '*.zip' -d /usr/local/bin && \
    rm -rf  *.zip

RUN echo "====> Setting up ansible environment varibales and parameters  <====" 
ENV HOME                      /home/ansible
ENV PATH                      /etc/ansible/bin:$PATH
ENV ANSIBLE_SSH_PIPELINING                True
ENV ANSIBLE_GATHERING                     smart
ENV ANSIBLE_HOST_KEY_CHECKING             false
ENV ANSIBLE_RETRY_FILES_ENABLED           false

RUN echo "===> Setting up an ansible user..." && \ 
    adduser -h $HOME ansible -D \
    && chown -R ansible:ansible $HOME
RUN echo "ansible ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
    && chmod 0440 /etc/sudoers

ENTRYPOINT ["sh", "-c", "terraform -v && ansible --version && packer --version"]
