# syntax=docker/dockerfile:1.7

ARG KEYCLOAK_VERSION=25.0.1

FROM quay.io/keycloak/keycloak:${KEYCLOAK_VERSION} as builder

# make it smol and tiny
ENV KC_FEATURES_DISABLED=authorization,client-policies,par,impersonation,kerberos,step-up-authentication,ciba,device-flow
ENV KC_FEATURES=scripts
ENV KC_METRICS_ENABLED=true

ENV KC_DB=postgres

ARG METRICS_SPI_VERSION=6.0.0
ADD --chown=keycloak:keycloak --chmod=554 --checksum=sha256:442ade5b9110ef27893ee69124b3dc51845d69d3acd9b4049c545baf8ca5aca3 https://github.com/aerogear/keycloak-metrics-spi/releases/download/${METRICS_SPI_VERSION}/keycloak-metrics-spi-${METRICS_SPI_VERSION}.jar /opt/keycloak/providers/keycloak-metrics-spi-${METRICS_SPI_VERSION}.jar

RUN /opt/keycloak/bin/kc.sh build --health-enabled=true

FROM quay.io/keycloak/keycloak:${KEYCLOAK_VERSION}
COPY --from=builder /opt/keycloak/ /opt/keycloak/
WORKDIR /opt/keycloak

ENV KC_HTTP_ENABLED true
ENV KC_HTTPS_PORT 0
ENV KC_PROXY edge

ENTRYPOINT ["/opt/keycloak/bin/kc.sh", "start"]
