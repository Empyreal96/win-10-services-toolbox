 @echo off
 CLS
 ECHO.
 ECHO.
echo I made this script using various bits of info I found using
echo the Microsoft site and a few forum board solutions. I have tested
echo this with Windows 10 Home ARM64 and Windows 10 Pro x64 and use it frequently, 
echo and will continue to improve this script.
echo Any issues contact @Empyreal96 on xda-developers.com
echo.
echo This script will let you control Windows Update services and
echo run the Routine Service Disable (Services disabled in the script on boot)
echo This message will appear once more after gaining Admin permissions.
echo This script is taken from my Win 10 ARM64 Optimised build at xda-developers
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
title Windows Update Services Tool
:home
mode con:cols=80 lines=20
cls
echo.
echo Do you want to start or stop Windows Update services?
echo this includes "wuauserv" "BITS" and "DoSvc"
echo Option 4 is a list of Services safe to disable (From my tests)
echo =============
echo.
echo 1) Start
echo 2) Stop
echo 3) Run Routine Service Disable (Services safe to disable)
echo 4) Exit
echo.
echo.
set /p web=Type option:
if "%web%"=="1" goto startwu
if "%web%"=="2" goto stopwu
if "%web%"=="3" goto routine
if "%web%"=="4" exit
goto home
:startwu
mode con:cols=80 lines=18
sc.exe config wuauserv start=auto
sc.exe start wuauserv
sc.exe config BITS start=auto
sc.exe start BITS
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DoSvc" /v Start /t REG_DWORD /d 2 /f
sc.exe config DoSvc start=auto
sc.exe start DoSvc
Pause
goto home
:stopwu
mode con:cols=80 lines=18
sc.exe stop wuauserv
sc.exe config wuauserv start=disabled
sc.exe stop BITS
sc.exe config BITS start=disabled
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DoSvc" /v Start /t REG_DWORD /d 4 /f
sc.exe stop DoSvc
sc.exe config DoSvc start=disabled
Pause
goto home

:routine
mode con:cols=80 lines=18
reg add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v Disabled /t REG_DWORD /d 1 /f
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
sc.exe config SharedRealitySvc start=disabled
sc.exe stop VSS
sc.exe config VSS start=disabled
sc.exe stop Wecsvc
sc.exe config Wecsvc start=disabled
sc.exe stop spectrum
sc.exe config spectrum start=disabled
sc.exe stop XtaCache
reg add "HKLM\SYSTEM\CurrentControlSet\Services\XtaCache" /v Start /t REG_DWORD /d 4 /f
pause
goto home


:exit
exit
