#!/usr/bin/env bash

if [ -z ${ROS_OS_OVERRIDE+x} ]; then
    rosdep --rosdistro=$ROS_DISTRO --os=$ROS_OS_OVERRIDE update
else
    rosdep --rosdistro=$ROS_DISTRO update
fi