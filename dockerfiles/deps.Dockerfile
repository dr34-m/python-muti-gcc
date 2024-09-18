FROM buildpack-deps:stretch-scm
COPY ../sources.list /etc/apt/sources.list
RUN set -ex; apt-get update; \
    apt-get install -y --no-install-recommends autoconf automake bzip2 dpkg-dev file g++ gcc imagemagick libbz2-dev \
    libc6-dev libcurl4-openssl-dev libdb-dev libevent-dev libffi-dev libgdbm-dev libglib2.0-dev libgmp-dev \
    libjpeg-dev libkrb5-dev liblzma-dev libmagickcore-dev libmagickwand-dev libmaxminddb-dev libncurses5-dev \
    libncursesw5-dev libpng-dev libpq-dev libreadline-dev libsqlite3-dev libssl-dev libtool libwebp-dev libxml2-dev \
    libxslt-dev libyaml-dev make patch unzip xz-utils libbluetooth-dev tk-dev uuid-dev zlib1g-dev \
    $( if apt-cache show 'default-libmysqlclient-dev' 2>/dev/null | grep -q '^Version:'; \
    then echo 'default-libmysqlclient-dev'; else echo 'libmysqlclient-dev'; fi ) ;  rm -rf /var/lib/apt/lists/*; \
    wget -O openssl.tar.gz "https://www.openssl.org/source/openssl-1.1.1w.tar.gz"; mkdir -p /usr/src/openssl; \
    tar --extract --directory /usr/src/openssl --strip-components=1 --file openssl.tar.gz; rm openssl.tar.gz; \
    cd /usr/src/openssl; ./config; make; make install; \
    gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; PATS="/usr/lib/$gnuArch"; \
    cp /usr/local/lib/libcrypto.* "$PATS/"; cp /usr/local/lib/libssl.* "$PATS/"; \
    openssl version
