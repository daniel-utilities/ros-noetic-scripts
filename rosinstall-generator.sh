#!/usr/bin/env bash
WORKING_DIR="$PWD"
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

PACKAGES="$1"
ROSINSTALL_CONFIG="ros-noetic.rosinstall"

if [[ "$PACKAGES" == "" ]]; then
    echo "ERROR: Must provide a space-separated list of packages in the first argument."
    echo "Usage:"
    echo "  rosinstall-generator.sh \"PACKAGE1 PACKAGE2 PACKAGE3...\""
    exit
fi

source "$HOME/.profile"

# Generate install configuration
echo "Generating rosinstall configuration for the following packages:"
echo "$PACKAGES"
rosinstall_generator --rosdistro=$ROS_DISTRO --deps --wet-only --tar $PACKAGES > "./$ROSINSTALL_CONFIG"

# Download packages
echo "Downloading source code into ./src..."
vcs import --input "./$ROSINSTALL_CONFIG" --workers 2 "./src"
