#!/usr/bin/env bash
WORKING_DIR="$PWD"
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
CONFIG_DIR="$SCRIPT_DIR/config"
DOWNLOAD_DIR="$HOME/downloads"
if [ -d "$HOME/Downloads" ]; then DOWNLOAD_DIR="$HOME/Downloads"; fi

# Check for sudo
if [ "$EUID" -eq 0 ]; then
    echo "ERROR: Script cannot be run with sudo."
    echo "Please rerun script without root privileges."
    exit
fi

# Check that packages have already been

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
cd "$SCRIPT_DIR"
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

# Pre-install warning
echo
echo "The installer is now ready to install ROS."
echo "Please ensure ~/.profile and ~/.rosconfig are configured correctly for your device before continuing."
echo
echo "If this is a Raspberry Pi, ROS must be installed from source. This will take a long time."
echo 
echo "The remainder of the script can be left unattended."
echo
read -r -p "Continue with install? (Y/N): " 
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit
fi

source "$HOME/.profile"

# Download and install ROS prerequisites
cd "$SCRIPT_DIR"
echo
echo "Downloading prerequisites..."
echo
chmod +x "./install-prerequisites.sh" && "./install-prerequisites.sh"

# ROSDEP
cd "$SCRIPT_DIR"
echo
echo "Initializing ROSDEP..."
echo
sudo rosdep init
chmod +x "./update-rosdep.sh" && "./update-rosdep.sh"

# Finally begin ROS install
# Raspberry Pi must be installed from source
# All other devices will attempt to use the package manager
if [[ "$IDENTITY" == *"raspi"* ]]; then
    CATKIN_WS="$DOWNLOAD_DIR/rosinstall_catkin_ws"
    echo
    echo "Creating ROS installation space in \"$CATKIN_WS\" ..."
    mkdir -p "$CATKIN_WS"
    cd "$CATKIN_WS"

    chmod +x "$SCRIPT_DIR/rosinstall-generator.sh" && "$SCRIPT_DIR/rosinstall-generator.sh" "$ROS_PACKAGES"

else
    echo
    echo "Attempting to download the following packages: "
    echo "$ROS_PACKAGES"
    echo
    sudo apt-get -y install $ROS_PACKAGES

fi

# Post-install tasks
echo
echo "ROS install script complete."
echo "Test ROS installation by running:"
echo "  source ~/.profile"
echo "roscore"
echo

cd "$WORKING_DIR"