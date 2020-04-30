 @echo off
 CLS
 ECHO.
 ECHO.
echo I made this script using various bits of info I found using
echo the Microsoft site and a few forum boards. I have tested
echo this and use it frequently, and will continue to improve this script.
echo Tested on Windows 10: Home and Pro on x64 and ARM64.
echo Any issues contact @Empyreal96 on xda-developers.com
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
title Empyreal's Toolbox
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
echo 5) Run Routine Services Disable (Services safe to disable)
echo 6) Telemetry and User Data Sharing
echo 7) OneDrive
echo 8) Misc Tweaks
echo 9) Exit
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
if "%web%"=="8" goto misc
if "%web%"=="9" goto exit
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
echo 3) Stop Cortana Searching Online
echo 4) Start Cortana Searching Online
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