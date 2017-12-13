FROM clearwater/base
MAINTAINER maintainers@projectclearwater.org

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes clearwater-memcached
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes astaire

COPY memcached.supervisord.conf /etc/supervisor/conf.d/memcached.conf
COPY astaire.supervisord.conf /etc/supervisor/conf.d/astaire.conf
COPY clearwater-group.supervisord.conf /etc/supervisor/conf.d/clearwater-group.conf

EXPOSE 11211
