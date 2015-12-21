::@echo off

:: Set working dir
cd %~dp0 & cd ../../

if not exist %CERT_FILE% goto certificate

:: AIR output
if not exist %AIR_DIST_PATH% md %AIR_DIST_PATH%
set OUTPUT=%AIR_DIST_PATH%\%AIR_DIST_NAME%%AIR_TARGET%.%AIR_DIST_EXT%

:: Package
echo.
echo Packaging %AIR_DIST_NAME%%AIR_TARGET%.air using certificate %CERT_FILE%...
call adt -package %OPTIONS% %SIGNING_OPTIONS% -target native %OUTPUT% %AIR_DESKTOP_MANIFEST% %AIR_FILE_OR_DIR%
if errorlevel 1 goto failed
goto end

:certificate
echo.
echo Certificate not found: %CERT_FILE%
echo.
echo Troubleshooting: 
echo - generate a default certificate using 'bat\CreateCertificate.bat'
echo.
if %PAUSE_ERRORS%==1 pause
exit

:failed
echo AIR setup creation FAILED.
echo.
echo Troubleshooting: 
echo - verify AIR SDK target version in %AIR_DESKTOP_MANIFEST%
echo.
if %PAUSE_ERRORS%==1 pause
exit

:end
echo.
