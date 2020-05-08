@echo off
color 7D
mode con:cols=102 lines=32
CLS
ECHO ====================================================================================
echo.
echo **This message will appear once more after acquiring Admin permissions.**
echo =====================================================================================
echo.
echo This is my first script, started out as a simple tool I wanted to help me change parts
echo of Windows 10 on my Lumia 950 XL.. I got the itch for it now I have gone beyond that
echo Now it is becoming a fully-fledged Toolbox.. It is in constant progress.
echo =====================================================================================
echo.
echo Information/tweaks/commands used in this script:
echo =====================================================================================
echo.
echo I already had basic knowledge of some things. (Shown in first few commits of the project)
echo I used the internet trawling Microsoft's Documentation, Superuser forums, various Windows 10 Forums.
echo MajorGeeks website provided alot of the Registry tweaks used.
echo Tron script on Github: https://github.com/bmrf/tron for Removing Bad Updates and some Services
echo BeckarAC at Github for help structuring the code in the beginning Powershell section
echo =====================================================================================
echo.
echo Tested on Windows 10 Pro x64 and ARM64, Windows 10 Home ARM64 (Please tell me what editions work)
echo =====================================================================================
echo.
echo Any feedback or suggestions contact me on GitHub:
echo https://github.com/empyreal96 
echo ========================================================================
echo Anything that doesn't work, post a thread here:
echo https://github.com/Empyreal96/win-10-services-toolbox/issues
echo ========================================================================
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
mode con:cols=85 lines=25
cls
echo ===============================================================================
echo THIS TOOL WILL MODIFY VARIOUS PARTS OF WINDOWS. BY USING THIS TOOL
echo YOU KNOWINGLY ACCEPT THE RISKS IN MODIFYING/CHANGING/DELETING ANYTHING
echo THAT REQUIRES ADMIN PERMISSION AND/OR USED BY CERTAIN SYSTEM FILES/SERVICES.
echo I WILL NOT BE HELD RESPONSIBLE FOR ANY DAMAGE CAUSED, I TEST THIS THOROUGHLY WITH
echo MY COMPUTERS, BUT NO PC IS THE SAME.
echo.
echo IF YOU DON'T KNOW WHAT YOU WANT TO DO WITH THIS TOOL CLOSE THIS WINDOW NOW.
echo ===============================================================================
pause
goto home

title Windows 10 Toolbox by Empyreal96@Github
:home
mode con:cols=80 lines=25
cls
echo.
echo This tool will allow you to disable various components of Windows or enable
echo various parts of Windows, each section contains different tweaks for different
echo situations i.e Windows Update, Search, Features, Apps etc..
echo any issues contact @Empyreal96 at Github
echo.
echo.
echo 1) Windows Update
echo 2) Windows Search
echo 3) Cortana
echo 4) Windows Spotlight (Lockscreen Web Images, Lockscreen "Facts")
echo 5) Windows Services
echo 6) Telemetry and User Data Sharing
echo 7) OneDrive
echo 8) Powershell Tweaks
echo 9) Settings and Tweaks
echo 10) Exit
echo.
echo.
set /p web=Type option:
if "%web%"=="1" goto update
if "%web%"=="2" goto search
if "%web%"=="3" goto cortana
if "%web%"=="4" goto spotlight
if "%web%"=="5" goto winserv
if "%web%"=="6" goto telemetry
if "%web%"=="7" goto onedrive
if "%web%"=="8" goto powershellmenu
if "%web%"=="9" goto settweakmenu
if "%web%"=="10" exit
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
echo 3) Disable Automatic Driver Downloads
echo 4) Enable Automatic Driver Downloads
echo 5) Disable Automatic Maintenance
echo 6) Enable Automatic Maintenance
echo 7) Uninstall 'Bad' Updates
echo 8) Back
echo 9) Exit
echo.
echo.
set /p web=Type option:
if "%web%"=="1" goto startwu
if "%web%"=="2" goto stopwu
if "%web%"=="3" call :AutoWinDriverOff
if "%web%"=="4" call :AutoWinDriverOn
if "%web%"=="5" reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" /v MaintenanceDisabled /t REG_DWORD /d 1 /f && pause && goto update
if "%web%"=="6" reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" /v MaintenanceDisabled /t REG_DWORD /d 0 /f && pause && goto update
if "%web%"=="7" call :BadUpdates
if "%web%"=="8" goto home
if "%web%"=="9" exit
goto update

:BadUpdates
cls
echo.
echo This will attempt to Uninstall any bad updates (eg. KB2902907)
echo Not every one of these Updates will be installed so success varies.
echo.
echo Credit for finding these and the commands go to the devs behind
echo the Tron script on Github https://github.com/bmrf/tron
echo.
echo ONLY DO THIS IF YOU KNOW WHAT YOU ARE DOING..
echo.
echo.
set /P removebadup="Do you want to continue? (type y or n)"
if "%removebadup%"=="y" goto BadUpdatesRem
if "%removebadup%"=="n" goto update
goto BadUpdates
:BadUpdatesRem
::KB 2902907 (https://support.microsoft.com/en-us/kb/2902907)
wusa /uninstall /kb:2902907 /norestart /quiet
::KB 2922324 (https://support.microsoft.com/en-us/kb/2922324)
wusa /uninstall /kb:2922324 /norestart /quiet
::KB 2952664 (https://support.microsoft.com/en-us/kb/2952664)
wusa /uninstall /kb:2952664 /norestart /quiet
::KB 2976978 (https://support.microsoft.com/en-us/kb/2976978)
wusa /uninstall /kb:2976978 /norestart /quiet
::KB 2977759 (https://support.microsoft.com/en-us/kb/2977759)
wusa /uninstall /kb:2977759 /norestart /quiet
::KB 2990214 (https://support.microsoft.com/en-us/kb/2990214)
wusa /uninstall /kb:2990214 /norestart /quiet
::KB 3012973 (https://support.microsoft.com/en-us/kb/3012973)
wusa /uninstall /kb:3012973 /norestart /quiet
::KB 3014460 (https://support.microsoft.com/en-us/kb/3014460)
wusa /uninstall /kb:3014460 /norestart /quiet
::KB 3015249 (https://support.microsoft.com/en-us/kb/3015249)
wusa /uninstall /kb:3015249 /norestart /quiet
::KB 3021917 (https://support.microsoft.com/en-us/kb/3021917)
wusa /uninstall /kb:3021917 /norestart /quiet
::KB 3022345 (https://support.microsoft.com/en-us/kb/3022345)
wusa /uninstall /kb:3022345 /norestart /quiet
::KB 3035583 (https://support.microsoft.com/en-us/kb/3035583)
wusa /uninstall /kb:3035583 /norestart /quiet
::KB 3044374 (https://support.microsoft.com/en-us/kb/3044374)
wusa /uninstall /kb:3044374 /norestart /quiet
::KB 3050265 (https://support.microsoft.com/en-us/kb/3050265)
wusa /uninstall /kb:3050265 /norestart /quiet
::KB 3050267 (https://support.microsoft.com/en-us/kb/3050267)
wusa /uninstall /kb:3050267 /norestart /quiet
::KB 3065987 (https://support.microsoft.com/en-us/kb/3065987)
wusa /uninstall /kb:3065987 /norestart /quiet
::KB 3068708 (https://support.microsoft.com/en-us/kb/3068708)
wusa /uninstall /kb:3068708 /norestart /quiet
::KB 3075249 (https://support.microsoft.com/en-us/kb/3075249)
wusa /uninstall /kb:3075249 /norestart /quiet
::KB 3075851 (https://support.microsoft.com/en-us/kb/3075851)
wusa /uninstall /kb:3075851 /norestart /quiet
::KB 3075853 (https://support.microsoft.com/en-us/kb/3075853)
wusa /uninstall /kb:3075853 /norestart /quiet
::KB 3080149 (https://support.microsoft.com/en-us/kb/3080149)
wusa /uninstall /kb:3080149 /norestart /quiet
::Additional KB entries removed by Microsoft; originally associated with telemetry
wusa /uninstall /kb:2976987 /norestart /quiet
wusa /uninstall /kb:3068707 /norestart /quiet
cls
echo If any of the Updates installed were installed they have been removed, Restart to see effect.
echo If you got this message instantly then none of these updates are installed
pause
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

:AutoWinDriverOff
echo Windows Registry Editor Version 5.00 > .\AutoWinDriverOff.reg
echo. >> .\AutoWinDriverOff.reg
echo [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\current\device\Update] >> .\AutoWinDriverOff.reg
echo "ExcludeWUDriversInQualityUpdate"=dword:00000001 >> .\AutoWinDriverOff.reg
echo. >> .\AutoWinDriverOff.reg
echo [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\default\Update] >> .\AutoWinDriverOff.reg
echo "ExcludeWUDriversInQualityUpdate"=dword:00000001 >> .\AutoWinDriverOff.reg
echo. >> .\AutoWinDriverOff.reg
echo [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\default\Update\ExcludeWUDriversInQualityUpdate] >> .\AutoWinDriverOff.reg
echo "value"=dword:00000001 >> .\AutoWinDriverOff.reg
echo. >> .\AutoWinDriverOff.reg
echo [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings] >> .\AutoWinDriverOff.reg
echo "ExcludeWUDriversInQualityUpdate"=dword:00000001 >> .\AutoWinDriverOff.reg
echo. >> .\AutoWinDriverOff.reg
echo [HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate] >> .\AutoWinDriverOff.reg
echo "ExcludeWUDriversInQualityUpdate"=dword:00000001 >> .\AutoWinDriverOff.reg
echo. >> .\AutoWinDriverOff.reg
echo. >> .\AutoWinDriverOff.reg
reg import .\AutoWinDriverOff.reg
pause
del .\AutoWinDriverOff.reg
goto update

:AutoWinDriverOn
echo Windows Registry Editor Version 5.00 > .\AutoWinDriverOn.reg
echo. >> .\AutoWinDriverOn.reg
echo [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\current\device\Update] >> .\AutoWinDriverOn.reg
echo "ExcludeWUDriversInQualityUpdate"=dword:00000000 >> .\AutoWinDriverOn.reg
echo. >> .\AutoWinDriverOn.reg
echo [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\default\Update] >> .\AutoWinDriverOn.reg
echo "ExcludeWUDriversInQualityUpdate"=dword:00000000 >> .\AutoWinDriverOn.reg
echo. >> .\AutoWinDriverOn.reg
echo [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\default\Update\ExcludeWUDriversInQualityUpdate] >> .\AutoWinDriverOn.reg
echo "value"=dword:00000000 >> .\AutoWinDriverOn.reg
echo. >> .\AutoWinDriverOn.reg
echo [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings] >> .\AutoWinDriverOn.reg
echo "ExcludeWUDriversInQualityUpdate"=dword:00000000 >> .\AutoWinDriverOn.reg
echo. >> .\AutoWinDriverOn.reg
echo [HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate] >> .\AutoWinDriverOn.reg
echo "ExcludeWUDriversInQualityUpdate"=dword:00000000 >> .\AutoWinDriverOn.reg
echo. >> .\AutoWinDriverOn.reg
echo. >> .\AutoWinDriverOn.reg
reg import .\AutoWinDriverOn.reg
pause
del .\AutoWinDriverOn.reg
goto update



:search
mode con:cols=80 lines=22
cls
echo.
echo Here you can Start or Stop Windows Search and Indexing
echo You can also enable the Rounded 'Immersive' Search (Windows 10 1903 min.)
echo.
echo.
echo 1) Start Windows Search Services
echo 2) Stop Windows Search Services
echo 3) Enable Immersive Full Screen Search (Task Bar, Build 1903)
echo 4) Disable Immersive Full Screen Search
echo 5) Back
echo 6) Exit
echo.
echo.
set /p web=Type option:
if "%web%"=="1" goto searchstart
if "%web%"=="2" goto searchstop
if "%web%"=="3" call :ImmersiveSearch
if "%web%"=="4" call :NormalSearch
if "%web%"=="5" goto home
if "%web%"=="6" exit
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

:ImmersiveSearch
echo Windows Registry Editor Version 5.00 > .\ImmersiveSearch.reg
echo. >> .\ImmersiveSearch.reg
echo [HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Search] >> .\ImmersiveSearch.reg
echo "ImmersiveSearch"=dword:00000001 >> .\ImmersiveSearch.reg
echo. >> .\ImmersiveSearch.reg
echo [HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Search\Flighting\Override] >> .\ImmersiveSearch.reg
echo "CenterScreenRoundedCornerRadius"=dword:00000009 >> .\ImmersiveSearch.reg
echo "ImmersiveSearchFull"=dword:00000001 >> .\ImmersiveSearch.reg
echo. >> .\ImmersiveSearch.reg
reg import .\ImmersiveSearch.reg
pause
del .\ImmersiveSearch.reg
goto search

:NormalSearch
echo Windows Registry Editor Version 5.00 > .\NormalSearch.reg
echo. >> .\NormalSearch.reg
echo [HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Search] >> .\NormalSearch.reg
echo "ImmersiveSearch"=- >> .\NormalSearch.reg
echo. >> .\NormalSearch.reg
echo [HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Search\Flighting\Override] >> .\NormalSearch.reg
echo "CenterScreenRoundedCornerRadius"=- >> .\NormalSearch.reg
echo "ImmersiveSearchFull"=- >> .\NormalSearch.reg
echo. >> .\NormalSearch.reg
reg import .\NormalSearch.reg
pause
del .\NormalSearch.reg
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
echo 5) Back
echo 6) Exit
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
echo 3) Disable Spotlight Wallpapers
echo 4) Enable Spotlight Wallpapers
echo 5) Disable ALL Spotlight Features
echo 6) Enable ALL Spotlight Features
echo 7) Backup Spotlight Wallpapers to Desktop
echo 8) Back
echo 9) Exit
echo.
echo.
set /p web=Type option:
if "%web%"=="1" goto nofacts 
if "%web%"=="2" goto yesfacts
if "%web%"=="3" goto nowall
if "%web%"=="4" goto yeswall
if "%web%"=="5" goto nospot
if "%web%"=="6" goto yesspot
if "%web%"=="7" goto BackSpot
if "%web%"=="8" goto home
if "%web%"=="9" exit
goto spotlight


:BackSpot
@echo off
robocopy %localappdata%\Packages\Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy\LocalState\Assets %userprofile%\Desktop\SpotlightImages /min:50000 
rename %userprofile%\Desktop\SpotlightImages\*.* *.jpg
pause
echo Done. Opening Folder Now
explorer %userprofile%\Desktop\SpotlightImages\
goto spotlight

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
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Personalization" /v NoChangingLockScreen /t REG_DWORD /d 1 /f
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
reg add "HKLM\System\CurrentControlSet\Services\EntAppSvc" /v Start /t REG_DWORD /d 4 /f
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
rem ***Windows 10 1703 or Higher***
sc.exe stop WpcMonSvc
sc.exe config WpcMonSvc start=disabled
rem 
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
sc.exe stop fhsvc
sc.exe config fhsvc start=disabled
sc.exe stop NaturalAuthentication
sc.exe config NaturalAuthentication start=disabled
sc.exe stop SessionEnv
sc.exe config SessionEnv start=disabled
sc.exe stop TermService
sc.exe config TermService start=disabled
sc.exe stop SharedRealitySvc
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v EnableCdp /t REG_DWORD /d 1 /f
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
goto winserv


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
echo 3) Disable Connected User Experience Services
echo 4) Enable Connected User Experience Services
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
if "%web%"=="7" exit
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
if "%web%"=="5" exit
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
if "%web%"=="6" exit
goto powershellmenu

:metrouimenu
mode con:cols=80 lines=22
echo.
echo Here you can modify built-in bloat Windows Apps.
echo.
echo.
echo 1) Remove all 'Bloat' Apps
echo 2) Re-Install all 'Bloat' Apps (Not Working)
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
echo This section was added by @BeckarAC at Github
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
if "%web%"=="4" exit
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
if "%web%"=="4" exit
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
if "%web%"=="5" exit
goto syshealthmenu

:addwinfeat
cls
mode con:cols=80 lines=40
echo.
echo Here you will be able to add Windows Optional Features
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
if "%web%"=="65" exit
goto addwinfeat2


:remwinfeat
mode con:cols=80 lines=40
echo.
echo Here you will be able to remove Windows Optional Features
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
if "%web%"=="65" exit
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
cls
mode con:cols=80 lines=22
echo Scanning Windows Optional Features... Result will open in Notepad
echo Auto generated txt is deleted after closing Notepad so Save As new file.
powershell.exe get-windowsoptionalfeature -online > .\winfeat.txt
notepad .\winfeat.txt
pause
del .\winfeat.txt
goto viewinfomenu

:dismscan
cls
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
cls
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

:nobloat
cls
echo.
echo This will attempt to remove built in 'Bloatware'
echo apps like News, Get Help, 3DViewer, OneNote etc.
echo *Success may vary due to different Windows versions, 
echo Appx Package name changes and other factors*
echo THIS WILL TAKE TIME.
echo.
pause
powershell.exe "Get-AppxPackage *Microsoft.BingNews* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.GetHelp* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.Getstarted* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.Microsoft3DViewer* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.MicrosoftOfficeHub* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.MicrosoftSolitaireCollection* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.NetworkSpeedTest* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.Office.OneNote* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.Office.Sway* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.OneConnect* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.Print3D* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.RemoteDesktop* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.SkypeApp* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.WindowsAlarms* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.WindowsFeedbackHub* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.WindowsMaps* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.WindowsSoundRecorder* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.Xbox.TCUI* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.XboxApp* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.XboxGameOverlay* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.XboxIdentityProvider* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.XboxSpeechToTextOverlay* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.ZuneMusic* | Remove-AppxPackage"
powershell.exe "Get-AppxPackage *Microsoft.ZuneVideo* | Remove-AppxPackage"
cls
echo.
echo.
echo Finished. Some removal of Apps may have failed due to different Windows Builds,
echo different installed Apps and a few other variations.. This will be updated as and when
echo.
pause
goto metrouimenu

:yesbloat
echo This will attempt to install all the Default Apps installed with Windows.
echo This will vary in success with Windows Builds (Ideally 18xx or up)
echo.
echo THIS DOESN'T WORK FOR ME. I left it in though as a placeholder if you know how 
echo to make this work please let me know
pause
start powershell.exe -command "& {Get-AppxPackage -allusers | foreach {Add-AppxPackage -register "$($_.InstallLocation)\appxmanifest.xml" -DisableDevelopmentMode}}
pause
goto metrouimenu


:winserv
mode con:cols=80 lines=22
echo.
echo Here you can disable or enable *safe* Services
echo By safe I mean no visable impact on my systems when running this
echo I will be improving this section over time.
echo.
echo.
echo 1) View Services Being Changed
echo 2) Disable Services
echo 3) Re-Enable Services
echo 4) Back
echo 5) Exit
echo.
echo.
set /p web=Type option:
if "%web%"=="1" goto viewserv
if "%web%"=="2" goto routine1
if "%web%"=="3" goto yesservsafe
if "%web%"=="4" goto home
if "%web%"=="5" exit
if "%web%"=="6" goto routine1log
goto winserv

:routine1log 
call :routine1 >.\svclist.txt
notepad .\svclist.txt
pause
del .\svclist.txt
goto winserv

:yesservsafe
mode con:cols=80 lines=22
sc.exe config WerSvc start=auto
sc.exe config DiagTrack start=auto
sc.exe config DPS start=auto
sc.exe config MapsBroker start=auto
sc.exe config PcaSvc start=auto
sc.exe config Spooler start=auto
sc.exe config RemoteRegistry start=auto
sc.exe config lmhosts start=auto
sc.exe config WerSvc start=auto
sc.exe config stisvc start=auto
sc.exe config lfsvc start=auto
sc.exe config WbioSrvc start=auto
sc.exe config WMPNetworkSvc start=auto
reg add "HKLM\System\CurrentControlSet\Services\EntAppSvc" /v Start /t REG_DWORD /d 2 /f
sc.exe config HvHost start=auto
sc.exe config vmickvpexchange start=auto
sc.exe config vmicguestinterface start=auto
sc.exe config vmicshutdown start=auto
sc.exe config vmicheartbeat start=auto
sc.exe config vmicvmsession start=auto
sc.exe config vmicrdv start=auto
sc.exe config vmictimesync start=auto
sc.exe config vmicvss start=auto
sc.exe config AppVClient start=auto
sc.exe config RemoteAccess start=auto
sc.exe config SCardSvr start=auto
sc.exe config UevAgentService start=auto
sc.exe config ALG start=auto 
sc.exe config PeerDistSvc start=auto
sc.exe config WpcMonSvc start=auto
sc.exe config RpcLocator start=auto
sc.exe config RetailDemo start=auto
sc.exe config ScDeviceEnum start=auto
sc.exe config SCPolicySvc start=auto
sc.exe config FrameServer start=auto
sc.exe config SNMPTRAP start=auto
sc.exe config wisvc start=auto
sc.exe config WinRM start=auto
sc.exe config fhsvc start=auto
sc.exe config NaturalAuthentication start=auto
sc.exe config SessionEnv start=auto
sc.exe config TermService start=auto
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v EnableCdp /t REG_DWORD /d 0 /f
sc.exe config VSS start=auto
sc.exe config Wecsvc start=auto
sc.exe config spectrum start=auto
reg add "HKLM\SYSTEM\CurrentControlSet\Services\XtaCache" /v start /t REG_DWORD /d 2 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v Disabled /t REG_DWORD /d 1 /f
pause
goto winserv

:viewserv
echo Displaying list in Notepad..
echo. > .\svclist.txt
echo. >> .\svclist.txt
echo Service Name - Service Full Name  >> .\svclist.txt
echo. >> .\svclist.txt
echo. >> .\svclist.txt
echo WerSvc - Windows Error Reporting >> .\svclist.txt
echo DiagTrack - Connected User Experiences And Telemetry >> .\svclist.txt
echo DPS - Diagnostic Policy Service >> .\svclist.txt
echo MapsBroker - Downloaded Maps Manager >> .\svclist.txt
echo PcaSvc - Program Compatability Assisstant Service >> .\svclist.txt
echo Spooler - Print Spooler >> .\svclist.txt
echo RemoteRegistry - Remote Registry >> .\svclist.txt
echo lmhosts - TCP/IP (NetBIOS Helper) >> .\svclist.txt
echo stisvc - Still Imaging Service >> .\svclist.txt
echo lfsvc - Geolocation Service >> .\svclist.txt
echo WbioSrvc - Windows Biometric Service >> .\svclist.txt
echo WMPNetworkSvc - Windows Media Player Network Sharing Service >> .\svclist.txt
echo EntAppSvc - Enterprise App Management Service >> .\svclist.txt
echo HvHost - HV Host Service >> .\svclist.txt
echo vmickvpexchange - Hyper-V Data Exchange Service >> .\svclist.txt
echo vmicguestinterface - Hyper-V Guest Service Interface >> .\svclist.txt
echo vmicshutdown - Hyper-V Guest Shutdown Service >> .\svclist.txt
echo vmicheartbeat - Hyper-V Heartbeat Service >> .\svclist.txt
echo vmicvmsession - Hyper-V PowerShell Direct Service >> .\svclist.txt
echo vmicrdv - Hyper-V Remote Desktop Virtualization Service >> .\svclist.txt
echo vmictimesync - Hyper-V Time Synchronization Service >> .\svclist.txt
echo vmicvss - Hyper-V Volume Shadow Copy Requestor >> .\svclist.txt
echo AppVClient - Microsoft App-V Client >> .\svclist.txt
echo RemoteAccess - Routing and Remote Access >> .\svclist.txt
echo SCardSvr - Smart Card >> .\svclist.txt
echo UevAgentService - User Experience Virtualization Service >> .\svclist.txt
echo ALG  - Application Layer Gateway Service >> .\svclist.txt
echo PeerDistSvc - BranchCache >> .\svclist.txt
echo WpcMonSvc - Parental Controls Service **Windows 10 1809 or Higher** >> .\svclist.txt
echo RpcLocator - Remote Procedure Call (RPC) Locator >> .\svclist.txt
echo RetailDemo - Retail Demo >> .\svclist.txt
echo ScDeviceEnum - Smart Card Device Enumeration Service >> .\svclist.txt
echo SCPolicySvc - Smart Card Removal Policy >> .\svclist.txt
echo FrameServer - Windows Camera Frame Server >> .\svclist.txt
echo SNMPTRAP - SNMP Trap >> .\svclist.txt
echo wisvc - Windows Insider Service >> .\svclist.txt
echo WinRM - Windows Remote Management Service >> .\svclist.txt
echo fhsvc - File History Service >> .\svclist.txt
echo NaturalAuthentication - Natural Authentication >> .\svclist.txt
echo SessionEnv - Remote Desktop Configuration >> .\svclist.txt
echo TermService - Remote Desktop Services >> .\svclist.txt
echo ShareRealitySvc - Spatial Data Service >> .\svclist.txt
echo VSS - Volume Shadow Copy >> .\svclist.txt
echo Wecsvc - Windows Event Collector >> .\svclist.txt
echo spectrum - Windows Perception Service >> .\svclist.txt
notepad .\svclist.txt
pause
del .\svclist.txt
goto winserv


:settweakmenu
mode con:cols=80 lines=22
echo.
echo Here you can modify Settings for various Features
echo.
echo.
echo 1) Appearance
echo 2) Context Menu Items
echo 3) Windows Explorer
echo 4) Windows Security and Defender
echo 5) Windows System Settings
echo 6) Windows Programs and Features
echo 7) Misc Tweaks
echo 8) Advanced Misc Tweaks
echo 9) Back
echo 10) Exit
echo.
echo.
set /p web=Type option:
if "%web%"=="1" goto appearance 
if "%web%"=="2" goto contextmenu
if "%web%"=="3" goto explorermenu
if "%web%"=="4" goto winsecuritymenu
if "%web%"=="5" goto winsyssettings
if "%web%"=="6" goto WinPrograms
if "%web%"=="7" goto misc
if "%web%"=="8" goto AdvTweak
if "%web%"=="9" goto home
if "%web%"=="10" goto exit
goto settweakmenu


:WinPrograms
mode con:cols=80 lines=22
echo.
echo Here you can activate some Programs that are disabled by default.
echo Currently needing ideas for more things here.
echo.
echo.
echo 1) Try to install Group Policy Editor (Windows 10 Home)
echo 2) Enable "Classic" Photo Viewer
echo 3) PLACEHOLDER
echo 4) PLACEHOLDER
echo 5) Back
echo 6) Exit
echo.
echo.
set /p web=Type option:
if "%web%"=="1" goto GPInstaller
if "%web%"=="2" goto PhotoviewerInstaller
if "%web%"=="3" goto WinPrograms
if "%web%"=="4" goto WinPrograms
if "%web%"=="5" goto settweakmenu
if "%web%"=="6" exit
goto WinPrograms


:PhotoviewerInstaller
echo Windows Registry Editor Version 5.00 > .\PhotoInstaller.reg
echo. >> .\PhotoInstaller.reg
echo [HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\open] >> .\PhotoInstaller.reg
echo "MuiVerb"="@photoviewer.dll,-3043" >> .\PhotoInstaller.reg
echo. >> .\PhotoInstaller.reg
echo [HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\open\command] >> .\PhotoInstaller.reg
echo @=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,\ >> .\PhotoInstaller.reg
echo   00,5c,00,53,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,72,00,75,00,\ >> .\PhotoInstaller.reg
echo   6e,00,64,00,6c,00,6c,00,33,00,32,00,2e,00,65,00,78,00,65,00,20,00,22,00,25,\ >> .\PhotoInstaller.reg
echo   00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,00,46,00,69,00,6c,00,65,00,73,00,\ >> .\PhotoInstaller.reg
echo   25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,20,00,50,00,68,00,6f,\ >> .\PhotoInstaller.reg
echo   00,74,00,6f,00,20,00,56,00,69,00,65,00,77,00,65,00,72,00,5c,00,50,00,68,00,\ >> .\PhotoInstaller.reg
echo   6f,00,74,00,6f,00,56,00,69,00,65,00,77,00,65,00,72,00,2e,00,64,00,6c,00,6c,\ >> .\PhotoInstaller.reg
echo   00,22,00,2c,00,20,00,49,00,6d,00,61,00,67,00,65,00,56,00,69,00,65,00,77,00,\ >> .\PhotoInstaller.reg
echo   5f,00,46,00,75,00,6c,00,6c,00,73,00,63,00,72,00,65,00,65,00,6e,00,20,00,25,\ >> .\PhotoInstaller.reg
echo   00,31,00,00,00 >> .\PhotoInstaller.reg
echo. >> .\PhotoInstaller.reg
echo [HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\open\DropTarget] >> .\PhotoInstaller.reg
echo "Clsid"="{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}" >> .\PhotoInstaller.reg
echo. >> .\PhotoInstaller.reg
echo [HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Bitmap] >> .\PhotoInstaller.reg
echo "ImageOptionFlags"=dword:00000001 >> .\PhotoInstaller.reg
echo "FriendlyTypeName"=hex(2):40,00,25,00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,\ >> .\PhotoInstaller.reg
echo   00,46,00,69,00,6c,00,65,00,73,00,25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,\ >> .\PhotoInstaller.reg
echo   77,00,73,00,20,00,50,00,68,00,6f,00,74,00,6f,00,20,00,56,00,69,00,65,00,77,\ >> .\PhotoInstaller.reg
echo   00,65,00,72,00,5c,00,50,00,68,00,6f,00,74,00,6f,00,56,00,69,00,65,00,77,00,\ >> .\PhotoInstaller.reg
echo   65,00,72,00,2e,00,64,00,6c,00,6c,00,2c,00,2d,00,33,00,30,00,35,00,36,00,00,\ >> .\PhotoInstaller.reg
echo   00 >> .\PhotoInstaller.reg
echo. >> .\PhotoInstaller.reg
echo [HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Bitmap\DefaultIcon] >> .\PhotoInstaller.reg
echo @="%SystemRoot%\\System32\\imageres.dll,-70" >> .\PhotoInstaller.reg
echo. >> .\PhotoInstaller.reg
echo [HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Bitmap\shell\open\command] >> .\PhotoInstaller.reg
echo @=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,\ >> .\PhotoInstaller.reg
echo   00,5c,00,53,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,72,00,75,00,\ >> .\PhotoInstaller.reg
echo   6e,00,64,00,6c,00,6c,00,33,00,32,00,2e,00,65,00,78,00,65,00,20,00,22,00,25,\ >> .\PhotoInstaller.reg
echo   00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,00,46,00,69,00,6c,00,65,00,73,00,\ >> .\PhotoInstaller.reg
echo   25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,20,00,50,00,68,00,6f,\ >> .\PhotoInstaller.reg
echo   00,74,00,6f,00,20,00,56,00,69,00,65,00,77,00,65,00,72,00,5c,00,50,00,68,00,\ >> .\PhotoInstaller.reg
echo   6f,00,74,00,6f,00,56,00,69,00,65,00,77,00,65,00,72,00,2e,00,64,00,6c,00,6c,\ >> .\PhotoInstaller.reg
echo   00,22,00,2c,00,20,00,49,00,6d,00,61,00,67,00,65,00,56,00,69,00,65,00,77,00,\ >> .\PhotoInstaller.reg
echo   5f,00,46,00,75,00,6c,00,6c,00,73,00,63,00,72,00,65,00,65,00,6e,00,20,00,25,\ >> .\PhotoInstaller.reg
echo   00,31,00,00,00 >> .\PhotoInstaller.reg
echo. >> .\PhotoInstaller.reg
echo [HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Bitmap\shell\open\DropTarget] >> .\PhotoInstaller.reg
echo "Clsid"="{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}" >> .\PhotoInstaller.reg
echo. >> .\PhotoInstaller.reg
echo [HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\print] >> .\PhotoInstaller.reg
echo "NeverDefault"="" >> .\PhotoInstaller.reg
echo. >> .\PhotoInstaller.reg
echo [HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\print\command] >> .\PhotoInstaller.reg
echo @=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,\ >> .\PhotoInstaller.reg
echo   00,5c,00,53,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,72,00,75,00,\ >> .\PhotoInstaller.reg
echo   6e,00,64,00,6c,00,6c,00,33,00,32,00,2e,00,65,00,78,00,65,00,20,00,22,00,25,\ >> .\PhotoInstaller.reg
echo   00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,00,46,00,69,00,6c,00,65,00,73,00,\ >> .\PhotoInstaller.reg
echo   25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,20,00,50,00,68,00,6f,\ >> .\PhotoInstaller.reg
echo   00,74,00,6f,00,20,00,56,00,69,00,65,00,77,00,65,00,72,00,5c,00,50,00,68,00,\ >> .\PhotoInstaller.reg
echo   6f,00,74,00,6f,00,56,00,69,00,65,00,77,00,65,00,72,00,2e,00,64,00,6c,00,6c,\ >> .\PhotoInstaller.reg
echo   00,22,00,2c,00,20,00,49,00,6d,00,61,00,67,00,65,00,56,00,69,00,65,00,77,00,\ >> .\PhotoInstaller.reg
echo   5f,00,46,00,75,00,6c,00,6c,00,73,00,63,00,72,00,65,00,65,00,6e,00,20,00,25,\ >> .\PhotoInstaller.reg
echo   00,31,00,00,00 >> .\PhotoInstaller.reg
echo. >> .\PhotoInstaller.reg
echo [HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\print\DropTarget] >> .\PhotoInstaller.reg
echo "Clsid"="{60fd46de-f830-4894-a628-6fa81bc0190d}" >> .\PhotoInstaller.reg
echo. >> .\PhotoInstaller.reg
echo [HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.JFIF] >> .\PhotoInstaller.reg
echo "EditFlags"=dword:00010000 >> .\PhotoInstaller.reg
echo "ImageOptionFlags"=dword:00000001 >> .\PhotoInstaller.reg
echo "FriendlyTypeName"=hex(2):40,00,25,00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,\ >> .\PhotoInstaller.reg
echo   00,46,00,69,00,6c,00,65,00,73,00,25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,\ >> .\PhotoInstaller.reg
echo   77,00,73,00,20,00,50,00,68,00,6f,00,74,00,6f,00,20,00,56,00,69,00,65,00,77,\ >> .\PhotoInstaller.reg
echo   00,65,00,72,00,5c,00,50,00,68,00,6f,00,74,00,6f,00,56,00,69,00,65,00,77,00,\ >> .\PhotoInstaller.reg
echo   65,00,72,00,2e,00,64,00,6c,00,6c,00,2c,00,2d,00,33,00,30,00,35,00,35,00,00,\ >> .\PhotoInstaller.reg
echo   00 >> .\PhotoInstaller.reg
echo. >> .\PhotoInstaller.reg
echo [HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.JFIF\DefaultIcon] >> .\PhotoInstaller.reg
echo @="%SystemRoot%\\System32\\imageres.dll,-72" >> .\PhotoInstaller.reg
echo. >> .\PhotoInstaller.reg
echo [HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.JFIF\shell\open] >> .\PhotoInstaller.reg
echo "MuiVerb"=hex(2):40,00,25,00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,00,46,00,\ >> .\PhotoInstaller.reg
echo   69,00,6c,00,65,00,73,00,25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,\ >> .\PhotoInstaller.reg
echo   00,20,00,50,00,68,00,6f,00,74,00,6f,00,20,00,56,00,69,00,65,00,77,00,65,00,\ >> .\PhotoInstaller.reg
echo   72,00,5c,00,70,00,68,00,6f,00,74,00,6f,00,76,00,69,00,65,00,77,00,65,00,72,\ >> .\PhotoInstaller.reg
echo   00,2e,00,64,00,6c,00,6c,00,2c,00,2d,00,33,00,30,00,34,00,33,00,00,00 >> .\PhotoInstaller.reg
echo. >> .\PhotoInstaller.reg
echo [HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.JFIF\shell\open\command] >> .\PhotoInstaller.reg
echo @=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,\ >> .\PhotoInstaller.reg
echo   00,5c,00,53,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,72,00,75,00,\ >> .\PhotoInstaller.reg
echo   6e,00,64,00,6c,00,6c,00,33,00,32,00,2e,00,65,00,78,00,65,00,20,00,22,00,25,\ >> .\PhotoInstaller.reg
echo   00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,00,46,00,69,00,6c,00,65,00,73,00,\ >> .\PhotoInstaller.reg
echo   25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,20,00,50,00,68,00,6f,\ >> .\PhotoInstaller.reg
echo   00,74,00,6f,00,20,00,56,00,69,00,65,00,77,00,65,00,72,00,5c,00,50,00,68,00,\ >> .\PhotoInstaller.reg
echo   6f,00,74,00,6f,00,56,00,69,00,65,00,77,00,65,00,72,00,2e,00,64,00,6c,00,6c,\ >> .\PhotoInstaller.reg
echo   00,22,00,2c,00,20,00,49,00,6d,00,61,00,67,00,65,00,56,00,69,00,65,00,77,00,\ >> .\PhotoInstaller.reg
echo   5f,00,46,00,75,00,6c,00,6c,00,73,00,63,00,72,00,65,00,65,00,6e,00,20,00,25,\ >> .\PhotoInstaller.reg
echo   00,31,00,00,00 >> .\PhotoInstaller.reg
echo. >> .\PhotoInstaller.reg
echo [HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.JFIF\shell\open\DropTarget] >> .\PhotoInstaller.reg
echo "Clsid"="{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}" >> .\PhotoInstaller.reg
echo. >> .\PhotoInstaller.reg
echo [HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Jpeg] >> .\PhotoInstaller.reg
echo "EditFlags"=dword:00010000 >> .\PhotoInstaller.reg
echo "ImageOptionFlags"=dword:00000001 >> .\PhotoInstaller.reg
echo "FriendlyTypeName"=hex(2):40,00,25,00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,\ >> .\PhotoInstaller.reg
echo   00,46,00,69,00,6c,00,65,00,73,00,25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,\ >> .\PhotoInstaller.reg
echo   77,00,73,00,20,00,50,00,68,00,6f,00,74,00,6f,00,20,00,56,00,69,00,65,00,77,\ >> .\PhotoInstaller.reg
echo   00,65,00,72,00,5c,00,50,00,68,00,6f,00,74,00,6f,00,56,00,69,00,65,00,77,00,\ >> .\PhotoInstaller.reg
echo   65,00,72,00,2e,00,64,00,6c,00,6c,00,2c,00,2d,00,33,00,30,00,35,00,35,00,00,\ >> .\PhotoInstaller.reg
echo   00 >> .\PhotoInstaller.reg
echo. >> .\PhotoInstaller.reg
echo [HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Jpeg\DefaultIcon] >> .\PhotoInstaller.reg
echo @="%SystemRoot%\\System32\\imageres.dll,-72" >> .\PhotoInstaller.reg
echo. >> .\PhotoInstaller.reg
echo [HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Jpeg\shell\open] >> .\PhotoInstaller.reg
echo "MuiVerb"=hex(2):40,00,25,00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,00,46,00,\ >> .\PhotoInstaller.reg
echo   69,00,6c,00,65,00,73,00,25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,\ >> .\PhotoInstaller.reg
echo   00,20,00,50,00,68,00,6f,00,74,00,6f,00,20,00,56,00,69,00,65,00,77,00,65,00,\ >> .\PhotoInstaller.reg
echo   72,00,5c,00,70,00,68,00,6f,00,74,00,6f,00,76,00,69,00,65,00,77,00,65,00,72,\ >> .\PhotoInstaller.reg
echo   00,2e,00,64,00,6c,00,6c,00,2c,00,2d,00,33,00,30,00,34,00,33,00,00,00 >> .\PhotoInstaller.reg
echo. >> .\PhotoInstaller.reg
echo [HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Jpeg\shell\open\command] >> .\PhotoInstaller.reg
echo @=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,\ >> .\PhotoInstaller.reg
echo   00,5c,00,53,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,72,00,75,00,\ >> .\PhotoInstaller.reg
echo   6e,00,64,00,6c,00,6c,00,33,00,32,00,2e,00,65,00,78,00,65,00,20,00,22,00,25,\ >> .\PhotoInstaller.reg
echo   00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,00,46,00,69,00,6c,00,65,00,73,00,\ >> .\PhotoInstaller.reg
echo   25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,20,00,50,00,68,00,6f,\ >> .\PhotoInstaller.reg
echo   00,74,00,6f,00,20,00,56,00,69,00,65,00,77,00,65,00,72,00,5c,00,50,00,68,00,\ >> .\PhotoInstaller.reg
echo   6f,00,74,00,6f,00,56,00,69,00,65,00,77,00,65,00,72,00,2e,00,64,00,6c,00,6c,\ >> .\PhotoInstaller.reg
echo   00,22,00,2c,00,20,00,49,00,6d,00,61,00,67,00,65,00,56,00,69,00,65,00,77,00,\ >> .\PhotoInstaller.reg
echo   5f,00,46,00,75,00,6c,00,6c,00,73,00,63,00,72,00,65,00,65,00,6e,00,20,00,25,\ >> .\PhotoInstaller.reg
echo   00,31,00,00,00 >> .\PhotoInstaller.reg
echo. >> .\PhotoInstaller.reg
echo [HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Jpeg\shell\open\DropTarget] >> .\PhotoInstaller.reg
echo "Clsid"="{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}" >> .\PhotoInstaller.reg
echo. >> .\PhotoInstaller.reg
echo [HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Gif] >> .\PhotoInstaller.reg
echo "ImageOptionFlags"=dword:00000001 >> .\PhotoInstaller.reg
echo "FriendlyTypeName"=hex(2):40,00,25,00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,\ >> .\PhotoInstaller.reg
echo   00,46,00,69,00,6c,00,65,00,73,00,25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,\ >> .\PhotoInstaller.reg
echo   77,00,73,00,20,00,50,00,68,00,6f,00,74,00,6f,00,20,00,56,00,69,00,65,00,77,\ >> .\PhotoInstaller.reg
echo   00,65,00,72,00,5c,00,50,00,68,00,6f,00,74,00,6f,00,56,00,69,00,65,00,77,00,\ >> .\PhotoInstaller.reg
echo   65,00,72,00,2e,00,64,00,6c,00,6c,00,2c,00,2d,00,33,00,30,00,35,00,37,00,00,\ >> .\PhotoInstaller.reg
echo   00 >> .\PhotoInstaller.reg
echo. >> .\PhotoInstaller.reg
echo [HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Gif\DefaultIcon] >> .\PhotoInstaller.reg
echo @="%SystemRoot%\\System32\\imageres.dll,-83" >> .\PhotoInstaller.reg
echo. >> .\PhotoInstaller.reg
echo [HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Gif\shell\open\command] >> .\PhotoInstaller.reg
echo @=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,\ >> .\PhotoInstaller.reg
echo   00,5c,00,53,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,72,00,75,00,\ >> .\PhotoInstaller.reg
echo   6e,00,64,00,6c,00,6c,00,33,00,32,00,2e,00,65,00,78,00,65,00,20,00,22,00,25,\ >> .\PhotoInstaller.reg
echo   00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,00,46,00,69,00,6c,00,65,00,73,00,\ >> .\PhotoInstaller.reg
echo   25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,20,00,50,00,68,00,6f,\ >> .\PhotoInstaller.reg
echo   00,74,00,6f,00,20,00,56,00,69,00,65,00,77,00,65,00,72,00,5c,00,50,00,68,00,\ >> .\PhotoInstaller.reg
echo   6f,00,74,00,6f,00,56,00,69,00,65,00,77,00,65,00,72,00,2e,00,64,00,6c,00,6c,\ >> .\PhotoInstaller.reg
echo   00,22,00,2c,00,20,00,49,00,6d,00,61,00,67,00,65,00,56,00,69,00,65,00,77,00,\ >> .\PhotoInstaller.reg
echo   5f,00,46,00,75,00,6c,00,6c,00,73,00,63,00,72,00,65,00,65,00,6e,00,20,00,25,\ >> .\PhotoInstaller.reg
echo   00,31,00,00,00 >> .\PhotoInstaller.reg
echo. >> .\PhotoInstaller.reg
echo [HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Gif\shell\open\DropTarget] >> .\PhotoInstaller.reg
echo "Clsid"="{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}" >> .\PhotoInstaller.reg
echo. >> .\PhotoInstaller.reg
echo [HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Png] >> .\PhotoInstaller.reg
echo "ImageOptionFlags"=dword:00000001 >> .\PhotoInstaller.reg
echo "FriendlyTypeName"=hex(2):40,00,25,00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,\ >> .\PhotoInstaller.reg
echo   00,46,00,69,00,6c,00,65,00,73,00,25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,\ >> .\PhotoInstaller.reg
echo   77,00,73,00,20,00,50,00,68,00,6f,00,74,00,6f,00,20,00,56,00,69,00,65,00,77,\ >> .\PhotoInstaller.reg
echo   00,65,00,72,00,5c,00,50,00,68,00,6f,00,74,00,6f,00,56,00,69,00,65,00,77,00,\ >> .\PhotoInstaller.reg
echo   65,00,72,00,2e,00,64,00,6c,00,6c,00,2c,00,2d,00,33,00,30,00,35,00,37,00,00,\ >> .\PhotoInstaller.reg
echo   00 >> .\PhotoInstaller.reg
echo. >> .\PhotoInstaller.reg
echo [HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Png\DefaultIcon] >> .\PhotoInstaller.reg
echo @="%SystemRoot%\\System32\\imageres.dll,-71" >> .\PhotoInstaller.reg
echo. >> .\PhotoInstaller.reg
echo [HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Png\shell\open\command] >> .\PhotoInstaller.reg
echo @=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,\ >> .\PhotoInstaller.reg
echo   00,5c,00,53,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,72,00,75,00,\ >> .\PhotoInstaller.reg
echo   6e,00,64,00,6c,00,6c,00,33,00,32,00,2e,00,65,00,78,00,65,00,20,00,22,00,25,\ >> .\PhotoInstaller.reg
echo   00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,00,46,00,69,00,6c,00,65,00,73,00,\ >> .\PhotoInstaller.reg
echo   25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,20,00,50,00,68,00,6f,\ >> .\PhotoInstaller.reg
echo   00,74,00,6f,00,20,00,56,00,69,00,65,00,77,00,65,00,72,00,5c,00,50,00,68,00,\ >> .\PhotoInstaller.reg
echo   6f,00,74,00,6f,00,56,00,69,00,65,00,77,00,65,00,72,00,2e,00,64,00,6c,00,6c,\ >> .\PhotoInstaller.reg
echo   00,22,00,2c,00,20,00,49,00,6d,00,61,00,67,00,65,00,56,00,69,00,65,00,77,00,\ >> .\PhotoInstaller.reg
echo   5f,00,46,00,75,00,6c,00,6c,00,73,00,63,00,72,00,65,00,65,00,6e,00,20,00,25,\ >> .\PhotoInstaller.reg
echo   00,31,00,00,00 >> .\PhotoInstaller.reg
echo. >> .\PhotoInstaller.reg
echo [HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Png\shell\open\DropTarget] >> .\PhotoInstaller.reg
echo "Clsid"="{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}" >> .\PhotoInstaller.reg
echo. >> .\PhotoInstaller.reg
echo [HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Wdp] >> .\PhotoInstaller.reg
echo "EditFlags"=dword:00010000 >> .\PhotoInstaller.reg
echo "ImageOptionFlags"=dword:00000001 >> .\PhotoInstaller.reg
echo. >> .\PhotoInstaller.reg
echo [HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Wdp\DefaultIcon] >> .\PhotoInstaller.reg
echo @="%SystemRoot%\\System32\\wmphoto.dll,-400" >> .\PhotoInstaller.reg
echo. >> .\PhotoInstaller.reg
echo [HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Wdp\shell\open] >> .\PhotoInstaller.reg
echo "MuiVerb"=hex(2):40,00,25,00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,00,46,00,\ >> .\PhotoInstaller.reg
echo   69,00,6c,00,65,00,73,00,25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,\ >> .\PhotoInstaller.reg
echo   00,20,00,50,00,68,00,6f,00,74,00,6f,00,20,00,56,00,69,00,65,00,77,00,65,00,\ >> .\PhotoInstaller.reg
echo   72,00,5c,00,70,00,68,00,6f,00,74,00,6f,00,76,00,69,00,65,00,77,00,65,00,72,\ >> .\PhotoInstaller.reg
echo   00,2e,00,64,00,6c,00,6c,00,2c,00,2d,00,33,00,30,00,34,00,33,00,00,00 >> .\PhotoInstaller.reg
echo. >> .\PhotoInstaller.reg
echo [HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Wdp\shell\open\command] >> .\PhotoInstaller.reg
echo @=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,\ >> .\PhotoInstaller.reg
echo   00,5c,00,53,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,72,00,75,00,\ >> .\PhotoInstaller.reg
echo   6e,00,64,00,6c,00,6c,00,33,00,32,00,2e,00,65,00,78,00,65,00,20,00,22,00,25,\ >> .\PhotoInstaller.reg
echo   00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,00,46,00,69,00,6c,00,65,00,73,00,\ >> .\PhotoInstaller.reg
echo   25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,20,00,50,00,68,00,6f,\ >> .\PhotoInstaller.reg
echo   00,74,00,6f,00,20,00,56,00,69,00,65,00,77,00,65,00,72,00,5c,00,50,00,68,00,\ >> .\PhotoInstaller.reg
echo   6f,00,74,00,6f,00,56,00,69,00,65,00,77,00,65,00,72,00,2e,00,64,00,6c,00,6c,\ >> .\PhotoInstaller.reg
echo   00,22,00,2c,00,20,00,49,00,6d,00,61,00,67,00,65,00,56,00,69,00,65,00,77,00,\ >> .\PhotoInstaller.reg
echo   5f,00,46,00,75,00,6c,00,6c,00,73,00,63,00,72,00,65,00,65,00,6e,00,20,00,25,\ >> .\PhotoInstaller.reg
echo   00,31,00,00,00 >> .\PhotoInstaller.reg
echo. >> .\PhotoInstaller.reg
echo [HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Wdp\shell\open\DropTarget] >> .\PhotoInstaller.reg
echo "Clsid"="{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}" >> .\PhotoInstaller.reg
echo. >> .\PhotoInstaller.reg
echo [HKEY_CLASSES_ROOT\SystemFileAssociations\image\shell\Image Preview\command] >> .\PhotoInstaller.reg
echo @=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,\ >> .\PhotoInstaller.reg
echo   00,5c,00,53,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,72,00,75,00,\ >> .\PhotoInstaller.reg
echo   6e,00,64,00,6c,00,6c,00,33,00,32,00,2e,00,65,00,78,00,65,00,20,00,22,00,25,\ >> .\PhotoInstaller.reg
echo   00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,00,46,00,69,00,6c,00,65,00,73,00,\ >> .\PhotoInstaller.reg
echo   25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,20,00,50,00,68,00,6f,\ >> .\PhotoInstaller.reg
echo   00,74,00,6f,00,20,00,56,00,69,00,65,00,77,00,65,00,72,00,5c,00,50,00,68,00,\ >> .\PhotoInstaller.reg
echo   6f,00,74,00,6f,00,56,00,69,00,65,00,77,00,65,00,72,00,2e,00,64,00,6c,00,6c,\ >> .\PhotoInstaller.reg
echo   00,22,00,2c,00,20,00,49,00,6d,00,61,00,67,00,65,00,56,00,69,00,65,00,77,00,\ >> .\PhotoInstaller.reg
echo   5f,00,46,00,75,00,6c,00,6c,00,73,00,63,00,72,00,65,00,65,00,6e,00,20,00,25,\ >> .\PhotoInstaller.reg
echo   00,31,00,00,00 >> .\PhotoInstaller.reg
echo. >> .\PhotoInstaller.reg
echo [HKEY_CLASSES_ROOT\SystemFileAssociations\image\shell\Image Preview\DropTarget] >> .\PhotoInstaller.reg
echo "{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}"="" >> .\PhotoInstaller.reg
echo. >> .\PhotoInstaller.reg
echo [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities] >> .\PhotoInstaller.reg
echo "ApplicationDescription"="@%ProgramFiles%\\Windows Photo Viewer\\photoviewer.dll,-3069" >> .\PhotoInstaller.reg
echo "ApplicationName"="@%ProgramFiles%\\Windows Photo Viewer\\photoviewer.dll,-3009" >> .\PhotoInstaller.reg
echo. >> .\PhotoInstaller.reg
echo [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations] >> .\PhotoInstaller.reg
echo ".cr2"="PhotoViewer.FileAssoc.Tiff" >> .\PhotoInstaller.reg
echo ".jpg"="PhotoViewer.FileAssoc.Jpeg" >> .\PhotoInstaller.reg
echo ".wdp"="PhotoViewer.FileAssoc.Wdp" >> .\PhotoInstaller.reg
echo ".jfif"="PhotoViewer.FileAssoc.JFIF" >> .\PhotoInstaller.reg
echo ".dib"="PhotoViewer.FileAssoc.Bitmap" >> .\PhotoInstaller.reg
echo ".png"="PhotoViewer.FileAssoc.Png" >> .\PhotoInstaller.reg
echo ".jxr"="PhotoViewer.FileAssoc.Wdp" >> .\PhotoInstaller.reg
echo ".bmp"="PhotoViewer.FileAssoc.Bitmap" >> .\PhotoInstaller.reg
echo ".jpe"="PhotoViewer.FileAssoc.Jpeg" >> .\PhotoInstaller.reg
echo ".jpeg"="PhotoViewer.FileAssoc.Jpeg" >> .\PhotoInstaller.reg
echo ".gif"="PhotoViewer.FileAssoc.Gif" >> .\PhotoInstaller.reg
echo ".tif"="PhotoViewer.FileAssoc.Tiff" >> .\PhotoInstaller.reg
echo ".tiff"="PhotoViewer.FileAssoc.Tiff" >> .\PhotoInstaller.reg
echo. >> .\PhotoInstaller.reg
echo. >> .\PhotoInstaller.reg
reg import .\PhotoInstaller.reg
pause
del .\PhotoInstaller.reg
goto WinPrograms

:GPInstaller
::This tweak is thanks to MajorGeeks
pushd "%~dp0" 

dir /b %SystemRoot%\servicing\Packages\Microsoft-Windows-GroupPolicy-ClientExtensions-Package~3*.mum >List.txt 
dir /b %SystemRoot%\servicing\Packages\Microsoft-Windows-GroupPolicy-ClientTools-Package~3*.mum >>List.txt 

for /f %%i in ('findstr /i . List.txt 2^>nul') do dism /online /norestart /add-package:"%SystemRoot%\servicing\Packages\%%i" 
pause
goto WinPrograms

:winsyssettings
mode con:cols=80 lines=22
echo.
echo Here you can easily change some advanced Windows settings.
echo.
echo.
echo 1) Manage Page File/Virtual Memory 
echo 2) BSOD Disable Automatic Restart
echo 3) BSOD Enable Automatic Restart
echo 4) Enable Built-In Administrator Account (If it Exists)
echo 5) Disable Built-In Administrator Account
echo 6) Enable Developer Mode (For Unsigned Appx Packages)
echo 7) Disable Developer Mode
echo 8) Enable Unsigned Fonts
echo 9) Disable Unsigned Fonts (Usually for Security)
echo 10) Windows Ink and Typing
echo 11) Power Options
echo 12) Back
echo 13) Exit
echo.
echo.
set /p web=Type option:
if "%web%"=="1" goto winpagefile
if "%web%"=="2" cls && wmic RecoverOS set AutoReboot = False && pause && goto winsyssettings
if "%web%"=="3" cls && wmic RecoverOS set AutoReboot = True && pause && goto winsyssettings
if "%web%"=="4" cls net user Administrator /active:yes && pause && goto winsyssettings
if "%web%"=="5" cls net user Administrator /active:no && pause && goto winsyssettings
if "%web%"=="6" reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /t REG_DWORD /f /v AllowDevelopmentWithoutDevLicense /d 1 && pause && goto winsyssettings
if "%web%"=="7" reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /t REG_DWORD /f /v AllowDevelopmentWithoutDevLicense /d 0 && pause && goto winsyssettings
if "%web%"=="8" reg delete "HKLM\Software\Policies\Microsoft\Windows NT\MitigationOptions" /v MitigationOptions_FontBocking /f && pause && goto winsyssettings
if "%web%"=="9" reg add "HKLM\Software\Policies\Microsoft\Windows NT\MitigationOptions" /v MitigationOptions_FontBocking /t REG_DWORD /d 1 /f && pause && goto winsyssettings
if "%web%"=="10" goto WinInk
if "%web%"=="11" goto PowerOptionsMenu
if "%web%"=="12" goto settweakmenu
if "%web%"=="13" exit
goto winsyssettings

:PowerOptionsMenu
mode con:cols=80 lines=22
cls
echo.
echo Here you can modify your systems Power Plans
echo BE CAUTIOUS: You could screw things up if not careful
echo.
echo 1) View Available Plans
echo 2) View Evergy Report
echo 3) Change Power Plan
echo 4) Enable"Ultimate Performance" Plan (If PC Supports, 1803 and Up)
echo 5) Hard Drive Timeout
echo 6) Wireless Power Saving
echo 7) Back
echo 8) Exit
echo.
set /p web=Type option:
if "%web%"=="1" goto ViewPowerPlans
if "%web%"=="2" goto ViewEnergyRep
if "%web%"=="3" goto ChangePowerPlan
if "%web%"=="4" goto PowerUltimate
if "%web%"=="5" goto HDDTimeout
if "%web%"=="6" goto WifiSave
if "%web%"=="7" goto settweakmenu
if "%web%"=="8" goto home
goto PowerOptionsMenu

:ViewPowerPlans
cls
echo This will list currently available Power Plans for your PC..
pause
powercfg /list
pause
goto PowerOptionsMenu

:ChangePowerPlan
cls
echo Please make sure you have viewed what Plans are available to your PC
echo Not all of these will be available.
echo.
echo (MaximumPerformance)
echo (TimersOff)
echo (Balanced)
echo (MaximumBatteryLife)
echo (VideoPlayback)
echo (HighPerformance)
echo (PowerSourceOptimized)
echo (Powersaver)
echo B) Back
echo.
set /P pwrcfg=Type plan WITHOUT brackets or B for Back:
if "%pwrcfg%"=="MaximumPerformance" powercfg -setactive 01360e7e-525f-4625-ab94-f283dcfbd515 && echo Done.
if "%pwrcfg%"=="TimersOff" powercfg -setactive 25703703-e852-4c6a-b8d5-b36dd2e3f757 && echo Done.
if "%pwrcfg%"=="Balanced" powercfg -setactive 381b4222-f694-41f0-9685-ff5bb260df2e && echo Done.
if "%pwrcfg%"=="MaximumBatteryLife" powercfg -setactive 4ac93938-c0ab-4b33-9150-b71bf11e59d3 && echo Done.
if "%pwrcfg%"=="VideoPlayback" powercfg -setactive 6aea82bd-cf7f-424c-aee8-7dba1ee06330 && echo Done.
if "%pwrcfg%"=="HighPerformance" powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c && echo Done.
if "%pwrcfg%"=="PowerSourceOptimized" powercfg -setactive 8ce8c17f-8bb0-4d23-98d1-ae3311cbee5a && echo Done.
if "%pwrcfg%"=="Powersaver" powercfg -setactivea1841308-3541-4fab-bc81-f71556f20b4a && echo Done.
if "%pwrcfg%"=="B" goto PowerOptionsMenu
goto ChangePowerPlan

:PowerUltimate
cls
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61
powercfg -setactive e9a42b02-d5df-448d-aa00-03f14749eb61
pause
goto PowerOptionsMenu
goto
:HDDTimeout
cls
mode con:cols=80 lines=22
echo.
echo Here you can use a specific timeout for Hard Drives to sleep.
echo After you press enter you'll go back to the last menu.
echo.
echo.
set /p hddtime=Type time in Seconds (0 to Disable):
powercfg -setdcvalueindex 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 0012ee47-9041-4b5d-9b77-535fba8b1442 6738e2c4-e8a5-4a42-b16a-e040e769756e %hddtime%
pause
goto PowerOptionsMenu
:WifiSave
cls
echo.
echo Here you can adjust Wireless Adapter Power Saving
echo *This needs more testing, I had success changing this but others haven't*
echo 0 = Maximum Performance
echo 1
echo 2
echo 3
echo 4
echo 5 = Max Power Saving
echo 6) Back
set /P wifiyesno=Type number, 6 to go Back:
powercfg /SETDCVALUEINDEX SCHEME_CURRENT 19cbb8fa-5279-450e-9fac-8a3d5fedd0c1 12bbebe6-58d6-4636-95bb-3217ef867c1a %wifiyesno%
pause
goto PowerOptionsMenu

:ViewEnergyRep
cls
echo More accurate reported are Generated if ALL other Applications
echo are closed except this window
pause
echo.
powercfg -energy
C:/Windows/system32/energy-report.html
pause
goto PowerOptionsMenu

:WinInk
cls
mode con:cols=80 lines=22
echo.
echo Here you can change Windows Inking and Typing settings.
echo The list here is small at the moment, please suggest things.
echo.
echo 1) Disable Learing (Getting to Know You)
echo 2) Enable Learning
echo 3) Explorer-based Textbox Auto Complete ON
echo 4) Explorer-based Textbox Auto Complete OFF
echo 5) Back
echo 6) Exit
echo.
echo.
set /p web=Type option:
if "%web%"=="1" call :NoInkLearn
if "%web%"=="2" call :YesInkLearn
if "%web%"=="3" call :AutoText
if "%web%"=="4" call :DropText
if "%web%"=="5" 
if "%web%"=="6" 
goto WinInk

:AutoText
echo Windows Registry Editor Version 5.00 > .\AutoText.reg
echo. >> .\AutoText.reg
echo [HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoComplete] >> .\AutoText.reg
echo "Append Completion"="yes" >> .\AutoText.reg
echo. >> .\AutoText.reg
reg import .\AutoText.reg
pause
del .\AutoText.reg
goto WinInk


:DropText
echo Windows Registry Editor Version 5.00 > .\DropText.reg
echo. >> .\DropText.reg
echo [HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoComplete] >> .\DropText.reg
echo "Append Completion"="no" >> .\DropText.reg
echo. >> .\DropText.reg
reg import .\DropText.reg
pause
del .\DropText.reg
goto WinInk

:NoInkLearn
echo Windows Registry Editor Version 5.00 > .\NoInkLearn.reg
echo. >> .\NoInkLearn.reg
echo [HKEY_CURRENT_USER\Software\Microsoft\InputPersonalization] >> .\NoInkLearn.reg
echo "RestrictImplicitInkCollection"=dword:00000001 >> .\NoInkLearn.reg
echo "RestrictImplicitTextCollection"=dword:00000001 >> .\NoInkLearn.reg
echo. >> .\NoInkLearn.reg
echo [HKEY_CURRENT_USER\Software\Microsoft\InputPersonalization\TrainedDataStore] >> .\NoInkLearn.reg
echo "HarvestContacts"=dword:00000000 >> .\NoInkLearn.reg
echo. >> .\NoInkLearn.reg
echo [HKEY_CURRENT_USER\Software\Microsoft\Personalization\Settings] >> .\NoInkLearn.reg
echo "AcceptedPrivacyPolicy"=dword:00000000 >> .\NoInkLearn.reg
echo. >> .\NoInkLearn.reg
reg import .\NoInkLearn.reg
pause
del .\NoInkLearn
goto WinInk

:YesInkLearn
echo Windows Registry Editor Version 5.00 > .\YesInkLearn.reg
echo. >> .\YesInkLearn.reg
echo [HKEY_CURRENT_USER\Software\Microsoft\InputPersonalization] >> .\YesInkLearn.reg
echo "RestrictImplicitInkCollection"=dword:00000000 >> .\YesInkLearn.reg
echo "RestrictImplicitTextCollection"=dword:00000000 >> .\YesInkLearn.reg
echo. >> .\YesInkLearn.reg
echo [HKEY_CURRENT_USER\Software\Microsoft\InputPersonalization\TrainedDataStore] >> .\YesInkLearn.reg
echo "HarvestContacts"=dword:00000001 >> .\YesInkLearn.reg
echo. >> .\YesInkLearn.reg
echo [HKEY_CURRENT_USER\Software\Microsoft\Personalization\Settings] >> .\YesInkLearn.reg
echo "AcceptedPrivacyPolicy"=dword:00000001 >> .\YesInkLearn.reg
echo. >> .\YesInkLearn.reg
reg import .\YesInkLearn.reg
pause
del .\YesInkLearn
goto WinInk

:winpagefile
mode con:cols=80 lines=22
echo.
echo Here we can modify the Page File/Virtual Memory
echo Changing Drive location coming soon
echo.
echo.
echo 1) View Current Page File Settings
echo 2) Increase Page File
echo 3) Decrease Page File
echo 4) Disable Page File
echo 5) Enable Page File/Set Auto Page File
echo 6) Clear Page File On Shutdown
echo 7) Keep Page File Contents On Shutdown
echo 8) Back
echo 9) Exit
echo.
echo.
set /p web=Type option:
if "%web%"=="1" cls && wmic pagefile list /format:list && pause && goto winpagefile
if "%web%"=="2" goto BiggerPaging
if "%web%"=="3" goto SmallerPaging
if "%web%"=="4" call :DisablePaging
if "%web%"=="5" cls && wmic computersystem where name="%computername%" set AutomaticManagedPagefile=true && pause && goto winpagefile
if "%web%"=="6" reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v ClearPageFileAtShutdown /t REG_DWORD /d 1 /f && pause && goto winpagefile
if "%web%"=="7" reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v ClearPageFileAtShutdown /t REG_DWORD /d 0 /f && pause && goto winpagefile
if "%web%"=="8" goto settweakmenu
if "%web%"=="9" exit
goto winpagefile

:DisablePaging
cls
cls && wmic computersystem where name="%computername%" set AutomaticManagedPagefile=false
wmic pagefileset where name="C:\\pagefile.sys" set InitialSize=0,MaximumSize=0
wmic pagefileset where name="C:\\pagefile.sys" delete
pause
goto winpagefile
:BiggerPaging
cls
echo.
echo Increase the values from 4096mb - 8192mb (Usually default with 8GB Ram)
echo Key: MinimumSize -(to) MaximumSize  
echo.
echo 1) 5120 - 10240
echo 2) 6144 - 10240
echo 3) 7168 - 12288
echo 4) 8192 - 12288
echo 5) 9216 - 14336
echo 6) Back
echo 7) Exit
echo.
echo.
set /p web=Type option:
if "%web%"=="1" call :5120
if "%web%"=="2" call :6144
if "%web%"=="3" call :7168
if "%web%"=="4" call :8192
if "%web%"=="5" call :9216
if "%web%"=="6" goto winpagefile
if "%web%"=="7" exit
goto BiggerPaging

:5120
cls
wmic computersystem where name="%computername%" set AutomaticManagedPagefile=false
wmic pagefileset where name="C:\\pagefile.sys" set InitialSize=5120,MaximumSize=10240
pause
goto BiggerPaging
:6144
cls
wmic computersystem where name="%computername%" set AutomaticManagedPagefile=false
wmic pagefileset where name="C:\\pagefile.sys" set InitialSize=6144,MaximumSize=10240
pause
goto BiggerPaging
:7168
cls
wmic computersystem where name="%computername%" set AutomaticManagedPagefile=false
wmic pagefileset where name="C:\\pagefile.sys" set InitialSize=7168,MaximumSize=12288
pause
goto BiggerPaging
:8192
cls
wmic computersystem where name="%computername%" set AutomaticManagedPagefile=false
wmic pagefileset where name="C:\\pagefile.sys" set InitialSize=8192,MaximumSize=12288
pause
goto BiggerPaging
:9216
cls
wmic computersystem where name="%computername%" set AutomaticManagedPagefile=false
wmic pagefileset where name="C:\\pagefile.sys" set InitialSize=8192,MaximumSize=14336
pause
goto BiggerPaging

:SmallerPaging
cls
echo.
echo Decrease the values 
echo Key: MinimumSize -(to) MaximumSize  
echo.
echo 1) 4096 - 8192 (Usually default with 8GB Ram)
echo 2) 3072 - 6144
echo 3) 2048 - 4096
echo 4) 1024 - 2048
echo 5) Back
echo 6) Exit
echo.
echo.
set /p web=Type option:
if "%web%"=="1" call :4096
if "%web%"=="2" call :3072
if "%web%"=="3" call :2048
if "%web%"=="4" call :1024
if "%web%"=="5" goto winpagefile
if "%web%"=="6" exit
goto SmallerPaging
:4096
cls
wmic computersystem where name="%computername%" set AutomaticManagedPagefile=false
wmic pagefileset where name="C:\\pagefile.sys" set InitialSize=4096,MaximumSize=8192)
pause
goto SmallerPaging

:3072
cls
wmic computersystem where name="%computername%" set AutomaticManagedPagefile=false
wmic pagefileset where name="C:\\pagefile.sys" set InitialSize=3072,MaximumSize=6144
pause
goto SmallerPaging

:2048
cls
wmic computersystem where name="%computername%" set AutomaticManagedPagefile=false
wmic pagefileset where name="C:\\pagefile.sys" set InitialSize=2048,MaximumSize=4096
pause
goto SmallerPaging
:1024
cls
wmic computersystem where name="%computername%" set AutomaticManagedPagefile=false
wmic pagefileset where name="C:\\pagefile.sys" set InitialSize=1024,MaximumSize=2048
pause
goto SmallerPaging
:AdvTweak
mode con:cols=80 lines=22
echo.
echo Here is a list of Misc Tweaks
echo.
echo 1) Add File Hash to Context Menu
echo 2) Remove File Hash to Context Menu
echo 3) Disable Advertising ID for Relevant Ads
echo 4) Enable Advertising ID for Relevant Ads
echo 5) Disable All Advertising and Sponsored Apps
echo 6) Enable All Advertising and Sponsored Apps
echo 7) Disable App Launch Tracking
echo 8) Enable App Launch Tracking
echo 9) Disable Featured or Suggested Apps from Automatically Installing
echo 10) Enable Featured or Suggested Apps from Automatically Installing
echo 11) Disable "Get Even More Out of Windows"
echo 12) Enable  "Get Even More Out of Windows"
echo 13) Disable Hibernation
echo 14) Enable Hibernation
echo 15) Next Page
echo 16) Back
echo.
echo.
set /p web=Type option:
if "%web%"=="1" call :AddHash
if "%web%"=="2" call :RemoveHash
if "%web%"=="3" reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v Enabled /t REG_DWORD /d 0 /f && pause
if "%web%"=="4" reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v Enabled /t REG_DWORD /d 1 /f && pause
if "%web%"=="5" call :NoThirdAppAds
if "%web%"=="6" call :ThirdAppAds
if "%web%"=="7" reg add "HKCU\Software\Policies\Microsoft\Windows\EdgeUI" /v DisableMFUTracking /t REG_DWORD /d 1 /f && reg add "HKLM\Software\Policies\Microsoft\Windows\EdgeUI" /v DisableMFUTracking /t REG_DWORD /d 1 /f && pause
if "%web%"=="8" reg add "HKCU\Software\Policies\Microsoft\Windows\EdgeUI" /v DisableMFUTracking /t REG_DWORD /d 0 /f && reg add "HKLM\Software\Policies\Microsoft\Windows\EdgeUI" /v DisableMFUTracking /t REG_DWORD /d 0 /f && pause
if "%web%"=="9" reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SilentInstalledAppsEnabled /t REG_DWORD /d 0 /f && pause
if "%web%"=="10" reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SilentInstalledAppsEnabled /t REG_DWORD /d 1 /f && pause
if "%web%"=="11" reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-310093Enabled /t REG_DWORD /d 0 /f && pause
if "%web%"=="12" reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-310093Enabled /t REG_DWORD /d 1 /f && pause
if "%web%"=="13" call :NoHiber
if "%web%"=="14" call :YesHiber
if "%web%"=="15" goto AdvTweak1
if "%web%"=="16" goto settweakmenu
goto AdvTweak


:AddHash
echo Windows Registry Editor Version 5.00 > .\AddHash.reg
echo. >> .\AddHash.reg
echo. >> .\AddHash.reg
echo [HKEY_CLASSES_ROOT\*\shell\GetFileHash] >> .\AddHash.reg
echo "MUIVerb"="Hash" >> .\AddHash.reg
echo "SubCommands"="" >> .\AddHash.reg
echo. >> .\AddHash.reg
echo [HKEY_CLASSES_ROOT\*\shell\GetFileHash\shell\01SHA1] >> .\AddHash.reg
echo "MUIVerb"="SHA1" >> .\AddHash.reg
echo. >> .\AddHash.reg
echo [HKEY_CLASSES_ROOT\*\shell\GetFileHash\shell\01SHA1\command] >> .\AddHash.reg
echo @="powershell.exe -noexit get-filehash -literalpath '%1' -algorithm SHA1 | format-list" >> .\AddHash.reg
echo. >> .\AddHash.reg
echo. >> .\AddHash.reg
reg import .\AddHash.reg
pause
del .\AddHash.reg
goto AdvTweak


:RemoveHash
echo Windows Registry Editor Version 5.00 > .\RemoveHash.reg
echo. >> .\RemoveHash.reg
echo [-HKEY_CLASSES_ROOT\*\shell\GetFileHash] >> .\RemoveHash.reg
echo. >> .\RemoveHash.reg
reg import .\RemoveHash.reg
pause
del .\RemoveHash.reg
goto AdvTweak

:NoThirdAppAds
echo Windows Registry Editor Version 5.00 > .\NoThirdAppAds.reg
echo. >> .\NoThirdAppAds.reg
echo [HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager] >> .\NoThirdAppAds.reg
echo "SilentInstalledAppsEnabled"=dword:00000000 >> .\NoThirdAppAds.reg
echo. >> .\NoThirdAppAds.reg
echo [HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager] >> .\NoThirdAppAds.reg
echo "SystemPaneSuggestionsEnabled"=dword:00000000 >> .\NoThirdAppAds.reg
echo. >> .\NoThirdAppAds.reg
echo [HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced] >> .\NoThirdAppAds.reg
echo "ShowSyncProviderNotifications"=dword:00000000 >> .\NoThirdAppAds.reg
echo. >> .\NoThirdAppAds.reg
echo [HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager] >> .\NoThirdAppAds.reg
echo "SoftLandingEnabled"=dword:00000000 >> .\NoThirdAppAds.reg
echo. >> .\NoThirdAppAds.reg
echo [HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager] >> .\NoThirdAppAds.reg
echo "RotatingLockScreenEnabled"=dword:00000000 >> .\NoThirdAppAds.reg
echo. >> .\NoThirdAppAds.reg
echo [HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager] >> .\NoThirdAppAds.reg
echo "RotatingLockScreenOverlayEnabled"=dword:00000000 >> .\NoThirdAppAds.reg
echo. >> .\NoThirdAppAds.reg
echo [HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager] >> .\NoThirdAppAds.reg
echo "SubscribedContent-310093Enabled"=dword:00000000 >> .\NoThirdAppAds.reg
echo. >> .\NoThirdAppAds.reg
reg import .\NoThirdAppAds.reg
pause
del .\NoThirdAppAds.reg
goto AdvTweak


:ThirdAppAds
echo Windows Registry Editor Version 5.00 > .\ThirdAppAds.reg
echo. >> .\ThirdAppAds.reg
echo [HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager] >> .\ThirdAppAds.reg
echo "SilentInstalledAppsEnabled"=dword:00000001 >> .\ThirdAppAds.reg
echo. >> .\ThirdAppAds.reg
echo [HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager] >> .\ThirdAppAds.reg
echo "SystemPaneSuggestionsEnabled"=dword:00000001 >> .\ThirdAppAds.reg
echo. >> .\ThirdAppAds.reg
echo [HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced] >> .\ThirdAppAds.reg
echo "ShowSyncProviderNotifications"=dword:00000001 >> .\ThirdAppAds.reg
echo. >> .\ThirdAppAds.reg
echo [HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager] >> .\ThirdAppAds.reg
echo "SoftLandingEnabled"=dword:00000001 >> .\ThirdAppAds.reg
echo. >> .\ThirdAppAds.reg
echo [HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager] >> .\ThirdAppAds.reg
echo "RotatingLockScreenEnabled"=dword:00000001 >> .\ThirdAppAds.reg
echo. >> .\ThirdAppAds.reg
echo [HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager] >> .\ThirdAppAds.reg
echo "RotatingLockScreenOverlayEnabled"=dword:00000001 >> .\ThirdAppAds.reg
echo. >> .\ThirdAppAds.reg
echo [HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager] >> .\ThirdAppAds.reg
echo "SubscribedContent-310093Enabled"=dword:00000001 >> .\ThirdAppAds.reg
echo. >> .\ThirdAppAds.reg
reg import .\ThirdAppAds.reg
pause
del .\ThirdAppAds.reg
goto AdvTweak


:NoHiber
reg add "HKLM\System\CurrentControlSet\Control\Power" /v HibernateEnabled /t REG_DWORD /d 0 /f
powercfg /hibernate off
goto AdvTweak

:YesHiber
reg add "HKLM\System\CurrentControlSet\Control\Power" /v HibernateEnabled /t REG_DWORD /d 1 /f
powercfg /hibernate on
goto AdvTweak

:AdvTweak1
mode con:cols=80 lines=22
echo.
echo Here is a list of Misc Tweaks
echo.
echo 1) Disable Windows Welcome Experience Page
echo 2) Enable Windows Welcome Experience Page
echo 3) Disable Clipboard History
echo 4) Enable Clipboard History
echo 5) Disable Lock Computer
echo 6) Enable Lock Computer
echo 7) Disable "Fast Startup" on Boot
echo 8) Enable "Fast Startup" on Boot
echo 9) Turn Auto Adjust Hours Off
echo 10) Turn Auto Adjust Hours On
echo 11) Back
echo 12) Menu
echo.
echo.
set /p web=Type option:
if "%web%"=="1" reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-310093Enabled /t REG_DWORD /d 0 /f && pause
if "%web%"=="2" reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-310093Enabled /t REG_DWORD /d 1 /f && pause
if "%web%"=="3" reg add "HKLM\Software\Policies\Microsoft\Windows\System" /v AllowClipboardHistory /t REG_DWORD /d 0 /f && pause
if "%web%"=="4" reg add "HKLM\Software\Policies\Microsoft\Windows\System" /v AllowClipboardHistory /t REG_DWORD /d 1 /f && pause
if "%web%"=="5" reg add "HKLM\Software\Policies\Microsoft\Windows\Personalization" /v NoLockScreen /t REG_DWORD /d 1 /f && pause
if "%web%"=="6" reg add "HKLM\Software\Policies\Microsoft\Windows\Personalization" /v NoLockScreen /t REG_DWORD /d 1 /f && pause
if "%web%"=="7" reg add "HKLM\Software\Policies\Microsoft\Windows\System" /v HiberbootEnabled /t REG_DWORD /d 0 /f && reg add "HKLM\System\CurrentControlSet\Control\Session Manager\Power" /v HiberbootEnabled /t REG_DWORD /d 0 /f && pause
if "%web%"=="8" reg add "HKLM\Software\Policies\Microsoft\Windows\System" /v HiberbootEnabled /t REG_DWORD /d 1 /f && reg add "HKLM\System\CurrentControlSet\Control\Session Manager\Power" /v HiberbootEnabled /t REG_DWORD /d 1 /f && pause
if "%web%"=="9" reg add "HKLM\Software\Microsoft\WindowsUpdate\UX\Settings" /v SmartActiveHoursState /t REG_DWORD /d 2 /f && pause
if "%web%"=="10" reg add "HKLM\Software\Microsoft\WindowsUpdate\UX\Settings" /v SmartActiveHoursState /t REG_DWORD /d 1 /f && pause
if "%web%"=="11" goto AdvTweak
if "%web%"=="12" goto settweakmenu
goto AdvTweak1



:appearance
mode con:cols=80 lines=30
echo.
echo Here is a small list of Windows Appearance Tweaks
echo (Restart/Sign out may be required after changes)
echo.
echo.
echo 1) Enable Taskbar Transparency (Usually Default)
echo 2) Disable Taskbar Transparency
echo 3) Increase Taskbar Transparency
echo 4) Allow Windows To Automatically Clear Thumbnail Cache
echo 5) Stop Windows To Automatically Clear Thumbnail Cache
echo 6) Enable Old Volume Control Fly-out
echo 7) Disable Old Volume Control Fly-out (Usually Default)
echo 8) Enable Auto Hiding of Scrollbar in UWP Apps (Usually Default)
echo 9) Disable Auto Hiding of Scrollbar in UWP Apps
echo 10) Show Windows Build Version and Number on Desktop
echo 11) Hide Windows Build Version and Number on Desktop
echo 12) Enable Shortcut Name Extensions (Usually Default)
echo 13) Disable Shortcut Name Extensions
echo 14) Enable Fixing of Blurry Programs
echo 15) Disable Fixing of Blurry Programs
echo 16) Restore Windows Default DPI Scailing
echo 17) Back
echo 18) Exit
echo.
echo.
set /p web=Type option:
if "%web%"=="1" reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v EnableTransparency /t REG_DWORD /d 1 /f && pause && goto appearance
if "%web%"=="2" reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v EnableTransparency /t REG_DWORD /d 0 /f && pause && goto appearance
if "%web%"=="3" reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v UseOLEDTaskbarTransparency /t REG_DWORD /d 1 && reg add "HKLM\SOFTWARE\Microsoft\Windows\Dwm" /v ForceEffectMode /t REG_DWORD /d 1 /f &&  pause && goto appearance 
if "%web%"=="4" reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Thumbnail Cache" /v Autorun /t REG_DWORD /d 0 /f && reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Thumbnail Cache" /v Autorun /t REG_DWORD /d 0 /f && pause && goto appearance
if "%web%"=="5" reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Thumbnail Cache" /v Autorun /t REG_DWORD /d 1 /f && reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Thumbnail Cache" /v Autorun /t REG_DWORD /d 1 /f && pause && goto appearance
if "%web%"=="6" reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\MTCUVC" /v EnableMtcUvc /t REG_DWORD /d 0 /f && pause && goto appearance
if "%web%"=="7" reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\MTCUVC" /v EnableMtcUvc /t REG_DWORD /d 1 /f && pause && goto appearance
if "%web%"=="8" reg add "HKCU\Control Panel\Accessibility" /v DynamicScrollbars /t REG_DWORD /d 1 /f && pause && goto appearance
if "%web%"=="9" reg add "HKCU\Control Panel\Accessibility" /v DynamicScrollbars /t REG_DWORD /d 0 /f && pause && goto appearance
if "%web%"=="10" reg add "HKCU\\Control Panel\Desktop" /v PaintDesktopVersion /t REG_DWORD /d 1 /f && pause && goto appearance
if "%web%"=="11" reg add "HKCU\\Control Panel\Desktop" /v PaintDesktopVersion /t REG_DWORD /d 1 /f && pause && goto appearance
if "%web%"=="12" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v link /t REG_BINARY /d 15000000 /f && pause && goto appearance
if "%web%"=="13" reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v link /t REG_BINARY /d 00000000 /f && pause && goto appearance
if "%web%"=="14"  call :fixscale
if "%web%"=="15"  call :nofixscale
if "%web%"=="16"  call :defaultdpiset
if "%web%"=="17" goto settweakmenu
if "%web%"=="18" goto exit
goto appearance

:defaultdpiset
echo Windows Registry Editor Version 5.00 > .\defdpi.reg
echo. >> .\defdpi.reg
echo [HKEY_CURRENT_USER\Control Panel\Desktop] >> .\defdpi.reg
echo "LogPixels"=dword:00000096 >> .\defdpi.reg
echo "Win8DpiScaling"=dword:00000000 >> .\defdpi.reg
echo. >> .\defdpi.reg
echo [-HKEY_CURRENT_USER\Control Panel\Desktop\PerMonitorSettings] >> .\defdpi.reg
echo. >> .\defdpi.reg
echo [HKEY_CURRENT_USER\Control Panel\Desktop\WindowMetrics] >> .\defdpi.reg
echo "AppliedDPI"=dword:00000096 >> .\defdpi.reg
reg import .\defdpi.reg
pause
del .\defdpi.reg
goto appearance

:fixscale
echo Windows Registry Editor Version 5.00 > .\fixscale.reg
echo. >> .\fixscale.reg
echo [HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\Control Panel\Desktop] >> .\fixscale.reg
echo "EnablePerProcessSystemDPI"=dword:00000001 >> .\fixscale.reg
echo. >> .\fixscale.reg
echo [HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\Display] >> .\fixscale.reg
echo "EnablePerProcessSystemDPIForProcesses"="" >> .\fixscale.reg
echo "DisablePerProcessSystemDPIForProcesses"="" >> .\fixscale.reg
echo. >> .\fixscale.reg
echo [HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Control Panel\Desktop] >> .\fixscale.reg
echo "EnablePerProcessSystemDPI"=dword:00000001 >> .\fixscale.reg
echo. >> .\fixscale.reg
echo [HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Display] >> .\fixscale.reg
echo "EnablePerProcessSystemDPIForProcesses"=- >> .\fixscale.reg
echo "DisablePerProcessSystemDPIForProcesses"=- >> .\fixscale.reg
reg import .\fixscale.reg
pause
del .\fixscale.reg
goto appearance

:nofixscale
echo Windows Registry Editor Version 5.00 > .\fixscale.reg
echo. >> .\fixscale.reg
echo [HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\Control Panel\Desktop] >> .\fixscale.reg
echo "EnablePerProcessSystemDPI"=dword:00000000 >> .\fixscale.reg
echo. >> .\fixscale.reg
echo [HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\Display] >> .\fixscale.reg
echo "EnablePerProcessSystemDPIForProcesses"="" >> .\fixscale.reg
echo "DisablePerProcessSystemDPIForProcesses"="" >> .\fixscale.reg
echo. >> .\fixscale.reg
echo [HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Control Panel\Desktop] >> .\fixscale.reg
echo "EnablePerProcessSystemDPI"=dword:00000000 >> .\fixscale.reg
echo. >> .\fixscale.reg
echo [HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Display] >> .\fixscale.reg
echo "EnablePerProcessSystemDPIForProcesses"=- >> .\fixscale.reg
echo "DisablePerProcessSystemDPIForProcesses"=- >> .\fixscale.reg
reg import .\fixscale.reg
pause
del .\fixscale.reg
goto appearance


:contextmenu
mode con:cols=80 lines=22
echo.
echo Here you can add or remove custom items to the Right-Click Context Menu.
echo.
echo.
echo 1) Add "Take Ownership"
echo 2) Hide "Take Ownership"
echo 3) Add "Unblock File"
echo 4) Hide "Unblock File"
echo 5) Add "Classic Personalization Options"
echo 6) Hide "Classic Personalization Options"
echo 7) Add "Install CAB File"
echo 8) Hide "Install CAB File"
echo 9) Add "Open Command Prompt Here"
echo 10) Hide "Open Command Prompt Here"
echo 11) Next Page
echo 12) Back
echo.
echo.
set /p web=Type option:
if "%web%"=="1" call :AddOwnership
if "%web%"=="2" call :RemoveOwnership
if "%web%"=="3" call :AddUnblock
if "%web%"=="4" call RemoveUnblock
if "%web%"=="5" call :AddClassicPerson
if "%web%"=="6" call :RemoveClassicPerson
if "%web%"=="7" call :AddCAB
if "%web%"=="8" call :RemoveCab
if "%web%"=="9" call :AddCMD
if "%web%"=="10" call :RemoveCMD
if "%web%"=="11" goto contextmenup1
if "%web%"=="12" goto settweakmenu


:AddUnblock
echo Windows Registry Editor Version 5.00 > .\addunblock.reg
echo. >> .\addunblock.reg
echo [HKEY_CLASSES_ROOT\*\shell\unblock] >> .\addunblock.reg
echo "MUIVerb"="Unblock" >> .\addunblock.reg
echo "Extended"=- >> .\addunblock.reg
echo. >> .\addunblock.reg
echo [HKEY_CLASSES_ROOT\*\shell\unblock\command] >> .\addunblock.reg
echo @="powershell.exe Unblock-File -LiteralPath '%L'" >> .\addunblock.reg
echo. >> .\addunblock.reg
echo [HKEY_CLASSES_ROOT\Directory\shell\unblock] >> .\addunblock.reg
echo "MUIVerb"="Unblock" >> .\addunblock.reg
echo "Extended"=- >> .\addunblock.reg
echo "SubCommands"="" >> .\addunblock.reg
echo. >> .\addunblock.reg
echo [HKEY_CLASSES_ROOT\Directory\shell\unblock\shell\001flyout] >> .\addunblock.reg
echo "MUIVerb"="Unblock files in this folder" >> .\addunblock.reg
echo. >> .\addunblock.reg
echo [HKEY_CLASSES_ROOT\Directory\shell\unblock\shell\001flyout\command] >> .\addunblock.reg
echo @="powershell.exe get-childitem -LiteralPath '%L' | Unblock-File" >> .\addunblock.reg
echo. >> .\addunblock.reg
echo [HKEY_CLASSES_ROOT\Directory\shell\unblock\shell\002flyout] >> .\addunblock.reg
echo "MUIVerb"="Unblock files in this folder and subfolders" >> .\addunblock.reg
echo. >> .\addunblock.reg
echo [HKEY_CLASSES_ROOT\Directory\shell\unblock\shell\002flyout\command] >> .\addunblock.reg
echo @="powershell.exe get-childitem -LiteralPath '%L' -recurse | Unblock-File" >> .\addunblock.reg
reg import .\addunblock.reg
pause
del .\addunblock.reg
goto contextmenu
:RemoveUnblock
echo Windows Registry Editor Version 5.00 > .\removeunblock.reg
echo. >> .\removeunblock.reg
echo [-HKEY_CLASSES_ROOT\*\shell\unblock] >> .\removeunblock.reg
echo. >> .\removeunblock.reg
echo [-HKEY_CLASSES_ROOT\Directory\shell\unblock] >> .\removeunblock.reg
echo. >> .\removeunblock.reg
reg import .\removeunblock.reg
pause
del .\removeunblock.reg
goto contextmenu
:AddClassicPerson
echo Windows Registry Editor Version 5.00 > .\AddClassicPerson.reg
echo. >> .\AddClassicPerson.reg
echo [HKEY_CLASSES_ROOT\DesktopBackground\Shell\Personalization] >> .\AddClassicPerson.reg
echo "Icon"="themecpl.dll" >> .\AddClassicPerson.reg
echo "MUIVerb"="Personalize (Classic)" >> .\AddClassicPerson.reg
echo "Position"="Bottom" >> .\AddClassicPerson.reg
echo "SubCommands"="" >> .\AddClassicPerson.reg
echo. >> .\AddClassicPerson.reg
echo. >> .\AddClassicPerson.reg
echo [HKEY_CLASSES_ROOT\DesktopBackground\Shell\Personalization\shell\001flyout] >> .\AddClassicPerson.reg
echo "MUIVerb"="Theme Settings" >> .\AddClassicPerson.reg
echo "ControlPanelName"="Microsoft.Personalization" >> .\AddClassicPerson.reg
echo "Icon"="themecpl.dll" >> .\AddClassicPerson.reg
echo. >> .\AddClassicPerson.reg
echo [HKEY_CLASSES_ROOT\DesktopBackground\Shell\Personalization\shell\001flyout\command] >> .\AddClassicPerson.reg
echo @="explorer shell:::{ED834ED6-4B5A-4bfe-8F11-A626DCB6A921}" >> .\AddClassicPerson.reg
echo. >> .\AddClassicPerson.reg
echo. >> .\AddClassicPerson.reg
echo [HKEY_CLASSES_ROOT\DesktopBackground\Shell\Personalization\shell\002flyout] >> .\AddClassicPerson.reg
echo "Icon"="imageres.dll,-110" >> .\AddClassicPerson.reg
echo "MUIVerb"="Desktop Background" >> .\AddClassicPerson.reg
echo "CommandFlags"=dword:00000020 >> .\AddClassicPerson.reg
echo. >> .\AddClassicPerson.reg
echo [HKEY_CLASSES_ROOT\DesktopBackground\Shell\Personalization\shell\002flyout\command] >> .\AddClassicPerson.reg
echo @="explorer shell:::{ED834ED6-4B5A-4bfe-8F11-A626DCB6A921} -Microsoft.Personalization\\pageWallpaper" >> .\AddClassicPerson.reg
echo. >> .\AddClassicPerson.reg
echo [-HKEY_CLASSES_ROOT\DesktopBackground\Shell\Personalization\shell\003flyout] >> .\AddClassicPerson.reg
echo. >> .\AddClassicPerson.reg
echo [HKEY_CLASSES_ROOT\DesktopBackground\Shell\Personalization\shell\004flyout] >> .\AddClassicPerson.reg
echo "Icon"="themecpl.dll" >> .\AddClassicPerson.reg
echo "MUIVerb"="Color and Appearance" >> .\AddClassicPerson.reg
echo. >> .\AddClassicPerson.reg
echo [HKEY_CLASSES_ROOT\DesktopBackground\Shell\Personalization\shell\004flyout\command] >> .\AddClassicPerson.reg
echo @="explorer shell:::{ED834ED6-4B5A-4bfe-8F11-A626DCB6A921} -Microsoft.Personalization\\pageColorization" >> .\AddClassicPerson.reg
echo. >> .\AddClassicPerson.reg
echo. >> .\AddClassicPerson.reg
echo [HKEY_CLASSES_ROOT\DesktopBackground\Shell\Personalization\shell\005flyout] >> .\AddClassicPerson.reg
echo "Icon"="SndVol.exe,-101" >> .\AddClassicPerson.reg
echo "MUIVerb"="Sounds" >> .\AddClassicPerson.reg
echo. >> .\AddClassicPerson.reg
echo [HKEY_CLASSES_ROOT\DesktopBackground\Shell\Personalization\shell\005flyout\command] >> .\AddClassicPerson.reg
echo @="rundll32.exe shell32.dll,Control_RunDLL mmsys.cpl,,2" >> .\AddClassicPerson.reg
echo. >> .\AddClassicPerson.reg
echo. >> .\AddClassicPerson.reg
echo [HKEY_CLASSES_ROOT\DesktopBackground\Shell\Personalization\shell\006flyout] >> .\AddClassicPerson.reg
echo "Icon"="PhotoScreensaver.scr" >> .\AddClassicPerson.reg
echo "MUIVerb"="Screen Saver Settings" >> .\AddClassicPerson.reg
echo. >> .\AddClassicPerson.reg
echo [HKEY_CLASSES_ROOT\DesktopBackground\Shell\Personalization\shell\006flyout\command] >> .\AddClassicPerson.reg
echo @="rundll32.exe shell32.dll,Control_RunDLL desk.cpl,,1" >> .\AddClassicPerson.reg
echo. >> .\AddClassicPerson.reg
echo. >> .\AddClassicPerson.reg
echo [HKEY_CLASSES_ROOT\DesktopBackground\Shell\Personalization\shell\007flyout] >> .\AddClassicPerson.reg
echo "Icon"="desk.cpl" >> .\AddClassicPerson.reg
echo "MUIVerb"="Desktop Icon Settings" >> .\AddClassicPerson.reg
echo "CommandFlags"=dword:00000020 >> .\AddClassicPerson.reg
echo. >> .\AddClassicPerson.reg
echo [HKEY_CLASSES_ROOT\DesktopBackground\Shell\Personalization\shell\007flyout\command] >> .\AddClassicPerson.reg
echo @="rundll32.exe shell32.dll,Control_RunDLL desk.cpl,,0" >> .\AddClassicPerson.reg
echo. >> .\AddClassicPerson.reg
echo. >> .\AddClassicPerson.reg
echo [HKEY_CLASSES_ROOT\DesktopBackground\Shell\Personalization\shell\008flyout] >> .\AddClassicPerson.reg
echo "Icon"="main.cpl" >> .\AddClassicPerson.reg
echo "MUIVerb"="Mouse Pointers" >> .\AddClassicPerson.reg
echo. >> .\AddClassicPerson.reg
echo [HKEY_CLASSES_ROOT\DesktopBackground\Shell\Personalization\shell\008flyout\command] >> .\AddClassicPerson.reg
echo @="rundll32.exe shell32.dll,Control_RunDLL main.cpl,,1" >> .\AddClassicPerson.reg
echo. >> .\AddClassicPerson.reg
echo. >> .\AddClassicPerson.reg
echo [HKEY_CLASSES_ROOT\DesktopBackground\Shell\Personalization\shell\009flyout] >> .\AddClassicPerson.reg
echo "Icon"="taskbarcpl.dll,-1" >> .\AddClassicPerson.reg
echo "MUIVerb"="Notification Area Icons" >> .\AddClassicPerson.reg
echo "CommandFlags"=dword:00000020 >> .\AddClassicPerson.reg
echo. >> .\AddClassicPerson.reg
echo [HKEY_CLASSES_ROOT\DesktopBackground\Shell\Personalization\shell\009flyout\command] >> .\AddClassicPerson.reg
echo @="explorer shell:::{05d7b0f4-2121-4eff-bf6b-ed3f69b894d9}" >> .\AddClassicPerson.reg
echo. >> .\AddClassicPerson.reg
echo. >> .\AddClassicPerson.reg
echo [HKEY_CLASSES_ROOT\DesktopBackground\Shell\Personalization\shell\010flyout] >> .\AddClassicPerson.reg
echo "Icon"="taskbarcpl.dll,-1" >> .\AddClassicPerson.reg
echo "MUIVerb"="System Icons" >> .\AddClassicPerson.reg
echo. >> .\AddClassicPerson.reg
echo [HKEY_CLASSES_ROOT\DesktopBackground\Shell\Personalization\shell\010flyout\command] >> .\AddClassicPerson.reg
echo @="explorer shell:::{05d7b0f4-2121-4eff-bf6b-ed3f69b894d9} \\SystemIcons,,0" >> .\AddClassicPerson.reg
reg import .\AddClassicPerson.reg
pause
del .\AddClassicPerson.reg
goto contextmenu
:RemoveClassicPerson
echo Windows Registry Editor Version 5.00 > .\RemoveClassicPerson.reg
echo. >> .\RemoveClassicPerson.reg
echo [-HKEY_CLASSES_ROOT\DesktopBackground\Shell\Personalization] >> .\RemoveClassicPerson.reg
echo. >> .\RemoveClassicPerson.reg
reg import .\RemoveClassicPerson.reg
pause
del .\RemoveClassicPerson.reg
goto contextmenu
:AddCAB
echo Windows Registry Editor Version 5.00 > .\AddCAB.reg
echo. >> .\AddCAB.reg
echo [-HKEY_CLASSES_ROOT\CABFolder\Shell\RunAs] >> .\AddCAB.reg
echo. >> .\AddCAB.reg
echo [HKEY_CLASSES_ROOT\CABFolder\Shell\RunAs] >> .\AddCAB.reg
echo @="Install Cab File" >> .\AddCAB.reg
echo "HasLUAShield"="" >> .\AddCAB.reg
echo. >> .\AddCAB.reg
echo [HKEY_CLASSES_ROOT\CABFolder\Shell\RunAs\Command] >> .\AddCAB.reg
echo @="cmd /k dism /online /add-package /packagepath:\"%1\"" >> .\AddCAB.reg
echo. >> .\AddCAB.reg
echo. >> .\AddCAB.reg
reg import .\AddCAB.reg
pause
del .\AddCAB.reg
goto contextmenu
:RemoveCab
echo Windows Registry Editor Version 5.00 > .\RemoveCab.reg
echo. >> .\RemoveCab.reg
echo [-HKEY_CLASSES_ROOT\CABFolder\Shell\RunAs] >> .\RemoveCab.reg
echo. >> .\RemoveCab.reg
echo. >> .\RemoveCab.reg
echo. >> .\RemoveCab.reg
reg import .\RemoveCab.reg
pause
del .\RemoveCab.reg
goto contextmenu
:AddCMD
echo Windows Registry Editor Version 5.00 > .\AddCMD.reg
echo. >> .\AddCMD.reg
echo [HKEY_CLASSES_ROOT\Directory\shell\cmd2] >> .\AddCMD.reg
echo @="@shell32.dll,-8506" >> .\AddCMD.reg
echo "Extended"=- >> .\AddCMD.reg
echo "Icon"="imageres.dll,-5323" >> .\AddCMD.reg
echo "NoWorkingDirectory"="" >> .\AddCMD.reg
echo. >> .\AddCMD.reg
echo [HKEY_CLASSES_ROOT\Directory\shell\cmd2\command] >> .\AddCMD.reg
echo @="cmd.exe /s /k pushd \"%V\"" >> .\AddCMD.reg
echo. >> .\AddCMD.reg
echo. >> .\AddCMD.reg
echo [HKEY_CLASSES_ROOT\Directory\Background\shell\cmd2] >> .\AddCMD.reg
echo @="@shell32.dll,-8506" >> .\AddCMD.reg
echo "Extended"=- >> .\AddCMD.reg
echo "Icon"="imageres.dll,-5323" >> .\AddCMD.reg
echo "NoWorkingDirectory"="" >> .\AddCMD.reg
echo. >> .\AddCMD.reg
echo [HKEY_CLASSES_ROOT\Directory\Background\shell\cmd2\command] >> .\AddCMD.reg
echo @="cmd.exe /s /k pushd \"%V\"" >> .\AddCMD.reg
echo. >> .\AddCMD.reg
echo. >> .\AddCMD.reg
echo [HKEY_CLASSES_ROOT\Drive\shell\cmd2] >> .\AddCMD.reg
echo @="@shell32.dll,-8506" >> .\AddCMD.reg
echo "Extended"=- >> .\AddCMD.reg
echo "Icon"="imageres.dll,-5323" >> .\AddCMD.reg
echo "NoWorkingDirectory"="" >> .\AddCMD.reg
echo. >> .\AddCMD.reg
echo [HKEY_CLASSES_ROOT\Drive\shell\cmd2\command] >> .\AddCMD.reg
echo @="cmd.exe /s /k pushd \"%V\"" >> .\AddCMD.reg
echo. >> .\AddCMD.reg
echo. >> .\AddCMD.reg
echo [HKEY_CLASSES_ROOT\LibraryFolder\Background\shell\cmd2] >> .\AddCMD.reg
echo @="@shell32.dll,-8506" >> .\AddCMD.reg
echo "Extended"=- >> .\AddCMD.reg
echo "Icon"="imageres.dll,-5323" >> .\AddCMD.reg
echo "NoWorkingDirectory"="" >> .\AddCMD.reg
echo. >> .\AddCMD.reg
echo [HKEY_CLASSES_ROOT\LibraryFolder\Background\shell\cmd2\command] >> .\AddCMD.reg
echo @="cmd.exe /s /k pushd \"%V\"" >> .\AddCMD.reg
reg import .\AddCMD.reg
pause
del .\AddCMD.reg
goto contextmenu
:RemoveCMD
echo Windows Registry Editor Version 5.00 > .\RemoveCMD.reg
echo. >> .\RemoveCMD.reg
echo [-HKEY_CLASSES_ROOT\Directory\shell\cmd2] >> .\RemoveCMD.reg
echo. >> .\RemoveCMD.reg
echo [-HKEY_CLASSES_ROOT\Directory\Background\shell\cmd2] >> .\RemoveCMD.reg
echo. >> .\RemoveCMD.reg
echo [-HKEY_CLASSES_ROOT\Drive\shell\cmd2] >> .\RemoveCMD.reg
echo. >> .\RemoveCMD.reg
echo [-HKEY_CLASSES_ROOT\LibraryFolder\Background\shell\cmd2] >> .\RemoveCMD.reg
echo. >> .\RemoveCMD.reg
echo. >> .\RemoveCMD.reg
echo. >> .\RemoveCMD.reg
reg import .\RemoveCMD.reg
pause
del .\RemoveCMD.reg
goto contextmenu

:AddOwnership
echo Windows Registry Editor Version 5.00 > .\addown.reg
echo. >> .\addown.reg
echo [HKEY_CLASSES_ROOT\*\shell\runas] >> .\addown.reg
echo @="Take Ownership" >> .\addown.reg
echo "NoWorkingDirectory"="" >> .\addown.reg
echo. >> .\addown.reg
echo [HKEY_CLASSES_ROOT\*\shell\runas\command] >> .\addown.reg
echo @="cmd.exe /c takeown /f \"%1\" && icacls \"%1\" /grant administrators:F" >> .\addown.reg
echo "IsolatedCommand"="cmd.exe /c takeown /f \"%1\" && icacls \"%1\" /grant administrators:F" >> .\addown.reg
echo. >> .\addown.reg
echo [HKEY_CLASSES_ROOT\Directory\shell\runas] >> .\addown.reg
echo @="Take Ownership" >> .\addown.reg
echo "NoWorkingDirectory"="" >> .\addown.reg
echo. >> .\addown.reg
echo [HKEY_CLASSES_ROOT\Directory\shell\runas\command] >> .\addown.reg
echo @="cmd.exe /c takeown /f \"%1\" /r /d y && icacls \"%1\" /grant administrators:F /t" >> .\addown.reg
echo "IsolatedCommand"="cmd.exe /c takeown /f \"%1\" /r /d y && icacls \"%1\" /grant administrators:F /t" >> .\addown.reg
reg import .\addown.reg
pause
del .\addown.reg
goto contextmenu

:RemoveOwnership
echo Windows Registry Editor Version 5.00 > .\noown.reg
echo. >> .\noown.reg
echo [-HKEY_CLASSES_ROOT\*\shell\runas] >> .\noown.reg
echo. >> .\noown.reg
echo [-HKEY_CLASSES_ROOT\Directory\shell\runas] >> .\noown.reg
reg import .\noown.reg
pause
del .\noown.reg
goto contextmenu

:contextmenup1
mode con:cols=80 lines=22
echo.
echo.
echo 1) Add "Kill All Not Responding Tasks"
echo 2) Hide "Kill All Not Responding Tasks"
echo 3) Add "Scan With Windows Defender"
echo 4) Hide "Scan With Windows Defender"
echo 5) Add "Windows Defender Antivirus"
echo 6) Hide "Windows Defender Antivirus"
echo 7) Add "System File Checker"
echo 8) Hide "System File Checker"
echo 9) Add "Burn Disc Image"
echo 10) Hide "Burn Disc Image"
echo 11) Enable Wide Context Menu (Might be better for Touch devices)
echo 12) Disable Wide Context Menu 
echo 13) Back
echo.
echo.
set /p web=Type option:
if "%web%"=="1" call :AddKillTasks
if "%web%"=="2" call :RemoveKillTasks
if "%web%"=="3" call :AddScanDefend
if "%web%"=="4" call :RemoveScanDefend
if "%web%"=="5" call :AddAntivirus
if "%web%"=="6" call :RemoveAntivirus
if "%web%"=="7" call :AddSFC
if "%web%"=="8" call :RemoveSFC
if "%web%"=="9" call :AddBurn
if "%web%"=="10" call :RemoveBurn
if "%web%"=="11" call :EnableWideMenu
if "%web%"=="12" call :DisableWideMenu
if "%web%"=="13" goto settweakmenu

:AddKillTasks
echo Windows Registry Editor Version 5.00 > .\AddKillTasks.reg
echo. >> .\AddKillTasks.reg
echo [HKEY_CLASSES_ROOT\DesktopBackground\Shell\KillNRTasks] >> .\AddKillTasks.reg
echo "icon"="taskmgr.exe,-30651" >> .\AddKillTasks.reg
echo "MUIverb"="Kill all not responding tasks" >> .\AddKillTasks.reg
echo "Position"="Top" >> .\AddKillTasks.reg
echo. >> .\AddKillTasks.reg
echo [HKEY_CLASSES_ROOT\DesktopBackground\Shell\KillNRTasks\command] >> .\AddKillTasks.reg
echo @="CMD.exe /C taskkill.exe /f /fi \"status eq Not Responding\" & Pause" >> .\AddKillTasks.reg
echo. >> .\AddKillTasks.reg
reg import .\AddKillTasks.reg
pause
del .\AddKillTasks.reg
goto contextmenup1

:RemoveKillTasks
echo Windows Registry Editor Version 5.00 > .\RemoveKillTasks.reg
echo. >> .\RemoveKillTasks.reg
echo [-HKEY_CLASSES_ROOT\DesktopBackground\Shell\KillNRTasks] >> .\RemoveKillTasks.reg
echo. >> .\RemoveKillTasks.reg
reg import .\RemoveKillTasks.reg
pause
del .\RemoveKillTasks.reg
goto contextmenup1

:AddScanDefend
echo Windows Registry Editor Version 5.00 > .\AddScanDefend.reg
echo. >> .\AddScanDefend.reg
echo [HKEY_CLASSES_ROOT\*\shellex\ContextMenuHandlers\EPP] >> .\AddScanDefend.reg
echo @="{09A47860-11B0-4DA5-AFA5-26D86198A780}" >> .\AddScanDefend.reg
echo. >> .\AddScanDefend.reg
echo [HKEY_CLASSES_ROOT\CLSID\{09A47860-11B0-4DA5-AFA5-26D86198A780}\InprocServer32] >> .\AddScanDefend.reg
echo @="C:\\Program Files\\Windows Defender\\shellext.dll" >> .\AddScanDefend.reg
echo "ThreadingModel"="Apartment" >> .\AddScanDefend.reg
echo. >> .\AddScanDefend.reg
echo [HKEY_CLASSES_ROOT\CLSID\{09A47860-11B0-4DA5-AFA5-26D86198A780}\Version] >> .\AddScanDefend.reg
echo @="10.0.18362.1" >> .\AddScanDefend.reg
echo. >> .\AddScanDefend.reg
echo [HKEY_CLASSES_ROOT\Directory\shellex\ContextMenuHandlers\EPP] >> .\AddScanDefend.reg
echo @="{09A47860-11B0-4DA5-AFA5-26D86198A780}" >> .\AddScanDefend.reg
echo. >> .\AddScanDefend.reg
echo [HKEY_CLASSES_ROOT\Drive\shellex\ContextMenuHandlers\EPP] >> .\AddScanDefend.reg
echo @="{09A47860-11B0-4DA5-AFA5-26D86198A780}" >> .\AddScanDefend.reg
echo. >> .\AddScanDefend.reg
reg import .\AddScanDefend.reg
pause
del .\AddScanDefend.reg
goto contextmenup1

:RemoveScanDefend
echo Windows Registry Editor Version 5.00 > .\RemoveScanDefend.reg
echo. >> .\RemoveScanDefend.reg
echo [-HKEY_CLASSES_ROOT\*\shellex\ContextMenuHandlers\EPP] >> .\RemoveScanDefend.reg
echo. >> .\RemoveScanDefend.reg
echo [-HKEY_CLASSES_ROOT\CLSID\{09A47860-11B0-4DA5-AFA5-26D86198A780}] >> .\RemoveScanDefend.reg
echo. >> .\RemoveScanDefend.reg
echo [-HKEY_CLASSES_ROOT\Directory\shellex\ContextMenuHandlers\EPP] >> .\RemoveScanDefend.reg
echo. >> .\RemoveScanDefend.reg
echo [-HKEY_CLASSES_ROOT\Drive\shellex\ContextMenuHandlers\EPP] >> .\RemoveScanDefend.reg
echo. >> .\RemoveScanDefend.reg
reg import .\RemoveScanDefend.reg
pause
del .\RemoveScanDefend.reg
goto contextmenup1

:AddAntivirus
echo Windows Registry Editor Version 5.00 > .\AddAntivirus.reg
echo. >> .\AddAntivirus.reg
echo [-HKEY_CLASSES_ROOT\DesktopBackground\Shell\WindowsDefender] >> .\AddAntivirus.reg
echo. >> .\AddAntivirus.reg
echo [HKEY_CLASSES_ROOT\DesktopBackground\Shell\WindowsDefender] >> .\AddAntivirus.reg
echo "Icon"="%ProgramFiles%\\Windows Defender\\EppManifest.dll,-101" >> .\AddAntivirus.reg
echo "MUIVerb"="Windows Defender Antivirus" >> .\AddAntivirus.reg
echo "Position"="Bottom" >> .\AddAntivirus.reg
echo "SubCommands"="" >> .\AddAntivirus.reg
echo. >> .\AddAntivirus.reg
echo. >> .\AddAntivirus.reg
echo [HKEY_CLASSES_ROOT\DesktopBackground\Shell\WindowsDefender\shell\001flyout] >> .\AddAntivirus.reg
echo "Icon"="%ProgramFiles%\\Windows Defender\\EppManifest.dll,-101" >> .\AddAntivirus.reg
echo "MUIVerb"="Windows Security" >> .\AddAntivirus.reg
echo. >> .\AddAntivirus.reg
echo [HKEY_CLASSES_ROOT\DesktopBackground\Shell\WindowsDefender\shell\001flyout\command] >> .\AddAntivirus.reg
echo @="explorer windowsdefender:" >> .\AddAntivirus.reg
echo. >> .\AddAntivirus.reg
echo. >> .\AddAntivirus.reg
echo [HKEY_CLASSES_ROOT\DesktopBackground\Shell\WindowsDefender\shell\002flyout] >> .\AddAntivirus.reg
echo "Icon"="%ProgramFiles%\\Windows Defender\\EppManifest.dll,-101" >> .\AddAntivirus.reg
echo "MUIVerb"="Windows Security in Settings" >> .\AddAntivirus.reg
echo. >> .\AddAntivirus.reg
echo [HKEY_CLASSES_ROOT\DesktopBackground\Shell\WindowsDefender\shell\002flyout\command] >> .\AddAntivirus.reg
echo @="explorer ms-settings:windowsdefender" >> .\AddAntivirus.reg
echo. >> .\AddAntivirus.reg
echo. >> .\AddAntivirus.reg
echo [HKEY_CLASSES_ROOT\DesktopBackground\Shell\WindowsDefender\shell\003flyout] >> .\AddAntivirus.reg
echo "CommandFlags"=dword:00000020 >> .\AddAntivirus.reg
echo "Icon"="%ProgramFiles%\\Windows Defender\\EppManifest.dll,-101" >> .\AddAntivirus.reg
echo "MUIVerb"="Update" >> .\AddAntivirus.reg
echo. >> .\AddAntivirus.reg
echo [HKEY_CLASSES_ROOT\DesktopBackground\Shell\WindowsDefender\shell\003flyout\command] >> .\AddAntivirus.reg
echo @="\"C:\\Program Files\\Windows Defender\\MpCmdRun.exe\" -SignatureUpdate" >> .\AddAntivirus.reg
echo. >> .\AddAntivirus.reg
echo. >> .\AddAntivirus.reg
echo [HKEY_CLASSES_ROOT\DesktopBackground\Shell\WindowsDefender\shell\004flyout] >> .\AddAntivirus.reg
echo "Icon"="%ProgramFiles%\\Windows Defender\\EppManifest.dll,-101" >> .\AddAntivirus.reg
echo "MUIVerb"="Quick Scan" >> .\AddAntivirus.reg
echo. >> .\AddAntivirus.reg
echo [HKEY_CLASSES_ROOT\DesktopBackground\Shell\WindowsDefender\shell\004flyout\command] >> .\AddAntivirus.reg
echo @="\"C:\\Program Files\\Windows Defender\\MpCmdRun.exe\" -Scan -ScanType 1" >> .\AddAntivirus.reg
echo. >> .\AddAntivirus.reg
echo. >> .\AddAntivirus.reg
echo [HKEY_CLASSES_ROOT\DesktopBackground\Shell\WindowsDefender\shell\005flyout] >> .\AddAntivirus.reg
echo "Icon"="%ProgramFiles%\\Windows Defender\\EppManifest.dll,-101" >> .\AddAntivirus.reg
echo "MUIVerb"="Full Scan" >> .\AddAntivirus.reg
echo. >> .\AddAntivirus.reg
echo [HKEY_CLASSES_ROOT\DesktopBackground\Shell\WindowsDefender\shell\005flyout\command] >> .\AddAntivirus.reg
echo @="\"C:\\Program Files\\Windows Defender\\MpCmdRun.exe\" -Scan -ScanType 2" >> .\AddAntivirus.reg
echo. >> .\AddAntivirus.reg
echo. >> .\AddAntivirus.reg
echo [HKEY_CLASSES_ROOT\DesktopBackground\Shell\WindowsDefender\shell\006flyout] >> .\AddAntivirus.reg
echo "CommandFlags"=dword:00000020 >> .\AddAntivirus.reg
echo "HasLUAShield"="" >> .\AddAntivirus.reg
echo "Icon"="%ProgramFiles%\\Windows Defender\\EppManifest.dll,-101" >> .\AddAntivirus.reg
echo "MUIVerb"="Offline Scan" >> .\AddAntivirus.reg
echo. >> .\AddAntivirus.reg
echo [HKEY_CLASSES_ROOT\DesktopBackground\Shell\WindowsDefender\shell\006flyout\command] >> .\AddAntivirus.reg
echo @="PowerShell.exe Start-Process PowerShell -Verb RunAs Start-MpWDOScan" >> .\AddAntivirus.reg
echo. >> .\AddAntivirus.reg
reg import .\AddAntivirus.reg
pause
del .\AddAntivirus.reg
goto contextmenup1

:RemoveAntivirus
echo Windows Registry Editor Version 5.00 > .\RemoveAntivirus.reg
echo. >> .\RemoveAntivirus.reg
echo [-HKEY_CLASSES_ROOT\DesktopBackground\Shell\WindowsDefender] >>  .\RemoveAntivirus.reg
echo. >>  .\RemoveAntivirus.reg
reg import .\RemoveAntivirus.reg
pause
del .\RemoveAntivirus.reg
goto contextmenup1

:AddSFC
echo Windows Registry Editor Version 5.00 > .\AddSFC.reg
echo. >> .\AddSFC.reg
echo [HKEY_CLASSES_ROOT\DesktopBackground\Shell\SFC] >> .\AddSFC.reg
echo "Icon"="WmiPrvSE.exe" >> .\AddSFC.reg
echo "MUIVerb"="System File Checker" >> .\AddSFC.reg
echo "Position"="Bottom" >> .\AddSFC.reg
echo "Extended"=- >> .\AddSFC.reg
echo "SubCommands"="" >> .\AddSFC.reg
echo. >> .\AddSFC.reg
echo [HKEY_CLASSES_ROOT\DesktopBackground\shell\SFC\shell\001menu] >> .\AddSFC.reg
echo "HasLUAShield"="" >> .\AddSFC.reg
echo "MUIVerb"="Run System File Checker" >> .\AddSFC.reg
echo. >> .\AddSFC.reg
echo [HKEY_CLASSES_ROOT\DesktopBackground\shell\SFC\shell\001menu\command] >> .\AddSFC.reg
echo @="PowerShell -windowstyle hidden -command \"Start-Process cmd -ArgumentList '/s,/k, sfc /scannow' -Verb runAs\"" >> .\AddSFC.reg
echo. >> .\AddSFC.reg
echo [HKEY_CLASSES_ROOT\DesktopBackground\shell\SFC\shell\002menu] >> .\AddSFC.reg
echo "MUIVerb"="System File Checker log" >> .\AddSFC.reg
echo. >> .\AddSFC.reg
echo [HKEY_CLASSES_ROOT\DesktopBackground\shell\SFC\shell\002menu\command] >> .\AddSFC.reg
echo @="PowerShell (sls [SR] $env:windir\\Logs\\CBS\\CBS.log -s).Line >\"$env:userprofile\\Desktop\\sfcdetails.txt\"" >> .\AddSFC.reg
echo. >> .\AddSFC.reg
reg import .\AddSFC.reg
pause
del .\AddSFC.reg
goto contextmenup1

:RemoveSFC
echo Windows Registry Editor Version 5.00 > .\RemoveSFC.reg
echo. >> .\RemoveSFC.reg
echo [-HKEY_CLASSES_ROOT\DesktopBackground\Shell\SFC] >> .\RemoveSFC.reg
echo. >> .\RemoveSFC.reg
reg import .\RemoveSFC.reg
pause
del .\RemoveSFC.reg
goto contextmenup1

:AddBurn
echo Windows Registry Editor Version 5.00 > .\AddBurn.reg
echo. >> .\AddBurn.reg
echo [HKEY_CLASSES_ROOT\Windows.IsoFile\shell\burn] >> .\AddBurn.reg
echo "MUIVerb"=hex(2):40,00,25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,\ >> .\AddBurn.reg
echo   6f,00,74,00,25,00,5c,00,53,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,\ >> .\AddBurn.reg
echo   00,69,00,73,00,6f,00,62,00,75,00,72,00,6e,00,2e,00,65,00,78,00,65,00,2c,00,\ >> .\AddBurn.reg
echo   2d,00,33,00,35,00,31,00,00,00 >> .\AddBurn.reg
echo. >> .\AddBurn.reg
echo [HKEY_CLASSES_ROOT\Windows.IsoFile\shell\burn\command] >> .\AddBurn.reg
echo @=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,\ >> .\AddBurn.reg
echo   00,5c,00,53,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,69,00,73,00,\ >> .\AddBurn.reg
echo   6f,00,62,00,75,00,72,00,6e,00,2e,00,65,00,78,00,65,00,20,00,22,00,25,00,31,\ >> .\AddBurn.reg
echo   00,22,00,00,00 >> .\AddBurn.reg
echo. >> .\AddBurn.reg
echo. >> .\AddBurn.reg
reg import .\AddBurn.reg
pause
del .\AddBurn.reg
goto contextmenup1

:RemoveBurn
echo Windows Registry Editor Version 5.00 > .\RemoveBurn.reg
echo. >> .\RemoveBurn.reg
echo [-HKEY_CLASSES_ROOT\Windows.IsoFile\shell\burn] >> .\RemoveBurn.reg
echo. >> .\RemoveBurn.reg
reg import .\RemoveBurn.reg
pause
del .\RemoveBurn.reg
goto contextmenup1

:EnableWideMenu
powershell.exe -command "& {Start-Process cmd -ArgumentList '/s,/c,REG ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\FlightedFeatures" /V ImmersiveContextMenu /T REG_DWORD /D 1 /F' -Verb runAs}"
echo Restarting Explorer
pause
taskkill /f /im explorer.exe
start explorer.exe
goto contextmenup1


:DisableWideMenu
powershell.exe -command "& {Start-Process cmd -ArgumentList '/s,/c,REG ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\FlightedFeatures" /V ImmersiveContextMenu /T REG_DWORD /D 0 /F' -Verb runAs}"
echo Restarting Explorer
pause
taskkill /f /im explorer.exe
start explorer.exe
goto contextmenup1


:misc
mode con:cols=80 lines=22
echo.
echo Here is some tweaks that I can't make proper catagories for yet.
echo.
echo.
echo 1) Disable Windows Keylogger/Autologger
echo 2) Enable Windows Keylogger/Autologger
echo 3) Disable WiFi Sense
echo 4) Enable Wifi Sense
echo 5) Disable Windows Defender Sample Submission
echo 6) Enable Windows Defender Sample Submission
echo 7) Disable SmartScreen Filter for Store Apps (Unsure of purpose)
echo 8) Enable SmartScreen Filter for Store Apps
echo 9) Back
echo 10) Exit
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
if "%web%"=="9" goto settweakmenu
if "%web%"=="10" exit
goto misc


:explorermenu
mode con:cols=80 lines=22
echo.
echo Here is a list of File Explorer Settings and Tweaks
echo.
echo.
echo 1) Add Details Pane to File Explorer
echo 2) Remove Details Pane to File Explorer
echo 3) Enable Thumbnail Previews
echo 4) Disable Thumbnail Previews
echo 5) Add Quick Access to Navigation Pane
echo 6) Remove Quick Access from Navigation Pane
echo 7) Show File Name Extentions
echo 8) Hide File Name Extensions
echo 9) Add "Delete Folder Contents" to Explorer Context Menu
echo 10) Remove "Delete Folder Contents" to Explorer Context Menu
echo 11) Reset Folder View Settings
echo 12) Restore Default Shell Folders
echo 13) Add Administrator Control Panel to Desktop 'GodMode Folder'
echo 14) Back
echo 15) Exit

echo.
echo.
set /p web=Type option:
if "%web%"=="1" call :AddDetailPane
if "%web%"=="2" call :RemoveDetailpane
if "%web%"=="3" call :EnableThumbs
if "%web%"=="4" call :DisableThumbs
if "%web%"=="5" call :AddQuick
if "%web%"=="6" call :RemoveQuick
if "%web%"=="7" call :ShowExten
if "%web%"=="8" call :HideExtendd
if "%web%"=="9" call :AddDelFolder
if "%web%"=="10" call :RemoveDelFolder
if "%web%"=="11" call :ResetFolderView
if "%web%"=="12" call :RestoreDefaultShell
if "%web%"=="13" mkdir %userprofile%\Desktop\GodMode.{ED7BA470-8E54-465E-825C-99712043E01C} && explorer.exe %userprofile%\Desktop\GodMode.{ED7BA470-8E54-465E-825C-99712043E01C}
if "%web%"=="14" goto settweakmenu
if "%web%"=="15" exit
goto explorermenu

:AddDetailPane
echo Windows Registry Editor Version 5.00 > .\AddDetailPane.reg
echo. >> .\AddDetailPane.reg
echo. >> .\AddDetailPane.reg
echo [HKEY_CLASSES_ROOT\AllFilesystemObjects\shell\Windows.previewpane] >> .\AddDetailPane.reg
echo "CanonicalName"="{1380d028-a77f-4c12-96c7-ea276333f982}" >> .\AddDetailPane.reg
echo "Description"="@shell32.dll,-31416" >> .\AddDetailPane.reg
echo "Icon"="shell32.dll,-16814" >> .\AddDetailPane.reg
echo "MUIVerb"="@shell32.dll,-31415" >> .\AddDetailPane.reg
echo "PaneID"="{43abf98b-89b8-472d-b9ce-e69b8229f019}" >> .\AddDetailPane.reg
echo "PaneVisibleProperty"="PreviewPaneSizer_Visible" >> .\AddDetailPane.reg
echo "PolicyID"="{17067f8d-981b-42c5-98f8-5bc016d4b073}" >> .\AddDetailPane.reg
echo. >> .\AddDetailPane.reg
echo. >> .\AddDetailPane.reg
echo [HKEY_CLASSES_ROOT\Directory\Background\shell\Windows.previewpane] >> .\AddDetailPane.reg
echo "CanonicalName"="{1380d028-a77f-4c12-96c7-ea276333f982}" >> .\AddDetailPane.reg
echo "Description"="@shell32.dll,-31416" >> .\AddDetailPane.reg
echo "Icon"="shell32.dll,-16814" >> .\AddDetailPane.reg
echo "MUIVerb"="@shell32.dll,-31415" >> .\AddDetailPane.reg
echo "PaneID"="{43abf98b-89b8-472d-b9ce-e69b8229f019}" >> .\AddDetailPane.reg
echo "PaneVisibleProperty"="PreviewPaneSizer_Visible" >> .\AddDetailPane.reg
echo "PolicyID"="{17067f8d-981b-42c5-98f8-5bc016d4b073}" >> .\AddDetailPane.reg
echo. >> .\AddDetailPane.reg
echo. >> .\AddDetailPane.reg
echo [HKEY_CLASSES_ROOT\Drive\shell\Windows.previewpane] >> .\AddDetailPane.reg
echo "CanonicalName"="{1380d028-a77f-4c12-96c7-ea276333f982}" >> .\AddDetailPane.reg
echo "Description"="@shell32.dll,-31416" >> .\AddDetailPane.reg
echo "Icon"="shell32.dll,-16814" >> .\AddDetailPane.reg
echo "MUIVerb"="@shell32.dll,-31415" >> .\AddDetailPane.reg
echo "PaneID"="{43abf98b-89b8-472d-b9ce-e69b8229f019}" >> .\AddDetailPane.reg
echo "PaneVisibleProperty"="PreviewPaneSizer_Visible" >> .\AddDetailPane.reg
echo "PolicyID"="{17067f8d-981b-42c5-98f8-5bc016d4b073}" >> .\AddDetailPane.reg
echo. >> .\AddDetailPane.reg
echo. >> .\AddDetailPane.reg
echo [HKEY_CLASSES_ROOT\LibraryFolder\background\shell\Windows.previewpane] >> .\AddDetailPane.reg
echo "CanonicalName"="{1380d028-a77f-4c12-96c7-ea276333f982}" >> .\AddDetailPane.reg
echo "Description"="@shell32.dll,-31416" >> .\AddDetailPane.reg
echo "Icon"="shell32.dll,-16814" >> .\AddDetailPane.reg
echo "MUIVerb"="@shell32.dll,-31415" >> .\AddDetailPane.reg
echo "PaneID"="{43abf98b-89b8-472d-b9ce-e69b8229f019}" >> .\AddDetailPane.reg
echo "PaneVisibleProperty"="PreviewPaneSizer_Visible" >> .\AddDetailPane.reg
echo "PolicyID"="{17067f8d-981b-42c5-98f8-5bc016d4b073}" >> .\AddDetailPane.reg
echo. >> .\AddDetailPane.reg
echo. >> .\AddDetailPane.reg
reg import .\AddDetailPane.reg
pause
del .\AddDetailPane.reg
goto explorermenu


:RemoveDetailpane
echo Windows Registry Editor Version 5.00 > .\RemoveDetailpane.reg
echo. >> .\RemoveDetailpane.reg
echo [-HKEY_CLASSES_ROOT\AllFilesystemObjects\shell\Windows.previewpane] >> .\RemoveDetailpane.reg
echo. >> .\RemoveDetailpane.reg
echo [-HKEY_CLASSES_ROOT\Directory\Background\\shell\Windows.previewpane] >> .\RemoveDetailpane.reg
echo. >> .\RemoveDetailpane.reg
echo [-HKEY_CLASSES_ROOT\Drive\shell\Windows.previewpane] >> .\RemoveDetailpane.reg
echo. >> .\RemoveDetailpane.reg
echo [-HKEY_CLASSES_ROOT\LibraryFolder\background\shell\Windows.previewpane] >> .\RemoveDetailpane.reg
echo. >> .\RemoveDetailpane.reg
echo. >> .\RemoveDetailpane.reg
reg import .\RemoveDetailpane.reg
pause
del .\RemoveDetailpane.reg
goto explorermenu



:DisableThumbs
echo Windows Registry Editor Version 5.00 > .\DisableThumbs.reg
echo. >> .\DisableThumbs.reg
echo [HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer] >> .\DisableThumbs.reg
echo "DisableThumbnails"=dword:00000001 >> .\DisableThumbs.reg
echo. >> .\DisableThumbs.reg
echo [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer] >> .\DisableThumbs.reg
echo "DisableThumbnails"=dword:00000001 >> .\DisableThumbs.reg
echo. >> .\DisableThumbs.reg
echo. >> .\DisableThumbs.reg
reg import .\DisableThumbs.reg
REG ADD "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /V IconsOnly /T REG_DWORD /D 1 /F
echo Explorer Will Restart.
taskkill /f /im explorer.exe
start explorer.exe
pause
del .\DisableThumbs.reg
goto explorermenu

:EnableThumbs
echo Windows Registry Editor Version 5.00 > .\EnableThumbs.reg
echo. >> .\EnableThumbs.reg
echo [HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer] >> .\EnableThumbs.reg
echo "DisableThumbnails"=- >> .\EnableThumbs.reg
echo. >> .\EnableThumbs.reg
echo [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer] >> .\EnableThumbs.reg
echo "DisableThumbnails"=- >> .\EnableThumbs.reg
echo. >> .\EnableThumbs.reg
reg import .\EnableThumbs.reg
REG ADD "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /V IconsOnly /T REG_DWORD /D 0 /F
echo Explorer Will Restart.
taskkill /f /im explorer.exe
start explorer.exe
pause
del .\EnableThumbs.reg
goto explorermenu


:AddQuick
reg add "HKLM\\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v HubMode /t REG_DWORD /d 0 /f
goto explorermenu
:RemoveQuick
reg add "HKLM\\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v HubMode /t REG_DWORD /d 1 /f
goto explorermenu

:ShowExten
echo Windows Registry Editor Version 5.00 > .\ShowExten.reg
echo. >> .\ShowExten.reg
echo [HKEY_CLASSES_ROOT\AllFilesystemObjects\shell\Windows.ShowFileExtensions] >> .\ShowExten.reg
echo "CommandStateSync"="" >> .\ShowExten.reg
echo "Description"="@shell32.dll,-37571" >> .\ShowExten.reg
echo "ExplorerCommandHandler"="{4ac6c205-2853-4bf5-b47c-919a42a48a16}" >> .\ShowExten.reg
echo "MUIVerb"="@shell32.dll,-37570" >> .\ShowExten.reg
echo. >> .\ShowExten.reg
echo. >> .\ShowExten.reg
echo [HKEY_CLASSES_ROOT\Directory\Background\shell\Windows.ShowFileExtensions] >> .\ShowExten.reg
echo "CommandStateSync"="" >> .\ShowExten.reg
echo "Description"="@shell32.dll,-37571" >> .\ShowExten.reg
echo "ExplorerCommandHandler"="{4ac6c205-2853-4bf5-b47c-919a42a48a16}" >> .\ShowExten.reg
echo "MUIVerb"="@shell32.dll,-37570" >> .\ShowExten.reg
echo. >> .\ShowExten.reg
echo. >> .\ShowExten.reg
reg import .\ShowExten.reg
pause
del .\ShowExten.reg
goto explorermenu


:HideExten
echo Windows Registry Editor Version 5.00 > .\HideExten.reg
echo. >> .\HideExten.reg
echo [-HKEY_CLASSES_ROOT\AllFilesystemObjects\shell\Windows.ShowFileExtensions] >> .\HideExten.reg
echo. >> .\HideExten.reg
echo [-HKEY_CLASSES_ROOT\Directory\Background\shell\Windows.ShowFileExtensions] >> .\HideExten.reg
echo. >> .\HideExten.reg
echo. >> .\HideExten.regHideExten.reg
reg import .\HideExten.reg
pause
del .\HideExten.reg
goto explorermenu

:AddDelFolder
echo Windows Registry Editor Version 5.00 > .\AddDelFolder.reg
echo. >> .\AddDelFolder.reg
echo [HKEY_CLASSES_ROOT\Directory\shell\Empty] >> .\AddDelFolder.reg
echo "Icon"="shell32.dll,-16715" >> .\AddDelFolder.reg
echo "MUIVerb"="Delete Folder Contents" >> .\AddDelFolder.reg
echo "Position"="bottom" >> .\AddDelFolder.reg
echo "Extended"=- >> .\AddDelFolder.reg
echo "SubCommands"="" >> .\AddDelFolder.reg
echo. >> .\AddDelFolder.reg
echo [HKEY_CLASSES_ROOT\Directory\shell\Empty\shell\001flyout] >> .\AddDelFolder.reg
echo "Icon"="shell32.dll,-16715" >> .\AddDelFolder.reg
echo "MUIVerb"="Delete Folder Contents and Subfolders" >> .\AddDelFolder.reg
echo. >> .\AddDelFolder.reg
echo [HKEY_CLASSES_ROOT\Directory\shell\Empty\shell\001flyout\command] >> .\AddDelFolder.reg
echo @="cmd /c title Empty \"%1\" & (cmd /c echo. & echo This will permanently delete everything in this folder. & echo. & choice /c:yn /m \"Are you sure?\") & (if errorlevel 2 exit) & (cmd /c rd /s /q \"%1\" & md \"%1\")" >> .\AddDelFolder.reg
echo. >> .\AddDelFolder.reg
echo [HKEY_CLASSES_ROOT\Directory\shell\Empty\shell\002flyout] >> .\AddDelFolder.reg
echo "Icon"="shell32.dll,-16715" >> .\AddDelFolder.reg
echo "MUIVerb"="Delete Folder Contents but Not Subfolders" >> .\AddDelFolder.reg
echo. >> .\AddDelFolder.reg
echo [HKEY_CLASSES_ROOT\Directory\shell\Empty\shell\002flyout\command] >> .\AddDelFolder.reg
echo @="cmd /c title Empty \"%1\" & (cmd /c echo. & echo This will permanently delete everything in this folder, but not subfolders. & echo. & choice /c:yn /m \"Are you sure?\") & (if errorlevel 2 exit) & (cmd /c \"cd /d %1 && del /f /q *.*\")" >> .\AddDelFolder.reg
echo.  >> .\AddDelFolder.reg
echo. >> .\AddDelFolder.reg
reg import .\AddDelFolder.reg
pause
del .\AddDelFolder.reg
goto explorermenu

:RemoveDelFolder
echo Windows Registry Editor Version 5.00 > .\RemoveDelFolder.reg
echo. >> .\RemoveDelFolder.reg
echo [-HKEY_CLASSES_ROOT\Directory\shell\Empty] >> .\RemoveDelFolder.reg
echo. >> .\RemoveDelFolder.reg
reg import .\RemoveDelFolder.reg
pause
del .\RemoveDelFolder.reg
goto explorermenu

:ResetFolderView
echo.
reg delete "HKCU\SOfTWARE\Microsoft\Windows\Shell\BagMRU" /f
reg delete "HKCU\SOfTWARE\Microsoft\Windows\Shell\Bags" /f
reg delete "HKCU\SOfTWARE\Microsoft\Windows\ShellNoRoam\Bags" /f
reg delete "HKCU\SOfTWARE\Microsoft\Windows\ShellNoRoam\BagMRU" /f
reg delete "HKCU\SOfTWARE\Classes\Local Settings\Software\Microsoft\Windows\Shell\BagMRU" /f
reg delete "HKCU\SOfTWARE\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags" /f
reg delete "HKCU\SOfTWARE\Classes\Wow6432Node\Local Settings\Software\Microsoft\Windows\Shell\Bags" /f
reg delete "HKCU\SOfTWARE\Classes\Wow6432Node\Local Settings\Software\Microsoft\Windows\Shell\BagMRU" /f
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Streams\Defaults" /f
reg delete "HKCU\SOfTWARE\Microsoft\Windows\CurrentVersion\Explorer\Modules\GlobalSettings\Sizer" /f
echo Explorer Will Restart
pause
taskkill /f /im explorer.exe
start explorer.exe
goto explorermenu

:RestoreDefaultShell
echo Windows Registry Editor Version 5.00 > .\RestoreDefaultShell.reg
echo. >> .\RestoreDefaultShell.reg
echo. >> .\RestoreDefaultShell.reg
echo [HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders] >> .\RestoreDefaultShell.reg
echo "{F42EE2D3-909F-4907-8871-4C22FC0BF756}"=- >> .\RestoreDefaultShell.reg
echo "{7D83EE9B-2244-4E70-B1F5-5393042AF1E4}"=- >> .\RestoreDefaultShell.reg
echo "{A0C69A99-21C8-4671-8703-7934162FCF1D}"=- >> .\RestoreDefaultShell.reg
echo "{0DDD015D-B06C-45D5-8C4C-F59713854639}"=- >> .\RestoreDefaultShell.reg
echo "{35286a68-3c57-41a1-bbb1-0eae73d76c95}"=- >> .\RestoreDefaultShell.reg
echo "{3B193882-D3AD-4EAB-965A-69829D1FB59F}"=- >> .\RestoreDefaultShell.reg
echo "{AB5FB87B-7CE2-4F83-915D-550846C9537B}"=- >> .\RestoreDefaultShell.reg
echo "{B7BEDE81-DF94-4682-A7D8-57A52620B86F}"=- >> .\RestoreDefaultShell.reg
echo. >> .\RestoreDefaultShell.reg
echo "My Music"=hex(2):25,00,55,00,53,00,45,00,52,00,50,00,52,00,4f,00,46,00,49,00,\ >> .\RestoreDefaultShell.reg
echo   4c,00,45,00,25,00,5c,00,4d,00,75,00,73,00,69,00,63,00,00,00 >> .\RestoreDefaultShell.reg
echo "My Pictures"=hex(2):25,00,55,00,53,00,45,00,52,00,50,00,52,00,4f,00,46,00,49,\ >> .\RestoreDefaultShell.reg
echo   00,4c,00,45,00,25,00,5c,00,50,00,69,00,63,00,74,00,75,00,72,00,65,00,73,00,\ >> .\RestoreDefaultShell.reg
echo   00,00 >> .\RestoreDefaultShell.reg
echo "My Video"=hex(2):25,00,55,00,53,00,45,00,52,00,50,00,52,00,4f,00,46,00,49,00,\ >> .\RestoreDefaultShell.reg
echo   4c,00,45,00,25,00,5c,00,56,00,69,00,64,00,65,00,6f,00,73,00,00,00 >> .\RestoreDefaultShell.reg
echo "Personal"=hex(2):25,00,55,00,53,00,45,00,52,00,50,00,52,00,4f,00,46,00,49,00,\ >> .\RestoreDefaultShell.reg
echo   4c,00,45,00,25,00,5c,00,44,00,6f,00,63,00,75,00,6d,00,65,00,6e,00,74,00,73,\ >> .\RestoreDefaultShell.reg
echo   00,00,00 >> .\RestoreDefaultShell.reg
echo "{374DE290-123F-4565-9164-39C4925E467B}"=hex(2):25,00,55,00,53,00,45,00,52,00,\ >> .\RestoreDefaultShell.reg
echo   50,00,52,00,4f,00,46,00,49,00,4c,00,45,00,25,00,5c,00,44,00,6f,00,77,00,6e,\ >> .\RestoreDefaultShell.reg
echo   00,6c,00,6f,00,61,00,64,00,73,00,00,00 >> .\RestoreDefaultShell.reg
echo "Desktop"=hex(2):25,00,55,00,53,00,45,00,52,00,50,00,52,00,4f,00,46,00,49,00,\ >> .\RestoreDefaultShell.reg
echo   4c,00,45,00,25,00,5c,00,44,00,65,00,73,00,6b,00,74,00,6f,00,70,00,00,00 >> .\RestoreDefaultShell.reg
echo. >> .\RestoreDefaultShell.reg
echo. >> .\RestoreDefaultShell.reg
echo [HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders] >> .\RestoreDefaultShell.reg
echo "AppData"=hex(2):25,00,55,00,53,00,45,00,52,00,50,00,52,00,4f,00,46,00,49,00,\ >> .\RestoreDefaultShell.reg
echo   4c,00,45,00,25,00,5c,00,41,00,70,00,70,00,44,00,61,00,74,00,61,00,5c,00,52,\ >> .\RestoreDefaultShell.reg
echo   00,6f,00,61,00,6d,00,69,00,6e,00,67,00,00,00 >> .\RestoreDefaultShell.reg
echo "Cache"=hex(2):25,00,55,00,53,00,45,00,52,00,50,00,52,00,4f,00,46,00,49,00,4c,\ >> .\RestoreDefaultShell.reg
echo   00,45,00,25,00,5c,00,41,00,70,00,70,00,44,00,61,00,74,00,61,00,5c,00,4c,00,\ >> .\RestoreDefaultShell.reg
echo   6f,00,63,00,61,00,6c,00,5c,00,4d,00,69,00,63,00,72,00,6f,00,73,00,6f,00,66,\ >> .\RestoreDefaultShell.reg
echo   00,74,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,5c,00,49,00,4e,00,\ >> .\RestoreDefaultShell.reg
echo   65,00,74,00,43,00,61,00,63,00,68,00,65,00,00,00 >> .\RestoreDefaultShell.reg
echo "Cookies"=hex(2):25,00,55,00,53,00,45,00,52,00,50,00,52,00,4f,00,46,00,49,00,\ >> .\RestoreDefaultShell.reg
echo   4c,00,45,00,25,00,5c,00,41,00,70,00,70,00,44,00,61,00,74,00,61,00,5c,00,4c,\ >> .\RestoreDefaultShell.reg
echo   00,6f,00,63,00,61,00,6c,00,5c,00,4d,00,69,00,63,00,72,00,6f,00,73,00,6f,00,\ >> .\RestoreDefaultShell.reg
echo   66,00,74,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,5c,00,49,00,4e,\ >> .\RestoreDefaultShell.reg
echo   00,65,00,74,00,43,00,6f,00,6f,00,6b,00,69,00,65,00,73,00,00,00 >> .\RestoreDefaultShell.reg
echo "Desktop"=hex(2):25,00,55,00,53,00,45,00,52,00,50,00,52,00,4f,00,46,00,49,00,\ >> .\RestoreDefaultShell.reg
echo   4c,00,45,00,25,00,5c,00,44,00,65,00,73,00,6b,00,74,00,6f,00,70,00,00,00 >> .\RestoreDefaultShell.reg
echo "Favorites"=hex(2):25,00,55,00,53,00,45,00,52,00,50,00,52,00,4f,00,46,00,49,00,\ >> .\RestoreDefaultShell.reg
echo   4c,00,45,00,25,00,5c,00,46,00,61,00,76,00,6f,00,72,00,69,00,74,00,65,00,73,\ >> .\RestoreDefaultShell.reg
echo   00,00,00 >> .\RestoreDefaultShell.reg
echo "History"=hex(2):25,00,55,00,53,00,45,00,52,00,50,00,52,00,4f,00,46,00,49,00,\ >> .\RestoreDefaultShell.reg
echo   4c,00,45,00,25,00,5c,00,41,00,70,00,70,00,44,00,61,00,74,00,61,00,5c,00,4c,\ >> .\RestoreDefaultShell.reg
echo   00,6f,00,63,00,61,00,6c,00,5c,00,4d,00,69,00,63,00,72,00,6f,00,73,00,6f,00,\ >> .\RestoreDefaultShell.reg
echo   66,00,74,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,5c,00,48,00,69,\ >> .\RestoreDefaultShell.reg
echo   00,73,00,74,00,6f,00,72,00,79,00,00,00 >> .\RestoreDefaultShell.reg
echo "Local AppData"=hex(2):25,00,55,00,53,00,45,00,52,00,50,00,52,00,4f,00,46,00,\ >> .\RestoreDefaultShell.reg
echo   49,00,4c,00,45,00,25,00,5c,00,41,00,70,00,70,00,44,00,61,00,74,00,61,00,5c,\ >> .\RestoreDefaultShell.reg
echo   00,4c,00,6f,00,63,00,61,00,6c,00,00,00 >> .\RestoreDefaultShell.reg
echo "My Music"=hex(2):25,00,55,00,53,00,45,00,52,00,50,00,52,00,4f,00,46,00,49,00,\ >> .\RestoreDefaultShell.reg
echo   4c,00,45,00,25,00,5c,00,4d,00,75,00,73,00,69,00,63,00,00,00 >> .\RestoreDefaultShell.reg
echo "My Pictures"=hex(2):25,00,55,00,53,00,45,00,52,00,50,00,52,00,4f,00,46,00,49,\ >> .\RestoreDefaultShell.reg
echo   00,4c,00,45,00,25,00,5c,00,50,00,69,00,63,00,74,00,75,00,72,00,65,00,73,00,\ >> .\RestoreDefaultShell.reg
echo   00,00 >> .\RestoreDefaultShell.reg
echo "My Video"=hex(2):25,00,55,00,53,00,45,00,52,00,50,00,52,00,4f,00,46,00,49,00,\ >> .\RestoreDefaultShell.reg
echo   4c,00,45,00,25,00,5c,00,56,00,69,00,64,00,65,00,6f,00,73,00,00,00 >> .\RestoreDefaultShell.reg
echo "NetHood"=hex(2):25,00,55,00,53,00,45,00,52,00,50,00,52,00,4f,00,46,00,49,00,\ >> .\RestoreDefaultShell.reg
echo   4c,00,45,00,25,00,5c,00,41,00,70,00,70,00,44,00,61,00,74,00,61,00,5c,00,52,\ >> .\RestoreDefaultShell.reg
echo   00,6f,00,61,00,6d,00,69,00,6e,00,67,00,5c,00,4d,00,69,00,63,00,72,00,6f,00,\ >> .\RestoreDefaultShell.reg
echo   73,00,6f,00,66,00,74,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,5c,\ >> .\RestoreDefaultShell.reg
echo   00,4e,00,65,00,74,00,77,00,6f,00,72,00,6b,00,20,00,53,00,68,00,6f,00,72,00,\ >> .\RestoreDefaultShell.reg
echo   74,00,63,00,75,00,74,00,73,00,00,00 >> .\RestoreDefaultShell.reg
echo "Personal"=hex(2):25,00,55,00,53,00,45,00,52,00,50,00,52,00,4f,00,46,00,49,00,\ >> .\RestoreDefaultShell.reg
echo   4c,00,45,00,25,00,5c,00,44,00,6f,00,63,00,75,00,6d,00,65,00,6e,00,74,00,73,\ >> .\RestoreDefaultShell.reg
echo   00,00,00 >> .\RestoreDefaultShell.reg
echo "PrintHood"=hex(2):25,00,55,00,53,00,45,00,52,00,50,00,52,00,4f,00,46,00,49,00,\ >> .\RestoreDefaultShell.reg
echo   4c,00,45,00,25,00,5c,00,41,00,70,00,70,00,44,00,61,00,74,00,61,00,5c,00,52,\ >> .\RestoreDefaultShell.reg
echo   00,6f,00,61,00,6d,00,69,00,6e,00,67,00,5c,00,4d,00,69,00,63,00,72,00,6f,00,\ >> .\RestoreDefaultShell.reg
echo   73,00,6f,00,66,00,74,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,5c,\ >> .\RestoreDefaultShell.reg
echo   00,50,00,72,00,69,00,6e,00,74,00,65,00,72,00,20,00,53,00,68,00,6f,00,72,00,\ >> .\RestoreDefaultShell.reg
echo   74,00,63,00,75,00,74,00,73,00,00,00 >> .\RestoreDefaultShell.reg
echo "Programs"=hex(2):25,00,55,00,53,00,45,00,52,00,50,00,52,00,4f,00,46,00,49,00,\ >> .\RestoreDefaultShell.reg
echo   4c,00,45,00,25,00,5c,00,41,00,70,00,70,00,44,00,61,00,74,00,61,00,5c,00,52,\ >> .\RestoreDefaultShell.reg
echo   00,6f,00,61,00,6d,00,69,00,6e,00,67,00,5c,00,4d,00,69,00,63,00,72,00,6f,00,\ >> .\RestoreDefaultShell.reg
echo   73,00,6f,00,66,00,74,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,5c,\ >> .\RestoreDefaultShell.reg
echo   00,53,00,74,00,61,00,72,00,74,00,20,00,4d,00,65,00,6e,00,75,00,5c,00,50,00,\ >> .\RestoreDefaultShell.reg
echo   72,00,6f,00,67,00,72,00,61,00,6d,00,73,00,00,00 >> .\RestoreDefaultShell.reg
echo "Recent"=hex(2):25,00,55,00,53,00,45,00,52,00,50,00,52,00,4f,00,46,00,49,00,4c,\ >> .\RestoreDefaultShell.reg
echo   00,45,00,25,00,5c,00,41,00,70,00,70,00,44,00,61,00,74,00,61,00,5c,00,52,00,\ >> .\RestoreDefaultShell.reg
echo   6f,00,61,00,6d,00,69,00,6e,00,67,00,5c,00,4d,00,69,00,63,00,72,00,6f,00,73,\ >> .\RestoreDefaultShell.reg
echo   00,6f,00,66,00,74,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,5c,00,\ >> .\RestoreDefaultShell.reg
echo   52,00,65,00,63,00,65,00,6e,00,74,00,00,00 >> .\RestoreDefaultShell.reg
echo "SendTo"=hex(2):25,00,55,00,53,00,45,00,52,00,50,00,52,00,4f,00,46,00,49,00,4c,\ >> .\RestoreDefaultShell.reg
echo   00,45,00,25,00,5c,00,41,00,70,00,70,00,44,00,61,00,74,00,61,00,5c,00,52,00,\ >> .\RestoreDefaultShell.reg
echo   6f,00,61,00,6d,00,69,00,6e,00,67,00,5c,00,4d,00,69,00,63,00,72,00,6f,00,73,\ >> .\RestoreDefaultShell.reg
echo   00,6f,00,66,00,74,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,5c,00,\ >> .\RestoreDefaultShell.reg
echo   53,00,65,00,6e,00,64,00,54,00,6f,00,00,00 >> .\RestoreDefaultShell.reg
echo "Start Menu"=hex(2):25,00,55,00,53,00,45,00,52,00,50,00,52,00,4f,00,46,00,49,\ >> .\RestoreDefaultShell.reg
echo   00,4c,00,45,00,25,00,5c,00,41,00,70,00,70,00,44,00,61,00,74,00,61,00,5c,00,\ >> .\RestoreDefaultShell.reg
echo   52,00,6f,00,61,00,6d,00,69,00,6e,00,67,00,5c,00,4d,00,69,00,63,00,72,00,6f,\ >> .\RestoreDefaultShell.reg
echo   00,73,00,6f,00,66,00,74,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,\ >> .\RestoreDefaultShell.reg
echo   5c,00,53,00,74,00,61,00,72,00,74,00,20,00,4d,00,65,00,6e,00,75,00,00,00 >> .\RestoreDefaultShell.reg
echo "Startup"=hex(2):25,00,55,00,53,00,45,00,52,00,50,00,52,00,4f,00,46,00,49,00,\ >> .\RestoreDefaultShell.reg
echo   4c,00,45,00,25,00,5c,00,41,00,70,00,70,00,44,00,61,00,74,00,61,00,5c,00,52,\ >> .\RestoreDefaultShell.reg
echo   00,6f,00,61,00,6d,00,69,00,6e,00,67,00,5c,00,4d,00,69,00,63,00,72,00,6f,00,\ >> .\RestoreDefaultShell.reg
echo   73,00,6f,00,66,00,74,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,5c,\ >> .\RestoreDefaultShell.reg
echo   00,53,00,74,00,61,00,72,00,74,00,20,00,4d,00,65,00,6e,00,75,00,5c,00,50,00,\ >> .\RestoreDefaultShell.reg
echo   72,00,6f,00,67,00,72,00,61,00,6d,00,73,00,5c,00,53,00,74,00,61,00,72,00,74,\ >> .\RestoreDefaultShell.reg
echo   00,75,00,70,00,00,00 >> .\RestoreDefaultShell.reg
echo "Templates"=hex(2):25,00,55,00,53,00,45,00,52,00,50,00,52,00,4f,00,46,00,49,00,\ >> .\RestoreDefaultShell.reg
echo   4c,00,45,00,25,00,5c,00,41,00,70,00,70,00,44,00,61,00,74,00,61,00,5c,00,52,\ >> .\RestoreDefaultShell.reg
echo   00,6f,00,61,00,6d,00,69,00,6e,00,67,00,5c,00,4d,00,69,00,63,00,72,00,6f,00,\ >> .\RestoreDefaultShell.reg
echo   73,00,6f,00,66,00,74,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,5c,\ >> .\RestoreDefaultShell.reg
echo   00,54,00,65,00,6d,00,70,00,6c,00,61,00,74,00,65,00,73,00,00,00 >> .\RestoreDefaultShell.reg
echo "{374DE290-123F-4565-9164-39C4925E467B}"=hex(2):25,00,55,00,53,00,45,00,52,00,\ >> .\RestoreDefaultShell.reg
echo   50,00,52,00,4f,00,46,00,49,00,4c,00,45,00,25,00,5c,00,44,00,6f,00,77,00,6e,\ >> .\RestoreDefaultShell.reg
echo   00,6c,00,6f,00,61,00,64,00,73,00,00,00 >> .\RestoreDefaultShell.reg
echo. >> .\RestoreDefaultShell.reg
echo [HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders] >> .\RestoreDefaultShell.reg
echo "{F42EE2D3-909F-4907-8871-4C22FC0BF756}"=- >> .\RestoreDefaultShell.reg
echo "{7D83EE9B-2244-4E70-B1F5-5393042AF1E4}"=- >> .\RestoreDefaultShell.reg
echo "{A0C69A99-21C8-4671-8703-7934162FCF1D}"=- >> .\RestoreDefaultShell.reg
echo "{0DDD015D-B06C-45D5-8C4C-F59713854639}"=- >> .\RestoreDefaultShell.reg
echo "{35286a68-3c57-41a1-bbb1-0eae73d76c95}"=- >> .\RestoreDefaultShell.reg
echo "{3B193882-D3AD-4EAB-965A-69829D1FB59F}"=- >> .\RestoreDefaultShell.reg
echo "{AB5FB87B-7CE2-4F83-915D-550846C9537B}"=- >> .\RestoreDefaultShell.reg
echo "{B7BEDE81-DF94-4682-A7D8-57A52620B86F}"=- >> .\RestoreDefaultShell.reg
echo. >> .\RestoreDefaultShell.reg
echo. >> .\RestoreDefaultShell.reg
echo [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders] >> .\RestoreDefaultShell.reg
echo "Common AppData"=hex(2):25,00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,00,44,00,\ >> .\RestoreDefaultShell.reg
echo   61,00,74,00,61,00,25,00,00,00 >> .\RestoreDefaultShell.reg
echo "Common Desktop"=hex(2):25,00,50,00,55,00,42,00,4c,00,49,00,43,00,25,00,5c,00,\ >> .\RestoreDefaultShell.reg
echo   44,00,65,00,73,00,6b,00,74,00,6f,00,70,00,00,00 >> .\RestoreDefaultShell.reg
echo "Common Documents"=hex(2):25,00,50,00,55,00,42,00,4c,00,49,00,43,00,25,00,5c,\ >> .\RestoreDefaultShell.reg
echo   00,44,00,6f,00,63,00,75,00,6d,00,65,00,6e,00,74,00,73,00,00,00 >> .\RestoreDefaultShell.reg
echo "Common Programs"=hex(2):25,00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,00,44,00,\ >> .\RestoreDefaultShell.reg
echo   61,00,74,00,61,00,25,00,5c,00,4d,00,69,00,63,00,72,00,6f,00,73,00,6f,00,66,\ >> .\RestoreDefaultShell.reg
echo   00,74,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,5c,00,53,00,74,00,\ >> .\RestoreDefaultShell.reg
echo   61,00,72,00,74,00,20,00,4d,00,65,00,6e,00,75,00,5c,00,50,00,72,00,6f,00,67,\ >> .\RestoreDefaultShell.reg
echo   00,72,00,61,00,6d,00,73,00,00,00 >> .\RestoreDefaultShell.reg
echo "Common Start Menu"=hex(2):25,00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,00,44,\ >> .\RestoreDefaultShell.reg
echo   00,61,00,74,00,61,00,25,00,5c,00,4d,00,69,00,63,00,72,00,6f,00,73,00,6f,00,\ >> .\RestoreDefaultShell.reg
echo   66,00,74,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,5c,00,53,00,74,\ >> .\RestoreDefaultShell.reg
echo   00,61,00,72,00,74,00,20,00,4d,00,65,00,6e,00,75,00,00,00 >> .\RestoreDefaultShell.reg
echo "Common Startup"=hex(2):25,00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,00,44,00,\ >> .\RestoreDefaultShell.reg
echo   61,00,74,00,61,00,25,00,5c,00,4d,00,69,00,63,00,72,00,6f,00,73,00,6f,00,66,\ >> .\RestoreDefaultShell.reg
echo   00,74,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,5c,00,53,00,74,00,\ >> .\RestoreDefaultShell.reg
echo   61,00,72,00,74,00,20,00,4d,00,65,00,6e,00,75,00,5c,00,50,00,72,00,6f,00,67,\ >> .\RestoreDefaultShell.reg
echo   00,72,00,61,00,6d,00,73,00,5c,00,53,00,74,00,61,00,72,00,74,00,75,00,70,00,\ >> .\RestoreDefaultShell.reg
echo   00,00 >> .\RestoreDefaultShell.reg
echo "Common Templates"=hex(2):25,00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,00,44,\ >> .\RestoreDefaultShell.reg
echo   00,61,00,74,00,61,00,25,00,5c,00,4d,00,69,00,63,00,72,00,6f,00,73,00,6f,00,\ >> .\RestoreDefaultShell.reg
echo   66,00,74,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,5c,00,54,00,65,\ >> .\RestoreDefaultShell.reg
echo   00,6d,00,70,00,6c,00,61,00,74,00,65,00,73,00,00,00 >> .\RestoreDefaultShell.reg
echo "CommonMusic"=hex(2):25,00,50,00,55,00,42,00,4c,00,49,00,43,00,25,00,5c,00,4d,\ >> .\RestoreDefaultShell.reg
echo   00,75,00,73,00,69,00,63,00,00,00 >> .\RestoreDefaultShell.reg
echo "CommonPictures"=hex(2):25,00,50,00,55,00,42,00,4c,00,49,00,43,00,25,00,5c,00,\ >> .\RestoreDefaultShell.reg
echo   50,00,69,00,63,00,74,00,75,00,72,00,65,00,73,00,00,00 >> .\RestoreDefaultShell.reg
echo "CommonVideo"=hex(2):25,00,50,00,55,00,42,00,4c,00,49,00,43,00,25,00,5c,00,56,\ >> .\RestoreDefaultShell.reg
echo   00,69,00,64,00,65,00,6f,00,73,00,00,00 >> .\RestoreDefaultShell.reg
echo "{3D644C9B-1FB8-4f30-9B45-F670235F79C0}"=hex(2):25,00,50,00,55,00,42,00,4c,00,\ >> .\RestoreDefaultShell.reg
echo   49,00,43,00,25,00,5c,00,44,00,6f,00,77,00,6e,00,6c,00,6f,00,61,00,64,00,73,\ >> .\RestoreDefaultShell.reg
echo   00,00,00 >> .\RestoreDefaultShell.reg
echo. >> .\RestoreDefaultShell.reg
echo. >> .\RestoreDefaultShell.reg
reg import .\RestoreDefaultShell.reg
pause
del .\RestoreDefaultShell.reg
goto explorermenu


:winsecuritymenu
mode con:cols=80 lines=22
echo.
echo Here we can control parts of Windows Defender and Security.
echo.
echo.
echo 1) Enable Windows Defender
echo 2) Disable Windows Defender
echo 3) Enable "Find My Device"
echo 4) Disable "Find My Device"
echo 5) Enable Real-Time Protection
echo 6) Disable Real-Time Protection
echo 7) Enable "Possibly Unwanted Program Protection"
echo 8) Disable "Possibly Unwanted Program Protection"
echo 9) Show Firewall and Network Protection
echo 10) Hide Firewall and Network Protection
echo 11) Enable Network Scanning
echo 12) Disable Network Scanning
echo 13) Show "Device Performance and Health" in Security Center
echo 14) Hide  "Device Performance and Health" in Security Center
echo 15) Back
echo 16) Exit
echo.
echo.
set /p web=Type option:
if "%web%"=="1" call :EnableDefender
if "%web%"=="2" call :DisableDefender
if "%web%"=="3" call :EnableFindMe
if "%web%"=="4" call :DisableFindMe
if "%web%"=="5" reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v DisableRealtimeMonitoring /t REG_DWORD /d 0 /f && pause
if "%web%"=="6" reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v DisableRealtimeMonitoring /t REG_DWORD /d 1 /f && pause
if "%web%"=="7" call :EnablePUPP
if "%web%"=="8" call :DisablePUPP
if "%web%"=="9" reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Firewall and network protection" /v UILockdown /t REG_DWORD /d 0 /f && pause
if "%web%"=="10" reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Firewall and network protection" /v UILockdown /t REG_DWORD /d 1 /f && pause
if "%web%"=="11" reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Policy Manager" /v DisableScanningNetworkFiles /t REG_DWORD /d 0 /f && pause
if "%web%"=="12 reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Policy Manager" /v DisableScanningNetworkFiles /t REG_DWORD /d 1 /f && pause
if "%web%"=="13" reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Device performance and health" /v UILockdown /t REG_DWORD /d 0 /f && pause
if "%web%"=="14" call reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Device performance and health" /v UILockdown /t REG_DWORD /d 1 /f && pause
if "%web%"=="15" goto settweakmenu
if "%web%"=="16" exit
goto winsecuritymenu



:EnableDefender
echo Windows Registry Editor Version 5.00 > .\EnableDefender.reg
echo. >> .\EnableDefender.reg
echo [HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Run] >> .\EnableDefender.reg
echo "Windows Defender"="\"C:\\Program Files\\Windows Defender\\MSASCui.exe\" -hide" >> .\EnableDefender.reg
echo. >> .\EnableDefender.reg
echo [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run] >> .\EnableDefender.reg
echo "WindowsDefender"=hex:06,00,00,00,00,00,00,00,00,00,00,00 >> .\EnableDefender.reg
echo. >> .\EnableDefender.reg
echo [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run] >> .\EnableDefender.reg
echo "WindowsDefender"=hex(2):22,00,25,00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,00,\ >> .\EnableDefender.reg
echo   46,00,69,00,6c,00,65,00,73,00,25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,\ >> .\EnableDefender.reg
echo   00,73,00,20,00,44,00,65,00,66,00,65,00,6e,00,64,00,65,00,72,00,5c,00,4d,00,\ >> .\EnableDefender.reg
echo   53,00,41,00,53,00,43,00,75,00,69,00,4c,00,2e,00,65,00,78,00,65,00,22,00,00,\ >> .\EnableDefender.reg
echo   00 >> .\EnableDefender.reg
echo. >> .\EnableDefender.reg
echo [HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender] >> .\EnableDefender.reg
echo "DisableAntiSpyware"=- >> .\EnableDefender.reg
echo. >> .\EnableDefender.reg
echo. >> .\EnableDefender.reg
reg import .\EnableDefender.reg
pause
del .\EnableDefender.reg
goto winsecuritymenu


:DisableDefender
echo Windows Registry Editor Version 5.00 > .\DisableDefender.reg
echo. >> .\DisableDefender.reg
echo [HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Run] >> .\DisableDefender.reg
echo "Windows Defender"=- >> .\DisableDefender.reg
echo. >> .\DisableDefender.reg
echo [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run] >> .\DisableDefender.reg
echo "Windows Defender"=- >> .\DisableDefender.reg
echo. >> .\DisableDefender.reg
echo [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run] >> .\DisableDefender.reg
echo "WindowsDefender"=- >> .\DisableDefender.reg
echo. >> .\DisableDefender.reg
echo [HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender] >> .\DisableDefender.reg
echo "DisableAntiSpyware"=dword:00000001 >> .\DisableDefender.reg
echo. >> .\DisableDefender.reg
echo. >> .\DisableDefender.reg
reg import .\DisableDefender.reg
pause
del .\DisableDefender.reg
goto winsecuritymenu


:EnableFindMe
echo Windows Registry Editor Version 5.00 > .\EnableFindMe.reg
echo. >> .\EnableFindMe.reg
echo [HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\FindMyDevice] >> .\EnableFindMe.reg
echo "AllowFindMyDevice"=dword:00000001 >> .\EnableFindMe.reg
echo. >> .\EnableFindMe.reg
echo [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Settings\FindMyDevice] >> .\EnableFindMe.reg
echo "LocationSyncEnabled"=dword:00000001 >> .\EnableFindMe.reg
echo. >> .\EnableFindMe.reg
reg import .\EnableFindMe.reg
pause
del .\EnableFindMe.reg
goto winsecuritymenu



:DisableFindMe
echo Windows Registry Editor Version 5.00 > .\DisableFindMe.reg
echo. >> .\DisableFindMe.reg
echo [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Settings\FindMyDevice] >> .\DisableFindMe.reg
echo "LocationSyncEnabled"=dword:00000000 >> .\DisableFindMe.reg
echo. >> .\DisableFindMe.reg
echo [HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\FindMyDevice] >> .\DisableFindMe.reg
echo "AllowFindMyDevice"=dword:00000000 >> .\DisableFindMe.reg
echo. >> .\DisableFindMe.reg
reg import .\DisableFindMe.reg
pause
del .\DisableFindMe.reg
goto winsecuritymenu






:EnablePUPP
echo Windows Registry Editor Version 5.00 > .\EnablePUPP.reg
echo. >> .\EnablePUPP.reg
echo [HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender] >> .\EnablePUPP.reg
echo "PUAProtection"=dword:00000001 >> .\EnablePUPP.reg
echo. >> .\EnablePUPP.reg
echo [HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender\MpEngine] >> .\EnablePUPP.reg
echo "MpEnablePus"=dword:00000001 >> .\EnablePUPP.reg
echo. >> .\EnablePUPP.reg
reg import .\EnablePUPP.reg
pause
del .\EnablePUPP.reg
goto winsecuritymenu



:DisablePUPP
echo Windows Registry Editor Version 5.00 > .\DisablePUPP.reg
echo. >> .\DisablePUPP.reg
echo [HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender] >> .\DisablePUPP.reg
echo "PUAProtection"=dword:00000000 >> .\DisablePUPP.reg
echo. >> .\DisablePUPP.reg
echo [HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender\MpEngine] >> .\DisablePUPP.reg
echo "MpEnablePus"=dword:00000000 >> .\DisablePUPP.reg
echo. >> .\DisablePUPP.reg
reg import .\DisablePUPP.reg
pause
del .\DisablePUPP.reg
goto winsecuritymenu










