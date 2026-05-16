ARG ALFIS_REF=97754c176b21568c4df51b0ca32275a62df4577d

FROM messense/rust-musl-cross:aarch64-musl AS build

ARG ALFIS_REF
WORKDIR /work

COPY patches /work/patches
RUN git init src \
 && cd src \
 && git remote add origin https://github.com/Revertron/Alfis.git \
 && git fetch --depth 1 origin "${ALFIS_REF}" \
 && git checkout --detach FETCH_HEAD
WORKDIR /work/src
RUN git apply /work/patches/*.patch
RUN cargo build --release --no-default-features

FROM alpine:edge AS package

ARG ALFIS_REF
ARG PKG_VERSION=0.8.11.20260517-r1
ARG PKG_ARCH=aarch64_cortex-a53

WORKDIR /work

COPY --from=build /work/src/target/aarch64-unknown-linux-musl/release/alfis /rootfs/usr/bin/alfis
COPY rootfs/etc/alfis/alfis.toml /rootfs/etc/alfis/alfis.toml
COPY rootfs/etc/config/alfis /rootfs/etc/config/alfis
COPY rootfs/etc/init.d/alfis /rootfs/etc/init.d/alfis

RUN mkdir -p /out \
 && chmod 0755 /rootfs/usr/bin/alfis /rootfs/etc/init.d/alfis \
 && chmod 0644 /rootfs/etc/alfis/alfis.toml /rootfs/etc/config/alfis \
 && apk mkpkg \
    --files /rootfs \
    --output /out/alfis-${PKG_VERSION}.apk \
    --info name:alfis \
    --info version:${PKG_VERSION} \
    --info arch:${PKG_ARCH} \
    --info license:MIT \
    --info origin:openwrt-alfis \
    --info maintainer:"Damir Abdullin" \
    --info url:https://github.com/Revertron/Alfis \
    --info description:"ALFIS DNS daemon package for OpenWrt" \
 && cp /rootfs/usr/bin/alfis /out/alfis \
 && cp /rootfs/etc/alfis/alfis.toml /out/alfis.toml \
 && cp /rootfs/etc/config/alfis /out/alfis.uci \
 && cp /rootfs/etc/init.d/alfis /out/alfis.init

FROM scratch AS artifacts

COPY --from=package /out/ /
