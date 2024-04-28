# syntax=docker/dockerfile:1
ARG KEYCLOAK_VERSION=24.0.3

FROM registry.access.redhat.com/ubi9 AS extra-packages
RUN mkdir -p /mnt/rootfs
RUN dnf install --installroot /mnt/rootfs curl --releasever 9 --setopt install_weak_deps=false --nodocs -y; dnf --installroot /mnt/rootfs clean all

FROM quay.io/keycloak/keycloak:${KEYCLOAK_VERSION} as builder

# make it smol and tiny
ENV KC_FEATURES_DISABLED=authorization,client-policies,par,impersonation
ENV KC_FEATURES=web-authn
ENV KC_METRICS_ENABLED=true

ENV KC_DB=postgres

ARG METRICS_SPI_VERSION=4.0.0
ADD --chown=keycloak:keycloak --chmod=554 --checksum=sha256:0f434d06e73d6018b2c06a2ae611b875ca22ba7c86fc2d995fbde9e254b9bf8b https://github.com/aerogear/keycloak-metrics-spi/releases/download/${METRICS_SPI_VERSION}/keycloak-metrics-spi-${METRICS_SPI_VERSION}.jar /opt/keycloak/providers/keycloak-metrics-spi-${METRICS_SPI_VERSION}.jar

RUN /opt/keycloak/bin/kc.sh build --health-enabled=true

FROM quay.io/keycloak/keycloak:${KEYCLOAK_VERSION}
COPY --from=builder /opt/keycloak/ /opt/keycloak/
COPY --from=extra-packages /mnt/rootfs /
WORKDIR /opt/keycloak

ENV KC_HTTP_ENABLED true
ENV KC_HTTPS_PORT 0
ENV KC_PROXY edge

ENTRYPOINT ["/opt/keycloak/bin/kc.sh", "start", "--optimized"]
