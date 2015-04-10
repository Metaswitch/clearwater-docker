# Clearwater Docker

This repository contains [Dockerfiles](https://docs.docker.com/reference/builder/) for use with [Docker](https://www.docker.com/) and [Compose](https://docs.docker.com/compose/) to deploy [Project Clearwater](http://www.projectclearwater.org).

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

The deployment exposes

-   the Ellis web UI on port 80 (exposed on port 8080) for self-provisioning
-   STUN/TURN on port 3478 for media relay
-   SIP on port 5060 for service
-   SIP/WebSocket on port 5062 for service.
