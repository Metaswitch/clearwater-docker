FROM clearwater/base
MAINTAINER maintainers@projectclearwater.org

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes ralf-node
RUN sed -e 's/\(echo 0 > \/proc\/sys\/kernel\/yama\/ptrace_scope\)/# \0/g' -i /etc/init.d/ralf

COPY chronos.supervisord.conf /etc/supervisor/conf.d/chronos.conf
COPY memcached.supervisord.conf /etc/supervisor/conf.d/memcached.conf
COPY ralf.supervisord.conf /etc/supervisor/conf.d/ralf.conf
COPY clearwater-group.supervisord.conf /etc/supervisor/conf.d/clearwater-group.conf

EXPOSE 10888
