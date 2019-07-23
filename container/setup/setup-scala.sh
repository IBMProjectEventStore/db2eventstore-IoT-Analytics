#!/bin/bash
. $(dirname $0)/setup-header.sh

##
## scala
##

SCALA_VERSION=${SCALA_VERSION:=2.11.8}
rm -f /tmp/scala-${SCALA_VERSION}.${PKGTYPE}
# Get scala deb package into generic package name
wget -O /tmp/scala-${SCALA_VERSION}.${PKGTYPE} \
     http://downloads.typesafe.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.${PKGTYPE}
if [[ ${DISTRO} == ubuntu ]]; then
   apt-get -y install libjansi-java
fi
dpkg -i /tmp/scala-${SCALA_VERSION}.${PKGTYPE}
rm -f /tmp/scala-${SCALA_VERSION}.${PKGTYPE}


##
## SBT (Simple Build Tool)
##

## if SBT Repo not in list, then add it
# Not in CentOS (yum) repo list?
if [[ -d /etc/yum.repos.d && ! -f /etc/yum.repos.d/bintray-sbt-rpm.repo ]]
then
   curl https://bintray.com/sbt/rpm/rpm \
	| tee /etc/yum.repos.d/bintray-sbt-rpm.repo

# Not in Ubuntu (apt) repo list?
elif [[ -d /etc/apt/sources.list.d && ! -f /etc/apt/sources.list.d/sbt.list ]]
then
   sbtlist=/etc/apt/sources.list.d/sbt.list
   sbturl="https://dl.bintray.com/sbt/debian"
   echo "deb $sbturl /" | tee -a $sbtlist

   # Add repo key and install sbt
   apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 642AC823
fi

# install sbt from added repos
apt-get update
SBT_VERSION=""
apt-get -y install sbt${SBT_VERSION}

$(dirname $0)/setup-cleanup.sh
