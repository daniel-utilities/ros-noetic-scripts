#!/usr/bin/env bash
WORKING_DIR="$PWD"
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
CONFIG_DIR="$SCRIPT_DIR/config"
DOWNLOAD_DIR="$HOME/downloads"
if [ -d "$HOME/Downloads" ]; then DOWNLOAD_DIR="$HOME/Downloads"; fi


# Get device identity
cd "$SCRIPT_DIR"
echo
echo "Checking device type..."
chmod +x "./identify-device.sh" && source "./identify-device.sh"
if [[ "$IDENTITY" == "" ]]; then
    echo "Device is not a supported type."
    exit
fi
echo "IDENTITY set to $IDENTITY"

# Increase Swap (Raspberry Pi Only)
if [[ "$IDENTITY" == *"raspi"* ]]; then
    cd "$SCRIPT_DIR"
    echo
    echo "Raspberry Pi detected."
    echo "The Swap memory should be increased before continuing."
    echo "The ROS build process needs up to 2048MB swap."
    echo
    read -r -p "Edit swap memory? (Y/N): " 
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        chmod +x "./raspi-edit-swap.sh" && "./raspi-edit-swap.sh"
    fi
fi

# EEPROM update (RasPi 4 only)
if [[ "$IDENTITY" == "raspi4" ]]; then
    cd "$SCRIPT_DIR"
    echo
    echo "Raspberry Pi 4 (or greater) detected."
    echo "The EEPROM should be updated before continuting."
    echo
    read -r -p "Update RPi 4 EEPROM? (Y/N): " 
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        chmod +x "./raspi-eeprom-update.sh" && "./raspi-eeprom-update.sh"    
    fi
fi

# Install ccache
echo
echo "CCache reduces build time in large projects."
echo
read -r -p "Enable ccache? (Y/N): " 
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installing ccache..."
    sudo apt-get update
    sudo apt-get install -y ccache
    echo "Adding ccache to PATH..."
    APPEND='PATH="/usr/lib/ccache:$PATH"'
    FILE="$HOME/.profile"
    grep -qxF "$APPEND" "$FILE" || echo "$APPEND" | tee -a "$FILE" > /dev/null
fi

# Set ROS configuration
cd "$SCRIPT_DIR"
CONFIG_FILE="rosconfig-$IDENTITY"
echo
echo "Selected configuration file $CONFIG_FILE for this device."
echo
read -r -p "Overwrite ~/.rosconfig? (Y/N): " 
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    chmod +x "./install-config.sh" && "./install-config.sh" "$CONFIG_DIR/$CONFIG_FILE"
fi

source "$HOME/.profile"

echo
echo "Please ensure ~/.profile and ~/.rosconfig are suitable for your device before continuing."
echo
read -r -p "Continue with install? (Y/N): " 
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit
fi



# Download and install ROS prerequisites
cd "$SCRIPT_DIR"
chmod +x "./install-prerequisites.sh" && "./install-prerequisites.sh"

# ROSDEP
echo "Initializing ROSDEP..."
sudo rosdep init
rosdep --rosdistro=$ROS_DISTRO --os=$ROS_OS_OVERRIDE update

# Create installation space
if [ -d "$HOME/Downloads" ]; then
    echo "Creating ROS installation space in ~/Downloads..."
    mkdir -p "$HOME/Downloads/rosinstall-catkin-ws"
    cd "$HOME/Downloads/rosinstall-catkin-ws";
else
    echo "Creating ROS installation space in ~/downloads..."
    mkdir -p "$HOME/downloads/rosinstall-catkin-ws"
    cd "$HOME/downloads/rosinstall-catkin-ws";
fi

# Generate install files
rosinstall_generator --rosdistro=$ROS_DISTRO --deps --wet-only --tar PACKAGES > noetic-config.rosinstall



cd "$WORKING_DIR"