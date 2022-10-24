# RStudio Server version 2022.07.2

Docker image containing RStudio Workbench 2022.07.2-576.pro12.

Contains RStudio Pro ODBC Drivers, Python 3.9.9 and R 4.1.3.

## Docker Hub

This image is already built and ready to use here:

[Docker Hub - Alfmagar RStudio Workbench](https://hub.docker.com/r/alfmagar/rstudio-workbench)

If you prefer to customize it your way, feel free to download and modify this repository.

## How to build

```sh
docker build -t <your-image-name>:<your-tag> .
```

## Admitted vars


> **USER:** Default username for RStudio environment.

> **USER_PWD:** Default user password for RStudio environment.

> **RSTUDIO_LICENSE:** RStudio Workbench valid license.

## Where is data stored?

This image stores persistent data in 4 different locations:

- First volume containing all user's home directories. Mapped as /home inside the container.
- Second volume containing RServer data directory with socket and session files. Mapped at /data inside the container.
- Third volume containing RServer logs. Mapped at /var/log/supervisor inside the container.
- Fourth volume containing RStudio HTTP server logs. Mapped at /var/log/rstudio.

## How to use

You can use the included docker-compose file, along with a .env file like [env-example](./env-example)

If you prefer to run it in the classic Docker way, you can copy and addapt the following Docker run command:

```sh
docker run -d -p 80:80 -e USER=<your-username> -e USER_PWD=<your-password> -e RSTUDIO_LICENSE=<your-rstudio-license> -v <your-rstudio-home-directory>:/home -v <your-rstudio-data-directory>:/data -v <your-RServer-logs-directory>:/var/log/supervisor -v <your-http-server-data-directory>:/var/log/rstudio --hostname rstudio-workbench --name rstudio-workbench alfmagar/rstudio-workbench:latest
```
