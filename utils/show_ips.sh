sudo docker inspect --format '{{.Name}} {{ .NetworkSettings.Networks.clearwater_nw.IPAddress }}' $(sudo docker ps -q) |column -t

