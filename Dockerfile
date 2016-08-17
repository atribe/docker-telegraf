FROM appcelerator/alpine:20160726
MAINTAINER Nicolas Degory <ndegory@axway.com>

ENV TELEGRAF_VERSION 0.13.2

RUN apk update && apk upgrade && \
    apk --virtual build-deps add go>1.6 git gcc musl-dev make binutils && \
    export GOPATH=/go && \
    go get -v github.com/influxdata/telegraf && \
    cd $GOPATH/src/github.com/influxdata/telegraf && \
    git checkout -q --detach "${TELEGRAF_VERSION}" && \
    make && \
    chmod +x $GOPATH/bin/* && \
    mv $GOPATH/bin/* /bin/ && \
    apk del build-deps && \
    cd / && rm -rf /var/cache/apk/* $GOPATH && \
    mkdir -p /etc/telegraf

EXPOSE 8125/udp 8092/udp 8094

ENV INFLUXDB_URL http://localhost:8086
ENV INTERVAL 10s
ENV OUTPUT_INFLUXDB_ENABLED     true
ENV OUTPUT_CLOUDWATCH_ENABLED   false
ENV OUTPUT_KAFKA_ENABLED        false
ENV OUTPUT_FILE_ENABLED         false
ENV INPUT_KAFKA_ENABLED         false
ENV INPUT_CPU_ENABLED           false
ENV INPUT_DISK_ENABLED          false
ENV INPUT_DISKIO_ENABLED        false
ENV INPUT_KERNEL_ENABLED        false
ENV INPUT_MEM_ENABLED           false
ENV INPUT_PROCESS_ENABLED       false
ENV INPUT_SWAP_ENABLED          false
ENV INPUT_SYSTEM_ENABLED        false
ENV INPUT_DOCKER_ENABLED        true

COPY telegraf.conf.tpl /etc/telegraf/telegraf.conf.tpl
COPY run.sh /run.sh

ENV SERVICE_NAME=telegraf

ENTRYPOINT ["/bin/sh", "-c"]
CMD ["/run.sh"]

HEALTHCHECK --interval=5s --retries=30 --timeout=10s CMD pidof telegraf

LABEL axway_image=telegraf
# will be updated whenever there's a new commit
LABEL commit=${GIT_COMMIT}
LABEL branch=${GIT_BRANCH}
