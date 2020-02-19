# Mail-in-a-Box Dockerfile
###########################
#
# This file lets Mail-in-a-Box run inside of Docker (https://docker.io),
# a virtualization/containerization manager.
#
# Run:
#   $ containers/docker/run.sh
# to build the image, launch a storage container, and launch a Mail-in-a-Box
# container.
#
###########################################

# We need a better starting image than docker's ubuntu image because that
# base image doesn't provide enough to run most Ubuntu services. See
# http://phusion.github.io/baseimage-docker/ for an explanation.

FROM ubuntu:18.04

# Dockerfile metadata.
MAINTAINER Stenny Chong
EXPOSE 25 53/udp 53/tcp 80 443 587 993 4190
VOLUME /home/user-data

# Create the user-data user, so the start script doesn't have to.
RUN useradd -m user-data

# Docker has a beautiful way to cache images after each step. The next few
# steps of installing system packages are very intensive, so we take care
# of them early and let docker cache the image after that, before doing
# any Mail-in-a-Box specific system configuration. That makes rebuilds
# of the image extremely fast.

# Update system packages.
RUN apt-get update && apt-get -y install software-properties-common apt-utils
#RUN add-apt-repository -y ppa:mail-in-a-box/ppa
RUN DEBIAN_FRONTEND=noninteractive apt-get -y upgrade
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install lsb-release dialog locales net-tools iproute2 systemd nano
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install opendkim opendkim-tools opendmarc openssh-server python3 python3-dev python3-pip netcat-openbsd wget curl git sudo coreutils bc haveged pollinate unattended-upgrades cron ntp fail2ban
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install nsd ldnsutils openssh-client 
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install postfix postfix-pcre postgrey ca-certificates python3-flask links duplicity libyaml-dev python3-dnspython python3-dateutil python-pip
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install build-essential libssl-dev libffi-dev python3-dev munin munin-node libcgi-fast-perl
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install spampd razor pyzor dovecot-antispam libmail-dkim-perl openssl 

RUN locale-gen en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8

# Install packages needed by Mail-in-a-Box.
#ADD containers/docker/apt_package_list.txt /tmp/mailinabox_apt_package_list.txt
#RUN DEBIAN_FRONTEND=noninteractive apt-get install -y $(cat /tmp/mailinabox_apt_package_list.txt)

# from questions.sh -- needs merging into the above line
#RUN DEBIAN_FRONTEND=noninteractive apt-get install -y dialog python3 python3-pip systemd
RUN pip3 install "email_validator==0.1.0-rc4"

# Now add Mail-in-a-Box to the system.
ADD . /usr/local/mailinabox
#RUN /usr/local/mailinabox/setup/start.sh

ENTRYPOINT ["/sbin/init"]


