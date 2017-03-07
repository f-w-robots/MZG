FROM docker:1.13.1-dind

RUN mkdir /containers

VOLUME ["/containers"]

ENTRYPOINT dockerd-entrypoint.sh --storage-driver=aufs
