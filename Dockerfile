
# --->
# ---> Going with Ubuntu's Long Term Support (lts)
# ---> version which is currently 18.04.
# --->

FROM ubuntu:18.04


# --->
# ---> Assume the root user and install git, terraform,
# ---> a time zone manipulator and pythonic tools for
# ---> testing the AWS based infrastructure.
# --->

USER root

RUN apt-get update && apt-get --assume-yes install -qq -o=Dpkg::Use-Pty=0 \
      curl            \
      git             \
      jq              \
      python-pip      \
      build-essential \
      libssl-dev      \
      libffi-dev      \
      python-dev      \
      tree            \
      unzip


# --->
# ---> The python script (ran by Terraform) for pulling
# ---> down an etcd cluster discovery url needs a REST API
# ---> package called requests.
# --->
RUN pip install requests


# --->
# ---> Install the Terraform binary.
# --->

RUN \
    curl -o /tmp/terraform.zip https://releases.hashicorp.com/terraform/0.11.9/terraform_0.11.9_linux_amd64.zip && \
    unzip /tmp/terraform.zip -d /usr/local/bin && \
    chmod a+x /usr/local/bin/terraform         && \
    rm /tmp/terraform.zip                      && \
    terraform --version


USER ubuntu
WORKDIR /home/ubuntu
