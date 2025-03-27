FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && apt-get install -y bash sudo

RUN useradd -m -s /bin/bash docker-user && \
    echo "docker-user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

WORKDIR /home/docker-user/dotfiles/

COPY . /home/docker-user/dotfiles/

RUN chown -R docker-user:docker-user /home/docker-user/

USER docker-user

RUN ./installer.sh ubuntu || echo 'Installer failed' >> /home/docker-user/install.log
