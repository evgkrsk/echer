FROM crystallang/crystal:latest-alpine as build-env
ENV BUILD_PACKAGES upx
WORKDIR /app

RUN set -ex && \
    apk --update --no-cache upgrade && \
    apk --no-cache add $BUILD_PACKAGES

COPY shard.yml shard.lock ./
RUN set -ex && \
    shards install && \
    :

COPY . /app

RUN set -ex && \
    crystal bin/ameba.cr && \
    crystal tool format --check && \
    crystal spec --order=random --error-on-warnings && \
    shards build --release --static --stats --progress --local && \
    strip bin/echer && \
    upx -9 bin/echer && \
    :

FROM alpine:3.16.2
ENV UPDATE_PACKAGES dumb-init
WORKDIR /app

COPY --from=build-env /app/bin/echer /app/bin/echer

RUN set -ex && \
    apk upgrade --update-cache --no-cache && \
    apk --no-cache add --upgrade $UPDATE_PACKAGES && \
    rm -rf /var/cache/apk/* && \
    :

EXPOSE 8080
USER 1001:1001

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/app/bin/echer"]
