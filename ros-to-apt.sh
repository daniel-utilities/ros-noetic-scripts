#!/usr/bin/env bash
ROS_PACKAGES="$1"

if [[ "$ROS_PACKAGES" == "" ]]; then
    echo "ERROR: Must provide a space-separated list of packages in the first argument."
    echo "Usage:"
    echo "  ros-to-apt.sh \"PACKAGE1 PACKAGE2 PACKAGE3...\""
    exit 1
fi

source "$HOME/.rosconfig"

# Replace all _ with - then split the string into an array
ROS_PACKAGES="$(echo "$ROS_PACKAGES" | tr '_' '-')"
split(){ arr=( $ROS_PACKAGES ); }
IFS=$'\n' split

# Reconstruct the array, adding the prefix to each item
APT_PACKAGES=""
for pkg in "${arr[@]}"; do
    APT_PACKAGES="ros-$ROS_DISTRO-$pkg $APT_PACKAGES"
done

echo "$APT_PACKAGES"
