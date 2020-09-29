FROM openjdk:11-jre-slim
LABEL maintainer="github.com/daeks"

ENV EK_VERSION=7.9.0

RUN apt-get update -qq >/dev/null 2>&1 \
 && apt-get install wget sudo -qqy >/dev/null 2>&1 \
 && useradd -m -s /bin/bash elasticsearch \
 && echo elasticsearch ALL=NOPASSWD: ALL >/etc/sudoers.d/elasticsearch \
 && chmod 440 /etc/sudoers.d/elasticsearch

USER elasticsearch
WORKDIR /home/elasticsearch

RUN wget -q -O - https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-oss-${EK_VERSION}-no-jdk-linux-x86_64.tar.gz | tar -zx \
 && mkdir -p elasticsearch-${EK_VERSION}/data \
 && mkdir -p /usr/share/docker \
 && wget -q -O - https://artifacts.elastic.co/downloads/kibana/kibana-oss-${EK_VERSION}-linux-x86_64.tar.gz | tar -zx \
 && wget -q -O - https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-${EK_VERSION}-linux-x86_64.tar.gz | tar -zx
 
COPY filebeat.yml filebeat-${EK_VERSION}-linux-x86_64/filebeat.yml

CMD elasticsearch-${EK_VERSION}/bin/elasticsearch -E http.host=0.0.0.0 --quiet & kibana-${EK_VERSION}-linux-x86_64/bin/kibana --allow-root --host 0.0.0.0 -Q & filebeat-${EK_VERSION}-linux-x86_64/filebeat

EXPOSE 9200 5601