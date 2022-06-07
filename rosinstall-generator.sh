#!/usr/bin/env bash

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
echo "Downloading source code..."
vcs import --input "./$ROSINSTALL_CONFIG" --workers 2 "./src"

# Install missing system dependencies
# Attempt to find dep keys using the actual OS first; then, if an override is provided, use that to fill in the gaps.
sudo apt-get update
rosdep install --from-paths "./src" --ignore-packages-from-source --rosdistro=$ROS_DISTRO -y -r
if [ -z ${ROS_OS_OVERRIDE+x} ]; then
    rosdep install --from-paths "./src" --ignore-packages-from-source --rosdistro=$ROS_DISTRO --os=$ROS_OS_OVERRIDE -y -r
fi

# Build and install
sudo python3 "./src/catkin/bin/catkin_make_isolated"    \
        --install                                       \
        --install-space "$ROS_INSTALL_PATH"             \
        -DCMAKE_BUILD_TYPE=Release                      \
        -DBUILD_TESTING=OFF                             \
        $ROS_PARALLEL_JOBS
