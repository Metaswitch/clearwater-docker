# Clearwater Docker

This repository contains [Dockerfiles](https://docs.docker.com/reference/builder/) for use with [Docker](https://www.docker.com/) to deploy [Project Clearwater](http://www.projectclearwater.org).

The [aio](aio) directory contains a [Dockerfile](aio/Dockerfile) to instantiate a Clearwater [all-in-one](http://clearwater.readthedocs.org/en/latest/All_in_one_Images/) node under Docker.  To use it, run

    # Install Docker (on Ubuntu).
    apt-get update && apt-get install docker.io

    # Build the Docker image.
    docker build -t clearwater/aio

    # Start a Docker container with this image.
    docker run -p 8022:22 -p 8080:80 -p 8060:5060 -t -i clearwater/aio

The container exposes

-   SSH on port 22 (exposed on port 8022) for configuration and troubleshooting
-   the Ellis web UI on port 80 (exposed on port 8080) for self-provisioning
-   SIP on port 5060 (exposed on port 8060) for service.
