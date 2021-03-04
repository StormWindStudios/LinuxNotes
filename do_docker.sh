#!/usr/bin/env bash

##  do_docker.sh - "It installs Docker" 
##  Shane Sexton 
##  Mar 03 2021
##
##  Tested on Ubuntu 20.04 LTS
##   
## -- Collects dependencies
## -- Installs Docker repository with GPG key
## -- Installs Docker
## -- Creates Docker user (if necessary)
## -- Fixes permissions for Docker user (if necessary)
## -- Ensure docker.service and containerd.service are running

## URL Variables
DOCKER_GPG_URL='https://download.docker.com/linux/ubuntu/gpg'
DOCKER_REPO_URL='https://download.docker.com/linux/ubuntu'

## Path Variables
DOCKER_GPG_PATH='/usr/share/keyrings/docker-archive-keyring.gpg'
DOCKER_APT_PATH='/etc/apt/sources.list.d/docker.list'

## If first argument is --help or -h, print help and exit
## If first argument is --user or -u, set DOCKER_USER
## If neither match, fail.

while [[ $# -gt 0 ]]
do
  key="$1"

  case $key in
    -[hH]|--[hH][eE][lL][pP])
      echo "Usage: $( basename "$0") [options] [arg]"
      echo "    $(basename $0) --help"
      echo "    $(basename $0) --user mjackson"  
      echo "Options:"
      echo "    -u, --user        specify docker user name"
      echo "    -h, --help        show this help"
      exit 0;
    ;;
    -[uU]|--[uU][sS][eE][rR])
      DOCKER_USER=$2
      shift
      shift
    ;;
    *)
      echo "Unknown argument. See --help."
      exit 1;
    ;;
  esac
done

## If a username isn't specified, default to docker_user
DOCKER_USER=${DOCKER_USER:='docker_user'}

## Stop script if not running as root
if [[ $EUID -ne 0 ]]; then
    echo "Must be superuser to run this script."
    exit 1
fi

## Stop script if /etc/debian_version isn't present
echo "Checking /etc/debian_version..."
if [[ ! -f /etc/debian_version ]]; then
    echo "  No /etc/debian_version file. Is this debian?"
    exit 1
else
    ## Make sure debian version matches what script was written on
    echo "  Found /etc/debian_version."
    if [[ $(cat /etc/debian_version) == 'bullseye/sid' ]]; then
	 echo "  Correct version."   
    else 
	 echo "  Incorrect version. This is tested only bullseye/sid."
	 exit 1
    fi
fi

## Run silent updates
echo "Running apt updates..."
DEBIAN_FRONTEND=noninteractive apt update -qq &> /dev/null \
    && echo " Success."

## Run silent upgrades
echo "Running upgrades..."
DEBIAN_FRONTEND=noninteractive apt ugrade -qq &> /dev/null \
    && echo " Success."

## Install Docker dependencies
echo "Installing Docker dependencies..."
DEBIAN_FRONTEND=noninteractive apt install --assume-yes -qq \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg &> /dev/null \
    && echo "  Success."

# Download and save Docker GPG certificate if it's not present
echo "Checking for Docker GPG certificate..."
if [[ -f $DOCKER_GPG_PATH ]]; then
    echo "  Already installed." 
else
    echo "Installing Docker GPG certificate..."
    curl -fsSL $DOCKER_GPG_URL | gpg --dearmor -o $DOCKER_GPG_PATH \
    && echo "  Installed."
fi

# Add docker repository if it's not present
echo "Checking for Docker repository..."
if [[ -f $DOCKER_APT_PATH ]]; then
    echo "  Already present."
else
    echo "  Not present."
    echo "Adding Docker repository..."
    echo "deb [arch=$(dpkg --print-architecture) signed-by=$DOCKER_GPG_PATH] $DOCKER_REPO_URL $(lsb_release -cs) stable" | \
        sudo tee $DOCKER_APT_PATH > /dev/null \
	&& echo "  Success."
fi

## Run silent updates
echo "Running apt updates..."
DEBIAN_FRONTEND=noninteractive apt update -qq &> /dev/null \
    && echo "  Success."

## Silently install docker et al.
echo "Installing Docker..."
DEBIAN_FRONTEND=noninteractive apt install --assume-yes -qq \
    docker-ce \
    docker-ce-cli \
    containerd.io &> /dev/null \
    && echo "  Success."

## Check if the Docker user already exists on system
##   If not, create.
echo "Checking if Docker user \"$DOCKER_USER\" exists..."
if id -u "$DOCKER_USER" &>/dev/null; then
    echo "  User already exists."
else
    echo "  User doesn't exist."
    echo "Creating user..."
    useradd -m -U $DOCKER_USER && echo "  Success."
fi

## Check if the Docker user is already in the docker group
##   If not, add.
echo "Checking if Docker user \"$DOCKER_USER\" is in the docker group..."
if id -nGz "$DOCKER_USER" | grep -qzxF "docker"; then
    echo "  User $DOCKER_USER is already a member of docker."
else
    echo "  User $DOCKER_USER is no already a member of docker."
    echo "Adding $DOCKER_USER to docker..."
    usermod -aG docker $DOCKER_USER && echo "  Success."
fi

## Check if docker user already has ./docker in their homedir
##  If yes, make sure permissions and ownership are correct.
echo "Fixing Docker permissions in /home/$DOCKER_USER (if needed)..."
if [[ -d "/home/$DOCKER_USER/.docker" ]]; then
    echo "  Directory found."
    echo "Setting correct ownership..."
    chown "$DOCKER_USER":"$DOCKER_USER" /home/"$DOCKER_USER"/.docker -R && \
        echo "  Done."
    echo "Setting correct permissions..."
    sudo chmod g+rwx "/home/$DOCKER_USER/.docker" -R && \
        echo "  Done."
else
    echo "  Directory not found. Nothing to do."
fi

# Enable docker.service, if not already enabled
echo "Checking if docker.service is enabled..."
if systemctl is-enabled docker.service &> /dev/null; then
    echo "  docker.service enabled"
else
    echo "  docker.service disabled."
    echo "Enabling docker.service..."
    systemctl enable docker.service &> /dev/null && \
        echo "  Enabled."
fi

# Enable containerd.service, if not already enabled
echo "Checking if containerd.service is enabled..."
if systemctl is-enabled containerd.service &> /dev/null; then
    echo "  containerd.service enabled"
else
    echo "  containerd.service disabled."
    echo "Enabling containerd.service..."
    systemctl enable containerd.service &> /dev/null && \
        echo "  Enabled."
fi
