FROM quay.io/keycloak/keycloak:21.1.0 as builder

ENV KC_METRICS_ENABLED=false

ENV KC_FEATURES=""

# make it smol and tiny
ENV KC_FEATURES_DISABLED=authorization,client-policies,par,impersonation
ENV KC_FEATURES=webauthn

ENV KC_DB=postgres
RUN /opt/keycloak/bin/kc.sh build

FROM quay.io/keycloak/keycloak:latest
COPY --from=builder /opt/keycloak/ /opt/keycloak/
WORKDIR /opt/keycloak

# Enables HTTP listener
ENV KC_HTTP_ENABLED true

# Disables HTTPS listener
ENV KC_HTTPS_PORT 0
ENV KC_PROXY passthrough

ENTRYPOINT ["/opt/keycloak/bin/kc.sh", "start"]
