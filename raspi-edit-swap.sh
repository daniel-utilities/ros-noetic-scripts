#!/usr/bin/env bash

echo
echo "Disabling swap..."
sudo dphys-swapfile swapoff
echo 
echo "Swap disabled."
echo
echo "Swap memory must now be manually configured in /etc/dphys-swapfile."
echo "In the file, please uncomment and set the following values:"
echo "  CONF_SWAPSIZE=2048"
echo "  CONF_MAXSWAP=2048"
echo
unset REPLY
while [[ ! $REPLY =~ ^[Yy]$ ]]; do 
    echo
    read -r -p "Continue to editor? (Y/N): " 
    if [[ $REPLY =~ ^[Yy]$ ]]; then sudo nano /etc/dphys-swapfile; fi
    echo
    read -r -p "Finished editing? (Y/N): " 
done
echo
echo "Rebuilding swap space..."
echo "This may take some time."
sudo dphys-swapfile setup
sudo dphys-swapfile swapon
