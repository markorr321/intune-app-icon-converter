<#
.SYNOPSIS
    Quick helper script to download some sample images for testing the Intune Logo Converter

.DESCRIPTION
    This script creates a test-images folder and provides instructions for getting test images.
    You can use your own images or search for some test logos online.
#>

# Create test images folder
$testFolder = Join-Path -Path $PSScriptRoot -ChildPath "test-images"
if (-not (Test-Path -Path $testFolder)) {
    New-Item -Path $testFolder -ItemType Directory | Out-Null
    Write-Host "Created test-images folder: $testFolder" -ForegroundColor Green
}
else {
    Write-Host "Test-images folder already exists: $testFolder" -ForegroundColor Yellow
}

Write-Host "`nTo test the Intune Logo Converter, you can:" -ForegroundColor Cyan
Write-Host "1. Copy any PNG, JPG, or BMP images into the test-images folder" -ForegroundColor White
Write-Host "2. Use images from your Pictures folder" -ForegroundColor White
Write-Host "3. Take a screenshot (Windows + Shift + S) and save it" -ForegroundColor White
Write-Host "4. Search for 'company logo png' online and download a few samples" -ForegroundColor White
Write-Host "`nGood test cases:" -ForegroundColor Cyan
Write-Host "- Square images (e.g., 512x512, 1024x1024) - test Fit/Stretch modes" -ForegroundColor White
Write-Host "- Rectangular images (e.g., 800x400, 1920x1080) - test Fit mode with padding" -ForegroundColor White
Write-Host "- Portrait images (e.g., 400x800) - test Crop mode" -ForegroundColor White
Write-Host "- PNG with transparency - test transparency preservation" -ForegroundColor White
Write-Host "`nPress any key to open the test-images folder..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Start-Process $testFolder
