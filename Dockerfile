FROM ubuntu:16.04

MAINTAINER "Marco Huenseler <marco.huenseler+git@gmail.com>"

ENV BUILD_DEPS="build-essential pkg-config libavahi-client-dev libssl-dev zlib1g-dev wget libcurl4-gnutls-dev git-core liburiparser-dev"

# Head of release/4.0 branch as of 2017/03/26
ENV BUILD_COMMIT="1856b94aa35d547034304fbe7e59afe7870c1b5a"

# Build TVHeadend
RUN apt-get update && \
    apt-get install -y --no-install-suggests --no-install-recommends \
        $BUILD_DEPS gettext bzip2 python curl ca-certificates \
        libssl1.0.0 zlib1g liburiparser1 libavahi-common3 libavahi-client3 libdbus-1-3 libselinux1 liblzma5 libgcrypt20 libpcre3 libgpg-error0 && \
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
