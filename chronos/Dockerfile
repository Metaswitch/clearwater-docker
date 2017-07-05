FROM clearwater/base
MAINTAINER maintainers@projectclearwater.org

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes chronos 

COPY snmpd.supervisord.conf /etc/supervisor/conf.d/snmpd.conf
COPY chronos.supervisord.conf /etc/supervisor/conf.d/chronos.conf
COPY clearwater-group.supervisord.conf /etc/supervisor/conf.d/clearwater-group.conf

RUN find /etc -type d -exec chmod 777 {} \;
RUN find /opt -type d -exec chmod 777 {} \;
RUN find /usr -type d -exec chmod 777 {} \;
RUN find /var -type d -exec chmod 777 {} \;
RUN find /run -type d -exec chmod 777 {} \;
EXPOSE 7253
USER metaswitch
