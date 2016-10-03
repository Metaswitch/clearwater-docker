sudo docker exec $1 clearwater-etcdctl ls --recursive | grep 'clustering\/' |  xargs -n1 -i sh -c 'echo "\n{}"; sudo docker exec '$1' clearwater-etcdctl get {};'; echo ""

