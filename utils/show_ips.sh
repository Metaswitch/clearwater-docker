sudo docker inspect --format '{{.Name}} {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(sudo docker ps -q) |column -t
