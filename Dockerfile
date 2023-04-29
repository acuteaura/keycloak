FROM registry.access.redhat.com/ubi9 AS extra-packages
RUN mkdir -p /mnt/rootfs
RUN dnf install --installroot /mnt/rootfs curl --releasever 9 --setopt install_weak_deps=false --nodocs -y; dnf --installroot /mnt/rootfs clean all

FROM quay.io/keycloak/keycloak:21.1.1 as builder
ENV KC_METRICS_ENABLED=false
ENV KC_FEATURES=""

# make it smol and tiny
ENV KC_FEATURES_DISABLED=authorization,client-policies,par,impersonation
ENV KC_FEATURES=webauthn

ENV KC_DB=postgres
RUN /opt/keycloak/bin/kc.sh build --health-enabled=true

FROM quay.io/keycloak/keycloak:21.1.1
COPY --from=builder /opt/keycloak/ /opt/keycloak/
COPY --from=extra-packages /mnt/rootfs /
WORKDIR /opt/keycloak

# Enables HTTP listener
ENV KC_HTTP_ENABLED true

# Disables HTTPS listener
ENV KC_HTTPS_PORT 0
ENV KC_PROXY passthrough

ENTRYPOINT ["/opt/keycloak/bin/kc.sh", "start"]
