# Format and Copy
This is a PowerShell script, with a GUI, that eases bulk USB drive creation. It formats the removable drives attached to the system, using the disk label specified, and then copies the contents of a designated folder to the root of the USB drive.

Parellel formatting and parallel copying allow for a large speed improvement compared to other solutions that typically perform a sequential copy.

Be careful, this script will format ALL removable devices attached to the system.

The bootable variant installs the syslinux bootloader to the drive and sets the active flag on the primary partition, to make the drive bootable.

#### Configuration
Each button in the GUI is assigned a label and a function. Within each respective function the drive label and source folder are set as variables.
