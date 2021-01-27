FROM registry.access.redhat.com/ubi7/ubi:latest
LABEL maintainer "Chen Gao <Chen.Gao@.ibm.com>"

ENV IOT_REPO_PATH=/root/db2eventstore-IoT-Analytics
ENV KAFKA_REPO_PATH=/root/db2eventstore-kafka 
ENV SPARK_HOME="/spark_home"
ENV PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin
ARG ES_VERSION=latest
ARG BRANCH=master
ARG SETUP_AREA=${IOT_REPO_PATH}/container/setup

# Install neccessary packages
RUN yum install -y \
    wget \
    vim \
    unzip \
    less \
    git \
    gcc \
    make \
    sudo \
    zlib-devel \
    openssl-devel \
    && yum clean all \
    && rm -rf /var/cache/yum

RUN git clone --single-branch --branch ${BRANCH} https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics.git ${IOT_REPO_PATH}

# Install jq
RUN wget -O /usr/local/bin/jq https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
RUN chmod +x /usr/local/bin/jq

# Install screen
RUN wget -P /tmp/ http://mirror.centos.org/centos/7/os/x86_64/Packages/screen-4.1.0-0.26.20120314git3c2946.el7.x86_64.rpm
RUN yum localinstall -y /tmp/screen-4.1.0-0.26.20120314git3c2946.el7.x86_64.rpm && yum clean all && rm -rf /var/cache/yum && rm -rf /tmp/screen-4.1.0-0.26.20120314git3c2946.el7.x86_64.rpm

# Setup Screen
RUN echo -e 'startup_message off \nhardstatus on \nhardstatus alwayslastline \nvbell off \nhardstatus string "%{.bW}%-w%{..G}%n %t%{-}%+w %=%{..G} %H %{..Y} %m/%d %C%a"' > ${HOME}/.screenrc

# Setup vim 
RUN echo -e 'syntax enable \nset tabstop=4 \nset number \nset hlsearch \nset incsearch' > ${HOME}/.vimrc

# copy json file to user_volume
COPY ./es-releases.json /root/user_volume/
RUN ls -R /root/user_volume

# get variabls from json and setup sparke
RUN ${SETUP_AREA}/setup-container.sh $ES_VERSION

# Create client config file
RUN mkdir -p /bluspark/external_conf/
RUN touch /bluspark/external_conf/bluspark.conf
WORKDIR /root
