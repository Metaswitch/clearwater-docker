FROM clearwater/base
MAINTAINER maintainers@projectclearwater.org

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes clearwater-memcached
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes astaire

COPY memcached.supervisord.conf /etc/supervisor/conf.d/memcached.conf
COPY astaire.supervisord.conf /etc/supervisor/conf.d/astaire.conf
COPY clearwater-group.supervisord.conf /etc/supervisor/conf.d/clearwater-group.conf

RUN find /etc -type d -exec chmod 777 {} \;
RUN find /opt -type d -exec chmod 777 {} \;
RUN find /usr -type d -exec chmod 777 {} \;
RUN find /var -type d -exec chmod 777 {} \;
RUN find /run -type d -exec chmod 777 {} \;
EXPOSE 11311
USER metaswitch
