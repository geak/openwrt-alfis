# openwrt-alfis

Docker-based build setup for packaging [ALFIS](https://github.com/Revertron/Alfis) for OpenWrt as an `.apk` package.

The package is meant for headless OpenWrt systems. Graphical components are excluded from the build.

## Build

From the repository root:

```sh
docker build \
  --build-arg ALFIS_REF=ce16cb7b0c595833890b4f4d2f9efe13a2454061 \
  --build-arg PKG_VERSION=0.8.9.20260420-r1 \
  --build-arg PKG_ARCH=aarch64_cortex-a53 \
  --output ./dist \
  .
```

## Installation on OpenWrt

Copy the package to the router and install it:

```sh
scp ./dist/alfis-0.8.9.20260420-r1.apk root@openwrt:/tmp/
```

On a router:

```sh
apk verify --allow-untrusted /tmp/alfis-0.8.9.20260420-r1.apk
apk add --simulate --allow-untrusted --force-non-repository /tmp/alfis-0.8.9.20260420-r1.apk
apk add --allow-untrusted --force-non-repository /tmp/alfis-0.8.9.20260420-r1.apk
```

Configure storage before the first start:

```sh
uci set alfis.main.workdir='/storage/alfis'
uci commit alfis
```

Enable and start the service:

```sh
/etc/init.d/alfis enable && /etc/init.d/alfis start
```

Check service status:

```sh
/etc/init.d/alfis status
```

If `dig` is available on the router, test the local DNS listener:

```sh
dig @127.0.0.1 -p 5533 example.ygg
```

Depending on the local DNS setup, configure `dnsmasq` or another resolver to forward ALFIS zones to `127.0.0.1#5533`.
For OpenWrt `dnsmasq`, add this to the relevant section in `/etc/config/dhcp`:

```sh
list server '/ygg/127.0.0.1#5533'
```
