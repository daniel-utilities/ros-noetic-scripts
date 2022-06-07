#!/usr/bin/env bash

echo
echo "WARNING:"
echo "The system will reboot after updating the Raspberry Pi EEPROM."
echo
read -r -p "Continue with EEPROM update and reboot? (Y/N): " 
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit
fi
echo "Updating EEPROM..."
sudo rpi-eeprom-update
sudo rpi-eeprom-update -a
sudo shutdown -r now