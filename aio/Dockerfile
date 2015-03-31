FROM ubuntu:14.04
MAINTAINER maintainers@projectclearwater.org

RUN apt-get update && apt-get install -y openssh-server supervisor curl
RUN mkdir -p /var/run/sshd /var/log/supervisor
RUN echo 'root:root' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
EXPOSE 22
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD ["/usr/bin/supervisord"]

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
COPY sysctl /sbin/sysctl
RUN sed -e 's/\#\(precedence ::ffff:0:0\/96  100\)/\1/g' -i /etc/gai.conf

RUN echo deb http://repo.cw-ngv.com/mirw binary/ > /etc/apt/sources.list.d/clearwater.list
RUN curl -L http://repo.cw-ngv.com/repo_key | apt-key add -
RUN apt-get update && apt-get install -y --force-yes clearwater-infrastructure clearwater-auto-config-generic
RUN /etc/init.d/clearwater-auto-config-generic restart
RUN /etc/init.d/clearwater-infrastructure restart
COPY clearwater-infrastructure.supervisord.conf /etc/supervisor/conf.d/clearwater-infrastructure.conf

RUN apt-get update && apt-get install -y --force-yes clearwater-cassandra
RUN sed -e 's/-user cassandra/-user root/g' -i /etc/init.d/cassandra

RUN apt-get update && apt-get install -y --force-yes mysql-server
RUN /etc/init.d/mysql start && apt-get update && apt-get install -y --force-yes ellis
RUN /etc/init.d/mysql start && /usr/share/clearwater/ellis/env/bin/python /usr/share/clearwater/ellis/src/metaswitch/ellis/tools/create_numbers.py --start 6505550000 --count 1000

RUN apt-get update && apt-get install -y --force-yes bono
RUN sed -e 's/\(echo 0 > \/proc\/sys\/kernel\/yama\/ptrace_scope\)/# \0/g' -i /etc/init.d/bono

RUN apt-get update && apt-get install -y --force-yes restund
RUN sed -e 's/\(echo 0 > \/proc\/sys\/kernel\/yama\/ptrace_scope\)/# \0/g' -i /etc/init.d/restund

RUN apt-get update && apt-get install -y --force-yes sprout
RUN sed -e 's/\(echo 0 > \/proc\/sys\/kernel\/yama\/ptrace_scope\)/# \0/g' -i /etc/init.d/sprout

RUN /etc/init.d/cassandra start && apt-get update && apt-get install -y --force-yes homer

RUN /etc/init.d/cassandra start && apt-get update && apt-get install -y --force-yes libevent-2.0-5 libcurl3-gnutls homestead homestead-prov
RUN sed -e 's/\(echo 0 > \/proc\/sys\/kernel\/yama\/ptrace_scope\)/# \1/g' -i /etc/init.d/homestead

COPY cassandra.supervisord.conf /etc/supervisor/conf.d/cassandra.conf
COPY ellis.supervisord.conf /etc/supervisor/conf.d/ellis.conf
COPY bono.supervisord.conf /etc/supervisor/conf.d/bono.conf
COPY restund.supervisord.conf /etc/supervisor/conf.d/restund.conf
COPY sprout.supervisord.conf /etc/supervisor/conf.d/sprout.conf
COPY homer.supervisord.conf /etc/supervisor/conf.d/homer.conf
COPY homestead.supervisord.conf /etc/supervisor/conf.d/homestead.conf

EXPOSE 22 80 5060
