# syntax=docker/dockerfile:1
FROM debian:bookworm-slim AS build
ARG K8S_OBJECT_DIFF_GO_VERSION=0.5.0
ARG TARGETARCH=amd64

WORKDIR /work
RUN --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    apt-get update && apt-get install -y curl
RUN curl -L -o /work/objdiff \
    https://github.com/berquerant/k8s-object-diff-go/releases/download/v${K8S_OBJECT_DIFF_GO_VERSION}/objdiff_${K8S_OBJECT_DIFF_GO_VERSION}_linux_${TARGETARCH}
RUN chmod +x /work/objdiff

FROM debian:bookworm-slim

COPY --from=build /work/objdiff /usr/local/bin
COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
