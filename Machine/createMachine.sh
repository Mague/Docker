#!/bin/sh
# https://github.com/docker/machine
# https://www.digitalocean.com/

INPUT="$1"
ACCESSTOKEN="$2"
LOCATION="$3"

MACHINE="/usr/local/bin/docker-machine"
MACHINERELEASE="https://github.com/docker/machine/releases/download/v0.5.6/docker-machine_linux-amd64"
HARDENING="https://raw.githubusercontent.com/konstruktoid/Docker/master/Security/baselineDockerHost.sh"
SHA256SUM="ebaf9fc4bdc19e8523905490af422ab4db5dea7bd399c917c7e00851a65d3df5"

if ! test -d "$TMP"; then
  TMP=/tmp
fi

if [ "$INPUT" = "install" ]; then
  echo "Downloading $MACHINERELEASE."
  curl -sSL $MACHINERELEASE > $TMP/machine

  if [ "$(openssl sha1 -sha256 $TMP/machine | awk '{print $NF}')" != "$SHA256SUM" ]; then
    echo "SHA256 mismatch. Exiting."
    exit 1
  else
    echo "SHA256 OK."
  fi

  sudo mv $TMP/machine $MACHINE
  sudo chown root:root $MACHINE*
  sudo chmod 0755 $MACHINE*
  $MACHINE -v
  exit
fi

if [ -z "$ACCESSTOKEN" ]; then
  echo "ACCESSTOKEN required"
  exit
fi

if ! test -x "$MACHINE"; then
  echo "docker-machine doesn't seem to be installed."
fi

if [ -z "$INPUT" ]; then
  echo "Machine name required"
  exit 1
else
  docker-machine create --driver digitalocean --digitalocean-access-token "$ACCESSTOKEN" --digitalocean-region "$LOCATION" "$INPUT"
  docker-machine ssh "$INPUT" "wget -O /tmp/baselineDockerHost.sh $HARDENING; /bin/bash /tmp/baselineDockerHost.sh"
fi
