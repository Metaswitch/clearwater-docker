FROM clearwater/base
MAINTAINER maintainers@projectclearwater.org

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes mysql-server
RUN /etc/init.d/mysql start && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes ellis
RUN /etc/init.d/mysql start

COPY ellis.supervisord.conf /etc/supervisor/conf.d/ellis.conf
COPY mysql.supervisord.conf /etc/supervisor/conf.d/mysql.conf
COPY initsql.supervisord.conf /etc/supervisor/conf.d/initsql.conf
COPY nginx.supervisord.conf /etc/supervisor/conf.d/nginx.conf
COPY clearwater-group.supervisord.conf /etc/supervisor/conf.d/clearwater-group.conf

EXPOSE 80
