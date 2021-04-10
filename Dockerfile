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
    shards build --release --static && \
    strip bin/echer && \
    upx -9 bin/echer && \
    rm -f bin/echer.dwarf && \
    :

FROM alpine:latest
# FIXME
ENV UPDATE_PACKAGES enca

WORKDIR /app

ENV CRYSTAL_ENV production
ENV WEB_PORT 8080

COPY --from=build-env /app/bin /app/bin

RUN set -ex && \
    apk --update --no-cache -u add $UPDATE_PACKAGES && \
    rm -rf /var/cache/apk/* && \
    :

EXPOSE $WEB_PORT

CMD ["/app/bin/echer"]
