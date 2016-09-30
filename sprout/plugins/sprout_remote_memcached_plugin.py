# Project Clearwater - IMS in the Cloud
# Copyright (C) 2015  Metaswitch Networks Ltd
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the
# Free Software Foundation, either version 3 of the License, or (at your
# option) any later version, along with the "Special Exception" for use of
# the program along with SSL, set forth below. This program is distributed
# in the hope that it will be useful, but WITHOUT ANY WARRANTY;
# without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more
# details. You should have received a copy of the GNU General Public
# License along with this program.  If not, see
# <http://www.gnu.org/licenses/>.
#
# The author can be reached by email at clearwater@metaswitch.com or by
# post at Metaswitch Networks Ltd, 100 Church St, Enfield EN2 6BQ, UK
#
# Special Exception
# Metaswitch Networks Ltd  grants you permission to copy, modify,
# propagate, and distribute a work formed by combining OpenSSL with The
# Software, or a work derivative of such a combination, even if such
# copying, modification, propagation, or distribution would otherwise
# violate the terms of the GPL. You must comply with the GPL in all
# respects for all of the code used other than OpenSSL.
# "OpenSSL" means OpenSSL toolkit software distributed by the OpenSSL
# Project and licensed under the OpenSSL Licenses, or a work based on such
# software and licensed under the OpenSSL Licenses.
# "OpenSSL Licenses" means the OpenSSL License and Original SSLeay License
# under which the OpenSSL Project distributes the OpenSSL toolkit software,
# as those licenses appear in the file LICENSE-OPENSSL.

from metaswitch.clearwater.cluster_manager.plugin_base import SynchroniserPluginBase
from metaswitch.clearwater.etcd_shared.plugin_utils import run_command
import logging

from os import sys, path
sys.path.append(path.dirname(path.abspath(__file__)))
from memcached_utils import write_memcached_cluster_settings

_log = logging.getLogger("sprout_remote_memcached_plugin")

class SproutRemoteMemcachedPlugin(SynchroniserPluginBase):
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
    _log.info("Loading the sprout remote Memcached plugin")
    return SproutRemoteMemcachedPlugin(params)
