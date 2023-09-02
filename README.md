# earthly-raspi-packer
Take the pain out of bootstrapping Arch Linux ARM on Raspberry Pi.

This is an [Earthly](https://earthly.dev/faq) pipeline that:
- Spins up an Alpine VM
- Downloads and extracts the Arch Linux ARM rootfs
- Creates a disk image
- Creates a file system and mounts it
- Copies the operating system and bootloader into the image
- Creates an image that can be written to an SD card

Further to this, a script is added that allows for further customisation as part of the first boot:
- Importing SSH keys from Github (using a personal access token and the Github API)
- Creating a custom user account
- Disabling the `alarm` user
- Setting an initial password
- Initialising the Pacman keyring
- Bringing software up to date
- Installing an AUR package manager

# Why?
If you have a Linux box already (WSL is fine), sure you can follow the [ten step caveated process](https://archlinuxarm.org/platforms/armv8/broadcom/raspberry-pi-4).
But, then you have to: 
- dissassemble your device, since if you're me you have it in a case with a screen.
- use your arthritic fingers that don't want to cooperate to get the tiny SD card out.
- Burn the image on to the card (don't forget to check it!)
- Get it back into the hardware and reassemble
- Boot, set *everything* up again and hope you don't get yourself into a mess.

Repeat ad-infinitum every time you make a mistake, want to try something else... what a pain.
I am of course aware that solutions such as USB-booting, backups, and SSH exist so you can ease some of this. 
I think computers ought to be nicer than that, even for "technical people" who choose Arch.

# This is a solved problem
I tried a few other alternatives, but they didn't fit my needs or had attributes I didn't 
like much. That's okay - why not teach myself something? 

In addition, it would be nice if I could have everything configured just the way I want 
from the get go and be able to smoke test the basics without needing actual hardware.

It's nowhere near production-ready and just scratches my own itch. Caveat emptor!
