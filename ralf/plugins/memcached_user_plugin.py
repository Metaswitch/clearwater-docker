# Copyright (C) Metaswitch Networks
# If license terms are provided to you in a COPYING file in the root directory
# of the source code repository by which you are accessing this code, then
# the license outlined in that COPYING file applies to your use.
# Otherwise no rights are granted except for those provided to you by
# Metaswitch Networks in a separate written agreement.

from metaswitch.clearwater.cluster_manager.plugin_base import SynchroniserPluginBase
from metaswitch.clearwater.etcd_shared.plugin_utils import run_command
import logging

from os import sys, path
sys.path.append(path.dirname(path.abspath(__file__)))
from memcached_utils import write_memcached_cluster_settings

_log = logging.getLogger("memcached_user_plugin")

class MemcachedUserPlugin(SynchroniserPluginBase):
    def __init__(self, params):
        self._key = "/{}/{}/node_type_memcached/clustering/memcached".format(params.etcd_key, params.local_site)

    def key(self):  # pragma: no cover
        return self._key

    def should_be_in_cluster(self):  # pragma: no cover
        return False

    def files(self):  # pragma: no cover
        return ["/etc/clearwater/cluster_settings"]

    def cluster_description(self):  # pragma: no cover
        return "local Memcached cluster"

    def on_cluster_changing(self, cluster_view):  # pragma: no cover
        self.write_cluster_settings(cluster_view)

    def on_joining_cluster(self, cluster_view):  # pragma: no cover
        # We should never join the remote cluster, because it's the *remote*
        # cluster
        pass

    def on_new_cluster_config_ready(self, cluster_view):  # pragma: no cover
        # No Astaire resync needed - the remote site handles that
        pass

    def on_stable_cluster(self, cluster_view):  # pragma: no cover
        self.write_cluster_settings(cluster_view)

    def on_leaving_cluster(self, cluster_view):  # pragma: no cover
        # We should never leave the remote cluster, because it's the *remote*
        # cluster
        pass

    def write_cluster_settings(self, cluster_view):
        write_memcached_cluster_settings("/etc/clearwater/cluster_settings",
                                         cluster_view)
        run_command("/usr/share/clearwater/bin/reload_memcached_users")


def load_as_plugin(params):  # pragma: no cover
    _log.info("Loading the Memcached user plugin")
    return MemcachedUserPlugin(params)
