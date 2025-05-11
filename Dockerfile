FROM debian:bookworm-slim
ARG YQ_VERSION=v4.45.4
ARG YQ_BINARY=yq_linux_amd64

COPY setup.sh entrypoint.sh object.sh /
RUN /setup.sh

ENTRYPOINT ["/entrypoint.sh"]
