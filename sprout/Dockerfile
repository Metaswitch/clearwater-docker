FROM clearwater/base
MAINTAINER maintainers@projectclearwater.org

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes sprout
RUN sed -e 's/\(echo 0 > \/proc\/sys\/kernel\/yama\/ptrace_scope\)/# \0/g' -i /etc/init.d/sprout
RUN apt-get install -y --force-yes clearwater-snmp-handler-astaire
#RUN echo "log_level=5" >> /etc/clearwater/user_settings

COPY sprout.supervisord.conf /etc/supervisor/conf.d/sprout.conf
COPY clearwater-group.supervisord.conf /etc/supervisor/conf.d/clearwater-group.conf

# Set up the socket factory to run so SAS works (upstart is not in use here).
RUN cp /etc/clearwater/socket-factory.supervisord.conf /etc/supervisor/conf.d/

# We are not root.
RUN sed -e 's/ulimit/true/' -i /etc/init.d/sprout
RUN sed -e 's/chown/true/' -i /etc/init.d/sprout
RUN sed -e 's/install /true /' -i /etc/init.d/sprout
RUN sed -e 's/--chuid $NAME//' -i /etc/init.d/sprout
RUN mkdir /var/run/sprout

RUN find /etc -type d -exec chmod 777 {} \;
RUN find /opt -type d -exec chmod 777 {} \;
RUN find /usr -type d -exec chmod 777 {} \;
RUN find /var -type d -exec chmod 777 {} \;
RUN find /run -type d -exec chmod 777 {} \;

EXPOSE 5052 5054
USER metaswitch
