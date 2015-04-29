#!/bin/bash
set -e
set -x

export LC_ALL=C
export DEBIAN_FRONTEND=noninteractive
minimal_apt_get_install='apt-get install -y --no-install-recommends'

# https://docs.docker.com/articles/dockerfile_best-practices/ :
# Avoid RUN apt-get upgrade or dist-upgrade
# apt-get dist-upgrade -y --no-install-recommends
# Don’t do RUN apt-get update on a single line  (but along with apt-get install)
apt-get update && $minimal_apt_get_install \
	nano \
	psmisc \
	unzip \
   && apt-get autoremove && apt-get autoclean

## Fix locale.
# $minimal_apt_get_install language-pack-en
# locale-gen en_US
# update-locale LANG=en_US.UTF-8 LC_CTYPE=en_US.UTF-8
# echo -n en_US.UTF-8 > /etc/container_environment/LANG
# echo -n en_US.UTF-8 > /etc/container_environment/LC_CTYPE

# Clean up APT when done.
apt-get clean
rm -rf /var/lib/apt/lists/*

# Now the real stuff.. ;-)
mkdir /root/Jenkins
# curl -L http://mirrors.jenkins-ci.org/war/latest/jenkins.war -o /root/Jenkins/jenkins.war 
mv /build/Downloads/jenkins.war /root/Jenkins/jenkins.war

# Run Hudson once during image creation, so that it's faster first time?
# RUN java -jar hudson.war

rm -rf /build
rm -rf /tmp/* /var/tmp/*

