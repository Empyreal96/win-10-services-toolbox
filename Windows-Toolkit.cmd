 @echo off
 CLS
 ECHO.
 ECHO.
echo I made this script using various bits of info I found using
echo the Microsoft site and a few forum boards. I have tested
echo this and use it frequently, and will continue to improve this script.
echo Tested on Windows 10: Home and Pro on x64 and ARM64.
echo Any issues, feedback or suggestions contact @Empyreal96 on Github
echo Powershell Feature options scripted by @BeckarAC on Github
echo.
echo This script will let you control different parts of Windows, for example:
echo Windows Update/Cortana/Telemetry/Search/Spotlight/OneDrive etc. 
echo.
echo This message will appear once more after gaining Admin permissions.
echo.
pause

:init
 setlocal DisableDelayedExpansion
 set cmdInvoke=1
 set winSysFolder=System32
 set "batchPath=%~0"
 for %%k in (%0) do set batchName=%%~nk
 set "vbsGetPrivileges=%temp%\OEgetPriv_%batchName%.vbs"
 setlocal EnableDelayedExpansion

:checkPrivileges
  NET FILE 1>NUL 2>NUL
  if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges )

:getPrivileges
  if '%1'=='ELEV' (echo ELEV & shift /1 & goto gotPrivileges)
  ECHO.
  ECHO.
  ECHO Invoking UAC for Privilege Escalation
  ECHO.

  ECHO Set UAC = CreateObject^("Shell.Application"^) > "%vbsGetPrivileges%"
  ECHO args = "ELEV " >> "%vbsGetPrivileges%"
  ECHO For Each strArg in WScript.Arguments >> "%vbsGetPrivileges%"
  ECHO args = args ^& strArg ^& " "  >> "%vbsGetPrivileges%"
  ECHO Next >> "%vbsGetPrivileges%"

  if '%cmdInvoke%'=='1' goto InvokeCmd 

  ECHO UAC.ShellExecute "!batchPath!", args, "", "runas", 1 >> "%vbsGetPrivileges%"
  goto ExecElevation

:InvokeCmd
  ECHO args = "/c """ + "!batchPath!" + """ " + args >> "%vbsGetPrivileges%"
  ECHO UAC.ShellExecute "%SystemRoot%\%winSysFolder%\cmd.exe", args, "", "runas", 1 >> "%vbsGetPrivileges%"

:ExecElevation
 "%SystemRoot%\%winSysFolder%\WScript.exe" "%vbsGetPrivileges%" %*
 exit /B

:gotPrivileges
 setlocal & cd /d %~dp0
 if '%1'=='ELEV' (del "%vbsGetPrivileges%" 1>nul 2>nul  &  shift /1)



@echo off
title Windows 10 Toolbox by Empyreal96
:home
mode con:cols=80 lines=25
cls
echo.
echo This tool will allow you to disable various components of Windows or enable
echo various parts of Windows, each section contains different tweaks for different
echo situations i.e Windows Update, Search, Cortana and Spotlight etc..
echo any issues contact @Empyreal96 at xda-developers.com
echo.
echo.
echo 1) Windows Update
echo 2) Windows Search
echo 3) Cortana
echo 4) Windows Spotlight (Lockscreen Web Images, Lockscreen "Facts")
echo 5) Disable "Safe" Services
echo 6) Telemetry and User Data Sharing
echo 7) OneDrive
echo 8) Powershell Tweaks
echo 9) Misc Tweaks
echo 10) Exit
echo.
echo.
set /p web=Type option:
if "%web%"=="1" goto update
if "%web%"=="2" goto search
if "%web%"=="3" goto cortana
if "%web%"=="4" goto spotlight
if "%web%"=="5" goto routine1
if "%web%"=="6" goto telemetry
if "%web%"=="7" goto onedrive
if "%web%"=="8" goto powershellmenu
if "%web%"=="9" goto misc
if "%web%"=="10" goto exit
goto home

:update
mode con:cols=80 lines=18
cls
echo.
echo Do you want to start or stop Windows Update services?
echo this includes "wuauserv" "BITS" and "DoSvc"
echo.
echo.
echo 1) Start Update Services
echo 2) Stop Update Services
echo 3) Back
echo 4) Exit
echo.
echo.
set /p web=Type option:
if "%web%"=="1" goto startwu
if "%web%"=="2" goto stopwu
if "%web%"=="3" goto home
if "%web%"=="4" exit
goto update

:startwu
mode con:cols=80 lines=18
sc.exe config wuauserv start=auto
sc.exe start wuauserv
sc.exe config BITS start=auto
sc.exe start BITS
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DoSvc" /v Start /t REG_DWORD /d 2 /f
sc.exe config DoSvc start=auto
sc.exe start DoSvc
goto update

:stopwu
mode con:cols=80 lines=18
sc.exe stop wuauserv
sc.exe config wuauserv start=disabled
sc.exe stop BITS
sc.exe config BITS start=disabled
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DoSvc" /v Start /t REG_DWORD /d 4 /f
sc.exe stop DoSvc
sc.exe config DoSvc start=disabled
goto update

:search
mode con:cols=80 lines=22
cls
echo.
echo Here you can Start or Stop Windows Search and Indexing
echo.
echo.
echo 1) Start Windows Search Services
echo 2) Stop Windows Search Services
echo 3) Back
echo 4) Exit
echo.
echo.
set /p web=Type option:
if "%web%"=="1" goto searchstart
if "%web%"=="2" goto searchstop
if "%web%"=="3" goto home
if "%web%"=="4" goto exit
goto search

:searchstart
mode con:cols=80 lines=22
sc.exe config WSearch start=auto
sc.exe start WSearch
goto search

:searchstop
mode con:cols=80 lines=22
sc.exe stop WSearch
sc.exe config WSearch start=disabled
goto search

:cortana
mode con:cols=80 lines=22
cls
echo Here you can Start or Stop Cortana services
echo #Restart will be needed for action to take effect#
echo.
echo 1) Start Cortana
echo 2) Stop Cortana
echo.
echo 3) Stop Cortana Searching Online
echo 4) Start Cortana Searching Online
echo.
echo 3) Back
echo 4) Exit
echo.
echo.
set /p web=Type option:
if "%web%"=="1" goto cortanaon
if "%web%"=="2" goto cortanaoff
if "%web%"=="3" goto stopweb
if "%web%"=="4" goto startweb
if "%web%"=="5" goto home
if "%web%"=="6" exit
goto cortana

:stopweb
mode con:cols=80 lines=22
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "BingSearchEnabled" /t REG_DWORD /d "0" /f
pause
goto cortana
:startweb:
mode con:cols=80 lines=22
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "BingSearchEnabled" /t REG_DWORD /d "1" /f
pause
goto cortana
:cortanaoff
mode con:cols=80 lines=22
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v AllowCortana /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v BingSearchEnabled /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v  AllowSearchToUseLocation /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v  CortanaConsent  /t REG_DWORD /d 0 /f
goto cortana
:cortanaon
mode con:cols=80 lines=22
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v AllowCortana /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v BingSearchEnabled /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v  AllowSearchToUseLocation /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v  CortanaConsent  /t REG_DWORD /d 1 /f
goto cortana

:spotlight
mode con:cols=80 lines=22
cls
echo.
echo Here you can choose what to disable from
echo Windows Spotlight, i.e Lockreen Images, facts and 
echo Content Delivery for Windows Spotlight.
echo #THIS NEEDS TESTING MORE#
echo.
echo.
echo 1) Disable "Fun Facts"
echo 2) Enable "Fun Facts"
echo.
echo 3) Disable Spotlight Wallpapers
echo 4) Enable Spotlight Wallpapers
echo.
echo 5) Disable ALL Spotlight Features
echo 6) Enable ALL Spotlight Features
echo 7) Back
echo 8) Exit
echo.
echo.
set /p web=Type option:
if "%web%"=="1" goto nofacts 
if "%web%"=="2" goto yesfacts
if "%web%"=="3" goto nowall
if "%web%"=="4" goto yeswall
if "%web%"=="5" goto nospot
if "%web%"=="6" goto yesspot
if "%web%"=="7" goto home
if "%web%"=="8" exit


:nofacts
mode con:cols=80 lines=22
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338388Enabled /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338389Enabled /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-353696Enabled /t REG_DWORD /d 0 /f
reg load HKLM\defuser %USERPROFILES%\default\ntuser.dat >NUL 2>&1
reg add "HKLM\defuser\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v RotatingLockScreenOverlayEnabled /t REG_DWORD /d 0 /f >NUL 2>&1
reg unload HKLM\defuser >NUL 2>&1

pause
goto spotlight

:yesfacts
mode con:cols=80 lines=22
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338388Enabled /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338389Enabled /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-353696Enabled /t REG_DWORD /d 1 /f
reg load HKLM\defuser %USERPROFILES%\default\ntuser.dat >NUL 2>&1
reg add "HKLM\defuser\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v RotatingLockScreenOverlayEnabled /t REG_DWORD /d 1 /f >NUL 2>&1
reg unload HKLM\defuser >NUL 2>&1
pause
goto spotlight 

:nowall
mode con:cols=80 lines=22
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Personalization" /v NoChangingLockScreen /t REG_WORD /d 1 /f
pause
goto spotlight
:yeswall
mode con:cols=80 lines=22
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Personalization" /v NoChangingLockScreen /t REG_DWORD /d 0 /f
pause
goto spotlight

:nospot
mode con:cols=80 lines=22
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v ContentDeliveryAllowed /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v RotatingLockScreenEnabled /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v RotatingLockScreenOverlayEnabled /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Policies\Microsoft\Windows\CloudContent" /v DisableWindowsSpotlightFeatures /t REG_DWORD /d 1 /f
pause
goto spotlight

:yesspot
mode con:cols=80 lines=22
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v ContentDeliveryAllowed /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v RotatingLockScreenOverlayEnabled /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v RotatingLockScreenEnabled /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Policies\Microsoft\Windows\CloudContent" /v DisableWindowsSpotlightFeatures /t REG_DWORD /d 0 /f
pause
goto spotlight




:routine1
mode con:cols=80 lines=22
sc.exe stop WerSvc
sc.exe config WerSvc start=disabled
sc.exe stop DiagTrack
sc.exe config DiagTrack start=disabled
sc.exe stop DPS
sc.exe config DPS start=disabled
sc.exe stop MapsBroker
sc.exe config MapsBroker start=disabled
sc.exe stop PcaSvc
sc.exe config PcaSvc start=disabled
sc.exe stop Spooler
sc.exe config Spooler start=disabled
sc.exe stop RemoteRegistry
sc.exe config RemoteRegistry start=disabled
sc.exe stop lmhosts
sc.exe config lmhosts start=disabled
sc.exe stop WerSvc
sc.exe config WerSvc start=disabled
sc.exe stop stisvc
sc.exe config stisvc start=disabled
sc.exe stop lfsvc
sc.exe config lfsvc start=disabled
sc.exe stop WbioSrvc
sc.exe config WbioSrvc start=disabled
sc.exe stop WMPNetworkSvc
sc.exe config WMPNetworkSvc start=disabled
sc.exe stop EntAppSvc
sc.exe config EntAppSvc start=disabled
sc.exe stop HvHost
sc.exe config HvHost start=disabled
sc.exe stop vmickvpexchange
sc.exe config vmickvpexchange start=disabled
sc.exe stop vmicguestinterface
sc.exe config vmicguestinterface start=disabled
sc.exe stop vmicshutdown
sc.exe config vmicshutdown start=disabled
sc.exe stop vmicheartbeat
sc.exe config vmicheartbeat start=disabled
sc.exe stop vmicvmsession
sc.exe config vmicvmsession start=disabled
sc.exe stop vmicrdv 
sc.exe config vmicrdv start=disabled
sc.exe stop vmictimesync
sc.exe config vmictimesync start=disabled
sc.exe stop vmicvss
sc.exe config vmicvss start=disabled
sc.exe stop AppVClient
sc.exe config AppVClient start=disabled
sc.exe stop RemoteAccess
sc.exe config RemoteAccess start=disabled
sc.exe stop SCardSvr
sc.exe config SCardSvr start=disabled
sc.exe stop UevAgentService
sc.exe config UevAgentService start=disabled
sc.exe stop ALG 
sc.exe config ALG start=disabled 
sc.exe stop PeerDistSvc
sc.exe config PeerDistSvc start=disabled
sc.exe stop WpcMonSvc
sc.exe config WpcMonSvc start=disabled
sc.exe stop RpcLocator
sc.exe config RpcLocator start=disabled
sc.exe stop RetailDemo
sc.exe config RetailDemo start=disabled
sc.exe stop ScDeviceEnum
sc.exe config ScDeviceEnum start=disabled
sc.exe stop SCPolicySvc
sc.exe config SCPolicySvc start=disabled
sc.exe stop FrameServer
sc.exe config FrameServer start=disabled
sc.exe stop SNMPTRAP
sc.exe config SNMPTRAP start=disabled
sc.exe stop wisvc 
sc.exe config wisvc start=disabled
sc.exe stop WinRM
sc.exe config WinRM start=disabled
sc.exe stop wbengine
sc.exe config wbengine start=disabled
sc.exe stop fhsvc
sc.exe config fhsvc start=disabled
sc.exe stop NaturalAuthentication
sc.exe config NaturalAuthentication start=disabled
sc.exe stop SessionEnv
sc.exe config SessionEnv start=disabled
sc.exe stop TermService
sc.exe config TermService start=disabled
sc.exe stop SharedRealitySvc
sc.exe config ShareRealitySvc start=disabled
sc.exe stop VSS
sc.exe config VSS start=disabled
sc.exe stop Wecsvc
sc.exe config Wecsvc start=disabled
sc.exe stop spectrum
sc.exe config spectrum start=disabled
sc.exe stop XtaCache
reg add "HKLM\SYSTEM\CurrentControlSet\Services\XtaCache" /v start /t REG_DWORD /d 4 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v Disabled /t REG_DWORD /d 1 /f
pause
goto home


:telemetry
mode con:cols=80 lines=22
cls
echo.
echo Here you can change Windows Telemetry and User diagnostic sharing
echo **Any scheduled tasks deleted cannot be re-added from this tool yet.
echo Disabling Connect User Experience broke cellular on my Lumia 950 XL**
echo.
echo.
echo 1) Disable Telemetry Data Collection
echo 2) Enable Telemetry Data Collection
echo.
echo 3) Disable Connected User Experience Services
echo 4) Enable Connected User Experience Services
echo.
echo 5) Remove Telemetry Scheduled Tasks (credit bmrf - tron - Github)
echo 6) Back
echo 7) Exit
echo.
set /p web=Type option:
if "%web%"=="1" goto notel
if "%web%"=="2" goto yestel
if "%web%"=="3" goto nocon
if "%web%"=="4" goto yescon
if "%web%"=="5" goto teltask
if "%web%"=="6" goto home
if "%web%"=="7" goto exit
goto telemetry
:yestel
mode con:cols=80 lines=22
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "1" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata" /v PreventDeviceMetadataFromNetwork /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\MRT" /v DontOfferThroughWUAU /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\SQMClient\Windows" /v "CEIPEnable" /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "AITEnable" /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "DisableUAR" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\AutoLogger-Diagtrack-Listener" /v Start /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\SQMLogger" /v Start /t REG_DWORD /d 1 /f
sc.exe config diagnosticshub.standardcollector.service start=auto
sc.exe start diagnosticshub.standardcollector.service
pause
goto telemetry

:notel
mode con:cols=80 lines=22
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "0" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata" /v PreventDeviceMetadataFromNetwork /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\MRT" /v DontOfferThroughWUAU /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\SQMClient\Windows" /v "CEIPEnable" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "AITEnable" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "DisableUAR" /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\AutoLogger-Diagtrack-Listener" /v Start /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\SQMLogger" /v Start /t REG_DWORD /d 0 /f
pause
goto telemetry

:nocon
mode con:cols=80 lines=22
sc.exe stop DiagTrack
sc.exe config DiagTrack start=disabled
sc.exe stop dmwappushsvc
sc.exe config dmwappushsvc start=disabled
sc.exe stop dmwappushservice
sc.exe config dmwappushservice start=disabled
pause
goto telemetry

:yescon
mode con:cols=80 lines=22
sc.exe config DiagTrack start=auto
sc.exe start DiagTrack
sc.exe config dmwappushsvc start=auto
sc.exe start dmwappushsvc
sc.exe config dmwappushservice start=auto
sc.exe start dmwappushservice
pause
goto telemetry


:teltask
mode con:cols=80 lines=22
schtasks /delete /F /TN "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser"
schtasks /delete /F /TN "Microsoft\Windows\Application Experience\ProgramDataUpdater"
schtasks /delete /F /TN "Microsoft\Windows\Autochk\Proxy"
schtasks /delete /F /TN "Microsoft\Windows\Customer Experience Improvement Program\Consolidator"
schtasks /delete /F /TN "Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask"
schtasks /delete /F /TN "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip"
schtasks /delete /F /TN "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector"
schtasks /delete /F /TN "Microsoft\Windows\PI\Sqm-Tasks"
schtasks /delete /F /TN "Microsoft\Windows\Power Efficiency Diagnostics\AnalyzeSystem"
schtasks /delete /F /TN "Microsoft\Windows\Windows Error Reporting\QueueReporting"
schtasks /delete /F /TN "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser"
schtasks /delete /F /TN "Microsoft\Windows\Application Experience\Aitagent"
schtasks /delete /F /TN "Microsoft\Windows\Application Experience\ProgramDataUpdater"
schtasks /delete /F /TN "Microsoft\Windows\Maintenance\Winsat"
schtasks /delete /F /TN "Microsoft\Windows\Media Center\ActicateWIndowsSearch"
schtasks /delete /F /TN "Microsoft\Windows\Media Center\ConfigureInternetTimeService"
schtasks /delete /F /TN "Microsoft\Windows\Media Center\DispatchRecoveryTasks"
schtasks /delete /F /TN "Microsoft\Windows\Media Center\Ehdrminit
schtasks /delete /F /TN "Microsoft\Windows\Media Center\InstallPlayReady"
schtasks /delete /F /TN "Microsoft\Windows\Media Center\McUpdate"
schtasks /delete /F /TN "Microsoft\Windows\Media Center\MediaCenterRecoveryTask"
schtasks /delete /F /TN "Microsoft\Windows\Media Center\ObjectStoreRecoveryTask"
schtasks /delete /F /TN "Microsoft\Windows\Media Center\OcurActivate"
schtasks /delete /F /TN "Microsoft\Windows\Media Center\OcurDiscovery"
schtasks /delete /F /TN "Microsoft\Windows\Media Center\PbdaDiscovery">nul 2>&1
schtasks /delete /F /TN "Microsoft\Windows\Media Center\PbdaDiscoveryw1"
schtasks /delete /F /TN "Microsoft\Windows\Media Center\PbdaDiscoveryw2"
schtasks /delete /F /TN "Microsoft\Windows\Media Center\PvvrRecoveryTask"
schtasks /delete /F /TN "Microsoft\Windows\Media Center\PvrScheduleTask"
schtasks /delete /F /TN "Microsoft\Windows\Media Center\RegisterSearch"
schtasks /delete /F /TN "Microsoft\Windows\Media Center\ReindexSearchRoot"
schtasks /delete /F /TN "Microsoft\Windows\Media Center\SqlliteRecoveryTask"
schtasks /delete /F /TN "Microsoft\Windows\Media Center\UpdateRecordPath"
pause 
goto telemetry

:onedrive
mode con:cols=80 lines=22
echo.
echo Here you can Uninstall OneDrive and remove it's explorer intergration
echo.
echo.
echo 1) Uninstall OneDrive (Cannot be undone currently)
echo 2) Disable Explorer Intergration
echo 3) Enable Explorer Intergration
echo 4) Back
echo 5) Exit
echo.
echo.
set /p web=Type option:
if "%web%"=="1" goto unone
if "%web%"=="2" goto noexplore
if "%web%"=="3" goto yesexplore
if "%web%"=="4" goto home
if "%web%"=="5" goto exit
goto onedrive

:unone
mode con:cols=80 lines=22
rd C:\OneDriveTemp /Q /S >NUL 2>&1
rd "%USERPROFILE%\OneDrive" /Q /S >NUL 2>&1
rd "%LOCALAPPDATA%\Microsoft\OneDrive" /Q /S >NUL 2>&1
rd "%PROGRAMDATA%\Microsoft OneDrive" /Q /S >NUL 2>&1
reg add "HKCR\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}\ShellFolder" /f /v Attributes /t REG_DWORD /d 0 >NUL 2>&1
reg add "HKCR\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}\ShellFolder" /v Attributes /t REG_DWORD /d 0 /f >NUL 2>&1
start /wait TASKKILL /F /IM explorer.exe
start explorer.exe
pause
goto onedrive

:noexplore
mode con:cols=80 lines=22
reg add "HKLM\software\policies\microsoft\windows\skydrive" /v "disablefilesync" /t REG_DWORD /d 1 /f
reg add "HKCR\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /v "System.IsPinnedToNameSpaceTree" /t REG_DWORD /d 0 /f
reg add "HKCR\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /v "System.IsPinnedToNameSpaceTree" /t REG_DWORD /d 0 /f
pause
goto onedrive
:yesexplore
mode con:cols=80 lines=22
reg add "HKLM\software\policies\microsoft\windows\skydrive" /v "disablefilesync" /t REG_DWORD /d 0 /f
reg add "HKCR\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /v "System.IsPinnedToNameSpaceTree" /t REG_DWORD /d 1 /f
reg add "HKCR\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /v "System.IsPinnedToNameSpaceTree" /t REG_DWORD /d 1 /f
pause
goto onedrive


:misc
mode con:cols=80 lines=22
echo.
echo Here is some tweaks that I can't make proper catagories for yet.
echo.
echo.
echo 1) Disable Windows Keylogger/Autologger
echo 2) Enable Windows Keylogger/Autologger
echo.
echo 3) Disable WiFi Sense
echo 4) Enable Wifi Sense
echo.
echo 5) Disable Windows Defender Sample Submission
echo 6) Enable Windows Defender Sample Submission
echo.
echo 7) Disable SmartScreen Filter for Store Apps (Unsure of purpose)
echo 8) Enable SmartScreen Filter for Store Apps
echo 9) Back
echo 0) Exit
echo.
echo.
set /p web=Type option:
if "%web%"=="1" goto nokeylog
if "%web%"=="2" goto yeskeylog
if "%web%"=="3" goto nowifi
if "%web%"=="4" goto yeswifi
if "%web%"=="5" goto nodefsamp
if "%web%"=="6" goto yesdefsamp
if "%web%"=="7" goto nostoresmart
if "%web%"=="8" goto yesstoresmart
if "%web%"=="9" goto home
if "%web%"=="0" goto exit
goto misc
:nokeylog
mode con:cols=80 lines=22
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\AutoLogger-Diagtrack-Listener" /v Start /t REG_DWORD /d 0 /f
pause
goto misc
:yeskeylog
mode con:cols=80 lines=22
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\AutoLogger-Diagtrack-Listener" /v Start /t REG_DWORD /d 1 /f
pause
goto misc
:nowifi
mode con:cols=80 lines=22
reg add "HKLM\Software\Microsoft\wcmsvc\wifinetworkmanager" /v wifisensecredshared /t REG_DWORD /d 0 /f
reg add "HKLM\Software\Microsoft\wcmsvc\wifinetworkmanager" /v wifisenseopen /t REG_DWORD /d 0 /f
pause
goto misc
:yeswifi
mode con:cols=80 lines=22
reg add "HKLM\Software\Microsoft\wcmsvc\wifinetworkmanager" /v wifisensecredshared /t REG_DWORD /d 1 /f
reg add "HKLM\Software\Microsoft\wcmsvc\wifinetworkmanager" /v wifisenseopen /t REG_DWORD /d 1 /f
pause
goto misc
:nodefsamp
mode con:cols=80 lines=22
reg add "HKLM\Software\Microsoft\Windows Defender\spynet" /v spynetreporting /t REG_DWORD /d 0 /f
reg add "HKLM\Software\Microsoft\Windows Defender\spynet" /v submitsamplesconsent /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v SubmitSamplesConcent /t REG_DWORD /d 2 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v SpynetReporting /t REG_DWORD /d 0 /f
pause
goto misc
:yesdefsamp
mode con:cols=80 lines=22
reg add "HKLM\Software\Microsoft\Windows Defender\spynet" /v spynetreporting /t REG_DWORD /d 1 /f
reg add "HKLM\Software\Microsoft\Windows Defender\spynet" /v submitsamplesconsent /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v SubmitSamplesConcent /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v SpynetReporting /t REG_DWORD /d 1 /f
pause
goto misc
:nostoresmart
mode con:cols=80 lines=22
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" /v EnableWebContentEvaluation /t REG_DWORD /d 0 /f 
pause
goto misc
:yesstoresmart
mode con:cols=80 lines=22
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" /v EnableWebContentEvaluation /t REG_DWORD /d 1 /f 
pause
goto misc

:powershellmenu
mode con:cols=80 lines=22
echo.
echo Here is a collection of Powershell commands to tweak windows
echo.
echo.
echo 1) Metro-UI Apps
echo 2) Windows Optional Features
echo 3) Display Various Information (Built in Apps, Disabled Features etc.)
echo 4) System Health
echo 5) Back
echo 6) Exit
echo.
echo.
set /p web=Type option:
if "%web%"=="1" goto metrouimenu
if "%web%"=="2" goto winfeaturesmenu
if "%web%"=="3" goto viewinfomenu
if "%web%"=="4" goto syshealthmenu
if "%web%"=="5" goto home
if "%web%"=="6" goto exit
goto powershellmenu

:metrouimenu
mode con:cols=80 lines=22
echo.
echo Here you can modify built-in Windows Apps.
echo excluding Windows Mail etc.
echo.
echo.
echo 1) Remove all 'Bloat' Apps
echo 2) Re-Install all 'Bloat' Apps
echo 3) Back
echo 4) Exit
echo.
echo.
set /p web=Type option:
if "%web%"=="1" goto nobloat
if "%web%"=="2" goto yesbloat
if "%web%"=="3" goto powershellmenu
if "%web%"=="4" goto exit
:winfeaturesmenu
mode con:cols=80 lines=22
echo.
echo Here you can add or remove various Windows Features like
echo .NET Framework, Windows Subsystem Linux etc.
echo.
echo.
echo 1) Add Features
echo 2) Remove Features
echo 3) Back
echo 4) Exit
echo.
echo.
set /p web=Type option:
if "%web%"=="1" goto addwinfeat
if "%web%"=="2" goto remwinfeat
if "%web%"=="3" goto powershellmenu
if "%web%"=="4" goto exit
goto winfeaturesmenu
:viewinfomenu
mode con:cols=80 lines=22
echo.
echo Here we can view bits of info on Options in the previous menu.
echo.
echo.
echo 1) View Pre-Installed Metro-UI Apps
echo 2) View Windows Optional Features States
echo 3) Back
echo 4) Exit
echo.
echo.
set /p web=Type option:
if "%web%"=="1" goto viewmetro
if "%web%"=="2" goto viewwinfeat
if "%web%"=="3" goto powershellmenu
if "%web%"=="4" goto exit
goto viewinfomenu

:syshealthmenu
mode con:cols=80 lines=22
echo.
echo Here you can scan System files and attempt repair on any issues
echo.
echo.
echo 1) Use DISM to Scan Running Windows Install
echo 2) Use DISM to Repair Running Windows Install
echo 3) System File Checker (sfc /scannow)
echo 4) Back
echo 5) Exit
echo.
echo.
set /p web=Type option:
if "%web%"=="1" goto dismscan
if "%web%"=="2" goto dismfix
if "%web%"=="3" goto sfccheck
if "%web%"=="4" goto powershellmenu
if "%web%"=="5" goto exit
goto syshealthmenu

:addwinfeat
mode con:cols=80 lines=40
echo.
echo Here you will be able to add Windows Optional Features
echo.
echo.
echo.
echo 1) Microsoft-Windows-Subsystem-Linux
echo 2) LegacyComponents
echo 3) DirectPlay
echo 4) SimpleTCP
echo 5) SNMP
echo 6) WMISnmpProvider
echo 7) MicrosoftWindowsPowerShellV2Root
echo 8) MicrosoftWindowsPowerShellV2
echo 9) Windows-Identity-Foundation
echo 10) Internet-Explorer-Optional-amd64
echo 11) NetFx3
echo 12) NetFx4-AdvSrvs
echo 13) NetFx4Extended-ASPNET45
echo 14) MediaPlayback
echo 15) WindowsMediaPlayer
echo 16) Printing-PrintToPDFServices-Features
echo 17) Printing-XPSServices-Features
echo 18) RasRip
echo 19) MSRDC-Infrastructure
echo 20) SearchEngine-Client-Package
echo 21) TelnetClient
echo 22) TFTP
echo 23) Xps-Foundation-Xps-Viewer
echo 24) WorkFolders-Client
echo 25) Next Page
echo.
echo.
echo.
set /p web=Type option:
if "%web%"=="1" DISM /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux
if "%web%"=="2" DISM /online /enable-feature /featurename:LegacyComponents && pause && goto addwinfeat
if "%web%"=="3" DISM /online /enable-feature /featurename:DirectPlay
if "%web%"=="4" DISM /online /enable-feature /featurename:SimpleTCP
if "%web%"=="5" DISM /online /enable-feature /featurename:SNMP
if "%web%"=="6" DISM /online /enable-feature /featurename:WMISnmpProvider
if "%web%"=="7" DISM /online /enable-feature /featurename:MicrosoftWindowsPowerShellV2Root
if "%web%"=="8" DISM /online /enable-feature /featurename:MicrosoftWindowsPowerShellV2
if "%web%"=="9" DISM /online /enable-feature /featurename:Windows-Identity-Foundation
if "%web%"=="10" DISM /online /enable-feature /featurename:Internet-Explorer-Optional-amd64
if "%web%"=="11" DISM /online /enable-feature /featurename:NetFx3
if "%web%"=="12" DISM /online /enable-feature /featurename:NetFx4-AdvSrvs
if "%web%"=="13" DISM /online /enable-feature /featurename:NetFx4Extended-ASPNET45
if "%web%"=="14" DISM /online /enable-feature /featurename:MediaPlayback
if "%web%"=="15" DISM /online /enable-feature /featurename:WindowsMediaPlayer
if "%web%"=="16" DISM /online /enable-feature /featurename:Printing-PrintToPDFServices-Features
if "%web%"=="17" DISM /online /enable-feature /featurename:Printing-XPSServices-Features
if "%web%"=="18" DISM /online /enable-feature /featurename:RasRip
if "%web%"=="19" DISM /online /enable-feature /featurename:MSRDC-Infrastructure
if "%web%"=="20" DISM /online /enable-feature /featurename:SearchEngine-Client-Package
if "%web%"=="21" DISM /online /enable-feature /featurename:TelnetClient
if "%web%"=="22" DISM /online /enable-feature /featurename:TFTP
if "%web%"=="23" DISM /online /enable-feature /featurename:Xps-Foundation-Xps-Viewer
if "%web%"=="24" DISM /online /enable-feature /featurename:WorkFolders-Client
if "%web%"=="25" goto addwinfeat1
goto addwinfeat






:addwinfeat1
mode con:cols=80 lines=40
echo.
echo 26) SMB1Protocol
echo 27) Microsoft-Hyper-V-All
echo 28) Microsoft-Hyper-V-Tools-All
echo 29) Microsoft-Hyper-V-Management-Clients
echo 30) Microsoft-Hyper-V-Management-PowerShell
echo 31) Microsoft-Hyper-V
echo 32) Microsoft-Hyper-V-Hypervisor
echo 33) Microsoft-Hyper-V-Services
echo 34) Printing-Foundation-Features
echo 35) Printing-Foundation-LPRPortMonitor
echo 36) Printing-Foundation-LPDPrintService
echo 37) Printing-Foundation-InternetPrinting-Client
echo 38) FaxServicesClientPackage
echo 39) ScanManagementConsole
echo 40) DirectoryServices-ADAM-Client
echo 41) ServicesForNFS-ClientOnly
echo 42) ClientForNFS-Infrastructure
echo 43) NFS-Administration
echo 44) RasCMAK
echo 45) TIFFIFilter
echo 46) SmbDirect
echo 47) Containers
echo 48) Client-DeviceLockdown
echo 49) Client-EmbeddedShellLauncher
echo 50) Next Page
echo.
echo.
echo.
set /p web=Type option:
if "%web%"=="26" DISM /online /enable-feature /featurename:SMB1Protocol
if "%web%"=="27" DISM /online /enable-feature /featurename:Microsoft-Hyper-V-All
if "%web%"=="28" DISM /online /enable-feature /featurename:Microsoft-Hyper-V-Tools-All
if "%web%"=="29" DISM /online /enable-feature /featurename:Microsoft-Hyper-V-Management-Clients
if "%web%"=="30" DISM /online /enable-feature /featurename:Microsoft-Hyper-V-Management-PowerShell
if "%web%"=="31" DISM /online /enable-feature /featurename:Microsoft-Hyper-V
if "%web%"=="32" DISM /online /enable-feature /featurename:Microsoft-Hyper-V-Hypervisor
if "%web%"=="33" DISM /online /enable-feature /featurename:Microsoft-Hyper-V-Services
if "%web%"=="34" DISM /online /enable-feature /featurename:Printing-Foundation-Features
if "%web%"=="35" DISM /online /enable-feature /featurename:Printing-Foundation-LPRPortMonitor
if "%web%"=="36" DISM /online /enable-feature /featurename:Printing-Foundation-LPDPrintService
if "%web%"=="37" DISM /online /enable-feature /featurename:Printing-Foundation-InternetPrinting-Client
if "%web%"=="38" DISM /online /enable-feature /featurename:FaxServicesClientPackage
if "%web%"=="39" DISM /online /enable-feature /featurename:ScanManagementConsole
if "%web%"=="40" DISM /online /enable-feature /featurename:DirectoryServices-ADAM-Client
if "%web%"=="41" DISM /online /enable-feature /featurename:ServicesForNFS-ClientOnly
if "%web%"=="42" DISM /online /enable-feature /featurename:ClientForNFS-Infrastructure
if "%web%"=="43" DISM /online /enable-feature /featurename:NFS-Administration
if "%web%"=="44" DISM /online /enable-feature /featurename:RasCMAK
if "%web%"=="45" DISM /online /enable-feature /featurename:TIFFIFilter
if "%web%"=="46" DISM /online /enable-feature /featurename:SmbDirect
if "%web%"=="47" DISM /online /enable-feature /featurename:Containers
if "%web%"=="48" DISM /online /enable-feature /featurename:Client-DeviceLockdown
if "%web%"=="49" DISM /online /enable-feature /featurename:Client-EmbeddedShellLauncher
if "%web%"=="50" goto addwinfeat2
goto addwinfeat1






:addwinfeat2
mode con:cols=80 lines=40
echo.
echo 51) Client-EmbeddedBootExp
echo 52) Client-EmbeddedLogon
echo 53) Client-KeyboardFilter
echo 54) Client-UnifiedWriteFilter
echo 55) MultiPoint-Connector
echo 56) MultiPoint-Connector-Services
echo 57) MultiPoint-Tools
echo 58) DataCenterBridging
echo 59) Microsoft-Hyper-V-Common-Drivers-Package
echo 60) Microsoft-Windows-NetFx-VCRedist-Package
echo 61) Microsoft-Windows-Printing-PrintToPDFServices-Package
echo 62) Microsoft-Windows-Printing-XPSServices-Package
echo 63) Microsoft-Windows-Client-EmbeddedExp-Package
echo 64) Back to features menu
echo 65) Exit
echo.
echo.
echo.
set /p web=Type option:
if "%web%"=="51" DISM /online /enable-feature /featurename:Client-EmbeddedBootExp
if "%web%"=="52" DISM /online /enable-feature /featurename:Client-EmbeddedLogon
if "%web%"=="53" DISM /online /enable-feature /featurename:Client-KeyboardFilter
if "%web%"=="54" DISM /online /enable-feature /featurename:UnifiedWriteFilter
if "%web%"=="55" DISM /online /enable-feature /featurename:MultiPoint-Connector
if "%web%"=="56" DISM /online /enable-feature /featurename:MultiPoint-Connector-Services
if "%web%"=="57" DISM /online /enable-feature /featurename:MultiPoint-Tools
if "%web%"=="58" DISM /online /enable-feature /featurename:DataCenterBridging
if "%web%"=="59" DISM /online /enable-feature /featurename:Microsoft-Hyper-V-Common-Drivers-Package
if "%web%"=="60" DISM /online /enable-feature /featurename:Microsoft-Windows-NetFx-VCRedist-Package
if "%web%"=="61" DISM /online /enable-feature /featurename:Microsoft-Windows-Printing-PrintToPDFServices-Package
if "%web%"=="62" DISM /online /enable-feature /featurename:Microsoft-Windows-Printing-XPSServices-Package
if "%web%"=="63" DISM /online /enable-feature /featurename:Microsoft-Windows-Client-EmbeddedExp-Package
if "%web%"=="64" goto winfeaturesmenu
if "%web%"=="65" goto exit
goto addwinfeat2


:remwinfeat
mode con:cols=80 lines=40
echo.
echo Here you will be able to remove Windows Optional Features
echo.
echo.
echo.
echo 1) Microsoft-Windows-Subsystem-Linux
echo 2) LegacyComponents
echo 3) DirectPlay
echo 4) SimpleTCP
echo 5) SNMP
echo 6) WMISnmpProvider
echo 7) MicrosoftWindowsPowerShellV2Root
echo 8) MicrosoftWindowsPowerShellV2
echo 9) Windows-Identity-Foundation
echo 10) Internet-Explorer-Optional-amd64
echo 11) NetFx3
echo 12) NetFx4-AdvSrvs
echo 13) NetFx4Extended-ASPNET45
echo 14) MediaPlayback
echo 15) WindowsMediaPlayer
echo 16) Printing-PrintToPDFServices-Features
echo 17) Printing-XPSServices-Features
echo 18) RasRip
echo 19) MSRDC-Infrastructure
echo 20) SearchEngine-Client-Package
echo 21) TelnetClient
echo 22) TFTP
echo 23) Xps-Foundation-Xps-Viewer
echo 24) WorkFolders-Client
echo 25) Next Page
echo 0) Back
echo.
echo.
echo.
set /p web=Type option:
if "%web%"=="1" DISM /online /disable-feature /featurename:Microsoft-Windows-Subsystem-Linux
if "%web%"=="2" DISM /online /disable-feature /featurename:LegacyComponents && pause && goto remwinfeat
if "%web%"=="3" DISM /online /disable-feature /featurename:DirectPlay
if "%web%"=="4" DISM /online /disable-feature /featurename:SimpleTCP
if "%web%"=="5" DISM /online /disable-feature /featurename:SNMP
if "%web%"=="6" DISM /online /disable-feature /featurename:WMISnmpProvider
if "%web%"=="7" DISM /online /disable-feature /featurename:MicrosoftWindowsPowerShellV2Root
if "%web%"=="8" DISM /online /disable-feature /featurename:MicrosoftWindowsPowerShellV2
if "%web%"=="9" DISM /online /disable-feature /featurename:Windows-Identity-Foundation
if "%web%"=="10" DISM /online /disable-feature /featurename:Internet-Explorer-Optional-amd64
if "%web%"=="11" DISM /online /disable-feature /featurename:NetFx3
if "%web%"=="12" DISM /online /disable-feature /featurename:NetFx4-AdvSrvs
if "%web%"=="13" DISM /online /disable-feature /featurename:NetFx4Extended-ASPNET45
if "%web%"=="14" DISM /online /disable-feature /featurename:MediaPlayback
if "%web%"=="15" DISM /online /disable-feature /featurename:WindowsMediaPlayer
if "%web%"=="16" DISM /online /disable-feature /featurename:Printing-PrintToPDFServices-Features
if "%web%"=="17" DISM /online /disable-feature /featurename:Printing-XPSServices-Features
if "%web%"=="18" DISM /online /disable-feature /featurename:RasRip
if "%web%"=="19" DISM /online /disable-feature /featurename:MSRDC-Infrastructure
if "%web%"=="20" DISM /online /disable-feature /featurename:SearchEngine-Client-Package
if "%web%"=="21" DISM /online /disable-feature /featurename:TelnetClient
if "%web%"=="22" DISM /online /disable-feature /featurename:TFTP
if "%web%"=="23" DISM /online /disable-feature /featurename:Xps-Foundation-Xps-Viewer
if "%web%"=="24" DISM /online /disable-feature /featurename:WorkFolders-Client
if "%web%"=="25" goto remwinfeat1
if "%web%"=="0" goto winfeaturesmenu
goto remwinfeat






:remwinfeat1
mode con:cols=80 lines=40
echo.
echo 26) SMB1Protocol
echo 27) Microsoft-Hyper-V-All
echo 28) Microsoft-Hyper-V-Tools-All
echo 29) Microsoft-Hyper-V-Management-Clients
echo 30) Microsoft-Hyper-V-Management-PowerShell
echo 31) Microsoft-Hyper-V
echo 32) Microsoft-Hyper-V-Hypervisor
echo 33) Microsoft-Hyper-V-Services
echo 34) Printing-Foundation-Features
echo 35) Printing-Foundation-LPRPortMonitor
echo 36) Printing-Foundation-LPDPrintService
echo 37) Printing-Foundation-InternetPrinting-Client
echo 38) FaxServicesClientPackage
echo 39) ScanManagementConsole
echo 40) DirectoryServices-ADAM-Client
echo 41) ServicesForNFS-ClientOnly
echo 42) ClientForNFS-Infrastructure
echo 43) NFS-Administration
echo 44) RasCMAK
echo 45) TIFFIFilter
echo 46) SmbDirect
echo 47) Containers
echo 48) Client-DeviceLockdown
echo 49) Client-EmbeddedShellLauncher
echo 50) Next Page
echo.
echo.
echo.
set /p web=Type option:
if "%web%"=="26" DISM /online /disable-feature /featurename:SMB1Protocol
if "%web%"=="27" DISM /online /disable-feature /featurename:Microsoft-Hyper-V-All
if "%web%"=="28" DISM /online /disable-feature /featurename:Microsoft-Hyper-V-Tools-All
if "%web%"=="29" DISM /online /disable-feature /featurename:Microsoft-Hyper-V-Management-Clients
if "%web%"=="30" DISM /online /disable-feature /featurename:Microsoft-Hyper-V-Management-PowerShell
if "%web%"=="31" DISM /online /disable-feature /featurename:Microsoft-Hyper-V
if "%web%"=="32" DISM /online /disable-feature /featurename:Microsoft-Hyper-V-Hypervisor
if "%web%"=="33" DISM /online /disable-feature /featurename:Microsoft-Hyper-V-Services
if "%web%"=="34" DISM /online /disable-feature /featurename:Printing-Foundation-Features
if "%web%"=="35" DISM /online /disable-feature /featurename:Printing-Foundation-LPRPortMonitor
if "%web%"=="36" DISM /online /disable-feature /featurename:Printing-Foundation-LPDPrintService
if "%web%"=="37" DISM /online /disable-feature /featurename:Printing-Foundation-InternetPrinting-Client
if "%web%"=="38" DISM /online /disable-feature /featurename:FaxServicesClientPackage
if "%web%"=="39" DISM /online /disable-feature /featurename:ScanManagementConsole
if "%web%"=="40" DISM /online /disable-feature /featurename:DirectoryServices-ADAM-Client
if "%web%"=="41" DISM /online /disable-feature /featurename:ServicesForNFS-ClientOnly
if "%web%"=="42" DISM /online /disable-feature /featurename:ClientForNFS-Infrastructure
if "%web%"=="43" DISM /online /disable-feature /featurename:NFS-Administration
if "%web%"=="44" DISM /online /disable-feature /featurename:RasCMAK
if "%web%"=="45" DISM /online /disable-feature /featurename:TIFFIFilter
if "%web%"=="46" DISM /online /disable-feature /featurename:SmbDirect
if "%web%"=="47" DISM /online /disable-feature /featurename:Containers
if "%web%"=="48" DISM /online /disable-feature /featurename:Client-DeviceLockdown
if "%web%"=="49" DISM /online /disable-feature /featurename:Client-EmbeddedShellLauncher
if "%web%"=="50" goto remwinfeat2
goto remwinfeat1






:remwinfeat2
mode con:cols=80 lines=40
echo.
echo 51) Client-EmbeddedBootExp
echo 52) Client-EmbeddedLogon
echo 53) Client-KeyboardFilter
echo 54) Client-UnifiedWriteFilter
echo 55) MultiPoint-Connector
echo 56) MultiPoint-Connector-Services
echo 57) MultiPoint-Tools
echo 58) DataCenterBridging
echo 59) Microsoft-Hyper-V-Common-Drivers-Package
echo 60) Microsoft-Windows-NetFx-VCRedist-Package
echo 61) Microsoft-Windows-Printing-PrintToPDFServices-Package
echo 62) Microsoft-Windows-Printing-XPSServices-Package
echo 63) Microsoft-Windows-Client-EmbeddedExp-Package
echo 64) Back to features menu
echo 65) Exit
echo.
echo.
echo.
set /p web=Type option:
if "%web%"=="51" DISM /online /disable-feature /featurename:Client-EmbeddedBootExp
if "%web%"=="52" DISM /online /disable-feature /featurename:Client-EmbeddedLogon
if "%web%"=="53" DISM /online /disable-feature /featurename:Client-KeyboardFilter
if "%web%"=="54" DISM /online /disable-feature /featurename:UnifiedWriteFilter
if "%web%"=="55" DISM /online /disable-feature /featurename:MultiPoint-Connector
if "%web%"=="56" DISM /online /disable-feature /featurename:MultiPoint-Connector-Services
if "%web%"=="57" DISM /online /disable-feature /featurename:MultiPoint-Tools
if "%web%"=="58" DISM /online /disable-feature /featurename:DataCenterBridging
if "%web%"=="59" DISM /online /disable-feature /featurename:Microsoft-Hyper-V-Common-Drivers-Package
if "%web%"=="60" DISM /online /disable-feature /featurename:Microsoft-Windows-NetFx-VCRedist-Package
if "%web%"=="61" DISM /online /disable-feature /featurename:Microsoft-Windows-Printing-PrintToPDFServices-Package
if "%web%"=="62" DISM /online /disable-feature /featurename:Microsoft-Windows-Printing-XPSServices-Package
if "%web%"=="63" DISM /online /disable-feature /featurename:Microsoft-Windows-Client-EmbeddedExp-Package
if "%web%"=="64" goto winfeaturesmenu
if "%web%"=="65" goto exit
goto remwinfeat2

:viewmetro
mode con:cols=80 lines=22
echo Scanning APPX Packages... Result will open in Notepad
echo Auto generated txt is deleted after closing Notepad so Save As new file.
powershell.exe "Get-AppxPackage -AllUsers | Select Name, PackageFullName" > .\winappx.txt
notepad .\winappx.txt
pause
del .\winappx.txt
goto viewinfomenu


:viewwinfeat
mode con:cols=80 lines=22
echo Scanning Windows Optional Features... Result will open in Notepad
echo Auto generated txt is deleted after closing Notepad so Save As new file.
powershell.exe get-windowsoptionalfeature -online > c:\winfeat.txt
notepad .\winfeat.txt
pause
del .\winfeat.txt
goto viewinfomenu

:dismscan
echo Scanning System Files with DISM...
echo Using /CheckHealth and /ScanHealth commands
echo This may take a while...
echo.
powershell.exe DISM /Online /Cleanup-Image /CheckHealth
echo.
pause
powershell.exe DISM /Online /Cleanup-Image /ScanHealth
pause
goto syshealthmenu


:dismfix
echo This will attempt to fix any issues with your install..
echo This will take a while...
echo.
powershell DISM /Online /Cleanup-Image /RestoreHealth
pause
goto syshealthmenu


:sfccheck
echo This will scan your system with Windows System File Checker
echo This will take a while..
echo.
SFC /scannow
pause
goto syshealthmenu



