FROM docker.io/fedora:30

LABEL name="oc/ansible/terraform container"

ENV APP_ROOT=/opt/executor
ENV PATH=${APP_ROOT}:${PATH} HOME=${APP_ROOT}

RUN mkdir -p ${APP_ROOT} && \
    chown -R 1001:root ${APP_ROOT} && \
    chmod -R u+x ${APP_ROOT}&& \
    chgrp -R 0 ${APP_ROOT} && \
    chmod -R g=u ${APP_ROOT} /etc/passwd /etc/group

# Install rpm packages
RUN export http_proxy=http://10.0.2.2:3128 && export https_proxy=http://10.0.2.2:3128 && \
    ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime && \
    dnf clean all && \
    dnf makecache && \
    dnf install git vim-minimal bash-completion python3-devel python3-pip tar unzip bzip2 curl wget gcc openssh-clients findutils -y && \
    unset http_proxy https_proxy

# Install pip packages
RUN export http_proxy=http://10.0.2.2:3128 && export https_proxy=http://10.0.2.2:3128 && \
    python3 -m pip install --upgrade pip && \
    pip3 install ansible==2.6.0 openshift &&  \
    unset http_proxy https_proxy

# Install openshift clients 3.9 and 3.11
RUN export http_proxy=http://10.0.2.2:3128 && export https_proxy=http://10.0.2.2:3128 && \
    curl -L https://github.com/openshift/origin/releases/download/v3.9.0/openshift-origin-client-tools-v3.9.0-191fece-linux-64bit.tar.gz -o /tmp/openshift-client-39.tar.gz && \
    tar -zxvf /tmp/openshift-client-39.tar.gz -C /tmp/ && \
    mv /tmp/openshift-origin-client-tools-v3.9.0-191fece-linux-64bit/oc /usr/bin/oc && \
    curl -L https://github.com/openshift/origin/releases/download/v3.11.0/openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz -o /tmp/openshift-client-311.tar.gz && \
    tar -zxvf /tmp/openshift-client-311.tar.gz -C /tmp/ && \
    mv /tmp/openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit/oc /usr/bin/oc311 && \
    rm -rf /tmp/openshift-* && \
    unset http_proxy https_proxy
   
# Install terraform
RUN export http_proxy=http://10.0.2.2:3128 && export https_proxy=http://10.0.2.2:3128 && \
    curl -L https://releases.hashicorp.com/terraform/0.11.8/terraform_0.11.8_linux_amd64.zip -o /tmp/terraform_0.11.8_linux_amd64.zip && \
    cd /tmp && unzip terraform_0.11.8_linux_amd64.zip && \
    mv /tmp/terraform /usr/bin/terraform_0.11.8 && \
    rm -rf /tmp/terraform-* && \
    unset http_proxy https_proxy

WORKDIR ${APP_ROOT}

USER 1001

# default command: display Ansible version
CMD [ "ansible-playbook", "--version" ]
