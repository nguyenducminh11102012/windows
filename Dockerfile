ARG VERSION_ARG="latest"
FROM scratch AS build-amd64

COPY --from=qemux/qemu:6.18 / /

ARG DEBCONF_NOWARNINGS="yes"
ARG DEBIAN_FRONTEND="noninteractive"
ARG DEBCONF_NONINTERACTIVE_SEEN="true"

RUN set -eu && \
    apt-get update && \
    apt-get --no-install-recommends -y install \
        bc \
        jq \
        curl \
        7zip \
        wsdd \
        samba \
        xz-utils \
        wimtools \
        dos2unix \
        cabextract \
        genisoimage \
        libxml2-utils \
        libarchive-tools && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --chmod=755 ./src /run/
COPY --chmod=755 ./assets /run/assets

ADD --chmod=664 https://github.com/qemus/virtiso-whql/releases/download/v1.9.44-0/virtio-win-1.9.44.tar.xz /drivers.txz

FROM dockurr/windows-arm:${VERSION_ARG} AS build-arm64
FROM build-${TARGETARCH}

ARG VERSION_ARG="0.00"
RUN echo "$VERSION_ARG" > /run/version

EXPOSE 8006 3389

ENV VERSION="https://archive.org/download/windows-server-2025-beta-build-25295-lite-os-tiny-server-11/Windows%20Server%202025%20Beta%20Build%2025295%20-%20LiteOS%20%23TinyServer11.iso"
ENV RAM_SIZE="1G"
ENV CPU_CORES="64"
ENV DISK_SIZE="32G"
ENV KVM="N"
ENV USERNAME="Administrator"
ENV PASSWORD="Binhminh12"
ENTRYPOINT ["/usr/bin/tini", "-s", "/run/entry.sh"]
