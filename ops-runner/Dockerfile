FROM google/cloud-sdk:alpine

RUN apk add --update coreutils jq

ENV KUBECTL_VER 1.17.4
RUN wget -O /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VER}/bin/linux/amd64/kubectl \
    && chmod +x /usr/local/bin/kubectl

COPY --from=mikefarah/yq /usr/bin/yq /usr/local/bin/yq

COPY run-script.sh /src/

RUN mkdir -p /src/config_repo
RUN git clone https://github.com/qlik-oss/qliksense-k8s /src/config_repo
#RUN cd /src/config_repo && git checkout master
RUN ls -la /src/config_repo/*

WORKDIR /src
ENTRYPOINT ["./run-script.sh"]

