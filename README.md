# Clearwater Docker

This branch contains termporary workarounds to get Clearwater running on OpenShift (and using an external HSS).

The main issue is that on OpenShift nothing is allowed to run as root.  To work around this...
- We add a "Metaswitch" user
- We set this as the USER so that e.g. supervisord is started as the Metaswitch user
- Packages are still installed as root though and so, post installation, we change the permissions on lots of stuff so that the Metaswitch user can execute / update / write etc.

To use an external HSS we hack the clearwater-auto-config-docker script to configure fixed hss_domain, hss_hostname and hss_proxy in shared config.  Before building, replace $HSS_IP with the IP address of the HSS to use (or remove this setting and set up DNS to resolve hss_hostname appropriately instead)..

These changes are temporary workarounds and are not suitable for merging into master.
