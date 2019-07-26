FROM registry.access.redhat.com/ubi7/ubi:latest
LABEL maintainer "Chen Gao <Chen.Gao@.ibm.com>"

ARG SETUP_AREA=/setup
COPY setup ${SETUP_AREA}

ARG JAVA_VERSION=1.8.0

# Install neccessary packages
RUN yum install -y \
    java-${JAVA_VERSION}-openjdk-devel \
    wget \
    vim \
    unzip \
    less \
    git \
    gcc \
    make \
    sudo \
    zlib-devel \
    && yum clean all \
    && rm -rf /var/cache/yum

ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/usr/lib/jvm/java-${JAVA_VERSION}-openjdk/jre/lib/amd64/server" \
    JAVA_HOME=/usr/lib/jvm/java-${JAVA_VERSION}-openjdk \
    JVM_LIBRARY_PATH=/usr/lib/jvm/java-${JAVA_VERSION}-openjdk/jre/lib/amd64/server/libjvm.so \
    IOT_REPO_PATH=/root/db2eventstore-IoT-Analytics

RUN git clone https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics.git ${IOT_REPO_PATH}

# Install jq
RUN wget -O /usr/local/bin/jq https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
RUN chmod +x /usr/local/bin/jq

# Setup spark/scala/python/rest
ENV SPARK_HOME="/spark_home"
ENV PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin
RUN ${SETUP_AREA}/setup-spark.sh
RUN ${SETUP_AREA}/setup-scala.sh
RUN ${SETUP_AREA}/setup-python.sh
RUN ${SETUP_AREA}/setup-kafka.sh
RUN ${IOT_REPO_PATH}/rest/install.sh

# Copy ES2.0 client libraries
RUN wget -P ${SPARK_HOME}/jars/ https://repo1.maven.org/maven2/com/ibm/event/ibm-db2-eventstore-client-spark-2.2.1/2.0.0/ibm-db2-eventstore-client-spark-2.2.1-2.0.0.jar

# Create client config file
RUN mkdir -p /bluspark/external_conf/
RUN touch /bluspark/external_conf/bluspark.conf
WORKDIR /root
