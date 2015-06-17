FROM ubuntu:14.04
MAINTAINER maintainers@projectclearwater.org

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-server supervisor curl
RUN mkdir -p /var/run/sshd /var/log/supervisor
RUN echo 'root:root' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
EXPOSE 22
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
COPY sysctl /sbin/sysctl
RUN sed -e 's/\#\(precedence ::ffff:0:0\/96  100\)/\1/g' -i /etc/gai.conf

RUN echo deb http://repo.cw-ngv.com/stable binary/ > /etc/apt/sources.list.d/clearwater.list
RUN curl -L http://repo.cw-ngv.com/repo_key | apt-key add -
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes clearwater-infrastructure clearwater-auto-config-docker
RUN /etc/init.d/clearwater-auto-config-docker restart
RUN /etc/init.d/clearwater-infrastructure restart
COPY clearwater-infrastructure.supervisord.conf /etc/supervisor/conf.d/clearwater-infrastructure.conf
COPY clearwater-group.supervisord.conf /etc/supervisor/conf.d/clearwater-group.conf
