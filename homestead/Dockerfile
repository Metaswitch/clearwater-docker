FROM clearwater/base
MAINTAINER maintainers@projectclearwater.org

RUN apt-get update 
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes homestead homestead-prov clearwater-prov-tools
RUN sed -e 's/\(echo 0 > \/proc\/sys\/kernel\/yama\/ptrace_scope\)/# \1/g' -i /etc/init.d/homestead

EXPOSE 8888 8889
