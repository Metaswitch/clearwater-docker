FROM clearwater/base
MAINTAINER maintainers@projectclearwater.org

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes homestead-cassandra homestead-prov-cassandra homer-cassandra
RUN sed -e 's/-c cassandra/-c root/g' -i /etc/init.d/cassandra

COPY start_cassandra.sh /usr/bin/start_cassandra.sh
COPY cassandra.supervisord.conf /etc/supervisor/conf.d/cassandra.conf
COPY clearwater-group.supervisord.conf /etc/supervisor/conf.d/clearwater-group.conf

EXPOSE 9160 7001 7001 9042
