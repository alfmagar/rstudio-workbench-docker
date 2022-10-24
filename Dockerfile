# Parent image
FROM ubuntu:22.04

# Define build args
ARG DEBIAN_FRONTEND=noninteractive
ARG TZ=Europe/Madrid
ARG LANG=es_ES.UTF-8
ARG LANGUAGE=es_ES:es
ARG LC_ALL=es_ES.UTF-8
ARG PYTHON_VERSION=3.9.9
ARG PYTHON_MAJOR=3
ARG R_VERSION=4.1.3

# Define environment variables
ENV USER=rstudio
ENV USER_PWD=rstudio
ENV RSTUDIO_LICENSE=NULL

# Set timezone
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Update image packages
RUN apt-get update -y && apt-get upgrade -y

# Install deps
RUN apt-get install -y locales supervisor wget gdebi gdebi-core curl build-essential libffi-dev libgdbm-dev libsqlite3-dev libssl-dev zlib1g-dev unixodbc unixodbc-dev

# Configure system locales
RUN locale-gen es_ES.UTF-8
RUN localedef -f UTF-8 -i es_ES es_ES.UTF-8

# Install Python
RUN wget https://python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz
RUN tar -xvzf Python-${PYTHON_VERSION}.tgz
WORKDIR /Python-${PYTHON_VERSION}
RUN ./configure \
    --prefix=/opt/python/${PYTHON_VERSION} \
    --enable-shared \
    LDFLAGS=-Wl,-rpath=/opt/python/${PYTHON_VERSION}/lib,--disable-new-dtags
RUN make && make install
WORKDIR /
RUN rm -rf Python-${PYTHON_VERSION}*

# Install PIP
RUN curl -O https://bootstrap.pypa.io/get-pip.py
RUN /opt/python/${PYTHON_VERSION}/bin/python${PYTHON_MAJOR} get-pip.py
RUN rm -fr get-pip.py

# Install R
RUN curl -O https://cdn.rstudio.com/r/ubuntu-2204/pkgs/r-${R_VERSION}_1_amd64.deb
RUN gdebi -n r-${R_VERSION}_1_amd64.deb
RUN ln -s /opt/R/${R_VERSION}/bin/R /usr/local/bin/R && ln -s /opt/R/${R_VERSION}/bin/Rscript /usr/local/bin/Rscript
RUN rm -fr r-${R_VERSION}_1_amd64.deb

# Install RStudio
RUN curl -O https://download2.rstudio.org/server/jammy/amd64/rstudio-workbench-2022.07.2-576.pro12-amd64.deb
RUN gdebi -n rstudio-workbench-2022.07.2-576.pro12-amd64.deb
RUN rm ./rstudio-workbench-2022.07.2-576.pro12-amd64.deb
RUN rstudio-server stop

# Install RStudio Professional Drivers
RUN wget https://cdn.rstudio.com/drivers/7C152C12/installer/rstudio-drivers_2021.10.0_amd64.deb && \
    gdebi -n rstudio-drivers_2021.10.0_amd64.deb && \
    rm rstudio-drivers_2021.10.0_amd64.deb && \
    cp /etc/odbcinst.ini /etc/odbcinst.ini.bak && \
    cat /opt/rstudio-drivers/odbcinst.ini.sample | sudo tee -a /etc/odbcinst.ini

# Copy RStudio/Supervisor config files and entrypoint script
COPY resources/configuration/rserver.conf /etc/rstudio/rserver.conf
COPY resources/configuration/launcher-env /etc/rstudio/launcher-env
COPY resources/configuration/logging.conf /etc/rstudio/logging.conf
COPY resources/configuration/launcher.local.conf /etc/rstudio/launcher.local.conf
COPY resources/configuration/launcher.conf /etc/rsturio/launcher.conf
COPY resources/configuration/notifications.conf /etc/rstudio/notifications.conf
COPY resources/configuration/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY resources/scripts/entrypoint.sh /entrypoint.sh

# Create RStudio data folder with right permissions
RUN mkdir /data && chown rstudio-server /data && chmod 755 /data && chmod +x /entrypoint.sh

# Expose Rstudio port
EXPOSE 80

# Set up default volumes
VOLUME [ "/home"]
VOLUME [ "/data" ]
VOLUME [ "/var/log/supervisor"]
VOLUME [ "/var/log/rstudio" ]

# Configure Healthcheck for RStudio Workbench SSL port
HEALTHCHECK CMD curl --fail http://localhost:80 || exit 1

#Configure entrypoint script
ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
