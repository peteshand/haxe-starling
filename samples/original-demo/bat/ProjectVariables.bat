:: Static path to Haxe SDK
set SDK=C:\_sdks\haxe\3.2\haxe
set SDK_VERSION=3.2.0

:: required to generate dertificate
set FLEX_SDK=C:\_sdks\flex4.6_air18

:: Your application ID (must match <id> of Application descriptor) and remove spaces
set APP_TITLE=OpenFLStarlingSamples
set APP_PACK=starling.samples
set APP_ID=%APP_PACK%.%APP_TITLE%

:: Your certificate information
set CERT_NAME=OpenFLStarlingSamples
set CERT_PASS=fd
set CERT_FILE="bat\%CERT_NAME%.p12"
set SIGNING_OPTIONS=-storetype pkcs12 -keystore %CERT_FILE% -storepass %CERT_PASS%


:: AIR SPECIFIC VARS

:: Application descriptor
set OPENFL_MANIFEST=application.xml
set AIR_DESKTOP_MANIFEST=air-desktop.xml
set AIR_MOBILE_MANIFEST=air-mobile.xml

:: Files to package
set AIR_APP_DIR=bin\flash\bin
set AIR_FILE_OR_DIR=-C %AIR_APP_DIR% .

:: Output
set AIR_DIST_PATH=dist
set AIR_DIST_NAME=OpenFLStarlingSamples
set AIR_DIST_EXT=exe