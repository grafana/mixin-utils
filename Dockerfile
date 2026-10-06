FROM golang:1.25@sha256:699337d620559a59b4a2bb298ad59611e535d2ee755a34cf2d2a98f37578dc80

RUN go install -a github.com/monitoring-mixins/mixtool/cmd/mixtool@master
RUN go install github.com/google/go-jsonnet/cmd/jsonnet@latest
RUN go install -a github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb@latest
RUN curl -fSL -o "/usr/local/bin/grr" "https://github.com/grafana/grizzly/releases/download/v0.2.0/grr-linux-amd64" \
    && chmod a+x "/usr/local/bin/grr"
RUN apt-get update; \
    apt-get install -y jq unzip; \
    rm -rf /var/lib/apt/lists/*

COPY ./common.sh /
COPY ./entrypoint.sh /
COPY ./util.libsonnet /
COPY ./grr.libsonnet /

ENTRYPOINT [ "/entrypoint.sh" ]