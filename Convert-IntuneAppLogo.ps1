<#
.SYNOPSIS
    Intune App Logo Converter - Convert images to the correct size for Intune Company Portal apps.

.DESCRIPTION
    This tool provides a GUI to convert images to 256x256 pixels PNG format, which is the
    recommended size for Microsoft Intune Company Portal app icons.

    Features:
    - Drag and drop images or browse for files
    - Three resize modes: Fit (with padding), Stretch, or Crop
    - Preview before and after conversion
    - Maintains transparency for PNG images
    - Customizable background color for padding

.NOTES
    Author: Intune Logo Converter Tool
    Version: 1.0
    Requirements: Windows PowerShell 5.1 or later
#>

# Load required assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Global variables
$script:OriginalImage = $null
$script:ConvertedImage = $null
$script:SourceFilePath = ""
$script:BackgroundColor = [System.Drawing.Color]::Transparent
$script:OutputFolder = ""

#region Functions

function Load-ImageFile {
    param (
        [string]$FilePath
    )

    try {
        # Validate file exists
        if (-not (Test-Path -Path $FilePath)) {
            [System.Windows.Forms.MessageBox]::Show("File not found: $FilePath", "Error",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Error)
            return $false
        }

        # Validate file extension
        $validExtensions = @('.png', '.jpg', '.jpeg', '.bmp', '.gif')
        $extension = [System.IO.Path]::GetExtension($FilePath).ToLower()
        if ($extension -notin $validExtensions) {
            [System.Windows.Forms.MessageBox]::Show("Invalid file format. Please select a PNG, JPG, BMP, or GIF image.", "Error",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Error)
            return $false
        }

        # Dispose of previous image if exists
        if ($script:OriginalImage) {
            $script:OriginalImage.Dispose()
        }

        # Load the image
        $script:OriginalImage = [System.Drawing.Image]::FromFile($FilePath)
        $script:SourceFilePath = $FilePath

        # Update preview
        $originalPictureBox.Image = $script:OriginalImage
        $originalDimensionsLabel.Text = "Original: $($script:OriginalImage.Width) x $($script:OriginalImage.Height) px"

        # Clear converted image
        $convertedPictureBox.Image = $null
        $convertedDimensionsLabel.Text = "Converted: N/A"
        $script:ConvertedImage = $null

        # Enable convert button
        $convertButton.Enabled = $true
        $saveButton.Enabled = $false

        # Update status
        $statusLabel.Text = "Image loaded successfully"
        $statusLabel.ForeColor = [System.Drawing.Color]::Green

        return $true
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show("Error loading image: $($_.Exception.Message)", "Error",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error)
        return $false
    }
}

function Convert-ImageToIntuneSize {
    param (
        [System.Drawing.Image]$SourceImage,
        [string]$ResizeMethod,
        [System.Drawing.Color]$BgColor
    )

    try {
        $targetSize = 256
        $bitmap = New-Object System.Drawing.Bitmap($targetSize, $targetSize)
        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)

        # Set high quality rendering
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
        $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality

        # Clear with background color
        $graphics.Clear($BgColor)

        $sourceWidth = $SourceImage.Width
        $sourceHeight = $SourceImage.Height

        switch ($ResizeMethod) {
            "Fit" {
                # Maintain aspect ratio, fit within 256x256
                $scale = [Math]::Min($targetSize / $sourceWidth, $targetSize / $sourceHeight)
                $newWidth = [int]($sourceWidth * $scale)
                $newHeight = [int]($sourceHeight * $scale)

                # Center the image
                $x = [int](($targetSize - $newWidth) / 2)
                $y = [int](($targetSize - $newHeight) / 2)

                $destRect = New-Object System.Drawing.Rectangle($x, $y, $newWidth, $newHeight)
                $srcRect = New-Object System.Drawing.Rectangle(0, 0, $sourceWidth, $sourceHeight)

                $graphics.DrawImage($SourceImage, $destRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)
            }

            "Stretch" {
                # Stretch to fill entire 256x256
                $destRect = New-Object System.Drawing.Rectangle(0, 0, $targetSize, $targetSize)
                $srcRect = New-Object System.Drawing.Rectangle(0, 0, $sourceWidth, $sourceHeight)

                $graphics.DrawImage($SourceImage, $destRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)
            }

            "Crop" {
                # Scale to cover 256x256, crop from center
                $scale = [Math]::Max($targetSize / $sourceWidth, $targetSize / $sourceHeight)
                $scaledWidth = [int]($sourceWidth * $scale)
                $scaledHeight = [int]($sourceHeight * $scale)

                # Calculate crop offset
                $offsetX = [int](($scaledWidth - $targetSize) / 2)
                $offsetY = [int](($scaledHeight - $targetSize) / 2)

                # Calculate source rectangle for center crop
                $srcX = [int]($offsetX / $scale)
                $srcY = [int]($offsetY / $scale)
                $srcWidth = [int]($targetSize / $scale)
                $srcHeight = [int]($targetSize / $scale)

                $destRect = New-Object System.Drawing.Rectangle(0, 0, $targetSize, $targetSize)
                $srcRect = New-Object System.Drawing.Rectangle($srcX, $srcY, $srcWidth, $srcHeight)

                $graphics.DrawImage($SourceImage, $destRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)
            }
        }

        $graphics.Dispose()

        return $bitmap
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show("Error converting image: $($_.Exception.Message)", "Error",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error)
        return $null
    }
}

function Save-ConvertedImage {
    param (
        [System.Drawing.Image]$Image,
        [string]$SavePath
    )

    try {
        # Ensure directory exists
        $directory = [System.IO.Path]::GetDirectoryName($SavePath)
        if (-not (Test-Path -Path $directory)) {
            New-Item -Path $directory -ItemType Directory -Force | Out-Null
        }

        # Save as PNG
        $Image.Save($SavePath, [System.Drawing.Imaging.ImageFormat]::Png)

        # Update status
        $statusLabel.Text = "Image saved successfully: $SavePath"
        $statusLabel.ForeColor = [System.Drawing.Color]::Green

        [System.Windows.Forms.MessageBox]::Show("Image saved successfully!`n`n$SavePath", "Success",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information)

        return $true
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show("Error saving image: $($_.Exception.Message)", "Error",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error)
        return $false
    }
}

function Set-OutputFolder {
    try {
        $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
        $folderBrowser.Description = "Select or create a folder for saving converted Intune logos"
        $folderBrowser.ShowNewFolderButton = $true

        # Set initial directory to Documents if output folder not set
        if ([string]::IsNullOrEmpty($script:OutputFolder)) {
            $documentsPath = [Environment]::GetFolderPath("MyDocuments")
            $suggestedFolder = Join-Path -Path $documentsPath -ChildPath "Intune-App-Icons"

            # Offer to create the suggested folder
            $result = [System.Windows.Forms.MessageBox]::Show(
                "Would you like to create a dedicated folder for Intune logos?`n`nSuggested location:`n$suggestedFolder`n`nClick 'Yes' to use this folder, or 'No' to choose a different location.",
                "Create Output Folder",
                [System.Windows.Forms.MessageBoxButtons]::YesNoCancel,
                [System.Windows.Forms.MessageBoxIcon]::Question
            )

            if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
                # Create and use the suggested folder
                if (-not (Test-Path -Path $suggestedFolder)) {
                    New-Item -Path $suggestedFolder -ItemType Directory -Force | Out-Null
                }
                $script:OutputFolder = $suggestedFolder
                $outputFolderLabel.Text = "Output: $script:OutputFolder"
                $statusLabel.Text = "Output folder set: $script:OutputFolder"
                $statusLabel.ForeColor = [System.Drawing.Color]::Green
                return $true
            }
            elseif ($result -eq [System.Windows.Forms.DialogResult]::Cancel) {
                return $false
            }
            # If No, continue to show folder browser
        }
        else {
            $folderBrowser.SelectedPath = $script:OutputFolder
        }

        # Show folder browser dialog
        if ($folderBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $script:OutputFolder = $folderBrowser.SelectedPath
            $outputFolderLabel.Text = "Output: $script:OutputFolder"
            $statusLabel.Text = "Output folder set: $script:OutputFolder"
            $statusLabel.ForeColor = [System.Drawing.Color]::Green
            return $true
        }

        return $false
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show("Error setting output folder: $($_.Exception.Message)", "Error",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error)
        return $false
    }
}

function Open-IntunePortal {
    try {
        $intuneUrl = "https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/AppsMenu/~/overview"
        Start-Process $intuneUrl
        $statusLabel.Text = "Opening Intune Apps in your default browser..."
        $statusLabel.ForeColor = [System.Drawing.Color]::Blue
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show("Error opening Intune Portal: $($_.Exception.Message)", "Error",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error)
    }
}

#endregion

#region GUI Setup

# Create main form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Intune App Logo Converter"
$form.Size = New-Object System.Drawing.Size(650, 720)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
$form.MaximizeBox = $false

# Title Label
$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Location = New-Object System.Drawing.Point(20, 20)
$titleLabel.Size = New-Object System.Drawing.Size(600, 30)
$titleLabel.Text = "Convert images to 256x256 PNG for Intune Company Portal"
$titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($titleLabel)

# Drag-Drop Zone Panel
$dropPanel = New-Object System.Windows.Forms.Panel
$dropPanel.Location = New-Object System.Drawing.Point(20, 60)
$dropPanel.Size = New-Object System.Drawing.Size(600, 80)
$dropPanel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$dropPanel.BackColor = [System.Drawing.Color]::WhiteSmoke
$dropPanel.AllowDrop = $true
$form.Controls.Add($dropPanel)

# Drop Zone Label
$dropLabel = New-Object System.Windows.Forms.Label
$dropLabel.Location = New-Object System.Drawing.Point(10, 10)
$dropLabel.Size = New-Object System.Drawing.Size(580, 60)
$dropLabel.Text = "Drag and drop an image here`n(PNG, JPG, BMP, GIF)"
$dropLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$dropLabel.Font = New-Object System.Drawing.Font("Segoe UI", 11)
$dropLabel.ForeColor = [System.Drawing.Color]::Gray
$dropLabel.AllowDrop = $true
$dropPanel.Controls.Add($dropLabel)

# Browse Button
$browseButton = New-Object System.Windows.Forms.Button
$browseButton.Location = New-Object System.Drawing.Point(20, 150)
$browseButton.Size = New-Object System.Drawing.Size(120, 30)
$browseButton.Text = "Browse..."
$browseButton.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$form.Controls.Add($browseButton)

# Preview Section Label
$previewLabel = New-Object System.Windows.Forms.Label
$previewLabel.Location = New-Object System.Drawing.Point(20, 190)
$previewLabel.Size = New-Object System.Drawing.Size(200, 25)
$previewLabel.Text = "Preview:"
$previewLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($previewLabel)

# Original Image Panel
$originalPanel = New-Object System.Windows.Forms.Panel
$originalPanel.Location = New-Object System.Drawing.Point(20, 220)
$originalPanel.Size = New-Object System.Drawing.Size(280, 240)
$originalPanel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$form.Controls.Add($originalPanel)

# Original Label
$originalLabel = New-Object System.Windows.Forms.Label
$originalLabel.Location = New-Object System.Drawing.Point(5, 5)
$originalLabel.Size = New-Object System.Drawing.Size(270, 20)
$originalLabel.Text = "Original"
$originalLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$originalPanel.Controls.Add($originalLabel)

# Original PictureBox
$originalPictureBox = New-Object System.Windows.Forms.PictureBox
$originalPictureBox.Location = New-Object System.Drawing.Point(10, 30)
$originalPictureBox.Size = New-Object System.Drawing.Size(256, 180)
$originalPictureBox.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::Zoom
$originalPictureBox.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$originalPanel.Controls.Add($originalPictureBox)

# Original Dimensions Label
$originalDimensionsLabel = New-Object System.Windows.Forms.Label
$originalDimensionsLabel.Location = New-Object System.Drawing.Point(10, 215)
$originalDimensionsLabel.Size = New-Object System.Drawing.Size(260, 20)
$originalDimensionsLabel.Text = "Original: N/A"
$originalDimensionsLabel.Font = New-Object System.Drawing.Font("Segoe UI", 8)
$originalPanel.Controls.Add($originalDimensionsLabel)

# Converted Image Panel
$convertedPanel = New-Object System.Windows.Forms.Panel
$convertedPanel.Location = New-Object System.Drawing.Point(330, 220)
$convertedPanel.Size = New-Object System.Drawing.Size(280, 240)
$convertedPanel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$form.Controls.Add($convertedPanel)

# Converted Label
$convertedLabel = New-Object System.Windows.Forms.Label
$convertedLabel.Location = New-Object System.Drawing.Point(5, 5)
$convertedLabel.Size = New-Object System.Drawing.Size(270, 20)
$convertedLabel.Text = "Converted (256x256)"
$convertedLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$convertedPanel.Controls.Add($convertedLabel)

# Converted PictureBox
$convertedPictureBox = New-Object System.Windows.Forms.PictureBox
$convertedPictureBox.Location = New-Object System.Drawing.Point(10, 30)
$convertedPictureBox.Size = New-Object System.Drawing.Size(256, 180)
$convertedPictureBox.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::Zoom
$convertedPictureBox.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$convertedPanel.Controls.Add($convertedPictureBox)

# Converted Dimensions Label
$convertedDimensionsLabel = New-Object System.Windows.Forms.Label
$convertedDimensionsLabel.Location = New-Object System.Drawing.Point(10, 215)
$convertedDimensionsLabel.Size = New-Object System.Drawing.Size(260, 20)
$convertedDimensionsLabel.Text = "Converted: N/A"
$convertedDimensionsLabel.Font = New-Object System.Drawing.Font("Segoe UI", 8)
$convertedPanel.Controls.Add($convertedDimensionsLabel)

# Options Group Box
$optionsGroupBox = New-Object System.Windows.Forms.GroupBox
$optionsGroupBox.Location = New-Object System.Drawing.Point(20, 470)
$optionsGroupBox.Size = New-Object System.Drawing.Size(590, 110)
$optionsGroupBox.Text = "Conversion Options"
$optionsGroupBox.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($optionsGroupBox)

# Resize Method Label
$resizeMethodLabel = New-Object System.Windows.Forms.Label
$resizeMethodLabel.Location = New-Object System.Drawing.Point(15, 25)
$resizeMethodLabel.Size = New-Object System.Drawing.Size(120, 20)
$resizeMethodLabel.Text = "Resize Method:"
$resizeMethodLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$optionsGroupBox.Controls.Add($resizeMethodLabel)

# Fit Radio Button
$fitRadioButton = New-Object System.Windows.Forms.RadioButton
$fitRadioButton.Location = New-Object System.Drawing.Point(15, 50)
$fitRadioButton.Size = New-Object System.Drawing.Size(250, 20)
$fitRadioButton.Text = "Fit (maintain aspect ratio with padding)"
$fitRadioButton.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$fitRadioButton.Checked = $true
$optionsGroupBox.Controls.Add($fitRadioButton)

# Stretch Radio Button
$stretchRadioButton = New-Object System.Windows.Forms.RadioButton
$stretchRadioButton.Location = New-Object System.Drawing.Point(280, 50)
$stretchRadioButton.Size = New-Object System.Drawing.Size(150, 20)
$stretchRadioButton.Text = "Stretch to fill"
$stretchRadioButton.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$optionsGroupBox.Controls.Add($stretchRadioButton)

# Crop Radio Button
$cropRadioButton = New-Object System.Windows.Forms.RadioButton
$cropRadioButton.Location = New-Object System.Drawing.Point(450, 50)
$cropRadioButton.Size = New-Object System.Drawing.Size(130, 20)
$cropRadioButton.Text = "Crop to fill"
$cropRadioButton.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$optionsGroupBox.Controls.Add($cropRadioButton)

# Background Color Label
$bgColorLabel = New-Object System.Windows.Forms.Label
$bgColorLabel.Location = New-Object System.Drawing.Point(15, 80)
$bgColorLabel.Size = New-Object System.Drawing.Size(150, 20)
$bgColorLabel.Text = "Background Color (Fit):"
$bgColorLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$optionsGroupBox.Controls.Add($bgColorLabel)

# Background Color Button
$bgColorButton = New-Object System.Windows.Forms.Button
$bgColorButton.Location = New-Object System.Drawing.Point(180, 75)
$bgColorButton.Size = New-Object System.Drawing.Size(120, 25)
$bgColorButton.Text = "Transparent"
$bgColorButton.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$optionsGroupBox.Controls.Add($bgColorButton)

# Convert Button
$convertButton = New-Object System.Windows.Forms.Button
$convertButton.Location = New-Object System.Drawing.Point(20, 595)
$convertButton.Size = New-Object System.Drawing.Size(120, 35)
$convertButton.Text = "Convert"
$convertButton.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$convertButton.Enabled = $false
$form.Controls.Add($convertButton)

# Save Button
$saveButton = New-Object System.Windows.Forms.Button
$saveButton.Location = New-Object System.Drawing.Point(150, 595)
$saveButton.Size = New-Object System.Drawing.Size(120, 35)
$saveButton.Text = "Save As..."
$saveButton.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$saveButton.Enabled = $false
$form.Controls.Add($saveButton)

# Set Output Folder Button
$setOutputFolderButton = New-Object System.Windows.Forms.Button
$setOutputFolderButton.Location = New-Object System.Drawing.Point(280, 595)
$setOutputFolderButton.Size = New-Object System.Drawing.Size(150, 35)
$setOutputFolderButton.Text = "Set Output Folder"
$setOutputFolderButton.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$form.Controls.Add($setOutputFolderButton)

# Output Folder Label
$outputFolderLabel = New-Object System.Windows.Forms.Label
$outputFolderLabel.Location = New-Object System.Drawing.Point(440, 595)
$outputFolderLabel.Size = New-Object System.Drawing.Size(180, 35)
$outputFolderLabel.Text = "Output: Not Set"
$outputFolderLabel.Font = New-Object System.Drawing.Font("Segoe UI", 8)
$outputFolderLabel.ForeColor = [System.Drawing.Color]::Gray
$outputFolderLabel.AutoEllipsis = $true
$form.Controls.Add($outputFolderLabel)

# Status Label
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Location = New-Object System.Drawing.Point(20, 640)
$statusLabel.Size = New-Object System.Drawing.Size(450, 25)
$statusLabel.Text = "Ready. Load an image to begin."
$statusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$statusLabel.ForeColor = [System.Drawing.Color]::Blue
$form.Controls.Add($statusLabel)

# Open Intune Portal Button
$openIntuneButton = New-Object System.Windows.Forms.Button
$openIntuneButton.Location = New-Object System.Drawing.Point(480, 637)
$openIntuneButton.Size = New-Object System.Drawing.Size(140, 30)
$openIntuneButton.Text = "Open Intune Portal"
$openIntuneButton.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$openIntuneButton.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 212)
$openIntuneButton.ForeColor = [System.Drawing.Color]::White
$openIntuneButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$form.Controls.Add($openIntuneButton)

#endregion

#region Event Handlers

# Drag Enter Event for Drop Panel
$dropPanel.Add_DragEnter({
    param($sender, $e)
    if ($e.Data.GetDataPresent([Windows.Forms.DataFormats]::FileDrop)) {
        $files = $e.Data.GetData([Windows.Forms.DataFormats]::FileDrop)
        $validExtensions = @('.png', '.jpg', '.jpeg', '.bmp', '.gif')
        $extension = [System.IO.Path]::GetExtension($files[0]).ToLower()

        if ($extension -in $validExtensions) {
            $e.Effect = [System.Windows.Forms.DragDropEffects]::Copy
            $dropPanel.BackColor = [System.Drawing.Color]::LightBlue
        }
        else {
            $e.Effect = [System.Windows.Forms.DragDropEffects]::None
        }
    }
})

# Drag Leave Event for Drop Panel
$dropPanel.Add_DragLeave({
    $dropPanel.BackColor = [System.Drawing.Color]::WhiteSmoke
})

# Drag Enter Event for Drop Label
$dropLabel.Add_DragEnter({
    param($sender, $e)
    if ($e.Data.GetDataPresent([Windows.Forms.DataFormats]::FileDrop)) {
        $files = $e.Data.GetData([Windows.Forms.DataFormats]::FileDrop)
        $validExtensions = @('.png', '.jpg', '.jpeg', '.bmp', '.gif')
        $extension = [System.IO.Path]::GetExtension($files[0]).ToLower()

        if ($extension -in $validExtensions) {
            $e.Effect = [System.Windows.Forms.DragDropEffects]::Copy
            $dropPanel.BackColor = [System.Drawing.Color]::LightBlue
        }
        else {
            $e.Effect = [System.Windows.Forms.DragDropEffects]::None
        }
    }
})

# Drop Event for Drop Panel
$dropPanel.Add_DragDrop({
    param($sender, $e)
    $dropPanel.BackColor = [System.Drawing.Color]::WhiteSmoke

    if ($e.Data.GetDataPresent([Windows.Forms.DataFormats]::FileDrop)) {
        $files = $e.Data.GetData([Windows.Forms.DataFormats]::FileDrop)
        Load-ImageFile -FilePath $files[0]
    }
})

# Drop Event for Drop Label
$dropLabel.Add_DragDrop({
    param($sender, $e)
    $dropPanel.BackColor = [System.Drawing.Color]::WhiteSmoke

    if ($e.Data.GetDataPresent([Windows.Forms.DataFormats]::FileDrop)) {
        $files = $e.Data.GetData([Windows.Forms.DataFormats]::FileDrop)
        Load-ImageFile -FilePath $files[0]
    }
})

# Browse Button Click Event
$browseButton.Add_Click({
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Filter = "Image Files (*.png;*.jpg;*.jpeg;*.bmp;*.gif)|*.png;*.jpg;*.jpeg;*.bmp;*.gif"
    $openFileDialog.Title = "Select an Image"

    if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        Load-ImageFile -FilePath $openFileDialog.FileName
    }
})

# Background Color Button Click Event
$bgColorButton.Add_Click({
    $colorDialog = New-Object System.Windows.Forms.ColorDialog
    $colorDialog.Color = $script:BackgroundColor
    $colorDialog.FullOpen = $true

    if ($colorDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $script:BackgroundColor = $colorDialog.Color

        if ($script:BackgroundColor.A -eq 0) {
            $bgColorButton.Text = "Transparent"
        }
        else {
            $bgColorButton.Text = "RGB($($script:BackgroundColor.R),$($script:BackgroundColor.G),$($script:BackgroundColor.B))"
        }
        $bgColorButton.BackColor = $script:BackgroundColor
    }
})

# Set Output Folder Button Click Event
$setOutputFolderButton.Add_Click({
    Set-OutputFolder
})

# Convert Button Click Event
$convertButton.Add_Click({
    if ($null -eq $script:OriginalImage) {
        [System.Windows.Forms.MessageBox]::Show("Please load an image first.", "Error",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }

    # Determine resize method
    $resizeMethod = "Fit"
    if ($stretchRadioButton.Checked) {
        $resizeMethod = "Stretch"
    }
    elseif ($cropRadioButton.Checked) {
        $resizeMethod = "Crop"
    }

    # Update status
    $statusLabel.Text = "Converting image..."
    $statusLabel.ForeColor = [System.Drawing.Color]::Blue
    $form.Refresh()

    # Dispose of previous converted image
    if ($script:ConvertedImage) {
        $script:ConvertedImage.Dispose()
    }

    # Convert the image
    $script:ConvertedImage = Convert-ImageToIntuneSize -SourceImage $script:OriginalImage -ResizeMethod $resizeMethod -BgColor $script:BackgroundColor

    if ($null -ne $script:ConvertedImage) {
        # Update preview
        $convertedPictureBox.Image = $script:ConvertedImage
        $convertedDimensionsLabel.Text = "Converted: 256 x 256 px"

        # Enable save button
        $saveButton.Enabled = $true

        # Update status
        $statusLabel.Text = "Image converted successfully. Click 'Save As...' to export."
        $statusLabel.ForeColor = [System.Drawing.Color]::Green
    }
})

# Save Button Click Event
$saveButton.Add_Click({
    if ($null -eq $script:ConvertedImage) {
        [System.Windows.Forms.MessageBox]::Show("Please convert an image first.", "Error",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }

    # Check if output folder is set, if not offer to set it
    if ([string]::IsNullOrEmpty($script:OutputFolder)) {
        $result = [System.Windows.Forms.MessageBox]::Show(
            "Would you like to set a dedicated output folder for saving converted logos?`n`nThis will make it easier to organize your Intune app icons.",
            "Set Output Folder",
            [System.Windows.Forms.MessageBoxButtons]::YesNo,
            [System.Windows.Forms.MessageBoxIcon]::Question
        )

        if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
            if (-not (Set-OutputFolder)) {
                # User cancelled, continue with save dialog
            }
        }
    }

    $saveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
    $saveFileDialog.Filter = "PNG Image (*.png)|*.png"
    $saveFileDialog.Title = "Save Converted Image"

    # Set initial directory to output folder if set
    if (-not [string]::IsNullOrEmpty($script:OutputFolder)) {
        $saveFileDialog.InitialDirectory = $script:OutputFolder
    }

    # Set default filename
    if (-not [string]::IsNullOrEmpty($script:SourceFilePath)) {
        $originalFileName = [System.IO.Path]::GetFileNameWithoutExtension($script:SourceFilePath)
        $saveFileDialog.FileName = "$originalFileName`_256x256.png"
    }
    else {
        $saveFileDialog.FileName = "converted_256x256.png"
    }

    if ($saveFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        Save-ConvertedImage -Image $script:ConvertedImage -SavePath $saveFileDialog.FileName
    }
})

# Open Intune Portal Button Click Event
$openIntuneButton.Add_Click({
    Open-IntunePortal
})

# Form Closing Event
$form.Add_FormClosing({
    # Dispose of images
    if ($script:OriginalImage) {
        $script:OriginalImage.Dispose()
    }
    if ($script:ConvertedImage) {
        $script:ConvertedImage.Dispose()
    }
})

#endregion

# Show the form
[void]$form.ShowDialog()
