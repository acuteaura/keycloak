FROM quay.io/keycloak/keycloak:19.0.1 as builder

ENV KC_METRICS_ENABLED=false

ENV KC_FEATURES=""

# make it smol and tiny
ENV KC_FEATURES_DISABLED=authorization,client-policies,par,impersonation,web-authn

ENV KC_STORAGE_AREA_ACTION_TOKEN=jpa
ENV KC_STORAGE_AREA_AUTH_SESSION=jpa
ENV KC_STORAGE_AREA_AUTHORIZATION=jpa
ENV KC_STORAGE_AREA_CLIENT=jpa
ENV KC_STORAGE_AREA_CLIENT_SCOPE=jpa
ENV KC_STORAGE_AREA_EVENT_ADMIN=jpa
ENV KC_STORAGE_AREA_EVENT_AUTH=jpa
ENV KC_STORAGE_AREA_GROUP=jpa
ENV KC_STORAGE_AREA_LOGIN_FAILURE=jpa
ENV KC_STORAGE_AREA_REALM=jpa
ENV KC_STORAGE_AREA_ROLE=jpa
ENV KC_STORAGE_AREA_SINGLE_USE_OBJECT=jpa
ENV KC_STORAGE_AREA_USER=jpa
ENV KC_STORAGE_AREA_USER_SESSION=jpa

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
