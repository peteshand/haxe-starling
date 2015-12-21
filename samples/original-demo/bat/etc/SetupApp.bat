:: Set working dir
cd %~dp0 & cd ../../

:user_configuration

:: NOTICE: all paths are relative to project root

call bat\ProjectVariables.bat

:validation
findstr /C:"%APP_PACK%" "%OPENFL_MANIFEST%" > NUL
if errorlevel 1 goto badpack
findstr /C:"%APP_TITLE%" "%OPENFL_MANIFEST%" > NUL
if errorlevel 1 goto badtitle
goto end

:badpack
echo.
echo ERROR: 
echo   Application package in 'bat\etc\SetupApp.bat' (APP_PACK) 
echo   does NOT match Application descriptor '%OPENFL_MANIFEST%' (package)
echo.
if %PAUSE_ERRORS%==1 pause
exit

:badtitle
echo.
echo ERROR: 
echo   Application package in 'bat\etc\SetupApp.bat' (APP_TITLE) 
echo   does NOT match Application descriptor '%OPENFL_MANIFEST%' (title)
echo.
if %PAUSE_ERRORS%==1 pause
exit

:end
