
 @echo off
 CLS
 ECHO.
 ECHO =============================
 ECHO Running Admin shell
 ECHO =============================

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
  ECHO **************************************
  ECHO Invoking UAC for Privilege Escalation
  ECHO **************************************

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

mkdir C:\SetupLogs
echo "making sure SetupComplete runs" > C:\SetupLogs\SetupComp1.txt
echo Disable Hibernation > C:\SetupLogs\HiberOff.txt
powercfg -h off

echo Disable Error Reporting Service > C:\SetupLogs\DisErrorRep.txt
reg add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v Disabled /t REG_DWORD /d 1 /f
sc stop WerSvc
sc.exe config WerSvc start=disabled

echo Disable Memory Dump Creation > C:\SetupLogs\MemDump.txt
reg add "HKLM\SYSTEM\CurrentControlSet\Control\CrashControl" /v CrashDumpEnabled /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\CrashControl" /v LogEvent /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\CrashControl" /v SendAlert /t REG_DWORD /d 0 /f

echo Disable Telemetry Tasks (taken from parts of Tron scripts - https://github.com/bmrf/tron ) > C:\SetupLogs\TelemTron.txt
schtasks /delete /F /TN "\Microsoft\Windows\Autochk\Proxy"
schtasks /delete /F /TN "\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask"
schtasks /delete /F /TN "\Microsoft\Windows\Windows Error Reporting\QueueReporting"
schtasks /delete /f /tn "\Microsoft\Windows\application experience\aitagent"
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata" /v PreventDeviceMetadataFromNetwork /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\MRT" /v DontOfferThroughWUAU /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\SQMClient\Windows" /v "CEIPEnable" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "AITEnable" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "DisableUAR" /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\AutoLogger-Diagtrack-Listener" /v "Start" /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\SQMLogger" /v "Start" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /f /v "AllowTelemetry" /t REG_DWORD /d 0 >NUL 2>&1
reg add "HKLM\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\DataCollection" /f /v "AllowTelemetry" /t REG_DWORD /d 0 >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DiagTrack" /f /v "Start" /t REG_DWORD /d 4 >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\dmwappushservice" /f /v "Start" /t REG_DWORD /d 4 >NUL 2>&1

echo Stopping any *unneeded* services remaining > C:\SetupLogs\UnneedSvc.txt
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
sc.exe config SharedRealitySvc start=disabled
sc.exe stop VSS
sc.exe config VSS start=disabled
sc.exe stop Wecsvc
sc.exe config Wecsvc start=disabled
sc.exe stop spectrum
sc.exe config spectrum start=disabled
sc.exe stop XtaCache
reg add "HKLM\SYSTEM\CurrentControlSet\Services\XtaCache" /v start /t REG_DWORD /d 4 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v Disabled /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DoSvc" /v Start /t REG_DWORD /d 4 /f

echo Update Removal > C:\SetupLogs\UpdRem.txt
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

echo Disable Cortana Reg > C:\SetupLogs\CortOff.txt
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v AllowCortana /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v BingSearchEnabled /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v  AllowSearchToUseLocation /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v  CortanaConsent  /t REG_DWORD /d 0 /f

echo Spotlight Disable Reg > C:\SetupLogs\SpotOff.txt
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v ContentDeliveryAllowed /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v RotatingLockScreenEnabled /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v RotatingLockScreenOverlayEnabled /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Policies\Microsoft\Windows\CloudContent" /v DisableWindowsSpotlightFeatures /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Personalization" /v NoChangingLockScreen /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338388Enabled /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338389Enabled /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-353696Enabled /t REG_DWORD /d 0 /f
reg load HKLM\defuser %USERPROFILES%\default\ntuser.dat >NUL 2>&1
reg add "HKLM\defuser\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v RotatingLockScreenOverlayEnabled /t REG_DWORD /d 0 /f >NUL 2>&1
reg unload HKLM\defuser >NUL 2>&1

echo Telemetry and Privacy Reg > C:\SetupLogs\TelemReg.txt
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
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\AutoLogger-Diagtrack-Listener" /v Start /t REG_DWORD /d 0 /f
reg add "HKLM\Software\Microsoft\wcmsvc\wifinetworkmanager" /v wifisensecredshared /t REG_DWORD /d 0 /f
reg add "HKLM\Software\Microsoft\wcmsvc\wifinetworkmanager" /v wifisenseopen /t REG_DWORD /d 0 /f
reg add "HKLM\Software\Microsoft\Windows Defender\spynet" /v spynetreporting /t REG_DWORD /d 0 /f
reg add "HKLM\Software\Microsoft\Windows Defender\spynet" /v submitsamplesconsent /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v SubmitSamplesConcent /t REG_DWORD /d 2 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v SpynetReporting /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" /v EnableWebContentEvaluation /t REG_DWORD /d 0 /f 
echo Windows Registry Editor Version 5.00 > C:\SetupLogs\NoInkLearn.reg
echo. >> C:\SetupLogs\NoInkLearn.reg
echo [HKEY_CURRENT_USER\Software\Microsoft\InputPersonalization] >> C:\SetupLogs\NoInkLearn.reg
echo "RestrictImplicitInkCollection"=dword:00000001 >> C:\SetupLogs\NoInkLearn.reg
echo "RestrictImplicitTextCollection"=dword:00000001 >> C:\SetupLogs\NoInkLearn.reg
echo. >> C:\SetupLogs\NoInkLearn.reg
echo [HKEY_CURRENT_USER\Software\Microsoft\InputPersonalization\TrainedDataStore] >> C:\SetupLogs\NoInkLearn.reg
echo "HarvestContacts"=dword:00000000 >> C:\SetupLogs\NoInkLearn.reg
echo. >> C:\SetupLogs\NoInkLearn.reg
echo [HKEY_CURRENT_USER\Software\Microsoft\Personalization\Settings] >> C:\SetupLogs\NoInkLearn.reg
echo "AcceptedPrivacyPolicy"=dword:00000000 >> C:\SetupLogs\NoInkLearn.reg
echo. >> C:\SetupLogs\NoInkLearn.reg
reg import C:\SetupLogs\NoInkLearn.reg
reg add "HKCU\Software\Policies\Microsoft\Windows\EdgeUI" /v DisableMFUTracking /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v Enabled /t REG_DWORD /d 0 /f
echo Silent App Install Reg > C:\SetupLogs\SilentApp.txt
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SilentInstalledAppsEnabled /t REG_DWORD /d 0 /f
reg add "HKLM\System\CurrentControlSet\Control\Power" /v HibernateEnabled /t REG_DWORD /d 0 /f
powercfg /hibernate off

echo add kill task context > C:\SetupLogs\Killtask.txt
echo Windows Registry Editor Version 5.00 > C:\SetupLogs\Killtask.reg
echo. >> C:\SetupLogs\Killtask.reg
echo [HKEY_CLASSES_ROOT\DesktopBackground\Shell\KillNRTasks] >> C:\SetupLogs\Killtask.reg
echo "icon"="taskmgr.exe,-30651" >> C:\SetupLogs\Killtask.reg
echo "MUIverb"="Kill Any Not Responding Tasks" >> C:\SetupLogs\Killtask.reg
echo "Position"="Top" >> C:\SetupLogs\Killtask.reg
echo. >> .C:\SetupLogs\Killtask.reg
echo [HKEY_CLASSES_ROOT\DesktopBackground\Shell\KillNRTasks\command] >> C:\SetupLogs\Killtask.reg
echo @="CMD.exe /C taskkill.exe /f /fi \"status eq Not Responding\" & Pause" >> C:\SetupLogs\Killtask.reg
echo. >> C:\SetupLogs\Killtask.reg
reg import C:\SetupLogs\Killtask.reg
mkdir %userprofile%\Desktop\GodMode.{ED7BA470-8E54-465E-825C-99712043E01C}
echo In theory its done > C:\SetupLogs\Complete.txt
exit