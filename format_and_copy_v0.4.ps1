# This script formats all removable drives attached to a system and 
# then copies the contents of a designated directory to the newly formatted drives

# Version 0.4

# Written by Stephen Heckler

# Variables
$disk_label = ""
$source = ""

# Enumerates the removable drives attached to the system and gets their root
$drives = Get-WMIObject win32_volume | ? { $_.DriveType -eq 2 } | % { Get-PSDrive $_.DriveLetter[0] } | Format-List Root | Out-String

# Removes the title of the line
$drives = $drives -replace 'Root : ','' 

# Formats a list of drives
$list_drives = (-split $drives) -join " "

# Removes the ":\" after the drive letter
$drives = $drives -replace ':\\',''

# Converts the array of drives into a list of strings
$drives = -split $drives

# Print number of connected drives
$numberofdrives = $drives.Length
echo "There will be $numberofdrives drives formatted"

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
$result = $host.ui.PromptForChoice("Format Drives","Do you want to format these drives?", $options, 1) # Default option is No

switch ($result)
    {
        0 {
            # Status Message
            echo "`nBeginning formatting"
            
            foreach ($drive in $drives) {
                # Status message
                echo "Formatting $($drive):\"
                
                try {    
                    # Format the drive, stopping if there is an error
                    Format-Volume -DriveLetter $drive -FileSystem FAT32 -NewFileSystemLabel $disk_label -ErrorAction Stop
                }
                catch { # If the above command throws an error, do the actions below
                    # Status messages
                    echo "Formatting $($drive):\ failed"
                    echo "The program will now exit"
                    
                    # Wait for user acknowledgement
                    pause
                    
                    # End program
                    exit
                }
            }
            
            # Status message
            echo "Formatting complete`n"

            # Status message
            echo "Beginning file copy`n"
            
            # Creates a workflow to copy files from the source to the drives in parellel
            workflow parellelcopy {
                param(
                    $source,
                    $drives
                    )

                foreach -parallel ($drive in $drives) {
                    # Status message
                    echo "Starting copy to $($drive):\"
                    
                    # Runs file copy
                    robocopy $source "$($drive):\" /e /eta /fft # Robocopy will print status messages for every file copied
                    #Copy-Item $source -Destination "$($drive):\" -Recurse # Copy-Item prints no output
                    
                    # Status message
                    echo "Done copying to $($drive):\"
                }
            }

            # Runs the above workflow, passing outside variables into the workflow via parameters
            parellelcopy -drives $drives -source $source

            # Status message
            echo "Copying Complete"
            pause
        }

        1 {
            # Goodbye.
            echo "Goodbye."          
        }
    }

  
