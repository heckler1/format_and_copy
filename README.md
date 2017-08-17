This is a PowerShell script designed to automate bulk USB drive creation. It formats the removable drives attached to the system
with the disk label specified, and then copies the contents of a designated folder to the root of the USB drive. 
Parellel formatting and copying allows for a large speed improvement compared to other solutions that typically perform a sequential copy.

Be careful, this script will format ALL removable devices attached to the system.

The bootable variant installs the syslinux bootloader to the drive and sets the active flag on the primary partition.