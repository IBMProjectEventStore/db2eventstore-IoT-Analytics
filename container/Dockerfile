FROM registry.access.redhat.com/ubi8/ubi:latest
LABEL maintainer "Chen Gao <Chen.Gao@ibm.com>"

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
    && yum -y update \
    && yum clean all \
    && rm -rf /var/cache/yum

RUN git clone --single-branch --branch ${BRANCH} https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics.git ${IOT_REPO_PATH}

# Install jq
RUN wget -O /usr/local/bin/jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
RUN chmod +x /usr/local/bin/jq

# Install screen
RUN rpm -ivh https://download-ib01.fedoraproject.org/pub/epel/8/Everything/x86_64/Packages/s/screen-4.6.2-12.el8.x86_64.rpm

# Setup Screen
RUN echo -e 'startup_message off \nhardstatus on \nhardstatus alwayslastline \nvbell off \nhardstatus string "%{.bW}%-w%{..G}%n %t%{-}%+w %=%{..G} %H %{..Y} %m/%d %C%a"' > ${HOME}/.screenrc

# Setup vim 
RUN echo -e 'syntax enable \nset tabstop=4 \nset number \nset hlsearch \nset incsearch' > ${HOME}/.vimrc

# copy json file to user_volume
COPY ./es-releases.json /root/user_volume/

# get variables from json and setup spark
RUN ${SETUP_AREA}/setup-container.sh $ES_VERSION

# Spark media extract from local copy from git repo $SPARK_MEDIA & SPARK_HOME defined in setup/setup-spark.sh
# comment line below and hard code versions as variable did not work
# RUN tar -xzvf /root/${SPARK_MEDIA}.tgz -C / \
RUN tar -xzvf /root/spark_media_package/spark-2.4.8-bin-hadoop2.6.tgz -C / \
&& mv spark-2.4.8-bin-hadoop2.6/* /spark_home \
&& echo "spark media file name = spark-2.4.8-bin-hadoop2.6.tgz and is extracted to /spark_home"

# Create client config file and eliminate this error message "cat: /usr/lib/jvm/java-1.8.0-openjdk/release: No such file or directory" when executing ./runscalaExample
RUN mkdir -p /bluspark/external_conf/
RUN touch /bluspark/external_conf/bluspark.conf /usr/lib/jvm/java-1.8.0-openjdk/release
WORKDIR /root

# Install IBM Db2 data server drivers
RUN tar -xvf /root/db2eventstore-IoT-Analytics/ibm_data_server_driver_package/v11.5.6_linuxx64_dsdriver.tar.gz -C / \
  && tar -xvf /dsdriver/odbc_cli_driver/linuxamd64/ibm_data_server_driver_for_odbc_cli.tar.gz -C / \
  && cp -r /dsdriver/security64 /clidriver/
