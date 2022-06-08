#!/usr/bin/env bash

rosdep --rosdistro=$ROS_DISTRO update

if [ -z "$ROS_OS_OVERRIDE" ]; then
    rosdep --rosdistro=$ROS_DISTRO --os=$ROS_OS_OVERRIDE update
fi
