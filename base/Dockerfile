FROM ubuntu:14.04
MAINTAINER maintainers@projectclearwater.org

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y supervisor curl
RUN apt-get install -y apt-transport-https unzip

RUN mkdir -p /var/log/supervisor
RUN echo 'root:root' | chpasswd
EXPOSE 22
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
COPY sysctl /sbin/sysctl
RUN sed -e 's/\#\(precedence ::ffff:0:0\/96  100\)/\1/g' -i /etc/gai.conf

RUN echo deb http://repo.cw-ngv.com/stable binary/ > /etc/apt/sources.list.d/clearwater.list

RUN curl -L http://repo.cw-ngv.com/repo_key | apt-key add -
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes clearwater-infrastructure clearwater-auto-config-docker clearwater-management
RUN apt-get install -y --force-yes clearwater-snmpd
RUN /etc/init.d/clearwater-auto-config-docker restart
RUN /etc/init.d/clearwater-infrastructure restart
COPY clearwater-infrastructure.supervisord.conf /etc/supervisor/conf.d/clearwater-infrastructure.conf
COPY clearwater-group.supervisord.conf /etc/supervisor/conf.d/clearwater-group.conf
COPY snmpd.supervisord.conf /etc/supervisor/conf.d/snmpd.conf
COPY pre-stop /usr/bin/pre-stop

# Changes to make everything work with Kubernetes
RUN apt-get install -y netcat-openbsd
RUN sed -i 's/SCTP_streams.*/No_SCTP;/' /usr/share/clearwater/bin/generic_create_diameterconf

COPY liveness.sh /usr/share/kubernetes/

# Some containers have socket factories that need to be started.  Supervisord config is common to all containers that need it
# so copy the relevant supervisord config into the base container and we'll move it to /etc/supervisor/conf.d so that it actually gets 
# invoked in the containers that need it.
COPY socket-factory.supervisord.conf /etc/clearwater/socket-factory.supervisord.conf
