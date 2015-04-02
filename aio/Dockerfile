FROM clearwater/base
MAINTAINER maintainers@projectclearwater.org

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes clearwater-cassandra
RUN sed -e 's/-user cassandra/-user root/g' -i /etc/init.d/cassandra

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes mysql-server
RUN /etc/init.d/mysql start && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes ellis
RUN /etc/init.d/mysql start && /usr/share/clearwater/ellis/env/bin/python /usr/share/clearwater/ellis/src/metaswitch/ellis/tools/create_numbers.py --start 6505550000 --count 1000

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes bono
RUN sed -e 's/\(echo 0 > \/proc\/sys\/kernel\/yama\/ptrace_scope\)/# \0/g' -i /etc/init.d/bono

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes restund
RUN sed -e 's/\(echo 0 > \/proc\/sys\/kernel\/yama\/ptrace_scope\)/# \0/g' -i /etc/init.d/restund

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes sprout
RUN sed -e 's/\(echo 0 > \/proc\/sys\/kernel\/yama\/ptrace_scope\)/# \0/g' -i /etc/init.d/sprout

RUN /etc/init.d/cassandra start && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes homer

RUN /etc/init.d/cassandra start && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes homestead homestead-prov
RUN sed -e 's/\(echo 0 > \/proc\/sys\/kernel\/yama\/ptrace_scope\)/# \1/g' -i /etc/init.d/homestead

COPY cassandra.supervisord.conf /etc/supervisor/conf.d/cassandra.conf
COPY ellis.supervisord.conf /etc/supervisor/conf.d/ellis.conf
COPY bono.supervisord.conf /etc/supervisor/conf.d/bono.conf
COPY restund.supervisord.conf /etc/supervisor/conf.d/restund.conf
COPY sprout.supervisord.conf /etc/supervisor/conf.d/sprout.conf
COPY homer.supervisord.conf /etc/supervisor/conf.d/homer.conf
COPY homestead.supervisord.conf /etc/supervisor/conf.d/homestead.conf
COPY nginx.supervisord.conf /etc/supervisor/conf.d/nginx.conf

EXPOSE 80 3478 5060
