FROM docker:1.11-dind

RUN mkdir /containers

VOLUME ["/containers"]

# TODO
# https://github.com/docker/docker/issues/1916
# https://github.com/docker/docker/pull/20767
# RUN docker pull our_containers
#

ENTRYPOINT dockerd-entrypoint.sh --storage-driver=aufs
