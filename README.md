# win-10-services-toolbox

I use this repo to store the script files I use for my Win 10 ARM64 Optimised build over on XDA developers site.

The scripts used here can be used on any Windows arch (ARM/x86/x64) but will modify Services running and Registry entries
for some services.

**Update-Service-Tool.bat** - A little batch to start and stop win updates on the go, also has some safe to disable services because its 
pulled from my main project and is ongoing work in progress.

**Windows-Toolkit.cmd** (Current Project Big update planned)) - An evergrowing toolkit to modify many aspects of windows.. very work in progress, not that much right now but still quite alot to do with the toolkit.
What it can do:

**Windows Update:**

Start/Stop Windows Update Services

Enable/Disable Automatic Driver Downloads

Enable/Disable Automatic Maintenance

**Windows Search:**

Start/Stop Windows Search

Enable "Immersive Fullscreen Search with Rounded Corners"

**Cortana:**

Start/Stop Cortana Service

Enable/Disable Web Results showing in Cortana Search

**Windows Spotlight:**

Enable/Disable "Fun Facts" on Lockscreen

Enable/Disable Spotlight Wallpapers

Enable/Disable ALL Spotlight features

Backup Spotlight Wallpapers

**Windows Services:**

Enable/Disable unneeded Services (Can view what is disabled beforehand)

Telemetry and User Diagnostics:

Enable/Disable Telemetry Data Collection

Enable/Disable Connected User Experience Services

Remove Telemetry Scheduled Tasks

**OneDrive:**

Uninstall OneDrive (Possibly for new users too)

Enable/Disable OneDrive Explorer Integration

**Powershell based Tweaks:**

Remove 'Bloat' Built-in Apps (Plans to integrate reinstalling bloat)

Manage Windows Optional Features

Attempt File System Repair with DISM and System File Checker

**Appearance:**

Enable/Disable Transparency

Enable/Disable Auto Clearing Thumbnails

Enable/Disable Thumbnails

Enable/Disable Old Style Volume Fly-out

Enable/Disable Fixing of Blurry Apps

**Context Menu**

Add/Remove Take Ownership

Add/Remove Unblock File

Enable Classic Personalize Menu

Install CAB Files

Add/Remove Open Command Prompt Here

More 'Advanced Options' available

**AND MUCH MORE!!**

![ToolScreen](https://github.com/Empyreal96/win-10-services-toolbox/blob/master/Update%20Switch%20Screens/screen.gif)

**Setup complete.cmd** - file used in my custom Win ARM image

I will update with a list of what is disabled at a later date when I release my more feature full script.
