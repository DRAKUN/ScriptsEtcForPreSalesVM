#!/bin/bash
set -e
set -x

export LC_ALL=C
export DEBIAN_FRONTEND=noninteractive
minimal_apt_get_install='apt-get install -y --no-install-recommends'

# https://docs.docker.com/articles/dockerfile_best-practices/ :
# Avoid RUN apt-get upgrade or apt-get dist-upgrade -y --no-install-recommends
# Don’t do RUN apt-get update on a single line  (but along with apt-get install)
apt-get update && $minimal_apt_get_install \
	nano \
	psmisc \
	unzip \
	supervisor \
	subversion \
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

# Now finally the real stuff.. ;-)
# Set up Jenkins
mkdir /root/Jenkins
# curl -L http://mirrors.jenkins-ci.org/war/latest/jenkins.war -o /root/Jenkins/jenkins.war 
mv /build/Downloads/jenkins.war /root/Jenkins/jenkins.war
# Run Hudson once during image creation, so that it's faster first time?
# RUN java -jar hudson.war

# Set up Maven
mv /build/Common/Maven/settings.xml /root/apache-maven-3.3.3/conf/
# Set up Maven repository
mkdir -p /root/.m2/repository/ && \
	mv /build/Downloads/p2.oams.com/dist/latest/master/t24-binaries*.zip /root/.m2/repository/ && \
	cd /root/.m2/repository/ && unzip t24-binaries*.zip && rm /root/.m2/repository/t24-binaries*.zip

# Set up SVN
cd /root/
svnadmin create DemoSVNServer
mv /build/Common/Subversion/svnserve.conf /root/DemoSVNServer/conf/
mv /build/Common/Subversion/passwds /root/DemoSVNServer/conf/

# Set up Supervisor
mkdir -p /var/log/supervisor
cp /build/Common/Supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Clean up
rm -rf /build
rm -rf /tmp/* /var/tmp/*
