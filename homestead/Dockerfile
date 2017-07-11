FROM clearwater/base
MAINTAINER maintainers@projectclearwater.org

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes homestead
RUN sed -e 's/\(echo 0 > \/proc\/sys\/kernel\/yama\/ptrace_scope\)/# \1/g' -i /etc/init.d/homestead

COPY homestead.supervisord.conf /etc/supervisor/conf.d/homestead.conf
#COPY homestead-prov.supervisord.conf /etc/supervisor/conf.d/homestead-prov.conf
COPY nginx.supervisord.conf /etc/supervisor/conf.d/nginx.conf
COPY clearwater-group.supervisord.conf /etc/supervisor/conf.d/clearwater-group.conf

# We are not root (homestead-prov does not assume root)
RUN sed -e 's/ulimit/true/' -i /etc/init.d/homestead
RUN sed -e 's/chown/true/' -i /etc/init.d/homestead
RUN sed -e 's/install /true /' -i /etc/init.d/homestead
RUN sed -e 's/--chuid $NAME//' -i /etc/init.d/homestead
RUN mkdir /var/run/homestead

RUN find /etc -type d -exec chmod 777 {} \;
RUN find /opt -type d -exec chmod 777 {} \;
RUN find /usr -type d -exec chmod 777 {} \;
RUN find /var -type d -exec chmod 777 {} \;
RUN find /run -type d -exec chmod 777 {} \;

RUN chown metaswitch:metaswitch /var/lib/homestead/*
RUN chown metaswitch:metaswitch /etc/monit/conf.d/*
RUN chown metaswitch:metaswitch /etc/nginx/sites-available/*
RUN chown metaswitch:metaswitch /var/run/clearwater/stats
#RUN sed -e 's/mktemp/mktemp --tmpdir=\/tmp/' -i /usr/share/clearwater/infrastructure/scripts/create-homestead-prov-nginx-config

USER metaswitch
EXPOSE 8888 8889
