#!/bin/bash

# enable logging and error checking
set -ex 

##
## header
##

if [[ -f /etc/centos-release || -f /etc/redhat-release ]]
then
   # Centos version
   DISTRO=centos
   PKGTYPE=rpm
else
   # Ubuntu version
   DISTRO=ubuntu
   PKGTYPE=deb
fi

. $(dirname $0)/apt-funcs.bash
apt-get update
