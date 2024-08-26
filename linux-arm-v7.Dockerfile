FROM dr34m/python-gcc6:init
RUN apt install -y g++ && cd ~ && wget -O openssl.tar.gz "https://www.openssl.org/source/openssl-1.1.1w.tar.gz" \
    && tar xzf openssl.tar.gz && rm openssl.tar.gz
RUN cd ~ && cd openssl-1.1.1w && ./config
RUN cd ~ && cd openssl-1.1.1w && make
RUN cd ~ && cd openssl-1.1.1w && make install
RUN PATS="/usr/lib/arm-linux-gnueabihf" \
    && cp /usr/local/lib/libcrypto.so "$PATS/libcrypto.so" \
    && cp /usr/local/lib/libcrypto.so.1.1 "$PATS/libcrypto.so.1.1" \
    && cp /usr/local/lib/libssl.so "$PATS/libssl.so" \
    && cp /usr/local/lib/libssl.so.1.1 "$PATS/libssl.so.1.1"
RUN openssl version
RUN cd ~ && apt install -y --no-install-recommends libbluetooth-dev tk-dev uuid-dev && rm -rf /var/lib/apt/lists/* \
    && wget -O python.tar.xz "https://www.python.org/ftp/python/3.11.9/Python-3.11.9.tar.xz" \
    && wget -O python.tar.xz.asc "https://www.python.org/ftp/python/3.11.9/Python-3.11.9.tar.xz.asc" \
    && GNUPGHOME="$(mktemp -d)" && export GNUPGHOME \
    && gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys "A035C8C19219BA821ECEA86B64E628F8D684696D" \
    && gpg --batch --verify python.tar.xz.asc python.tar.xz && gpgconf --kill all && rm -rf "$GNUPGHOME" python.tar.xz.asc \
    && mkdir -p /usr/src/python && tar --extract --directory /usr/src/python --strip-components=1 --file python.tar.xz \
    && rm python.tar.xz && cd /usr/src/python && gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
    && ./configure --build="$gnuArch" --enable-loadable-sqlite-extensions --enable-optimizations  \
    --enable-option-checking=fatal --enable-shared --with-lto --with-system-expat --without-ensurepip \
    && nproc="$(nproc)" && EXTRA_CFLAGS="$(dpkg-buildflags --get CFLAGS)" && LDFLAGS="$(dpkg-buildflags --get LDFLAGS)" \
    && make -j "$nproc" "EXTRA_CFLAGS=${EXTRA_CFLAGS:-}" "LDFLAGS=${LDFLAGS:-}" "PROFILE_TASK=${PROFILE_TASK:-}" \
    && rm python && make -j "$nproc" "EXTRA_CFLAGS=${EXTRA_CFLAGS:-}"  \
    "LDFLAGS=${LDFLAGS:--Wl},-rpath='\$\$ORIGIN/../lib'" "PROFILE_TASK=${PROFILE_TASK:-}" python \
    && make install && bin="$(readlink -ve /usr/local/bin/python3)"  \
    && dir="$(dirname "$bin")" \
    && mkdir -p "/usr/share/gdb/auto-load/$dir" && cp -vL Tools/gdb/libpython.py "/usr/share/gdb/auto-load/$bin-gdb.py" \
    && cd / && rm -rf /usr/src/python \
    && find /usr/local -depth \( \( -type d -a \( -name test -o -name tests -o -name idle_test \) \) -o  \
    \( -type f -a \( -name '*.pyc' -o -name '*.pyo' -o -name 'libpython*.a' \) \) \) -exec rm -rf '{}' +  \
    && ldconfig && python3 --version \
    && for src in idle3 pydoc3 python3 python3-config; do dst="$(echo "$src" | tr -d 3)";  \
    [ -s "/usr/local/bin/$src" ]; [ ! -e "/usr/local/bin/$dst" ]; ln -svT "$src" "/usr/local/bin/$dst"; done \
    && wget -O get-pip.py "https://github.com/pypa/get-pip/raw/c6add47b0abf67511cdfb4734771cbab403af062/public/get-pip.py";  \
    echo "22b849a10f86f5ddf7ce148ca2a31214504ee6c83ef626840fde6e5dcd809d11 *get-pip.py" | sha256sum -c -;  \
    export PYTHONDONTWRITEBYTECODE=1;  \
    python get-pip.py --disable-pip-version-check --no-cache-dir --no-compile "pip==24.2" "setuptools==73.0.1" ;  \
    rm -f get-pip.py; pip --version
RUN pip install pyinstaller
RUN cd ~ && wget https://sqlite.org/2024/sqlite-autoconf-3460000.tar.gz && tar -zxvf sqlite-autoconf-3460000.tar.gz \
    && cd sqlite-autoconf-3460000 && ./configure --prefix=/usr/local && make && make install && sqlite3 --version
CMD ["/bin/sh"]
