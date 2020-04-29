FROM google/cloud-sdk:alpine

RUN apk add --update coreutils

ENV KUSTOMIZE_VERSION 0.0.24
ENV KUBECTL_VER 1.17.4
RUN wget -O /tmp/kustomize.tar.gz https://github.com/qlik-oss/kustomize/releases/download/qlik%2Fv${KUSTOMIZE_VERSION}/kustomize_qlik_v${KUSTOMIZE_VERSION}_linux_amd64.tar.gz
RUN cd /tmp/ && tar xfv kustomize.tar.gz && chmod +x kustomize && mv kustomize /usr/local/bin/


RUN wget -O /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VER}/bin/linux/amd64/kubectl \
    && chmod +x /usr/local/bin/kubectl

COPY --from=mikefarah/yq /usr/bin/yq /usr/local/bin/yq

RUN mkdir -p /src/ejson-keys
#script will read k8s secrets and put ejson keys into this directory
ENV EJSON_KEYDIR /src/ejson-keys

COPY run-script.sh /src/
WORKDIR /src
ENTRYPOINT ["./run-script.sh"]

