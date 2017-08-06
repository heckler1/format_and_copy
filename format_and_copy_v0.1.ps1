# This script formats all removable drives attached to a system and 
# then copies a designated directory or file to the newly formatted drives

# Version 0.1

# Written by Stephen Heckler

# Variables
$disk_label = ""
$source = ""

# Enumerates the USB drives on the system and gets their root
$drives = Get-WMIObject win32_volume | ? { $_.DriveType -eq 2 } | % { Get-PSDrive $_.DriveLetter[0] } | Format-List Root | Out-String

# Removes the title of the line
$drives = $drives -replace 'Root : ','' 

# Removes the ":\" after the drive letter
$drives = $drives -replace ':\\',''

# Creates a seperate list of drives for the Copy-Items command to work from
$drive_list = $drives

# Converts the array of drives into a list of strings
$drive_list = -split $drive_list

# Places each drive letter on the same line
$drives = (-split $drives) -join ""

# Count the number of drives
$numberofdrives = $drives.Length

# Status message
echo "These are the drives that will be formatted:"

# Format list of drives
$drive_dryrun = (-split $drives) -join ","

# Print list of drives to be formatted
echo $drive_dryrun

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
            Format-Volume -DriveLetter $drives -FileSystem FAT32 -NewFileSystemLabel $disk_label | Out-Null

            # Status message
            echo "Formatting complete`n"

            # Status message
            echo "Beginning file copy`n"
			
            # Copies files from the source to the drives
            foreach ($drive in $drive_list) {
                Copy-Item $source -Destination "$($drive):\" -Recurse
            }

            # Status message
            echo "Copying Complete"
            pause
        }

        1 {
            echo "Goodbye."
            pause
            
        }
    }

  