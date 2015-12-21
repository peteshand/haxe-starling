:: Set working dir
cd %~dp0 & cd ../../

:user_configuration

call bat\ProjectVariables.bat

:: Use FD supplied SDK path if executed from FD
if exist "%FD_CUR_SDK%" set SDK=%FD_CUR_SDK%

:validation
if not exist "%SDK%" goto sdkerr
goto succeed

:sdkerr
echo.
echo ERROR: incorrect path to Haxe SDK in 'bat\etc\SetupSDK.bat'
echo.
echo Looking for: %SDK%
echo.
if %PAUSE_ERRORS%==1 pause
exit

:succeed
set PATH=%PATH%;%SDK%\bin;%FLEX_SDK%\bin
