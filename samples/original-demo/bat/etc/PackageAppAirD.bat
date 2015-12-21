@echo off

:: Set working dir
cd %~dp0 & cd ../../

set PAUSE_ERRORS=1
call bat\etc\SetupSDK.bat
call bat\etc\SetupApp.bat

set AIR_TARGET=
::set AIR_TARGET=-captive-runtime
set OPTIONS=-tsa none
call bat\etc\PackagerAirD.bat


if "%SKIP_PAUSE%" NEQ 1 pause
