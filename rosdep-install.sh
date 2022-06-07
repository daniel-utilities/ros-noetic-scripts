#!/usr/bin/env bash

if [ ! -d "./src" ]; then
    echo "ERROR: No ./src directory"
    exit 1
fi

sudo apt-get update

# Install missing system dependencies
# Attempt to find dep keys using the actual OS first; then, if an override is provided, use that to fill in the gaps.
echo
echo "Installing missing system dependencies..."
echo
rosdep install --from-paths "./src" --ignore-packages-from-source --rosdistro=$ROS_DISTRO -y -r

if [ -z ${ROS_OS_OVERRIDE+x} ]; then
    echo
    echo "Retrying with ROS_OS_OVERRIDE=$ROS_OS_OVERRIDE..."
    echo
    rosdep install --from-paths "./src" --ignore-packages-from-source --rosdistro=$ROS_DISTRO --os=$ROS_OS_OVERRIDE -y -r
fi
