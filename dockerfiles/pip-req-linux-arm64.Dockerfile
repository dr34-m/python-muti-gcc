FROM dr34m/python-gcc6:3.11.9
COPY requirements.txt ./
RUN /bin/sh -c set -eux; pip install --no-cache-dir -r requirements.txt; pip install --no-cache-dir \
    moviepy==1.0.3 paramiko==3.4.1