# Intune App Logo Converter

A PowerShell GUI tool to convert images to the correct size for Microsoft Intune Company Portal app icons.

## Overview

This tool provides an easy-to-use graphical interface for converting images to **256x256 pixels** in **PNG format**, which is the recommended size for app icons in Microsoft Intune Company Portal.

## Features

- **Drag and Drop Support**: Simply drag an image onto the application
- **File Browser**: Browse and select images from your file system
- **Dedicated Output Folder**: Set a folder to organize all your converted Intune logos
- **Quick Access to Intune**: One-click button to open Intune Apps portal
- **Live Preview**: See before and after comparison of your images
- **Three Resize Modes**:
  - **Fit**: Maintains aspect ratio with padding (recommended)
  - **Stretch**: Stretches image to fill 256x256 (may distort)
  - **Crop**: Scales and crops from center to fill 256x256
- **Transparency Support**: Preserves PNG transparency
- **Custom Background**: Choose background color for padding in Fit mode
- **Multiple Format Support**: Works with PNG, JPG, JPEG, BMP, and GIF

## Requirements

- **Operating System**: Windows 10/11 or Windows Server 2016+
- **PowerShell**: Version 5.1 or later (included with Windows)
- **.NET Framework**: Included with Windows

## Installation

1. Download or clone this repository
2. No installation required - it's a standalone PowerShell script!

## Usage

### Method 1: Right-click and Run

1. Right-click on `Convert-IntuneAppLogo.ps1`
2. Select **"Run with PowerShell"**

### Method 2: PowerShell Console

1. Open PowerShell
2. Navigate to the script directory:
   ```powershell
   cd "C:\Path\To\Intune-Logo-Converter"
   ```
3. Run the script:
   ```powershell
   .\Convert-IntuneAppLogo.ps1
   ```

### Method 3: PowerShell ISE

1. Open PowerShell ISE
2. Open the `Convert-IntuneAppLogo.ps1` file
3. Press **F5** to run

## How to Use the Tool

1. **Load an Image**:
   - Drag and drop an image file onto the drop zone, OR
   - Click the **"Browse..."** button to select a file

2. **Set Output Folder (Optional but Recommended)**:
   - Click **"Set Output Folder"** to create or select a dedicated folder for your converted logos
   - The tool will suggest creating a folder: `Documents\Intune-App-Icons`
   - This makes it easier to organize all your Intune app icons in one place
   - You can change this folder at any time

3. **Choose Conversion Options**:
   - **Resize Method**:
     - **Fit (Recommended)**: Maintains the original aspect ratio and adds padding if needed. Best for logos that shouldn't be distorted.
     - **Stretch**: Stretches the image to fill the entire 256x256 canvas. May distort rectangular images.
     - **Crop**: Scales the image to cover the entire 256x256 canvas and crops from the center. Best for photos.
   - **Background Color** (Fit mode only):
     - Click the color button to choose a background color for padding
     - Default is transparent (recommended for app icons)

4. **Convert**:
   - Click the **"Convert"** button
   - Preview the converted image in the right panel

5. **Save**:
   - Click **"Save As..."** to export your converted image
   - If you haven't set an output folder, you'll be prompted to create one
   - Default filename will be: `{original-name}_256x256.png`
   - The save dialog will automatically open to your output folder if set
   - Choose your save location and click Save

6. **Upload to Intune (Optional)**:
   - Click **"Open Intune Portal"** to launch the Intune Apps page in your browser
   - You'll be taken directly to the Apps section where you can upload your converted icons

## Intune App Icon Requirements

According to Microsoft's recommendations:

- **Recommended Size**: 256x256 pixels
- **Minimum Size**: 120x120 pixels (but 256x256 is preferred for best quality)
- **Maximum File Size**: 750KB (for branding logos)
- **Format**: PNG (recommended) or JPG
- **Transparency**: PNG supports transparency, which is ideal for app icons

### Why 256x256?

- High-DPI display support
- Optimal size for the Company Portal app tile
- Displays at full size on both web and iOS Company Portal
- Provides crisp, clear icons on all devices

## Tips for Best Results

1. **Set Output Folder First**: Create a dedicated folder (like `Intune-App-Icons`) to keep all your app icons organized in one place
2. **Start with High Resolution**: Use source images that are at least 256x256 or larger for best quality
3. **Use Transparent PNGs**: For app icons, PNG with transparent background looks most professional
4. **Fit Mode for Logos**: Use "Fit" mode to prevent distortion of company logos or text
5. **Crop Mode for Photos**: Use "Crop" mode for product photos or profile pictures
6. **Preview Before Saving**: Always check the preview to ensure the result looks good
7. **Square Source Images**: Images that are already square (1:1 aspect ratio) will convert best

## Troubleshooting

### Execution Policy Error

If you get an error about execution policy, run PowerShell as Administrator and execute:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Then try running the script again.

### Image Won't Load

- Ensure the file is a valid image format (PNG, JPG, BMP, GIF)
- Check that the file isn't corrupted
- Verify you have read permissions for the file

### Save Failed

- Ensure you have write permissions to the save location
- Check that there's enough disk space
- Make sure the filename doesn't contain invalid characters

## Examples

### Converting a Company Logo

1. Load your company logo (e.g., 800x400 PNG)
2. Select **"Fit"** mode
3. Keep background as **"Transparent"**
4. Convert and save
5. Result: 256x256 PNG with logo centered and transparent padding

### Converting an App Icon

1. Load your app icon (e.g., 512x512 PNG)
2. Select **"Stretch"** or **"Fit"** mode (if already square, both work)
3. Convert and save
4. Result: 256x256 PNG ready for Intune

### Converting a Product Photo

1. Load your product photo (e.g., 1200x900 JPG)
2. Select **"Crop"** mode
3. Convert and save
4. Result: 256x256 PNG with centered crop

## Version History

### Version 1.0 (2026-01-28)
- Initial release
- Windows Forms GUI
- Three resize modes (Fit, Stretch, Crop)
- Drag and drop support
- File browser
- Dedicated output folder management
- Automatic folder creation suggestion
- Quick access button to open Intune Apps portal
- Live preview
- Transparency support
- Custom background color picker

## License

This tool is provided as-is for use with Microsoft Intune deployments.

## Support

For issues or suggestions, please open an issue in the repository.

## References

- [Microsoft Intune Documentation](https://learn.microsoft.com/en-us/intune/)
- [Configure Intune Company Portal Branding](https://www.prajwaldesai.com/configure-intune-company-portal-branding/)
- [How To Set Application Logo In Intune](https://www.prajwaldesai.com/how-to-set-application-logo-in-intune/)

---

**Note**: This is an unofficial tool created to simplify the process of preparing app icons for Microsoft Intune Company Portal. It is not affiliated with or endorsed by Microsoft.
