FROM dr34m/python-gcc6:deps-without-python
ENV PATH=/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin LANG=C.UTF-8
ENV PYTHON_GET_PIP_URL=https://github.com/pypa/get-pip/raw/66d8a0f637083e2c3ddffc0cb1e65ce126afb856/public/get-pip.py
ENV PYTHON_GET_PIP_SHA256=6fb7b781206356f45ad79efbb19322caa6c2a5ad39092d0d44d0fec94117e118
ENV PYTHON_VERSION=3.11.9 PYTHON_PIP_VERSION=24.2 PYTHON_SETUPTOOLS_VERSION=65.5.1
RUN -c set -eux; wget -O python.tar.xz "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz"; \
    wget -O python.tar.xz.asc "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz.asc"; \
    export GNUPGHOME="$(mktemp -d)"; \
    gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys A035C8C19219BA821ECEA86B64E628F8D684696D; \
    gpg --batch --verify python.tar.xz.asc python.tar.xz; gpgconf --kill all; \
    rm -rf "$GNUPGHOME" python.tar.xz.asc; mkdir -p /usr/src/python; \
    tar --extract --directory /usr/src/python --strip-components=1 --file python.tar.xz; rm python.tar.xz; \
    cd /usr/src/python; gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; \
    ./configure --build="$gnuArch" --enable-loadable-sqlite-extensions --enable-optimizations  \
    --enable-option-checking=fatal --enable-shared --with-lto --with-system-expat --without-ensurepip; \
    nproc="$(nproc)"; EXTRA_CFLAGS="$(dpkg-buildflags --get CFLAGS)"; LDFLAGS="$(dpkg-buildflags --get LDFLAGS)"; \
    make -j "$nproc" "EXTRA_CFLAGS=${EXTRA_CFLAGS:-}" "LDFLAGS=${LDFLAGS:-}" "PROFILE_TASK=${PROFILE_TASK:-}" ; \
    rm python; make -j "$nproc" "EXTRA_CFLAGS=${EXTRA_CFLAGS:-}" "LDFLAGS=${LDFLAGS:--Wl},-rpath='\$\$ORIGIN/../lib'" "PROFILE_TASK=${PROFILE_TASK:-}" python ; \
    make install; bin="$(readlink -ve /usr/local/bin/python3)"; dir="$(dirname "$bin")"; \
    mkdir -p "/usr/share/gdb/auto-load/$dir"; cp -vL Tools/gdb/libpython.py "/usr/share/gdb/auto-load/$bin-gdb.py"; \
    cd /; rm -rf /usr/src/python; \
    find /usr/local -depth \( \( -type d -a \( -name test -o -name tests -o -name idle_test \) \) -o \( -type f -a \( -name '*.pyc' -o -name '*.pyo' -o -name 'libpython*.a' \) \) \) -exec rm -rf '{}' +; \
    ldconfig; python3 --version; cd /usr/local/bin; ln -s idle3 idle; ln -s pydoc3 pydoc; \
    ln -s python3 python; ln -s python3-config python-config; wget -O get-pip.py "$PYTHON_GET_PIP_URL"; \
    echo "$PYTHON_GET_PIP_SHA256 *get-pip.py" | sha256sum --check --strict -; \
    python get-pip.py --disable-pip-version-check --no-cache-dir "pip==$PYTHON_PIP_VERSION" "setuptools==$PYTHON_SETUPTOOLS_VERSION"; \
    ip --version; \
    find /usr/local -depth \( \( -type d -a \( -name test -o -name tests -o -name idle_test \) \) -o \( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \) -exec rm -rf '{}' +; \
    rm -f get-pip.py
CMD ["python3"]
