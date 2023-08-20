FROM golang:latest AS builder

LABEL org.opencontainers.image.source https://github.com/yangchuansheng/ip_derper

WORKDIR /app

ADD tailscale /app/tailscale

# build modified derper
RUN cd /app/tailscale/cmd/derper && \
    CGO_ENABLED=0 /usr/local/go/bin/go build -buildvcs=false -ldflags "-s -w" -o /app/derper && \
    cd /app && \
    rm -rf /app/tailscale

FROM ubuntu:20.04
WORKDIR /app

# ========= CONFIG =========
# - derper args

ENV DERP_DOMAIN 127.0.0.1
ENV DERP_CERT_MODE manual
ENV DERP_CERT_DIR /app/certs
ENV DERP_ADDR :443
ENV DERP_STUN true
ENV DERP_STUN_PORT 3478
ENV DERP_HTTP_PORT 80
ENV DERP_VERIFY_CLIENTS false
# ==========================

# apt
RUN apt-get update && \
    apt-get install -y openssl curl

COPY build_cert.sh /app/
COPY --from=builder /app/derper /app/derper


# CMD /app/derper --hostname=$DERP_DOMAIN \
#     --certmode=$DERP_CERT_MODE \
#     --certdir=$DERP_CERT_DIR \
#     --a=$DERP_ADDR \
#     --stun=$DERP_STUN  \
#     --stun-port=$DERP_STUN_PORT \
#     --http-port=$DERP_HTTP_PORT \
#     --verify-clients=$DERP_VERIFY_CLIENTS

# build self-signed certs && start derper
CMD bash /app/build_cert.sh $DERP_DOMAIN $DERP_CERT_DIR /app/san.conf && \
    /app/derper --hostname=$DERP_DOMAIN \
    --certmode=$DERP_CERT_MODE \
    --certdir=$DERP_CERT_DIR \
    --stun=$DERP_STUN  \
    --stun-port=$DERP_STUN_PORT \
    --a=$DERP_ADDR \
    --http-port=$DERP_HTTP_PORT \
    --verify-clients=$DERP_VERIFY_CLIENTS