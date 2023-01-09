#! /usr/bin/env bash

set -e

## Bash script to setup PX4 development environment on Ubuntu LTS (20.04, 18.04, 16.04).
## Can also be used in docker.
##
## Installs:
## - Common dependencies and tools for nuttx, jMAVSim, Gazebo
## - NuttX toolchain (omit with arg: --no-nuttx)
## - jMAVSim and Gazebo9 simulator (omit with arg: --no-sim-tools)
##
## Not Installs:
## - FastRTPS and FastCDR

INSTALL_NUTTX="true"
INSTALL_SIM="true"
INSTALL_ARCH=`uname -m`

# Parse arguments
for arg in "$@"
do
	if [[ $arg == "--no-nuttx" ]]; then
		INSTALL_NUTTX="false"
	fi

	if [[ $arg == "--no-sim-tools" ]]; then
		INSTALL_SIM="false"
	fi

done

# detect if running in docker
if [ -f /.dockerenv ]; then
	echo "Running within docker, installing initial dependencies";
	apt-get --quiet -y update && DEBIAN_FRONTEND=noninteractive apt-get --quiet -y install \
		ca-certificates \
		gnupg \
		lsb-core \
		sudo \
		wget \
		;
fi

# script directory
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# check requirements.txt exists (script not run in source tree)
REQUIREMENTS_FILE="requirements.txt"
if [[ ! -f "${DIR}/${REQUIREMENTS_FILE}" ]]; then
	echo "FAILED: ${REQUIREMENTS_FILE} needed in same directory as ubuntu.sh (${DIR})."
	return 1
fi


# check ubuntu version
# otherwise warn and point to docker?
UBUNTU_RELEASE="`lsb_release -rs`"

if [[ "${UBUNTU_RELEASE}" == "14.04" ]]; then
	echo "Ubuntu 14.04 is no longer supported"
	exit 1
elif [[ "${UBUNTU_RELEASE}" == "16.04" ]]; then
	echo "Ubuntu 16.04 is no longer supported"
	exit 1
elif [[ "${UBUNTU_RELEASE}" == "18.04" ]]; then
	echo "Ubuntu 18.04"
elif [[ "${UBUNTU_RELEASE}" == "20.04" ]]; then
	echo "Ubuntu 20.04"
fi


echo
echo "Installing PX4 general dependencies"

sudo apt-get update -y --quiet
sudo DEBIAN_FRONTEND=noninteractive apt-get -y --quiet --no-install-recommends install \
	astyle \
	build-essential \
	cmake \
	cppcheck \
	file \
	g++ \
	gcc \
	gdb \
	git \
	lcov \
	libxml2-dev \
	libxml2-utils \
	make \
	ninja-build \
	python3 \
	python3-dev \
	python3-pip \
	python3-setuptools \
	python3-wheel \
	rsync \
	shellcheck \
	unzip \
	zip \
	;

# Python3 dependencies
echo
echo "Installing PX4 Python3 dependencies"
if [ -n "$VIRTUAL_ENV" ]; then
	# virtual envrionments don't allow --user option
	python -m pip install -r ${DIR}/requirements.txt
else
	# older versions of Ubuntu require --user option
	python3 -m pip install --user -r ${DIR}/requirements.txt
fi


