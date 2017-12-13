FROM clearwater/base
MAINTAINER maintainers@projectclearwater.org

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes rogers

COPY rogers.supervisord.conf /etc/supervisor/conf.d/rogers.conf
COPY clearwater-group.supervisord.conf /etc/supervisor/conf.d/clearwater-group.conf

EXPOSE 11311
