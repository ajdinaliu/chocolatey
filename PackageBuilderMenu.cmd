@ECHO OFF
REM ¨°º©o¿,,¿o©º°¨¨°º©o¿,,¿o©º°¨¨°º©o¿,,¿o©º°¨¨°º©o¿,,¿o©º°¨

REM    Author: Ajdin Aliu
REM    Date  : 05.02.2015
REM    Goal  : NuGet Package Builder
REM    Version : PackageBuilder

REM ¨°º©o¿,,¿o©º°¨¨°º©o¿,,¿o©º°¨¨°º©o¿,,¿o©º°¨¨°º©o¿,,¿o©º°¨
@TITLE PackageBuilder
@COLOR 1F
echo ...running: %0
echo.
GOTO BEGIN
Readme: https://github.com/chocolatey/chocolatey/wiki/CreatePackagesQuickStart



:BEGIN
SET LocalRepo=%~dp0
SET LOG=%~dp0\Logs
SET NPP="C:\Program Files (x86)\Notepad++\notepad++.exe"
SET APIKEY=MyAPIKey
SET NuGetFeed=MyFeed

ECHO LocalRepo is now %LocalRepo%
ECHO APIKey is now %APIKEY%

:MENU
REM Build MenuItems
cls
ECHO =============================================================================
ECHO Current Variables:
If Defined packagename (
	ECHO.
	ECHO - Package Name is now "%packagename%" 
	ECHO.
)
If Defined packageversion (
	ECHO - Package Version is now "%packageversion%"
	ECHO.
)
ECHO =============================================================================

ECHO *****************************************************************************
ECHO [1] - Create new package
ECHO [2] - Edit package
ECHO [3] - Build package
ECHO [4] - Test package
ECHO [5] - Uninstall package
ECHO [6] - Push package
ECHO [7] - Install Package NuGetFeed (Development)
ECHO [8] - WarmUp - Set WarmUp environment
ECHO [9] - Change current Package
ECHO *****************************************************************************
ECHO. 

CHOICE /C:123456789E /D E /T 60 /N /M "Please choose action from Menu!"
ECHO Proceed action...
ECHO.

if %ERRORLEVEL%==1 goto GENTEMPLATE
if %ERRORLEVEL%==2 goto EDITTEMPLATE
if %ERRORLEVEL%==3 goto BUILDPACKAGE
if %ERRORLEVEL%==4 goto TESTPACKAGE
if %ERRORLEVEL%==5 goto UNINSTPACKAGE
if %ERRORLEVEL%==6 goto PUSHPACKAGE
if %ERRORLEVEL%==7 goto INSTPACKAGE
if %ERRORLEVEL%==8 goto WARMUP
if %ERRORLEVEL%==9 goto CURRPCKG



goto END

:CURRPCKG
CALL :NoPackageName
GOTO MENU


:WARMUP
ECHO.
ECHO WARMUP - Init Package Template Environment
ECHO -----------------------------------------------------------------------------
cinst warmup
choco install nuget.commandline

warmup addTextReplacement __CHOCO_PKG_MAINTAINER_NAME__ "AJAL"
warmup addTextReplacement __CHOCO_PKG_MAINTAINER_REPO__ "https://www.myget.org/feed/Packages/ajal_pub"

git clone https://github.com/chocolatey/chocolateytemplates.git
cd chocolateytemplates\_templates
warmup addTemplateFolder chocolatey "%cd%\chocolatey"
warmup addTemplateFolder chocolatey3 "%cd%\chocolatey3"
warmup addTemplateFolder chocolateyauto "%cd%\chocolateyauto"
warmup addTemplateFolder chocolateyauto3 "%cd%\chocolateyauto3"
cd %LocalRepo%
ECHO Done.
PAUSE
GOTO Continue


:GENTEMPLATE
ECHO Create new Package
ECHO -----------------------------------------------------------------------------
set /p packagename=Enter Package Name:
ECHO Package Name is now %packagename%

If Not Defined packagename (
	CALL :NoPackageName
)

ECHO *****************************************************************************
ECHO 1 - chocolatey (Default Template)
ECHO 2 - chocolatey3 (MobileApp)
ECHO 3 - chocolateyauto
ECHO 4 - chocolateyauto3
ECHO 5 - cancel
ECHO *****************************************************************************
ECHO.
CHOICE /C:1234 /M "Please choose template!"
if %ERRORLEVEL%==1 SET TPL=chocolatey
if %ERRORLEVEL%==2 SET TPL=chocolatey3
if %ERRORLEVEL%==3 SET TPL=chocolateyauto
if %ERRORLEVEL%==4 SET TPL=chocolateyauto3
if %ERRORLEVEL%==5 goto Continue

ECHO Creating %TPL% Package Template...
warmup %TPL% %packagename%
ECHO Done.
GOTO Continue

:EDITTEMPLATE
ECHO Edit Package %packagename%
ECHO -----------------------------------------------------------------------------
If Not Defined packagename (
	CALL :NoPackageName
)
%NPP% %LocalRepo%\%packagename%\%packagename%.nuspec
%NPP% %LocalRepo%\%packagename%\tools\chocolateyInstall.ps1
%NPP% %LocalRepo%\%packagename%\tools\chocolateyUninstall.ps1


ECHO Done.
ECHO Press any key...
GOTO Continue



:BUILDPACKAGE
ECHO Build package %packagename%
ECHO -----------------------------------------------------------------------------
If Not Defined packagename (
	CALL :NoPackageName
)
cd %LocalRepo%\%packagename%
cpack
cd %LocalRepo%
ECHO Done.
GOTO Continue

:TESTPACKAGE
ECHO Test package %packagename%
ECHO -----------------------------------------------------------------------------
If Not Defined packagename (
	CALL :NoPackageName
)
cd %LocalRepo%\%packagename%
choco install %packagename% -source '%LocalRepo%\%packagename%' --force -y
cd %LocalRepo%
ECHO Done.
GOTO Continue

:INSTPACKAGE
ECHO Install package %packagename%
ECHO -----------------------------------------------------------------------------
If Not Defined packagename (
	CALL :NoPackageName
)
cd %LocalRepo%\%packagename%
choco install %packagename% -source %NuGetFeed% --force -y
cd %LocalRepo%
ECHO Done.
GOTO Continue

:UNINSTPACKAGE
ECHO Uninstall package %packagename%
ECHO -----------------------------------------------------------------------------
If Not Defined packagename (
	CALL :NoPackageName
)
choco uninstall %packagename% -y

ECHO Done.
GOTO Continue

:PUSHPACKAGE
ECHO Push Package %packagename%
ECHO -----------------------------------------------------------------------------
If Not Defined packagename (
	CALL :NoPackageName
)
cd %LocalRepo%\%packagename%

ECHO.

:: rem run: nuget SetApiKey %APIKEY% -source %NuGetFeed%
::cpush %packagename%.%packageversion%.nupkg -source %NuGetFeed% -k %APIKEY%
::cpush -source %NuGetFeed% -k %APIKEY%
cpush -source %NuGetFeed%

cd %LocalRepo%
ECHO Done.
GOTO Continue


:NoPackageName

ECHO No PackageName defined!
ECHO.	
set /p packagename=Enter PackageName:
If Not Defined packagename (	
	ECHO No PackageName defined!
	PAUSE
	Goto MENU
)
ECHO PackageName is now "%packagename%"
GOTO:EOF

:Continue
ECHO.
ECHO Wollen Sie weiterfahren ?
CHOICE /C JNA /N /T 30 /D n /M "J fuer JA, N fuer NEIN, A fuer ABBRECHEN"
IF %ERRORLEVEL%==1 GOTO MENU

:end

