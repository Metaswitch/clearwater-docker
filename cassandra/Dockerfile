FROM clearwater/base
MAINTAINER maintainers@projectclearwater.org

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes homestead-cassandra homestead-prov-cassandra homer-cassandra
RUN sed -e 's/-c cassandra/-c root/g' -i /etc/init.d/cassandra

COPY start_cassandra.sh /usr/bin/start_cassandra.sh
COPY cassandra.supervisord.conf /etc/supervisor/conf.d/cassandra.conf
COPY clearwater-group.supervisord.conf /etc/supervisor/conf.d/clearwater-group.conf

# None of the ulimit calls work in containers. Replace "ulimit" with "true" so
# they do nothing rather than fail.
RUN sed -e 's/ulimit/true/' -i /etc/init.d/cassandra

RUN find /etc -type d -exec chmod 777 {} \;
RUN find /opt -type d -exec chmod 777 {} \;
RUN find /usr -type d -exec chmod 777 {} \;
RUN find /var -type d -exec chmod 777 {} \;
RUN find /run -type d -exec chmod 777 {} \;

EXPOSE 9160 7001 7001 9042
USER metaswitch
