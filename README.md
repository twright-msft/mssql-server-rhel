# mssql-server-rhel
This project is a Dockerfile for building an image based on the [official Red Hat Enterprise Linux 7 image](https://access.redhat.com/containers/#/registry.access.redhat.com/rhel7/rhel).  

## Prerequisites
* You will need access to the [Red Hat Container Catalog](https://access.redhat.com/containers) via a Red Hat subscription.
* You will need to login to the Red Hat Container Catalog using docker login. [More info](https://access.redhat.com/articles/2834301)
* You will also need to provide your Red Hat subscription credentials in the Dockerfile before you build.
* You will also need to build the image yourself using Docker's command line tool '[docker](https://docs.docker.com/engine/reference/commandline/cli/)'.

## To build an image
To build an image locally on your Docker host follow these steps:
```
<cd into or mkdir and cd into a new directory>
$ git clone https://github.com/twright-msft/mssql-server-rhel
$ docker build -t mssql-server-rhel .
```

## To run an image
Running an image is essentially the same as running the Ubuntu-based SQL Server image on Docker Hub.
```
$ docker run -e ACCEPT_EULA=Y -e SA_PASSWORD=<your_strong_password> -p 1433:1433 -d mssql-server-rhel
```
