#!/usr/bin/env bash
ROS_PACKAGES="$1"

if [[ "$ROS_PACKAGES" == "" ]]; then
    echo "ERROR: Must provide a space-separated list of packages in the first argument."
    echo "Usage:"
    echo "  ros-to-apt.sh \"PACKAGE1 PACKAGE2 PACKAGE3...\""
    exit 1
fi

source "$HOME/.profile"

# Replace all _ with - then split the string into an array
IFS=' ' read -a arr <<< "$(echo "$ROS_PACKAGES" | tr '_' '-' | tr '\n' ' ')"

# Reconstruct the array, adding the prefix to each item
APT_PACKAGES=""
for pkg in "${arr[@]}"; do
    APT_PACKAGES="ros-$ROS_DISTRO-$pkg $APT_PACKAGES"
done

echo "$APT_PACKAGES"
