FROM ubuntu:18.04

MAINTAINER "Marco Huenseler <marco.huenseler+git@gmail.com>"

ENV BUILD_DEPS="build-essential cmake pkg-config libavahi-client-dev libssl-dev zlib1g-dev wget libcurl4-gnutls-dev git-core liburiparser-dev libdvbcsa-dev"

# Latest successful CI builded commit of master as of 2019/08/11
ENV BUILD_COMMIT="ebb0968047b6a3aecd61b48792ab8b48a50ecb0d"

# Build TVHeadend
RUN apt-get update && \
    apt-get install -y --no-install-suggests --no-install-recommends \
        $BUILD_DEPS gettext bzip2 python curl ca-certificates \
        libssl1.0.0 zlib1g liburiparser1 libavahi-common3 libavahi-client3 libdbus-1-3 libselinux1 liblzma5 libgcrypt20 libpcre3 libgpg-error0 libdvbcsa1 && \
    git clone https://github.com/tvheadend/tvheadend /tvh-build && \
    cd /tvh-build && \
    git checkout -b work $BUILD_COMMIT && \
    ./configure --prefix=/usr && \
    make && \
    make install && \
    rm -rf /tvh-build && \
    apt-get purge -y $BUILD_DEPS && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create user & group
RUN groupadd -g 10710 tvheadend && \
    useradd -u 10710 -g tvheadend tvheadend && \
    install -o tvheadend -g tvheadend -d /tvh-data

VOLUME /tvh-data
EXPOSE 9981 9982

ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["-u", "tvheadend", "-g", "tvheadend", "-c", "/tvh-data/conf"]
