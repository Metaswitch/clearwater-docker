FROM clearwater/base
MAINTAINER maintainers@projectclearwater.org

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes ralf
RUN sed -e 's/\(echo 0 > \/proc\/sys\/kernel\/yama\/ptrace_scope\)/# \0/g' -i /etc/init.d/ralf
RUN apt-get install -y --force-yes clearwater-snmp-handler-astaire

COPY ralf.supervisord.conf /etc/supervisor/conf.d/ralf.conf
COPY clearwater-group.supervisord.conf /etc/supervisor/conf.d/clearwater-group.conf
COPY plugins/* /usr/share/clearwater/clearwater-cluster-manager/plugins/
COPY reload_memcached_users /usr/share/clearwater/bin/reload_memcached_users

# We need to start the socket factories so that we can write to SAS.
RUN cp /etc/clearwater/socket-factory.supervisord.conf /etc/supervisor/conf.d/

EXPOSE 10888
