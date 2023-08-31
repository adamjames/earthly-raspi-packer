#!/bin/bash

# init-once.sh: This script will run on the first boot of the Raspberry Pi.

# Function to add GitHub keys
add_github_keys() {
    local user_home=$1
    local github_token=$2
    if [ -z "$github_token" ]; then
        echo "No Github token provided."
        return
    fi

    KEYS=$(curl -H "Authorization: token $github_token" -s https://api.github.com/user/keys)
    SSH_KEYS=$(echo "$KEYS" | jq -r '.[].key')
    if [ ! -z "$SSH_KEYS" ]; then
        echo "$SSH_KEYS" >> "${user_home}/.ssh/authorized_keys"
        sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
    else
        echo "No valid SSH keys found for the provided GitHub token!"
    fi
}

# Get parameters from special files
if [ -f "/boot/setup_params.json" ]; then
    SETUP_PARAMS=$(cat /boot/setup_params.json)
    HOSTNAME=$(echo "$SETUP_PARAMS" | jq -r '.hostname')
    GITHUB_ACCESS_TOKEN=$(echo "$SETUP_PARAMS" | jq -r '.github_access_token')
    CUSTOM_USER=$(echo "$SETUP_PARAMS" | jq -r '.custom_user')
    DISABLE_ROOT=$(echo "$SETUP_PARAMS" | jq -r '.disable_root')
    REMOVE_ALARM=$(echo "$SETUP_PARAMS" | jq -r '.remove_alarm')
fi

# Set the hostname
if [ -n "$HOSTNAME" ]; then
    echo $HOSTNAME > /etc/hostname
fi

# Install necessary tools
pacman -Syu curl jq sudo base-devel git --noconfirm

# Initialize the pacman keyring
pacman-key --init
pacman-key --populate archlinuxarm

# Update all packages
pacman -Syu --noconfirm

# Compile and install Paru
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si --noconfirm
cd ..
rm -rf paru

# User-specific customizations
if [ "$DISABLE_ROOT" == "true" ]; then
    passwd -l root
fi

if [ "$REMOVE_ALARM" == "true" ]; then
    userdel -r alarm
fi

if [ -n "$CUSTOM_USER" ]; then
    useradd -m $CUSTOM_USER
    echo "$CUSTOM_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$CUSTOM_USER
    mkdir -p /home/$CUSTOM_USER/.ssh
    chown $CUSTOM_USER:$CUSTOM_USER /home/$CUSTOM_USER/.ssh
    add_github_keys "/home/$CUSTOM_USER" "$GITHUB_ACCESS_TOKEN"
else
    add_github_keys "/home/alarm" "$GITHUB_ACCESS_TOKEN"
f

if [ -n "$CUSTOM_USER" && -n "$INITIAL_PASSWORD" ]; then
    echo '$CUSTOM_USER:$INITIAL_PASSWORD' | sudo chpasswd
fi


# Disable this script from running again
sed -i '/\/root\/init-once.sh/d' /etc/rc.local

# Remove the setup parameters to prevent re-customization
rm -f /boot/setup_params.json
