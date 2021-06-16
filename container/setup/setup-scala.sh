#!/bin/bash
. $(dirname $0)/setup-header.sh

##
## scala
##

SCALA_VERSION=${SCALA_VERSION:=2.11.12}
rm -f /tmp/scala-${SCALA_VERSION}.${PKGTYPE}
# Get scala deb package into generic package name
# alternate download site if typsafe stops working is lightbend 
# https://downloads.lightbend.com/scala/2.11.12/scala-2.11.12.rpm
wget -O /tmp/scala-${SCALA_VERSION}.${PKGTYPE} \
     http://downloads.typesafe.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.${PKGTYPE}
if [[ ${DISTRO} == ubuntu ]]; then
   apt-get -y install libjansi-java
fi
dpkg -i /tmp/scala-${SCALA_VERSION}.${PKGTYPE}
rm -f /tmp/scala-${SCALA_VERSION}.${PKGTYPE}


##
## SBT (Simple Build Tool), used with scala
## dl.bintray.com is going away.  Installs version 1.5.3 of SBT from github.com.

wget -O /tmp/sbt-1.5.4.tgz https://github.com/sbt/sbt/releases/download/v1.5.4/sbt-1.5.4.tgz
tar xzvf /tmp/sbt-1.5.4.tgz -C /usr/share/
ln -s /usr/share/sbt/bin/sbt /usr/bin/sbt



$(dirname $0)/setup-cleanup.sh
