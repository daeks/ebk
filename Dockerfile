FROM openjdk:11-jre-slim
LABEL maintainer="github.com/daeks"

ENV EK_VERSION=7.9.0

ENV USER_NAME=elasticsearch
ENV USER_HOME=/home/${USER_NAME}

ENV FB_HOME=/usr/share/filebeat
ENV ES_HOME=/usr/share/elasticsearch

ENV ES_JAVA_OPTS="-Xms1g -Xmx1g"
ENV discovery.type=single-node

RUN apt-get update -qq >/dev/null 2>&1 \
 && apt-get install procps net-tools nano wget sudo -qqy >/dev/null 2>&1 \
 && useradd -m -u 1000 -s /bin/bash ${USER_NAME} \
 && echo ${USER_NAME} ALL=NOPASSWD: ALL >/etc/sudoers.d/${USER_NAME} \
 && chmod 440 /etc/sudoers.d/${USER_NAME} \
 && usermod -aG sudo ${USER_NAME}

RUN mkdir -p ${ES_HOME}/data \
 && mkdir -p ${FB_HOME}/data \
 && chown -R ${USER_NAME} ${ES_HOME} \
 && chown -R ${USER_NAME} ${FB_HOME} \
 && chmod -R +w ${ES_HOME} \
 && chmod -R +w ${FB_HOME}

USER ${USER_NAME}
WORKDIR ${USER_HOME}

RUN wget -q -O - https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-oss-${EK_VERSION}-no-jdk-linux-x86_64.tar.gz | tar -zx \
 && wget -q -O - https://artifacts.elastic.co/downloads/kibana/kibana-oss-${EK_VERSION}-linux-x86_64.tar.gz | tar -zx \
 && wget -q -O - https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-${EK_VERSION}-linux-x86_64.tar.gz | tar -zx
 
COPY filebeat.yml ${USER_HOME}/filebeat-${EK_VERSION}-linux-x86_64/filebeat.yml

CMD ${USER_HOME}/elasticsearch-${EK_VERSION}/bin/elasticsearch -Epath.data=${ES_HOME}/data --quiet &\
 ${USER_HOME}/kibana-${EK_VERSION}-linux-x86_64/bin/kibana --elasticsearch http://localhost:9200 --host 0.0.0.0 --silent &\
 sudo ${USER_HOME}/filebeat-${EK_VERSION}-linux-x86_64/filebeat -path.config ${USER_HOME}/filebeat-${EK_VERSION}-linux-x86_64 -path.data ${FB_HOME}/data

EXPOSE 5601