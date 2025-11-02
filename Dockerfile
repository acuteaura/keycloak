# syntax=docker/dockerfile:1

ARG KEYCLOAK_VERSION=26.4.2
ARG KC_FEATURES=scripts
ARG KC_FEATURES_DISABLED=client-policies,par,impersonation,kerberos,step-up-authentication,ciba
ARG KC_METRICS_ENABLED=true
ARG KC_DB=postgres
ARG METRICS_SPI_VERSION=7.0.0

FROM quay.io/keycloak/keycloak:${KEYCLOAK_VERSION} as builder

# Re-import all args for this stage
ARG KC_FEATURES_DISABLED KC_FEATURES KC_METRICS_ENABLED KC_DB METRICS_SPI_VERSION

ENV KC_FEATURES_DISABLED=${KC_FEATURES_DISABLED} \
    KC_FEATURES=${KC_FEATURES} \
    KC_METRICS_ENABLED=${KC_METRICS_ENABLED} \
    KC_DB=${KC_DB}

ADD --chown=keycloak:keycloak --chmod=554 --checksum=sha256:e7ec72ab1699e57a25b61cb5e3ef1c532ec9858ed6931c1b491d3368f5d007b8 https://github.com/aerogear/keycloak-metrics-spi/releases/download/${METRICS_SPI_VERSION}/keycloak-metrics-spi-${METRICS_SPI_VERSION}.jar /opt/keycloak/providers/keycloak-metrics-spi-${METRICS_SPI_VERSION}.jar

RUN /opt/keycloak/bin/kc.sh build --health-enabled=true

FROM quay.io/keycloak/keycloak:${KEYCLOAK_VERSION}

ARG KC_FEATURES_DISABLED KC_FEATURES KC_METRICS_ENABLED

COPY --from=builder /opt/keycloak/ /opt/keycloak/
WORKDIR /opt/keycloak

ENV KC_FEATURES_DISABLED=${KC_FEATURES_DISABLED} \
    KC_FEATURES=${KC_FEATURES} \
    KC_METRICS_ENABLED=${KC_METRICS_ENABLED} \
    KC_HTTP_ENABLED=true \
    KC_HTTPS_PORT=0 \
    KC_PROXY_HEADERS=xforwarded

ENTRYPOINT ["/opt/keycloak/bin/kc.sh", "start", "--optimized"]
