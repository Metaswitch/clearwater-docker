FROM clearwater/base
MAINTAINER maintainers@projectclearwater.org

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes mysql-server
RUN /etc/init.d/mysql start && DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes ellis

COPY create_numbers.sh /usr/share/clearwater/ellis/create_numbers.sh
COPY initsql.supervisord.conf /etc/supervisor/conf.d/initsql.conf

EXPOSE 80
