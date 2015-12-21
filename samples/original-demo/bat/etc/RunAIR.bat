@echo off

:: Set working dir
cd %~dp0 & cd ../../

set PAUSE_ERRORS=1
call bat\etc\SetupSDK.bat
call bat\etc\SetupApp.bat

echo.
echo Starting AIR Debug Launcher...
echo.

adl "%AIR_DESKTOP_MANIFEST%" "%AIR_APP_DIR%"
if errorlevel 1 goto error
goto end

:error
pause

:end
