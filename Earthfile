# Earthfile

VERSION 0.7
FROM --platform=linux/arm/v7 alpine:latest
WORKDIR /build

start:
    RUN apk update
    RUN apk add wget

get-image:
    FROM +start
    RUN wget http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-armv7-latest.tar.gz
    SAVE ARTIFACT ArchLinuxARM-rpi-armv7-latest.tar.gz

prepare-disk:
    RUN apk add e2fsprogs
    RUN dd if=/dev/zero of=/arch-disk.img bs=1M count=4096
    RUN mkfs.ext4 /arch-disk.img
    RUN mkdir /mnt/disk
    RUN --privileged mount -o loop /arch-disk.img /mnt/disk
    COPY +get-image/ArchLinuxARM-rpi-armv7-latest.tar.gz .
    RUN tar -xzf ArchLinuxARM-rpi-armv7-latest.tar.gz -C /mnt/disk
    SAVE ARTIFACT /arch-disk.img


prepare-root:
    # Pass in customization args
    ARG HOSTNAME
    ARG GITHUB_ACCESS_TOKEN
    ARG CUSTOM_USER
    ARG INITIAL_PASSWORD
    ARG DISABLE_ROOT
    ARG REMOVE_ALARM
    ENV PARAMS="HOSTNAME GITHUB_ACCESS_TOKEN CUSTOM_USER INITIAL_PASSWORD DISABLE_ROOT REMOVE_ALARM"
    FROM +prepare-disk

    # Install jq for safer JSON handling
    RUN apk add jq

    # Dynamically generate the JSON file based on existing environment variables
    RUN JSON_OBJ="{}"; \
      ALL_VALID=true; \
      for var in $PARAMS; do \
          value=$(eval echo \$$var); \
          if [ -z "$value" ]; then \
              echo "Error: $var is not set"; \
              ALL_VALID=false; \
              break; \
          fi; \
          JSON_OBJ=$(echo $JSON_OBJ | jq --arg key $var --arg value "$value" '. + {($key): $value}'); \
      done; \
      \
      if [ "$ALL_VALID" = true ]; then \
          echo $JSON_OBJ > /mnt/disk/boot/setup_params.json; \
      else \
          echo "One or more required parameters are not set. Aborting."; \
          exit 1; \
      fi``

    # Copy the init script that will run on the first boot of the Raspberry Pi
    COPY init-once.sh /mnt/disk/root/init-once.sh
    RUN chmod +x /mnt/disk/root/init-once.sh
    RUN echo "/root/init-once.sh" >> /mnt/disk/etc/rc.local
    COPY automate.exp /mnt/disk/root/automate.exp
    RUN chmod +x /mnt/disk/root/automate.exp
    SAVE ARTIFACT /arch-disk.img AS LOCAL arch-disk.img

test:
    ARG CUSTOM_USER
    ARG INITIAL_PASSWORD 
    FROM debian:bullseye-slim
    COPY arch-disk.img .
    RUN apt-get update -y && apt-get install -y qemu-system-arm qemu-utils expect
    COPY automate.exp .
    RUN chmod +x automate.exp
    RUN expect automate.exp $CUSTOM_USER $INITIAL_PASSWORD || (echo "Expect script failed"; exit 1)