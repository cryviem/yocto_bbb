FROM ubuntu:20.04
MAINTAINER an23592@gmail.com
LABEL description="yocto bbb env"

ENV DEBIAN_FRONTEND=noninteractive
ENV LD_LIBRARY_PATH=/usr/local/lib

RUN apt-get -y update && apt-get -y upgrade && \
	# Add support for add-apt-repository
	apt-get -y install gawk wget git diffstat unzip texinfo gcc build-essential chrpath socat cpio python3 python3-pip python3-pexpect \
	xz-utils debianutils iputils-ping python3-git python3-jinja2 libegl1-mesa libsdl1.2-dev pylint3 xterm python3-subunit mesa-common-dev zstd liblz4-tool \
	vim net-tools cmake sudo locales && \
	apt-get clean

RUN locale-gen en_US.UTF-8

RUN useradd -m -u 1024 -s /bin/bash -G root andy && \
	echo 'andy     ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER andy


CMD bash
