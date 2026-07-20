FROM golang:1.18@sha256:50c889275d26f816b5314fc99f55425fa76b18fcaf16af255f5d57f09e1f48da

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