# Clearwater Docker

This repository contains [Dockerfiles](https://docs.docker.com/reference/builder/) for use with [Docker](https://www.docker.com/) and [Compose](https://docs.docker.com/compose/) to deploy [Project Clearwater](http://www.projectclearwater.org).

## Using Compose

There is a [Compose file](minimal-distributed.yaml) to instantiate a minimal (non-fault-tolerant) distributed Clearwater deployment under Docker.

### Preparation

To prepare your system to deploy Clearwater using compose, run:

    # Install Docker (on Ubuntu) - we need the latest for compatibility with Compose.
    wget -qO- https://get.docker.com/ | sh

    # Install Docker Compose (on Ubuntu).
    sudo apt-get install python-pip -y
    sudo pip install -U docker-compose

    # Checkout clearwater-docker.
    git clone --recursive git@github.com:Metaswitch/clearwater-docker.git
    cd clearwater-docker

    # Build the base Clearwater docker image.
    sudo docker build -t clearwater/base base

### Starting Clearwater

To start the Clearwater services, run:

    # Build all the other Clearwater Docker images and start a deployment.
    sudo docker-compose -f minimal-distributed.yaml up -d

### Stopping Clearwater

To stop the Clearwater services, run:

    sudo docker-compose -f minimal-distributed.yaml stop

## Manual Turn-Up

If you can't or don't want to use Compose, you can turn the deployment up manually under Docker.

### Preparation

To prepare your system to deploy Clearwater manually, run:

    # Install Docker (on Ubuntu).
    wget -qO- https://get.docker.com/ | sh

    # Checkout clearwater-docker.
    git clone --recursive git@github.com:Metaswitch/clearwater-docker.git
    cd clearwater-docker

    # Build the Clearwater docker images.
    for i in base bono ellis homer homestead ralf sprout ; do sudo docker build -t clearwater/$i $i ; done

### Starting Clearwater

To start the Clearwater services, run:

    sudo docker network create --driver bridge clearwater_nw
    sudo docker run -d --net=clearwater_nw --name etcd quay.io/coreos/etcd:v2.2.5 -name etcd0 -advertise-client-urls http://etcd:2379,http://etcd:4001 -listen-client-urls http://0.0.0.0:2379,http://0.0.0.0:4001 -initial-advertise-peer-urls http://etcd:2380 -listen-peer-urls http://0.0.0.0:2380  -initial-cluster etcd0=http://etcd:2380 -initial-cluster-state new
    sudo docker run -d --net=clearwater_nw --name homestead -p 22 clearwater/homestead
    sudo docker run -d --net=clearwater_nw --name homer -p 22 clearwater/homer
    sudo docker run -d --net=clearwater_nw --name ralf -p 22 clearwater/ralf
    sudo docker run -d --net=clearwater_nw --name sprout -p 22 clearwater/sprout
    sudo docker run -d --net=clearwater_nw --name bono -p 22 -p 3478:3478 -p 3478:3478/udp -p 5060:5060 -p 5060:5060/udp -p 5062:5062 clearwater/bono
    sudo docker run -d --net=clearwater_nw --name ellis -p 22 -p 80:80 clearwater/ellis

The Clearwater Docker images use DNS for service discovery - they require, for example, that the name "ellis" should resolve to the Ellis container's IP address. In standard Docker, user-defined networks include [an embedded DNS server](https://docs.docker.com/engine/userguide/networking/dockernetworks/#docker-embedded-dns-server) which guarantees this (and this is why we create the clearwater_nw network) - and this type of DNS server is relatively common (for example, [Kubernetes provides something similar](http://kubernetes.io/docs/user-guide/services/#dns)).

### Stopping Clearwater

To stop the Clearwater services, run:

    sudo docker stop ellis
    sudo docker stop bono
    sudo docker stop sprout
    sudo docker stop ralf
    sudo docker stop homer
    sudo docker stop homestead
    
### Restarting Clearwater

To restart the Clearwater services, run:

    sudo docker start ellis
    sudo docker start bono
    sudo docker start sprout
    sudo docker start ralf
    sudo docker start homer
    sudo docker start homestead

## Exposed Services

The deployment exposes

-   the Ellis web UI on port 80 (exposed on port 8080) for self-provisioning - the signup key is "secret"
-   STUN/TURN on port 3478 for media relay
-   SIP on port 5060 for service
-   SIP/WebSocket on port 5062 for service.

Additionally, each node exposes SSH - use `sudo docker ps` to see what port its exposed on.  The username/password is root/root.

## What Next?

Once you've turned up the deployment, you can test it by

-   [making a call](http://clearwater.readthedocs.org/en/latest/Making_your_first_call) - make sure you configure your SIP clients with a proxy, as if it were an All-in-One node
-   [running the live tests](http://clearwater.readthedocs.org/en/latest/Running_the_live_tests) - again, set the PROXY and ELLIS elements, as if it were an All-in-One node.

## Cleaning Up

If you wish to destroy your deployment either to redeploy with a different configuration or version or to free up resources on your docker host, the following may be useful commands:

    # To rebuild an image (rather than pull it from the cache), add `--no-cache` or `--force-recreate` to the build commands
    sudo docker build --no-cache -t clearwater/base base
    sudo docker-compose -f minimal-distributed.yaml up --force-recreate
    
    # Remove all docker instances (not just Clearwater ones!)
    sudo docker rm $(sudo docker ps -aq)

    # Remove all the docker image files (not just Clearwater ones!)
    sudo docker rmi $(sudo docker images -aq)

    # Remove most of the docker image files, but not the Ubuntu 14.04 base
    # image, use this if you intend to redeploy the clearwater deployment
    # immediately to save time.
    #
    # This command will report an error due to a conflict, this can be safely
    # ignored.
    sudo docker rmi $(sudo docker images -a | tail -n +2 | grep -v "14.04" | tr -s ' ' | cut -f3 -d' ')
