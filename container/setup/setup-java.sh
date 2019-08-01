#!/bin/bash
##
## setup java
##

if [ -z "$JAVA_VERSION" ]
then
   JAVA_VERSION="1.8.0"
   echo "JAVA_VERSION not defined. Using local version JAVA_VERSION=${JAVA_VERSION}"
fi

yum install -y \
java-${JAVA_VERSION}-openjdk-devel \
&& yum clean all \
&& rm -rf /var/cache/yum

cat > /etc/profile.d/local_java.sh <<EOL
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/usr/lib/jvm/java-${JAVA_VERSION}-openjdk/jre/lib/amd64/server"
export JAVA_HOME=/usr/lib/jvm/java-${JAVA_VERSION}-openjdk
export JVM_LIBRARY_PATH=/usr/lib/jvm/java-${JAVA_VERSION}-openjdk/jre/lib/amd64/server/libjvm.so
EOL
