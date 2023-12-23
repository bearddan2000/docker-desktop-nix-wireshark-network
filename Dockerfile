FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

ENV DISPLAY :0

ENV NIX_CHANNEL nixpkgs

ENV NIX_CHANNEL_URL https://nixos.org/channels/nixos-22.05

ENV NIX_PKG wireshark

ENV USERNAME developer

WORKDIR /app

RUN apt update

RUN apt-get install -y --no-install-recommends \
    apt-transport-https \
    software-properties-common \
    nix sudo

RUN nix-channel --add $NIX_CHANNEL_URL $NIX_CHANNEL \
    && nix-channel --update \
    && nix-env -iA $NIX_CHANNEL.$NIX_PKG \
    && nix-build "<${NIX_CHANNEL}>" -A $NIX_PKG \
    && ln -s /app/result/bin/$NIX_PKG /bin/$NIX_PKG

# create and switch to a user
RUN echo "backus ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN useradd --no-log-init --home-dir /home/$USERNAME --create-home --shell /bin/bash $USERNAME
RUN adduser $USERNAME sudo

USER $USERNAME

WORKDIR /home/$USERNAME

CMD $NIX_PKG