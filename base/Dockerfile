FROM ubuntu:14.04
MAINTAINER maintainers@projectclearwater.org

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y supervisor curl
RUN apt-get install -y apt-transport-https unzip

# Certificates
COPY 99clearwater /etc/apt/apt.conf.d/99clearwater
RUN mkdir -p /etc/apt/certs
COPY repo_certs.zip /tmp/
RUN unzip /tmp/repo_certs.zip
RUN cd /etc/apt/certs && unzip -j /tmp/repo_certs.zip && rm /tmp/repo_certs.zip
RUN chmod 600 /etc/apt/certs/*

RUN mkdir -p /var/log/supervisor
RUN echo 'root:root' | chpasswd
EXPOSE 22
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
COPY sysctl /sbin/sysctl
RUN sed -e 's/\#\(precedence ::ffff:0:0\/96  100\)/\1/g' -i /etc/gai.conf

# v10
#RUN echo deb http://repo.cw-ngv.com/latest binary/ > /etc/apt/sources.list.d/clearwater.list
# v11
RUN echo deb https://repo.cw-ngv.com/~staging-cc/repo binary/ > /etc/apt/sources.list.d/clearwater.list

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
RUN sed -i 's/scscf.sprout/sprout/' /etc/init.d/clearwater-auto-config-docker

# Set up the URIs.
RUN sed -i 's/^\( \+sprout_hostname=.*\)/\1\n    icscf_uri="sip:\$sprout_hostname:5052;transport=tcp"/' /etc/init.d/clearwater-auto-config-docker
RUN sed -i 's/^\( \+sprout_hostname=.*\)/\1\n    scscf_uri="sip:\$sprout_hostname:5054;transport=tcp"/' /etc/init.d/clearwater-auto-config-docker
RUN sed -i 's/^\( \+s\/^sprout_hostname=.*\)/\1\n    s\/^icscf_uri=.*\/icscf_uri="'\''$icscf_uri'\''"\//' /etc/init.d/clearwater-auto-config-docker
RUN sed -i 's/^\( \+s\/^sprout_hostname=.*\)/\1\n    s\/^scscf_uri=.*\/scscf_uri="'\''$scscf_uri'\''"\//' /etc/init.d/clearwater-auto-config-docker
RUN echo "scscf_uri=\"sip:sprout:5054;transport=tcp\"" >> /etc/clearwater/shared_config
RUN echo "icscf_uri=\"sip:sprout:5052;transport=tcp\"" >> /etc/clearwater/shared_config
RUN echo 'snmp_ip=stats-engine.$ZONE'      >> /etc/clearwater/shared_config
RUN echo 'snmp_notification_types=rfc3877' >> /etc/clearwater/shared_config
RUN echo 'local_site_name=$LOCAL_SITE'     >> /etc/clearwater/shared_config
RUN echo 'remote_site_name=$REMOTE_SITE'   >> /etc/clearwater/shared_config
RUN echo 'sas_server=sas.$ZONE'            >> /etc/clearwater/shared_config

COPY liveness.sh /usr/share/kubernetes/
