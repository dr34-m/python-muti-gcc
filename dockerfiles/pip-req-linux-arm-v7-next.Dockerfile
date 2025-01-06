FROM dr34m/python-gcc6:pip-req
COPY requirements-next.txt ./
RUN /bin/sh -c set -eux; pip install --no-cache-dir -r requirements-next.txt