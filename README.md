# Clearwater Docker

This branch contains termporary workarounds to get Clearwater running on OpenShift (and using an external HSS).

The main issue is that on OpenShift nothing is allowed to run as root.  To work around this...
- We add a "Metaswitch" user
- We set this as the USER so that e.g. supervisord is started as the Metaswitch user
- Packages are still installed as root though and so, post installation, we change the permissions on lots of stuff so that the Metaswitch user can execute / update / write etc.

These changes are temporary workarounds and are not suitable for merging into master.

The base image is also enhanced to allow additional shared config settings to be configured via an environment variable (which can e.g. be specified in K8s deployment yaml files).  To use this the ADDITIONAL_SHARED_CONFIG variable must be set when the container is created. It can be used to specify multiple shared_config settings by separating them with \n's.  E.g. 
```
ADDITIONAL_SHARED_CONFIG=setting_one=value_a\nsetting_two=value_b   
```

