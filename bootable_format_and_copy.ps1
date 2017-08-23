# This script formats all removable drives attached to a system
# and copies the specified files or directories to the newly formatted drives and installs syslinux.
# It displays a GUI that allows you to select what type of USB you want to create.
# The buttons can be edited within the USBForm function.
# The drive label and source directory can be specified within each button's respective function.
# This script requires admin rights to install syslinux and set the active partition

# Version 1.0

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

# Create GUI
function USBForm {
    # Create form
    Add-Type -AssemblyName System.Windows.Forms
    $form = New-Object Windows.Forms.Form
    $form.Size = New-Object Drawing.Size @(1015,588)
    $form.Icon = [system.drawing.icon]::ExtractAssociatedIcon($PSHOME + "\powershell.exe")
    $form.Location.X = 10
    $form.location.Y = 10
    $form.font = New-Object System.Drawing.Font("Geneva",13)
    $form.text = "Create USB"

    # Create Type 1 Button
    $button1 = New-Object System.Windows.Forms.Button
    $button1.Size = new-object System.Drawing.Size(150,100)
    $button1.Location = new-object System.Drawing.Size(25,50)
    $button1.add_click({CreateUSB1})
    $button1.Text = "Create Type 1 USBs"
    $form.Controls.Add($button1)
    
    # Create Type 2 Button
    $button2 = New-Object System.Windows.Forms.Button
    $button2.Size = new-object System.Drawing.Size(150,100)
    $button2.Location = new-object System.Drawing.Size(225,50)
    $button2.add_click({CreateUSB2})
    $button2.Text = "Create Type 2 USBs"
    $form.Controls.Add($button2)

    # Create Type 3 Button
    $button3 = New-Object System.Windows.Forms.Button
    $button3.Size = new-object System.Drawing.Size(150,100)
    $button3.Location = new-object System.Drawing.Size(425,50)
    $button3.add_click({CreateUSB3})
    $button3.Text = "Create Type 3 USBs"
    $form.Controls.Add($button3)
        
    # Create Type 4 Button
    $button4 = New-Object System.Windows.Forms.Button
    $button4.Size = new-object System.Drawing.Size(150,100)
    $button4.Location = new-object System.Drawing.Size(25,175)
    $button4.add_click({CreateUSB4})
    $button4.Text = "Create Type 4 USBs"
    $form.Controls.Add($button4)

    # Create Type 5 Button
    $button5 = New-Object System.Windows.Forms.Button
    $button5.Size = new-object System.Drawing.Size(150,100)
    $button5.Location = new-object System.Drawing.Size(225,175)
    $button5.add_click({CreateUSB5})
    $button5.Text = "Create Type 5 USBs"
    $form.Controls.Add($button5)

    # Create Type 6 Button
    $button6 = New-Object System.Windows.Forms.Button
    $button6.Size = new-object System.Drawing.Size(150,100)
    $button6.Location = new-object System.Drawing.Size(425,175)
    $button6.add_click({CreateUSB6})
    $button6.Text = "Create Type 6 USBs"
    $form.Controls.Add($button6)

    # Create output message box
    $messagebox = New-Object System.Windows.Forms.RichTextBox
    $messagebox.Size = New-Object System.Drawing.Size(400,550)
    $messagebox.Location = New-Object System.Drawing.Size(600,0)
    $messagebox.Font = New-Object System.Drawing.Font("lucida console",10)
    $messagebox.ReadOnly = $true
    $messagebox.BackColor = [Drawing.Color]::fromARGB(1,36,86)
    $messagebox.ForeColor = [Drawing.Color]::White
    $form.Controls.Add($messagebox)

    # Display the form
    $Form.ShowDialog() 
}

# Create Type 1 USBs
function CreateUSB1 {

# Initialize variables
$disk_label = ""
$source = ""

# Create the drives
CreateUSB -disk_label $disk_label -source $source 

}

# Create Type 2 USBs
function CreateUSB2 {

# Initialize variables
$disk_label = ""
$source = ""

# Create the drives
CreateUSB -disk_label $disk_label -source $source 

}

# Create Type 3 USBs
function CreateUSB3 {

# Initialize variables
$disk_label = ""
$source = ""

# Create the drives
CreateUSB -disk_label $disk_label -source $source 

}

# Create Type 4 USBs
function CreateUSB4 {

# Initialize variables
$disk_label = ""
$source = ""

# Create the drives
CreateUSB -disk_label $disk_label -source $source 

}

# Create Type 5 USBs
function CreateUSB5 {

# Initialize variables
$disk_label = ""
$source = ""

# Create the drives
CreateUSB -disk_label $disk_label -source $source 

}

# Create Type 6 USBs
function CreateUSB6 {

# Initialize variables
$disk_label = ""
$source = ""

# Create the drives
CreateUSB -disk_label $disk_label -source $source 

}

# Function to enumerate, format, and print a list of removable devices attached to the system
function GetDrives {
    # Enumerates the removable drives attached to the system and gets their root
    $script:drives = Get-WMIObject win32_volume | ? { $_.DriveType -eq 2 } | % { Get-PSDrive $_.DriveLetter[0] } | Format-List Root | Out-String

    # Removes the title of each line
    $script:drives = $script:drives -replace 'Root : ','' 

    # Formats a list of drives
    $list_drives = (-split $script:drives) -join " "

    # Removes the ":\" after the drive letter
    $script:drives = $script:drives -replace ':\\',''

    # Converts the array of drives into a list of strings - May not be necessary?
    $script:drives = -split $script:drives

    # Print number of connected drives
    $numberofdrives = $script:drives.Length
    echo "There will be $numberofdrives drive(s) formatted`n"

    # Status message
    echo "These are the drives that will be formatted:`n"

    # Print list of drives to be formatted
    echo $list_drives
}

# Function to create USB drives, and check for any formatting errors
function CreateUSB {
    param(
        $disk_label,
        $source
    )

    # Enumerate list of drives
    $GetDrivesOutput = GetDrives

    # Create message box
    Add-Type -AssemblyName System.Windows.Forms

    # Show message box
    $result = [System.Windows.Forms.MessageBox]::Show($GetDrivesOutput, 'Warning', 'YesNo', 'Warning')

    # Check the result:
    if ($result -eq 'Yes') {
        # Status Message
        $messagebox.Text += "`nBeginning formatting`n"

        # Run the ParallelFormat workflow, passing outside variables into the workflow via parameters
        $format_output = ParallelFormat -drives $drives -disk_label $disk_label

        # Print format status messages
        $messagebox.Text += $format_output[0..($format_output.Count - 2)]

        # Status message
        $messagebox.Text += "Formatting complete`n`n"

        # If any drives failed to format, display an error and stop
        if ($format_output[-1] -gt 0) {
            #Create message box
            Add-Type -AssemblyName System.Windows.Forms

            # Assemble the complete error message
            $errormessage = "$($format_output[-1]) drive(s) failed to format.`nThe program will now stop."

            # Show message box
            $result = [System.Windows.Forms.MessageBox]::Show($errormessage, 'Format Failed', 'OK', 'Error')

            # Stop
            return
        }
            
        # Status message
        $messagebox.Text += "Beginning file copy"

        # Run the ParallelCopy workflow, passing outside variables into the workflow via parameters
        # Streams all output, as it happens, to the message box
        ParallelCopy -drives $drives -source $source | Out-String -Stream | ForEach-Object {
            $messagebox.lines = $messagebox.lines + $_
            $messagebox.Select($messagebox.Text.Length, 0)
            $messagebox.ScrollToCaret()
            $form.Update()
        }
    
        # Status message
        $messagebox.Text += "`nCopying Complete`n`nYou may now exit the program or start a new batch of drives."
    }
}

# Workflow to format the drives in parallel
workflow ParallelFormat {
    param(
        $drives,
        $disk_label
    )
    
    # Initialize number of format errors
    $count = 0

    foreach -parallel -ThrottleLimit 23 ($drive in $drives) { # Runs up to 23 threads in parallel, due to drive letter limitations
        try {    
            # Format the drive, throwing an error if the format fails
            InlineScript {Format-Volume -DriveLetter $Using:drive -FileSystem FAT32 -NewFileSystemLabel $Using:disk_label -ErrorAction Stop | Out-Null}
            # Status message
            Write-Output "Formatted $($drive):\`r`n"
        }
        catch {
            # Status message
            Write-Output "Formatting $($drive):\ failed`n"
                    
            # Sequence failed drive count
            $WORKFLOW:count++
        }

    }
    # Return the output of the workflow
    return $count
}

# Function to install syslinux and set the primary partition as active
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

# Workflow to copy files from the source to the drives in parellel
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
        Copy-Item $source -Destination "$($drive):\" -Recurse -Force # Copy-Item prints no output, but can run more parallel threads

        # Status message
        echo "Done copying to $($drive):\"

        # Make drive bootable
        MakeBootable -drive $drive
    }
}

USBForm