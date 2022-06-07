#!/usr/bin/env bash

# REPO Should be 'focal' or 'buster'; 'bullseye' is not yet available.
# Check http://packages.ros.org/ros/ubuntu for updates.
REPO="$ROS_REPOSITORY"
KEYRING_FILE="/usr/share/keyrings/ros-keyring.gpg"

if [[ "$REPO" == "" ]]; then
    echo "ERROR: valid repo must be provided."
    echo "Please set environment variable ROS_REPOSITORY."
    exit 1
fi

sudo mkdir -p "$(dirname "$KEYRING_FILE")"

# Sometimes need to initialize gpg and dirmngr before installing the keyring
echo "Initializing GPG..."
sudo apt-get update
sudo apt-get -y install gpg dirmngr ca-certificates --install-recommends
#systemctl --user stop dirmngr.socket
systemctl --user start dirmngr.socket
if [ ! -d "/root/.gnupg" ]; then sudo gpg -k; fi

# Download ROS keyring
echo "Downloading ROS keyring..."
sudo gpg --no-default-keyring \
         --keyring "$KEYRING_FILE" \
         --keyserver hkp://keyserver.ubuntu.com:80 \
         --recv-keys C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
echo "Received file: $KEYRING_FILE"
file "$KEYRING_FILE"

# Convert to PGP/GPG type
# sudo gpg --no-default-keyring \
#         --keyring "/usr/share/keyrings/ros-keyring-original.gpg" \
#         --export \
#         --output "/usr/share/keyrings/ros-keyring.gpg"

# Create sources file so APT can see it
sudo rm /etc/apt/sources.list.d/ros*.list
echo "Installing ROS keyring..."
LINE="deb [signed-by=$KEYRING_FILE] $REPO"
FILE="/etc/apt/sources.list.d/ros-latest.list"
echo "$LINE" | sudo tee "$FILE" > /dev/null

# Download required stuff from APT
echo "Installing ROS prerequisites..."
sudo apt-get update
sudo apt-get install -y gcc g++ build-essential cmake \
                        python3 python3-pip python3-venv \
                        python3-rosdep python3-rosinstall python3-rosinstall-generator \
                        python3-vcstool python3-wstool python3-catkin-tools
sudo pip3 install setuptools==59.8.0

# Check python is python3
PYTHON_GOOD="false"
while [[ "$PYTHON_GOOD" != "true" ]]; do
    PYTHONVERSION=$(python --version)
    PIPVERSION=$(pip --version)

    echo
    echo "Default Python version:"
    echo "$PYTHONVERSION"
    echo
    echo "Default Pip version:"
    echo "$PIPVERSION"
    echo

    if [[ "$PYTHONVERSION" == *"Python 3"* && "$PIPVERSION" == *"python 3"* ]]; then
        echo "Python 3 detected as default Python."
        PYTHON_GOOD="true"
    else
        echo "ERROR: Incorrect Python or Pip version."
        echo "Setup cannot continue until 'python --version' and 'pip --version' both return Python 3 versions."
        echo "You may be able to fix this by running:"
        echo "sudo update-alternatives --install /usr/local/bin/python python /usr/bin/python3 80"
        echo
        read -r -p "Continue with install? (Y/N): " 
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
done
