sprout_name=$(sudo docker ps --format "{{.Names}}" | grep sprout | head -1)
sudo docker exec $sprout_name /usr/share/clearwater/clearwater-cluster-manager/scripts/check_cluster_state | grep -v "local node"

