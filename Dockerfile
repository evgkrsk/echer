FROM crystallang/crystal:1.0.0-alpine as build-env
ENV BUILD_PACKAGES upx
WORKDIR /app

RUN apk --update --no-cache add $BUILD_PACKAGES

COPY shard.yml shard.lock ./
RUN set -ex && \
    shards install && \
    :

COPY . /app

RUN set -ex && \
    crystal bin/ameba.cr && \
    shards build --release --static && \
    strip bin/echer && \
    upx -9 bin/echer && \
    rm -f bin/echer.dwarf && \
    :

FROM alpine:3.13
ENV UPDATE_PACKAGES dumb-init
ENV CRYSTAL_ENV production
WORKDIR /app

COPY --from=build-env /app/bin /app/bin

RUN set -ex && \
    apk --update --no-cache -u add $UPDATE_PACKAGES && \
    rm -rf /var/cache/apk/* && \
    :

EXPOSE 8080

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/app/bin/echer"]
