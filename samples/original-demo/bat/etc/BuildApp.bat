@echo off

cd ../../

call bat\ProjectVariables.bat
"%SDK%/haxelib" run lime build "application.xml" flash -release

echo %cd%
echo /s icons\ios\icons %AIR_APP_DIR%\icons\
xcopy /s icons\ios\icons %AIR_APP_DIR%\icons\

cd bat\etc
set SKIP_PAUSE=1;
call PackageAppAirD.bat

del %AIR_APP_DIR%\icons\*.* /F /Q