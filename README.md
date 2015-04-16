# Clearwater Docker

This repository contains [Dockerfiles](https://docs.docker.com/reference/builder/) for use with [Docker](https://www.docker.com/) and [Compose](https://docs.docker.com/compose/) to deploy [Project Clearwater](http://www.projectclearwater.org).

## Using Compose

There is a [Compose file](minimal-distributed.yaml) to instantiate a minimal (non-fault-tolerant) distributed Clearwater deployment under Docker.  To use it, run

    # Install Docker (on Ubuntu) - we need the latest for compatibility with Compose.
    wget -qO- https://get.docker.com/ | sh

    # Install Docker Compose (on Ubuntu).
    apt-get install python-pip
    pip install -U docker-compose

    # Build the base Clearwater docker image.
    docker build -t clearwater/base base

    # Build all the other Clearwater Docker images and start a deployment.
    docker-compose -f minimal-distributed.yaml up

## Manual Turn-Up

If you can't or don't want to use Compose, you can turn the deployment up manually under Docker.  To use it, run

    # Install Docker (on Ubuntu) - we need the latest for compatibility with Compose.
    wget -qO- https://get.docker.com/ | sh

    # Build the Clearwater docker images.
    for i in base bono ellis homer homestead ralf sprout ; do docker build -t clearwater/$i $i ; done

    # Turn up all the containers and link them together.
    docker run -d --name homestead -p 22 clearwater/homestead
    docker run -d --name homer -p 22 clearwater/homer
    docker run -d --name ralf -p 22 clearwater/ralf
    docker run -d --name sprout -p 22 --link homestead:homestead --link homer:homer --link ralf:ralf clearwater/sprout
    docker run -d --name bono -p 22 -p 3478:3478 -p 3478:3478/udp -p 5060:5060 -p 5060:5060/udp -p 5062:5062 --link sprout:sprout clearwater/bono
    docker run -d --name ellis -p 22 -p 80:80 --link homestead:homestead --link homer:homer clearwater/ellis

# Exposed Services

The deployment exposes

-   the Ellis web UI on port 80 (exposed on port 8080) for self-provisioning - the signup key is "secret"
-   STUN/TURN on port 3478 for media relay
-   SIP on port 5060 for service
-   SIP/WebSocket on port 5062 for service.

Additionally, each node exposes SSH - use `docker ps` to see what port its exposed on.  The username/password is root/root.

# What Next?

Once you've turned up the deployment, you can test it by

-   [making a call](http://clearwater.readthedocs.org/en/latest/Making_your_first_call) - make sure you configure your SIP clients with a proxy, as if it were an All-in-One node
-   [running the live tests](http://clearwater.readthedocs.org/en/latest/Running_the_live_tests) - again, set the PROXY and ELLIS elements, as if it were an All-in-One node.
