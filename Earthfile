VERSION 0.7
FROM --platform=linux/arm/v7 alpine:latest
WORKDIR /build

start:
    RUN apk update
    RUN apk add wget

get-image:
    FROM +start
    # Download the latest Arch Linux ARM image
    RUN wget http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-armv7-latest.tar.gz
    SAVE ARTIFACT ArchLinuxARM-rpi-armv7-latest.tar.gz AS LOCAL output/ArchLinuxARM-rpi-armv7-latest.tar.gz

extract-image:
    COPY +get-image/ArchLinuxARM-rpi-armv7-latest.tar.gz .
    # Install necessary packages
    RUN apk add libarchive-tools

    # bsdtar is normally recommended, but spams errors
    # about extended attributes on alpine.
    RUN tar -xzf ArchLinuxARM-rpi-armv7-latest.tar.gz \
        && rm ArchLinuxARM-rpi-armv7-latest.tar.gz

prepare-root:
    FROM +extract-image
    # Prepare our customisation script
    COPY customise.sh /build/root/customise.sh
    RUN chmod +x /build/root/customise.sh

customise:
    FROM +prepare-root
    # Pass in customisation args
    ARG HOSTNAME
    ARG GITHUB_ACCESS_TOKEN
    ARG CUSTOM_USER
    ARG DISABLE_ROOT
    ARG REMOVE_ALARM

    # Move into the prepared environment, customise it, and exit
    RUN apk add arch-install-scripts
    RUN --privileged arch-chroot /build /bin/bash -c "HOSTNAME=$HOSTNAME \
        GITHUB_ACCESS_TOKEN=$GITHUB_ACCESS_TOKEN \
        ADD_USER=$ADD_USER \
        DISABLE_ROOT=$DISABLE_ROOT \
        REMOVE_ALARM=$REMOVE_ALARM \
        CUSTOM_USER=$CUSTOM_USER root/customise.sh;
        exit" 
        
pack:
    FROM +customise
    RUN dd if=/dev/zero of=arch-linux-pi.img bs=1M count=4096 && \
        mkfs.ext4 arch-linux-pi.img && \
        mkdir mnt && \
        mount -o loop arch-linux-pi.img mnt && \
        cp -a root/* mnt/ && \
        umount mnt

export:
    FROM +pack
    ARG HOSTNAME
    SAVE ARTIFACT arch-linux-pi.img AS LOCAL arch-linux-pi.img
