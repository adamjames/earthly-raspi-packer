#!/bin/bash

add_github_keys() {
    if [ -z "$GITHUB_ACCESS_TOKEN" ]; then
        echo "No Github token provided."
        return
    fi

    KEYS=$(curl -H "Authorization: token $GITHUB_ACCESS_TOKEN" -s -w "\n%{http_code}" https://api.github.com/user/keys)
    STATUS="${KEYS: -3}"  # Extract the last 3 characters, which is the HTTP status code
    if [ "$STATUS" -eq 200 ]; then
        SSH_KEYS=$(echo "$KEYS" | jq -r '.[].key')
        if [ ! -z "$SSH_KEYS" ]; then
            echo "$SSH_KEYS" >> "$1"
            # Disable password authentication over SSH
            sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
        else
            echo "No valid SSH keys found for the provided GitHub token!"
        fi
    else
        echo "Invalid Github token or another error occurred!"
    fi
}

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
    # Add passwordless sudo
    echo "$CUSTOM_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$CUSTOM_USER
    
    # Import Github keys
    mkdir -p /home/$CUSTOM_USER/.ssh
    chown $CUSTOM_USER:$CUSTOM_USER /home/$CUSTOM_USER/.ssh
    
    add_github_keys /home/$CUSTOM_USER/.ssh/authorized_keys
else
    add_github_keys /home/alarm/.ssh/authorized_keys
fi
