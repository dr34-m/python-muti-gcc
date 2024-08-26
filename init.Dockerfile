FROM debian:stretch
ENV PATH=/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin LANG=C.UTF-8
COPY sources.list /etc/apt/sources.list
RUN apt-get update && apt install -y gcc wget vim
