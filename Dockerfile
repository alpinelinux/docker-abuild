FROM alpine:edge
MAINTAINER Richard Mortier <mort@cantab.net>

RUN apk add --update-cache \
      alpine-conf \
      alpine-sdk \
    && setup-apkcache /var/cache/apk

RUN adduser -D builder \
    && addgroup builder abuild \
    && echo 'builder ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

COPY entrypoint.sh /home/builder

USER builder
WORKDIR /cwd
ENTRYPOINT ["/home/builder/entrypoint.sh"]
