# Clearwater Docker

This repository contains [Dockerfiles](https://docs.docker.com/reference/builder/) for use with [Docker](https://www.docker.com/) and [Compose](https://docs.docker.com/compose/) to deploy [Project Clearwater](http://www.projectclearwater.org).

There are three options for installing Docker:

- Using Docker Compose. This is the recommended approach.

- Using Kuberenetes.

- Manually. In this case you need to use some Docker options to set up the
  networking config that Compose or Kubernetes would set up automatically.

You should follow the "Common Preparation" section, then either the "Using Compose" or the "Manual Turn-Up" section.

## Common Preparation

When using the `3.13.0-74-generic` kernel, we've seen [an issue](https://github.com/Metaswitch/clearwater-docker/issues/24) which causes Clearwater not to start properly. If you are using this kernel (`uname -r` will tell you), you should install a newer kernel (e.g. with `sudo apt-get install linux-image-3.13.0-87-generic`) and reboot.

To prepare your system to deploy Clearwater on Docker, run:

    # Install Docker (on Ubuntu).
    wget -qO- https://get.docker.com/ | sh

    # Checkout clearwater-docker.
    # Either:
    git clone --recursive git@github.com:Metaswitch/clearwater-docker.git
    # Or:
    git clone --recursive https://github.com/Metaswitch/clearwater-docker.git

Edit clearwater-docker/.env so that PUBLIC_IP is set to an IP address that can be used by SIP clients to access the docker host.   E.g. if you are running in AWS, this wants to be the public IP of your AWS VM.

If you want to be able to monitor your Docker deployment via a web UI then you might like to install and run [Weave Scope](https://www.weave.works/products/weave-scope/).  This only takes a minute to [install](https://www.weave.works/install-weave-scope/) and provides real time visualizations showing all of your containers, their resource usage and the connectivity between them.

![alt text](docs/images/clearwater-docker in scope.jpg "Clearwater-Docker dispayed in Scope")

## Using Compose

There is a [Compose file](minimal-distributed.yaml) to instantiate a minimal (non-fault-tolerant) distributed Clearwater deployment under Docker.

#### Preparation

To prepare your system to deploy Clearwater using Compose, after running the common preparation steps above, run:

    # Install Docker Compose (on Ubuntu).
    sudo apt-get install python-pip -y
    sudo pip install -U docker-compose

    # Build the base Clearwater docker image.
    cd clearwater-docker
    sudo docker build -t clearwater/base base

#### Starting Clearwater

To start the Clearwater services, run:

    # Build all the other Clearwater Docker images and start a deployment.
    sudo docker-compose -f minimal-distributed.yaml up -d

#### Scaling the deployment

Having started up a deployment, it is then possible to scale it by adding more Sprout, Memcached, Chronos or Cassandra nodes.   E.g. to spin up an additional node of each of these types, run:

    sudo docker-compose -f minimal-distributed.yaml scale sprout=2 memcached=2 chronos=2 cassandra=2

Note that scaling of Docker deployments is a work in progress and there are currently a number of known issues...

* Bono doesn’t automatically start using new Sprout nodes unless the Bono process is restarted, e.g.

    `sudo docker exec clearwaterdocker_bono_1 sudo service bono restart`

* Homestead-prov and Ellis don’t load balance across multiple Cassandra nodes.

* There is no tested or documented process for scaling down clusters of storage nodes in Docker -- it isn't sufficient to just delete the containers as they need to be explicitly decommissioned and removed from the clusters.

If you scale up the clusters of storage nodes, you can monitor progress as new nodes join the clusters by running `utils/show_cluster_state.sh`.

## Using Kubernetes

Instead of using Docker Compose, you can deploy Clearwater in Kubernetes. This
requires a Kubernetes cluster, and a Docker repository.

### Prepare the images

- First, build all the required images locally.

        # Build the Clearwater docker images.
        cd clearwater-docker
        for i in base memcached cassandra chronos bono ellis homer homestead ralf sprout ; do docker build -t clearwater/$i $i ; done

- Next, push them to your repository (which must be accessible from the Kubernetes deployment)

        for i in base memcached cassandra chronos bono ellis homer homestead ralf sprout
        do
            docker tag -f clearwater/$i:latest path_to_your_repo/clearwater/$i:latest
            docker push path_to_your_repo/clearwater/$i:latest
        done

- Finally, change the image paths in the Kubernetes files. For every file
  ending `-rc.yaml`, edit the image path to be the correct path for your
  repository.


### Deploy Clearwater in Kubernetes

To deploy the images, you should simply do `kubectl create -f clearwater-docker/kubernetes`.

## Manual Turn-Up

If you can't or don't want to use Compose, you can turn the deployment up manually under Docker.

#### Preparation

To prepare your system to deploy Clearwater without using Compose, after running the common preparation steps above, run:

    # Build the Clearwater docker images.
    cd clearwater-docker
    for i in base memcached cassandra chronos bono ellis homer homestead ralf sprout ; do sudo docker build -t clearwater/$i $i ; done

#### Starting Clearwater

To start the Clearwater services, run:

    sudo docker network create --driver bridge clearwater_nw
    sudo docker run -d --net=clearwater_nw --name etcd quay.io/coreos/etcd:v2.2.5 -name etcd0 -advertise-client-urls http://etcd:2379,http://etcd:4001 -listen-client-urls http://0.0.0.0:2379,http://0.0.0.0:4001 -initial-advertise-peer-urls http://etcd:2380 -listen-peer-urls http://0.0.0.0:2380  -initial-cluster etcd0=http://etcd:2380 -initial-cluster-state new
    sudo docker run -d --net=clearwater_nw --name memcached -p 22 clearwater/memcached
    sudo docker run -d --net=clearwater_nw --name cassandra -p 22 clearwater/cassandra
    sudo docker run -d --net=clearwater_nw --name chronos -p 22 clearwater/chronos
    sudo docker run -d --net=clearwater_nw --name homestead -p 22 clearwater/homestead
    sudo docker run -d --net=clearwater_nw --name homer -p 22 clearwater/homer
    sudo docker run -d --net=clearwater_nw --name ralf -p 22 clearwater/ralf
    sudo docker run -d --net=clearwater_nw --network-alias=icscf.sprout --network-alias=scscf.sprout --name sprout -p 22 clearwater/sprout
    sudo docker run -d --net=clearwater_nw --name bono --env-file .env -p 22 -p 3478:3478 -p 3478:3478/udp -p 5060:5060 -p 5060:5060/udp -p 5062:5062 clearwater/bono
    sudo docker run -d --net=clearwater_nw --name ellis -p 22 -p 80:80 clearwater/ellis

The Clearwater Docker images use DNS for service discovery - they require, for example, that the name "ellis" should resolve to the Ellis container's IP address. In standard Docker, user-defined networks include [an embedded DNS server](https://docs.docker.com/engine/userguide/networking/dockernetworks/#docker-embedded-dns-server) which guarantees this (and this is why we create the clearwater_nw network) - and this type of DNS server is relatively common (for example, [Kubernetes provides something similar](http://kubernetes.io/docs/user-guide/services/#dns)).

#### Scaling the deployment

It is possible to spin up additional Sprout, Cassandra, Memcached and Chronos nodes simply by repeating the relevant command `docker run` command but providing a different name.   E.g.

    sudo docker run -d --net=clearwater_nw --name memcached_2 -p 22 clearwater/memcached

Scaling of clearwater-docker deployments is work in progress though, so see the limitations described above (for scaling using Compose).

## Exposed Services

The deployment exposes

-   the Ellis web UI on port 80 (exposed on port 8080) for self-provisioning - the signup key is "secret"
-   STUN/TURN on port 3478 for media relay
-   SIP on port 5060 for service
-   SIP/WebSocket on port 5062 for service.

Additionally, each node exposes SSH - use `sudo docker ps` to see what port its exposed on.  The username/password is root/root.   Alternatively you can run a bash session in a container by name using e.g. `sudo docker exec -it <container_name> bash`

## What Next?

Once you've turned up the deployment, you can test it by

-   [making a call](http://clearwater.readthedocs.org/en/latest/Making_your_first_call.html) - make sure you configure your SIP clients with a proxy, as if it were an All-in-One node
-   [running the live tests](http://clearwater.readthedocs.org/en/latest/Running_the_live_tests.html) - again, set the PROXY and ELLIS elements, as if it were an All-in-One node.

## Utilities

There are a few scripts that offer short cuts to querying aspects of your deployment:

    # Show an abbreviated version of docker ps that fits without wrapping on smaller terminals
    utils/short_ps.sh

    # Show the IP addresses of the containers in your deployment
    utils/show_ips.sh

    # Query Chronos nodes over SNMP to get the number of active registrations
    utils/show_registration_count.sh

    # Show information about the state of the storage clusters
    utils/show_cluster_state.sh

## Cleaning Up

If you wish to destroy your deployment either to redeploy with a different configuration or version or to free up resources on your docker host, the following may be useful commands:

    # To rebuild an image (rather than pull it from the cache), add `--no-cache` or `--force-recreate` to the build commands
    sudo docker build --no-cache -t clearwater/base base
    sudo docker-compose -f minimal-distributed.yaml up --force-recreate

    # Remove all docker containers (not just Clearwater ones!)
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
