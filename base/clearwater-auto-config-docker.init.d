#!/bin/bash

# @file clearwater-auto-config-docker.init.d
#
# Copyright (C) Metaswitch Networks 2017
# If license terms are provided to you in a COPYING file in the root directory
# of the source code repository by which you are accessing this code, then
# the license outlined in that COPYING file applies to your use.
# Otherwise no rights are granted except for those provided to you by
# Metaswitch Networks in a separate written agreement.

### BEGIN INIT INFO
# Provides:          clearwater-auto-config-docker
# Required-Start:    $network $local_fs
# Required-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: clearwater-auto-config-docker
# Description:       clearwater-auto-config-docker
# X-Start-Before:    clearwater-infrastructure bono sprout homer homestead ellis restund
### END INIT INFO

# Changes in this command should be replicated in clearwater-auto-config-*.init.d
do_auto_config()
{
  local_config=/etc/clearwater/local_config
  shared_config=/etc/clearwater/shared_config

  if [ -f /etc/clearwater/force_ipv6 ]
  then
    # The sed expression finds the first IPv6
    ip=$(hostname -I | sed -e 's/\(^\|^[0-9. ]* \)\([0-9A-Fa-f:]*\)\( .*$\|$\)/\2/g')
  else
    # The sed expression finds the first IPv4 address in the space-separate list of IPv4 and IPv6 addresses.
    # If there are no IPv4 addresses it finds the first IPv6 address.
    ip=$(hostname -I | sed -e 's/\(^\|^[0-9A-Fa-f: ]* \)\([0-9.][0-9.]*\)\( .*$\|$\)/\2/g' -e 's/\(^\)\(^[0-9A-Fa-f:]*\)\( .*$\|$\)/\2/g')
  fi

  # If a PUBLIC_IP variable is set use this, otherwise go with the local IP
  # here too.
  if [ -n "$PUBLIC_IP" ]
  then
    public_ip=$PUBLIC_IP
  else
    public_ip=$ip
  fi

  # Add square brackets around the address iff it is an IPv6 address
  bracketed_ip=$(/usr/share/clearwater/clearwater-auto-config-docker/bin/bracket-ipv6-address $ip)

  sed -e 's/^local_ip=.*$/local_ip='$ip'/g
          s/^public_ip=.*$/public_ip='$public_ip'/g
          s/^public_hostname=.*$/public_hostname='$public_ip'/g' -i $local_config
    sed -e '/^etcd_cluster=.*/d
            /^etcd_proxy=.*/d' -i $local_config

  # Extract DNS servers from resolv.conf and comma-separate them.
  nameserver=`grep nameserver /etc/resolv.conf | cut -d ' ' -f 2`
  nameserver=`echo $nameserver | tr ' ' ','`

  if [ -n "$ETCD_PROXY" ]
  then
    # Set up etcd proxy configuration from environment.  Shared configuration
    # should be uploaded and shared manually.
    echo "etcd_proxy=$ETCD_PROXY" >> $local_config

    # Remove the default shared configuration file.
    rm -f $shared_config
  else
    # Use the etcd container that our Docker Compose file sets up. This is so
    # we can rely on clearwater-cluster-manager to set up our datastores, as
    # would happen on a non-Docker Clearwater cluster.
    # We still want to auto-configure shared config on each node, though,
    # rather than rely on it being uploaded.

    echo "etcd_proxy=etcd0=http://etcd:2380" >> $local_config

    if [ -z "$ZONE" ]
    then
      # Assume the domain is example.com, and use the Docker internal DNS for service discovery.
      # See https://docs.docker.com/engine/userguide/networking/configure-dns/ for details.
      sprout_hostname=sprout
      sprout_registration_store=astaire
      chronos_hostname=chronos
      cassandra_hostname=cassandra
      hs_hostname=homestead:8888
      hs_provisioning_hostname=homestead-prov:8889
      xdms_hostname=homer:7888
      upstream_hostname=sprout
      ralf_hostname=ralf:10888
      ralf_session_store=astaire
      home_domain="example.com"
    else
      # Configure relative to the base zone and rely on externally configured DNS entries.
      sprout_hostname=sprout.$ZONE
      sprout_registration_store=astaire.$ZONE
      chronos_hostname=chronos.$ZONE
      cassandra_hostname=cassandra.$ZONE
      hs_hostname=homestead.$ZONE:8888
      hs_provisioning_hostname=homestead-prov.$ZONE:8889
      xdms_hostname=homer.$ZONE:7888
      upstream_hostname=sprout.$ZONE
      ralf_hostname=ralf.$ZONE:10888
      ralf_session_store=astaire.$ZONE
      home_domain=$ZONE
    fi

    sed -e 's/^home_domain=.*$/home_domain='$home_domain'/g
            s/^sprout_hostname=.*$/sprout_hostname='$sprout_hostname'/g
            s/^xdms_hostname=.*$/xdms_hostname='$xdms_hostname'/g
            s/^hs_hostname=.*$/hs_hostname='$hs_hostname'/g
            s/^hs_provisioning_hostname=.*$/hs_provisioning_hostname='$hs_provisioning_hostname'/g
            s/^upstream_hostname=.*$/upstream_hostname='$upstream_hostname'/g
            s/^ralf_hostname=.*$/ralf_hostname='$ralf_hostname'/g
            s/^sprout_registration_store=.*$/sprout_registration_store='$sprout_registration_store'/g
            s/^ralf_session_store=.*$/ralf_session_store='$ralf_session_store'/g
            s/^chronos_hostname=.*$/chronos_hostname='$chronos_hostname'/g
            s/^cassandra_hostname=.*$/cassandra_hostname='$cassandra_hostname'/g
            s/^email_recovery_sender=.*$/email_recovery_sender=clearwater@'$home_domain'/g' -i $shared_config

    sed -e '/^scscf_uri=.*/d' -i $shared_config
    echo "scscf_uri=\"sip:$sprout_hostname:5054;transport=tcp\"" >> $shared_config
    sed -e '/^icscf_uri=.*/d' -i $shared_config
    echo "icscf_uri=\"sip:$sprout_hostname:5052;transport=tcp\"" >> $shared_config

    # Add any additional shared config provided via the
    # ADDITIONAL_SHARED_CONFIG environment variable.
    echo -e $ADDITIONAL_SHARED_CONFIG >> $shared_config

    if [ -n "$nameserver" ]
    then
      sed -e '/^signaling_dns_server=.*/d' -i $shared_config
      echo "signaling_dns_server=$nameserver" >> $shared_config
    fi
  fi

  # Is this a Chronos node?   If so then we need to sort chronos.conf including setting up DNS server config.
  if [ -e /etc/chronos/chronos.conf.sample ]
  then
    if [ ! -e /etc/chronos/chronos.conf ]
    then
      cp /etc/chronos/chronos.conf.sample /etc/chronos/chronos.conf
    fi

    if [ -n "$nameserver" ]
    then
      echo "\n[dns]" >> /etc/chronos/chronos.conf
      echo "servers=$nameserver" >> /etc/chronos/chronos.conf
    fi

    sed -i "s/bind-address = 0.0.0.0/bind-address = $ip/" /etc/chronos/chronos.conf
  fi
}

case "$1" in
  start|restart|reload|force-reload)
    do_auto_config
    exit 0
  ;;

  status|stop)
    exit 0
  ;;

  *)
    echo "Usage: $SCRIPTNAME {start|stop|status|restart|force-reload}" >&2
    exit 3
  ;;
esac

:

