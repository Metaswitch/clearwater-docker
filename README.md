# Clearwater Docker

This repository contains [Dockerfiles](https://docs.docker.com/reference/builder/) for use with [Docker](https://www.docker.com/) to deploy [Project Clearwater](http://www.projectclearwater.org).

The [aio](aio) directory contains a [Dockerfile](aio/Dockerfile) to instantiate a Clearwater [all-in-one](http://clearwater.readthedocs.org/en/latest/All_in_one_Images/) node under Docker.  To use it, run

    # Install Docker (on Ubuntu).
    wget -qO- https://get.docker.com/ | sh

    # Install Docker Compose (on Ubuntu).
    apt-get install python-pip
    pip install -U docker-compose

    # Build the base Clearwater docker image.
    docker build -t clearwater/base base

    # Build all the other Clearwater Docker images and start a deployment.
    docker-compose -f minimal-distributed.yaml up

The container exposes

-   SSH on port 22 (exposed on port 8022) for configuration and troubleshooting
-   the Ellis web UI on port 80 (exposed on port 8080) for self-provisioning
-   SIP on port 5060 (exposed on port 8060) for service.
