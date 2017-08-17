# This script formats all removable drives attached to a system,
# copies the specified files or directories to the newly formatted drives and installs syslinux
# This script requires admin rights to install syslinux and set the active partition

# Version 0.6

# Written by Stephen Heckler

# Check for Admin rights, if not Admin, spawn new elevated PowerShell shell
param([switch]$Elevated)

function CheckAdmin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

if ((CheckAdmin) -eq $false) {
    if ($elevated) {
    # could not elevate, quit
    } 
    else {
        Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
    }
    exit
}

# Variables
$disk_label = ""
$source = ""

# Enumerates the removable drives attached to the system and gets their root
$drives = Get-WMIObject win32_volume | ? { $_.DriveType -eq 2 } | % { Get-PSDrive $_.DriveLetter[0] } | Format-List Root | Out-String

# Removes the title of each line
$drives = $drives -replace 'Root : ','' 

# Formats a list of drives
$list_drives = (-split $drives) -join " "

# Removes the ":\" after the drive letter
$drives = $drives -replace ':\\',''

# Converts the array of drives into a list of strings - May not be necessary?
$drives = -split $drives

# Creates a workflow to format the drives in parallel
workflow ParallelFormat {
    param(
        $drives,
        $disk_label
    )
    $count = 0
    foreach -parallel -ThrottleLimit 23 ($drive in $drives) { # Runs up to 23 threads in parallel, due to drive letter limitations
        # Status message
        Write-Output "Formatted $($drive):\"
              
        try {    
            # Format the drive, throwing an error if the format fails
            InlineScript {Format-Volume -DriveLetter $Using:drive -FileSystem FAT32 -NewFileSystemLabel $Using:disk_label -ErrorAction Stop | Out-Null}
        }
        catch { # If the above command throws an error, do the actions below
            # Status message
            Write-Output "Formatting $($drive):\ failed"
                    
            # Sequence failed drive count
            $WORKFLOW:count++
        }
    }
    # Return the output of the workflow
    return $count
}

# Creates a function to install syslinux and set the primary partition as active
function MakeBootable {
    param(
        $drive
    )
    
    # Status message
    echo "Installing syslinux on drive $drive"

    # Run syslinux installer
    cmd /c "$($drive):\syslinux.exe --mbr --active --raid $($drive):"
    
    # Status message
    echo "Setting partition on $($drive):\ as active"

    # Set partition as active
    Set-Partition -DriveLetter $drive -IsActive 1         
}

# Creates a workflow to copy files from the source to the drives in parellel, then makes the drives bootable
workflow ParallelCopy {
    param(
        $source,
        $drives
    )
    
    foreach -parallel -ThrottleLimit 23 ($drive in $drives) { # Runs up to 23 threads in parallel, due to drive letter limitations
        # Status message
        echo "Starting copy to $($drive):\"
                    
        # Runs file copy
        #robocopy $source "$($drive):\" /e /eta /fft # Robocopy will print status messages for every file copied
        Copy-Item $source -Destination "$($drive):\" -Recurse -Force # Copy-Item prints no output, but can run more threads at a time
                    
        # Status message
        echo "Done copying to $($drive):\"
               
        # Runs function to install syslinux
        MakeBootable -drive $drive
    }
}

# Print number of connected drives
$numberofdrives = $drives.Length
echo "There will be $numberofdrives drive(s) formatted"

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
            echo "`nBeginning formatting`n"

            # Run the ParallelFormat workflow, passing outside variables into the workflow via parameters
            $format_output = ParallelFormat -drives $drives -disk_label $disk_label

            # Print format status messages
            echo $format_output[0..($format_output.Count - 2)]
            
            # Status message
            echo "Formatting complete"

            # If any drives failed to format, print an error and exit
            if ($format_output[-1] -gt 0) {
                # Status messages
                echo "`n$($format_output[-1]) drive(s) failed to format."
                echo "The program will now exit."
                    
                # Wait for user acknowledgement
                pause
                    
                # End program
                exit
            }
            
            # Status message
            echo "Beginning file copy`n"

            # Run the ParallelCopy workflow, passing outside variables into the workflow via parameters
            ParallelCopy -drives $drives -source $source

            # Status message
            echo "Copying Complete"

            pause

            exit
        }

        1 {
            # Goodbye.
            echo "Goodbye."

            exit
        }
    }

  
