# Clearwater Docker

This repository contains [Dockerfiles](https://docs.docker.com/reference/builder/) for use with [Docker](https://www.docker.com/) and [Compose](https://docs.docker.com/compose/) to deploy [Project Clearwater](http://www.projectclearwater.org).

## Using Compose

There is a [Compose file](minimal-distributed.yaml) to instantiate a minimal (non-fault-tolerant) distributed Clearwater deployment under Docker.

### Preparation

To prepare your system to deploy Clearwater using compose, run:

    # Install Docker (on Ubuntu) - we need the latest for compatibility with Compose.
    wget -qO- https://get.docker.com/ | sh

    # Install Docker Compose (on Ubuntu).
    sudo apt-get install python-pip
    sudo pip install -U docker-compose

    # Checkout clearwater-docker.
    git clone --recursive git@github.com:Metaswitch/clearwater-docker.git
    cd clearwater-docker

    # Build the base Clearwater docker image.
    docker build -t clearwater/base base

### Starting Clearwater

To start the Clearwater services, run:

    # Build all the other Clearwater Docker images and start a deployment.
    docker-compose -f minimal-distributed.yaml up

### Stopping Clearwater

To stop the Clearwater services, run:

    docker-compose -f minimal-distributed.yaml stop

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
    for i in base bono ellis homer homestead ralf sprout ; do docker build -t clearwater/$i $i ; done

### Starting Clearwater

To start the Clearwater services, run:

    docker run -d --name homestead -p 22 clearwater/homestead
    docker run -d --name homer -p 22 clearwater/homer
    docker run -d --name ralf -p 22 clearwater/ralf
    docker run -d --name sprout -p 22 --link homestead:homestead --link homer:homer --link ralf:ralf clearwater/sprout
    docker run -d --name bono -p 22 -p 3478:3478 -p 3478:3478/udp -p 5060:5060 -p 5060:5060/udp -p 5062:5062 --link sprout:sprout clearwater/bono
    docker run -d --name ellis -p 22 -p 80:80 --link homestead:homestead --link homer:homer clearwater/ellis

### Stopping Clearwater

To stop the Clearwater services, run:

    docker stop -d --name ellis
    docker stop -d --name bono
    docker stop -d --name sprout
    docker stop -d --name ralf
    docker stop -d --name homer
    docker stop -d --name homestead

## Exposed Services

The deployment exposes

-   the Ellis web UI on port 80 (exposed on port 8080) for self-provisioning - the signup key is "secret"
-   STUN/TURN on port 3478 for media relay
-   SIP on port 5060 for service
-   SIP/WebSocket on port 5062 for service.

Additionally, each node exposes SSH - use `docker ps` to see what port its exposed on.  The username/password is root/root.

## What Next?

Once you've turned up the deployment, you can test it by

-   [making a call](http://clearwater.readthedocs.org/en/latest/Making_your_first_call) - make sure you configure your SIP clients with a proxy, as if it were an All-in-One node
-   [running the live tests](http://clearwater.readthedocs.org/en/latest/Running_the_live_tests) - again, set the PROXY and ELLIS elements, as if it were an All-in-One node.

## Cleaning Up

If you wish to destroy your deployment either to redeploy with a different configuration or version or to free up resources on your docker host, the following may be useful commands:

    # Remove all docker instances (not just Clearwater ones!)
    docker rm $(docker ps -aq)

    # Remove all the docker image files (not just Clearwater ones!)
    docker rmi $(docker images -aq)

    # Remove most of the docker image files, but not the Ubuntu 14.04 base
    # image, use this if you intend to redeploy the clearwater deployment
    # immediately to save time.
    #
    # This command will report an error due to a conflict, this can be safely
    # ignored.
    docker rmi $(docker images -a | tail -n +2 | grep -v "14.04" | tr -s ' ' | cut -f3 -d' ')
