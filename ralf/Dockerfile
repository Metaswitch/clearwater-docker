FROM clearwater/base
MAINTAINER maintainers@projectclearwater.org

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes ralf
RUN sed -e 's/\(echo 0 > \/proc\/sys\/kernel\/yama\/ptrace_scope\)/# \0/g' -i /etc/init.d/ralf

COPY ralf.supervisord.conf /etc/supervisor/conf.d/ralf.conf
COPY clearwater-group.supervisord.conf /etc/supervisor/conf.d/clearwater-group.conf
COPY plugins/* /usr/share/clearwater/clearwater-cluster-manager/plugins/
COPY reload_memcached_users /usr/share/clearwater/bin/reload_memcached_users

EXPOSE 10888
