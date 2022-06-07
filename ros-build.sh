#!/usr/bin/env bash

BUILD_TOOL="./src/catkin/bin/catkin_make_isolated"

if [ ! -d "./src" ]; then
    echo "ERROR: No src directory"
    exit
fi

if [ ! -f "$BUILD_TOOL" ]; then
    echo "ERROR: No build tool \"$BUILD_TOOL\""
    exit
fi

source "$HOME/.profile"

# Build and install
echo
echo "Building ROS from source: ./src"
echo "Installing to: $ROS_INSTALL_PATH"
echo
echo
sudo python3 "$BUILD_TOOL"                  \
        --install                           \
        --install-space "$ROS_INSTALL_PATH" \
        -DCMAKE_BUILD_TYPE=Release          \
        -DBUILD_TESTING=OFF                 \
        $ROS_PARALLEL_JOBS