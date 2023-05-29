#!/bin/env bash
set -Eeuxo pipefail
read -p "Enter your Windows username: " WINDOWS_USERNAME
if [ -d .vagrant ]; then
    echo "Removing .vagrant directory..."
    rm -rf .vagrant
fi
WINDOWS_PATH="/mnt/c/Users/$WINDOWS_USERNAME/Desktop/k8s-project/.vagrant"
echo "Copying .vagrant directory from Windows to Linux..."
cp -rv "$WINDOWS_PATH" ./
find .vagrant/ -type d -perm 777 -exec chmod 755 {} \;
find .vagrant/ -type f -print | xargs chmod 644
find .vagrant/ -type f -name private_key -print | xargs chmod 600
