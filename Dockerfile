FROM quay.io/keycloak/keycloak:18.0.0 as builder

ENV KC_METRICS_ENABLED=true

# This is just neat to have, but still limited in some ways
ENV KC_FEATURES=

# make it smol and tiny
ENV KC_FEATURES_DISABLED=authorization,client-policies,par,impersonation,web-authn

ENV KC_DB=postgres
RUN /opt/keycloak/bin/kc.sh build

FROM quay.io/keycloak/keycloak:latest
COPY --from=builder /opt/keycloak/lib/quarkus/ /opt/keycloak/lib/quarkus/
WORKDIR /opt/keycloak

# Enables HTTP listener
ENV KC_HTTP_ENABLED true

# Disables HTTPS listener
ENV KC_HTTPS_PORT 0
ENV KC_PROXY passthrough

ENTRYPOINT ["/opt/keycloak/bin/kc.sh", "start"]
