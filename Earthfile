VERSION 0.7
# Use the official earthly image as the base image
FROM earthly/dind:latest

# Set the working directory
WORKDIR /workspace

update:
  RUN apk update
  RUN apk upgrade --available

# Clone the packer-builder-arm repository
git-clone:
  FROM +update
  GIT CLONE https://github.com/mkaczanowski/packer-builder-arm.git packer-builder-arm

# Build the packer-builder-arm plugin
build-plugin:
  FROM +git-clone
  RUN apk add go git gcc musl-dev
  WORKDIR /workspace/packer-builder-arm
  RUN go mod download
  RUN go build

# Run the Packer build process
run-packer:
  FROM +build-plugin
  ARG PACKER_FILE
  COPY ${PACKER_FILE} /workspace/packer-builder-arm/
  WORKDIR /workspace/packer-builder-arm
  # Install necessary utilities and Packer
  RUN apk add sgdisk sfdisk e2fsprogs e2fsprogs-extra parted qemu-img qemu-system-arm packer 
  # Register the packer-builder-arm plugin with Packer
  RUN packer init .
  # Run the Packer build to create the Raspberry Pi 3 Arch Linux ARM image
  RUN packer build ${PACKER_FILE}
  # Save the image so that we can use it.
  SAVE ARTIFACT raspberry-pi-3b.img AS LOCAL raspberry-pi-3b.img

run-packer-podman:
  FROM +update
  ARG PACKER_FILE
  COPY ${PACKER_FILE} /workspace
  WITH DOCKER --pull mkaczanowski/packer-builder-arm:latest
    RUN docker run \
      --rm \
      --privileged \
      -v /dev:/dev \
      -v /workspace:/workspace \
      -w /workspace \
      mkaczanowski/packer-builder-arm:latest build /workspace/${PACKER_FILE} -extra-system-packages=bmap-tools,zstd
  END
  SAVE ARTIFACT raspberry-pi-3b.img AS LOCAL raspberry-pi-3b.img
