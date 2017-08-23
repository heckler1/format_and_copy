# This script formats all removable drives attached to a system and 
# then copies a designated directory or file to the newly formatted drives

# Version 0.2

# Written by Stephen Heckler

# Variables
$disk_label = "TEST"
$source = "C:\Users\Stephen\Desktop\DVL.iso"

# Enumerates the USB drives on the system and gets their root
$drives = Get-WMIObject win32_volume | ? { $_.DriveType -eq 2 } | % { Get-PSDrive $_.DriveLetter[0] } | Format-List Root | Out-String

# Removes the title of the line
$drives = $drives -replace 'Root : ','' 

# Format list of drives
$list_drives = (-split $drives) -join " "

# Removes the ":\" after the drive letter
$drives = $drives -replace ':\\',''

# Creates a seperate list of drives for the Copy-Items command to work from
$copy_drives = $drives

# Converts the array of drives into a list of strings
$copy_drives = -split $copy_drives

# Places each drive letter on the same line
$format_drives = (-split $drives) -join ""

# Status message
echo "These are the drives that will be formatted:"

# Print list of drives to be formatted
echo $list_drives

# Defines Yes option
$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
    "Formats the listed removable drives."

# Defines No option
$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
    "Ends the program."

# Defines array of options
$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no) 

# Defines choice menu
$result = $host.ui.PromptForChoice("Format Drives","Do you want to format these drives?", $options, 1) #default option is No

switch ($result)
    {
        0 {
            # Status Message
            echo "`nBeginning formatting"

            # Formats the drives with the desired label
            Format-Volume -DriveLetter $format_drives -FileSystem FAT32 -NewFileSystemLabel $disk_label | Out-Null

            # Status message
            echo "Formatting complete`n"

            # Status message
            echo "Beginning file copy`n"

            # Copies files from the source to the drives in sequence
            #foreach ($drive in $copy_drives) {
            #    echo "Starting copy to $($drive):\"
            #    robocopy $source "$($drive):\" /e /eta /mt:2
            #    echo "Done copying to $($drive):\"
            #    }
            
            # Creates a workflow to copy files from the source to the drives in parellel
            workflow parellelcopy {
                param(
                    $source,
                    $copy_drives)

                foreach -parallel ($drive in $copy_drives) {
                    echo "Starting copy to $($drive):\"
                    robocopy $source "$($drive):\" /e /eta /fft
                    #Copy-Item $source -Destination "$($drive):\" -Recurse
                    echo "Done copying to $($drive):\"
                }
            }
            # Runs the above workflow, passing outside variables into the workflow
            parellelcopy -copy_drives $copy_drives -source $source

            # Status message
            echo "Copying Complete"
            pause
        }

        1 {
            # Goodbye.
            echo "Goodbye."
            pause
            
        }
    }

  
