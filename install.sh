#!/usr/bin/env bash
WORKING_DIR="$PWD"
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
CONFIG_DIR="$SCRIPT_DIR/config"
PACKAGES_DIR="$SCRIPT_DIR/packages"
DOWNLOAD_DIR="$HOME/downloads"
if [ -d "$HOME/Downloads" ]; then DOWNLOAD_DIR="$HOME/Downloads"; fi

# Check for sudo
if [ "$EUID" -eq 0 ]; then
    echo "ERROR: Script cannot be run with sudo."
    echo "Please rerun script without root privileges."
    exit 1
fi

# Check package file is valid
PACKAGE_FILE="$1"
if [[ "$PACKAGE_FILE" == "" ]]; then
    echo "ERROR: Must provide a package file."
    echo "Package file must assign a space-separated list of ROS packages to the \$ROS_PACKAGES environment variable."
    echo "Packages will be installed using APT if possible, or from source if not."
    echo "You can use one of the following pre-configured package files, or create a new one:"
    echo "$PACKAGES_DIR/"
    ls "$PACKAGES_DIR"
    echo
    echo "Usage:"
    echo "  ./install.sh \"path/to/package_file\""
    exit 1
fi

source "$PACKAGE_FILE"

if [[ "$ROS_PACKAGES" == "" ]]; then
    echo "ERROR: Invalid package file \"$PACKAGE_FILE\""
    echo "Package file must assign a list of ROS packages to the \$ROS_PACKAGES environment variable."
    echo
    echo "Usage:"
    echo "  ./install.sh \"path/to/package_file\""
    exit 1
fi


# Get device identity
cd "$SCRIPT_DIR"
echo
echo "Checking device type..."
chmod +x "./identify-device.sh" && source "./identify-device.sh"
if [[ "$IDENTITY" == "" ]]; then
    echo "Device is not a supported type."
    exit 1
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
echo "Selected configuration file \"$CONFIG_FILE\" for this device."
echo
read -r -p "Overwrite ~/.rosconfig? (Y/N): " 
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    chmod +x "./install-config.sh" && "./install-config.sh" "$CONFIG_DIR/$CONFIG_FILE"
fi

# Pre-install warning
echo
echo "The installer is now ready to install ROS."
echo "Please ensure ~/.profile and ~/.rosconfig are configured correctly for your device before continuing."
echo
echo "The following ROS packages will be installed:"
echo "$ROS_PACKAGES"
echo
echo "If this is a Raspberry Pi, these packages must be installed from source. This will take a long time."
echo 
echo "The remainder of the script can be left unattended."
echo
read -r -p "Continue with install? (Y/N): " 
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
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
chmod +x "./rosdep-update.sh" && "./rosdep-update.sh"

# Finally begin ROS install
# Raspberry Pi must be installed from source
# All other devices will attempt to use the package manager
if [[ "$IDENTITY" == *"raspi"* ]]; then
    CATKIN_WS="$DOWNLOAD_DIR/rosinstall_catkin_ws"
    echo
    echo "Creating ROS installation space in \"$CATKIN_WS\" ..."
    echo
    mkdir -p "$CATKIN_WS"
    cd "$CATKIN_WS"

    # Make sure ROS_PACKAGES has spaces and not newlines
    ROS_PACKAGES="$(echo "$ROS_PACKAGES" | tr '\n' ' ')"

    chmod +x "$SCRIPT_DIR/rosinstall-generator.sh" && "$SCRIPT_DIR/rosinstall-generator.sh" "$ROS_PACKAGES"
    chmod +x "$SCRIPT_DIR/rosdep-install.sh" && "$SCRIPT_DIR/rosdep-install.sh"
    chmod +x "$SCRIPT_DIR/ros-build.sh" && "$SCRIPT_DIR/ros-build.sh"

else
    # Convert list of ROS packages to the equivalent APT packages
    chmod +x "$SCRIPT_DIR/ros-to-apt.sh" && APT_PACKAGES="$("$SCRIPT_DIR/ros-to-apt.sh" "$ROS_PACKAGES")"
    echo
    echo "Attempting to download the following APT packages: "
    echo "$APT_PACKAGES"
    echo
    sudo apt-get -y install --install-recommends $APT_PACKAGES

fi

# Post-install tasks
echo
echo "ROS install script complete."
echo "Test ROS installation by running:"
echo "  source ~/.profile"
echo "roscore"
echo

cd "$WORKING_DIR"