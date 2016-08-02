FROM clearwater/base
MAINTAINER maintainers@projectclearwater.org

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes clearwater-cassandra
RUN sed -e 's/-user cassandra/-user root/g' -i /etc/init.d/cassandra
RUN /etc/init.d/cassandra start && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes homer-node

COPY cassandra.supervisord.conf /etc/supervisor/conf.d/cassandra.conf
COPY homer.supervisord.conf /etc/supervisor/conf.d/homer.conf
COPY nginx.supervisord.conf /etc/supervisor/conf.d/nginx.conf
COPY clearwater-group.supervisord.conf /etc/supervisor/conf.d/clearwater-group.conf

EXPOSE 7888
