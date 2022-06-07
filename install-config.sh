#!/usr/bin/env bash

CONFIG="$1"

if [[ ! -f "$CONFIG" ]]; then
    echo "ERROR: Must provide a valid rosconfig file."
    echo "Usage:"
    echo "  install-config.sh \"ROSCONFIG_FILE\""
    exit
fi

# Set ROS configuration
echo "Copying $CONFIG to ~/.rosconfig..."
cp -f "$CONFIG" "$HOME/.rosconfig"

# Source ROS config, ROS install, and Catkin workspace
echo "Adding config in ~/.profile..."
APPEND1='source "$HOME/.rosconfig"'
APPEND2='[ -f "$ROS_INSTALL_PATH/setup.bash" ] && source "$ROS_INSTALL_PATH/setup.bash"'
APPEND3='[ -f "$DEFAULT_CATKIN_WS/setup.bash" ] && source "$DEFAULT_CATKIN_WS/devel/setup.bash"'
FILE="$HOME/.profile"
grep -qxF "$APPEND1" "$FILE" || echo "$APPEND1" | tee -a "$FILE" > /dev/null
grep -qxF "$APPEND2" "$FILE" || echo "$APPEND2" | tee -a "$FILE" > /dev/null
grep -qxF "$APPEND3" "$FILE" || echo "$APPEND3" | tee -a "$FILE" > /dev/null
