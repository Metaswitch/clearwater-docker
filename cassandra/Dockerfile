FROM clearwater/base
MAINTAINER maintainers@projectclearwater.org

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes homestead-cassandra homestead-prov-cassandra homer-cassandra
RUN sed -e 's/-user cassandra/-user root/g' -i /etc/init.d/cassandra

RUN /etc/init.d/cassandra start 

COPY cassandra.supervisord.conf /etc/supervisor/conf.d/cassandra.conf
COPY clearwater-group.supervisord.conf /etc/supervisor/conf.d/clearwater-group.conf

EXPOSE 9160 7001 7001 9042
