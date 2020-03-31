FROM alpine:3.8

ARG AWS_CLI_VERSION=1.16.270
ENV AWS_CLI_VERSION=$AWS_CLI_VERSION

ARG TERRAFORM_VERSION=0.12.12
ENV TERRAFORM_VERSION=$TERRAFORM_VERSION

ARG KUBE_VERSION=v1.16.2
ENV KUBE_VERSION=$KUBE_VERSION

ARG HELM_VERSION=v2.14.3
ENV HELM_VERSION=$HELM_VERSION

RUN apk add --update --no-cache -t \
      deps \
      ca-certificates \
      curl \
      python \
      py-pip \
      jq \
      git \
      openssh \
      groff \
      less \
      mailcap \
      bash \
      build-base \
    && pip install --upgrade pip \
    && pip install --no-cache-dir awscli==$AWS_CLI_VERSION \
    && apk del py-pip \
    && rm -rf /var/cache/apk/* /root/.cache/pip/*


# Install Terraform
RUN wget -q -O /terraform.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" \
    && unzip /terraform.zip -d /bin

# Install kubectl
RUN    wget -q https://storage.googleapis.com/kubernetes-release/release/${KUBE_VERSION}/bin/linux/amd64/kubectl -O /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl \
    && wget -q https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz -O - | tar -xzO linux-amd64/helm > /usr/local/bin/helm \
    && chmod +x /usr/local/bin/helm

# Install AWS IAM Authenticator
RUN mkdir -p $HOME/bin \
    && curl -o $HOME/bin/aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.12.7/2019-03-27/bin/linux/amd64/aws-iam-authenticator \
    && chmod +x $HOME/bin/aws-iam-authenticator \
    && export PATH=$HOME/bin:$PATH \
    && echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc

WORKDIR /root
VOLUME /root/.aws

ENTRYPOINT [ "aws" ]
CMD ["--version"]
