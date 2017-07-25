FROM ubuntu:14.04
MAINTAINER maintainers@projectclearwater.org

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y supervisor curl
RUN apt-get install -y apt-transport-https unzip

RUN mkdir -p /var/log/supervisor
RUN echo 'root:root' | chpasswd
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

# Changes to make everything work with Kubernetes
RUN apt-get install -y netcat-openbsd
RUN sed -i 's/SCTP_streams.*/No_SCTP;/' /usr/share/clearwater/bin/generic_create_diameterconf

COPY liveness.sh /usr/share/kubernetes/

# Set up user and group permissions. Note the "--no-log-init" flag, required to
# fix a docker build bug.
RUN groupadd -g 1000070000 metaswitch
RUN useradd --no-log-init -u 1000070000 -g metaswitch metaswitch
RUN mkdir /home/metaswitch
RUN chown metaswitch:metaswitch /home/metaswitch

# This script checks to see if you are root. Shoot that puppy.
RUN echo "echo Faked out root check" > /usr/share/clearwater/utils/check-root-permissions

# Do not try and run scripts that change /etc/hosts or /etc/hostname
RUN rm /usr/share/clearwater/infrastructure/scripts/1hosts
RUN rm /usr/share/clearwater/infrastructure/scripts/hostname

# Patch up /etc/init.d/clearwater-etcd, replacing ulimit, chown and install
# with "true"
RUN sed -e 's/ulimit/true/' -i /etc/init.d/clearwater-etcd
RUN sed -e 's/chown/true/' -i /etc/init.d/clearwater-etcd
RUN sed -e 's/install/true/' -i /etc/init.d/clearwater-etcd
RUN sed -e 's/--chuid $USER//' -i /etc/init.d/clearwater-etcd

# This directory needs to be created because the "install" command above got
# nuked.
RUN mkdir /var/run/clearwater-etcd

# Add any other settings that have been defined in ADDITIONAL_SHARED_CONFIG
RUN sed -i -e 's/\/bin\/sh/\/bin\/bash/g' /etc/init.d/clearwater-auto-config-docker
RUN sed -i -e '/echo "icscf/a \\n    echo -e $ADDITIONAL_SHARED_CONFIG >> $shared_config' /etc/init.d/clearwater-auto-config-docker
RUN sed -i -e '/echo "servers/a \\n      sed -i "s/bind-address = 0.0.0.0/bind-address = $ip/" /etc/chronos/chronos.conf' /etc/init.d/clearwater-auto-config-docker

# This file is not enabled, but is placed ready to be copied across if required
COPY socket-factory.supervisord.conf /etc/clearwater/socket-factory.supervisord.conf

# sudo fails in OpenShift so dummy it out
COPY sudo /usr/bin/sudo
RUN chmod a+x /usr/bin/sudo
