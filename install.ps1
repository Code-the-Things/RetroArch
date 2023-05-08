# Silence Output
$ProgressPreference = 'SilentlyContinue'

# Variables
$installer = 'https://buildbot.libretro.com/stable/1.15.0/windows/x86_64/RetroArch-Win64-setup.exe'
#$7zip = 'https://www.7-zip.org/a/7z2201-x64.exe'
$destination = $env:TEMP + '\RetroArch'
$SNES = "<%= archives.link('ROMs', 'SNES Roms.rar', 1200) %>"
$NES = "<%= archives.link('ROMs', 'NESMerge201.rar', 1200) %>"

# Install RetroArch
Start-BitsTransfer -Source $installer -Destination ($destination + "\retroarch.exe")

($destination + "\retroarch.exe") /S

Start-Sleep 30

# Grab ROMs
Start-BitsTransfer -Source $SNES -Destination ($destination + '\snes.rar') -Dynamic

Start-BitsTransfer -Source $NES -Destination ($destination + '\nes.rar') -Dynamic

# Install 7-Zip
# if (!(get-package 7-zip*)) {
#     Start-BitsTransfer -Source $7zip -Destination ($destination + "\7zip.msi")
#     msiexec /i ($destination + "\7zip.msi") /qb
# }

if (!(get-module 7Zip4PowerShell)) {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force;
    Set-PSRepository -Name 'PSGallery' -SourceLocation "https://www.powershellgallery.com/api/v2" -InstallationPolicy Trusted;
    Install-Module -Name 7Zip4PowerShell -Force;
}

# Extract ROMs
$archives = Get-ChildItem -Path $destination -Recurse -Include "*.zip", "*.rar", "*.7z"

foreach ($archive in $archives) {
    Expand-7Zip -ArchiveFileName $archive -TargetPath ("c:\ROMs\" + $archive.BaseName)
}

# Cleanup
Remove-Item -LiteralPath $destination -Force -Recurse