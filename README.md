# Windows 10 Toolkit

**Windows-Toolkit.cmd** (Current in transition to C# GUI) - An ever-growing toolkit to modify many aspects of Windows.

**Supported Versions** = Windows 10 64/32 Bit and ARM64, I use on Pro 64bit+ARM64 and Home 32bit+ARM64.

**Any Risks?** = There will _always_ be risk when modifying parts of Windows, make a Restore Point beforehand if worried.

**Requirements** = Access to Admin privileges. Knowledge of what you are wanting to do.

**Please add your suggestions for what I should add to it in the Issues Tab, along with any bugs**

#### **[Download](https://github.com/Empyreal96/win-10-services-toolbox/raw/master/Windows-Toolkit.cmd)**

## What it can do:

**Windows Update:**

- Start/Stop Windows Update Services

- Enable/Disable Automatic Driver Downloads

- Enable/Disable Automatic Maintenance

**Windows Search:**

- Start/Stop Windows Search

- Enable "Immersive Full screen Search with Rounded Corners"

**Cortana:**

- Start/Stop Cortana Service

- Enable/Disable Web Results showing in Cortana Search

**Windows Spotlight:**

- Enable/Disable "Fun Facts" on Lock screen

- Enable/Disable Spotlight Wallpapers

- Enable/Disable ALL Spotlight features

- Backup Spotlight Wallpapers

**Windows Services:**

- Enable/Disable unneeded Services (Can view what is disabled beforehand)

- Telemetry and User Diagnostics:

- Enable/Disable Telemetry Data Collection

- Enable/Disable Connected User Experience Services

- Remove Telemetry Scheduled Tasks

**OneDrive:**

- Uninstall OneDrive (Possibly for new users too)

- Enable/Disable OneDrive Explorer Integration

**Powershell based Tweaks:**

- Remove 'Bloat' Built-in Apps (Plans to integrate reinstalling bloat)

- Manage Windows Optional Features

- Attempt File System Repair with DISM and System File Checker

**Appearance:**

- Enable/Disable Transparency

- Enable/Disable Auto Clearing Thumbnails

- Enable/Disable Thumbnails

- Enable/Disable Old Style Volume Fly-out

- Enable/Disable Fixing of Blurry Apps

**Context Menu**

- Add/Remove Take Ownership

- Add/Remove Unblock File

- Enable Classic Personalize Menu

- Install CAB Files

- Add/Remove Open Command Prompt Here

- More 'Advanced Options' available

**AND MUCH MORE!!** (I will write a complete Changelog at somepoint)

![ToolScreen](https://github.com/Empyreal96/win-10-services-toolbox/blob/master/Update%20Switch%20Screens/screen2.gif)



**Setup complete.cmd** - file used in my custom Win ARM image



**Update-Service-Tool.bat** - A little batch to start and stop win updates on the go, also has some safe to disable services because its 
pulled from my main project over at XDA which is ongoing work in progress.
