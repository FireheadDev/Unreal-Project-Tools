@echo off


echo Getting settings from properties file...
echo -------------------
:: Parse members of the properties file
for /F "tokens=2 delims==" %%a in ('findstr /I "UnrealEnginePath=" "%~pd0settings.properties"') do set UnrealEnginePath=%%a
for /F "tokens=2 delims==" %%a in ('findstr /I "WaitOnEnd=" "%~pd0settings.properties"') do set WaitOnEnd=%%a
for /F "tokens=2 delims==" %%a in ('findstr /I "AutoOpenSolution=" "%~pd0settings.properties"') do set AutoOpenSolution=%%a
for /F "tokens=2 delims==" %%a in ('findstr /I "AutoOpenEditor=" "%~pd0settings.properties"') do set AutoOpenEditor=%%a
for /F "tokens=2 delims==" %%a in ('findstr /I "AutoBuildEditor=" "%~pd0settings.properties"') do set AutoBuildEditor=%%a
for /F "tokens=2 delims==" %%a in ('findstr /I "SaveEditorConfigs=" "%~pd0settings.properties"') do set SaveEditorConfigs=%%a
for /F "tokens=2 delims==" %%a in ('findstr /I "VisualStudioYear=" "%~pd0settings.properties"') do set VisualStudioYear=%%a
for /F "tokens=2 delims==" %%a in ('findstr /I "VisualStudioEdition=" "%~pd0settings.properties"') do set VisualStudioEdition=%%a

:: Find Project Name
for %%i in (%CurrentDirectory%..\*) do (
   if "%%~xi"==".uproject" set ProjectName=%%~ni
)

set UnrealVersion=%UnrealEnginePath:~-4%
if "%UnrealVersion:~0,1%"=="_" (
   set UnrealVersion=%UnrealEnginePath:~-3%
)

echo Found Unreal Project: %ProjectName%
echo Unreal Version Detected: %UnrealVersion%
echo Found Unreal Install at: %UnrealEnginePath%
echo -------------------
echo Visual Studio Version: Visual Studio %VisualStudioYear% %VisualStudioEdition%
echo -------------------
echo WaitOnEnd: %WaitOnEnd%
echo AutoOpenSolution: %AutoOpenSolution%
echo AutoOpenEditor: %AutoOpenEditor%
echo AutoBuildEditor: %AutoBuildEditor%
echo SaveEditorConfigs: %SaveEditorConfigs%

:: Set current directory to the one specified if one is provided
set CurrentDirectory=%1
if "%1"=="" (
   set CurrentDirectory=%~pd0
)
set BuildConfiguration=Development Editor
set EditorConfigStoragePath="%CurrentDirectory%\Config"
set EditorConfigPath="%CurrentDirectory%..\Saved\Config\WindowsEditor"
if "%UnrealVersion:~0,1%"=="4" (
   set EditorConfigPath="%CurrentDirectory%..\Saved\Config\Windows"
)

echo ----------------------------------------------------------------------------------------------


:: Clean folders for proper regeneration
if "%SaveEditorConfigs%"=="true" (
   mkdir %EditorConfigStoragePath%
   move "%EditorConfigPath%\SourceControlSettings.ini" "%EditorConfigStoragePath%\SourceControlSettings.ini"
   move "%EditorConfigPath%\DefaultEditor.ini" "%EditorConfigStoragePath%\DefaultEditor.ini"
   move "%EditorConfigPath%\EditorPerProjectUserSettings.ini" "%EditorConfigStoragePath%\EditorPerProjectUserSettings.ini"
)

echo Deleting saved folder
rmdir /S /Q %CurrentDirectory%..\Saved

echo Deleting binaries folder
rmdir /S /Q %CurrentDirectory%..\Binaries

echo Deleting intermediate folder
rmdir /S /Q %CurrentDirectory%..\Intermediate

echo Deleting editor folders
rmdir /S /Q %CurrentDirectory%..\.idea
rmdir /S /Q %CurrentDirectory%..\.vs

echo Deleting platforms folder
rmdir /S /Q %CurrentDirectory%..\Platforms

echo Deleting derived data cache
rmdir /S /Q %CurrentDirectory%..\DerivedDataCache

echo Deleting solution
del /F /Q %CurrentDirectory%..\*.vsconfig
del /F /Q %CurrentDirectory%..\*.sln
del /F /Q %CurrentDirectory%..\*.DotSettings.user

echo Cleanup complete

echo ----------------------------------------------------------------------------------------------

:: Generate project files
echo Generating project files...
echo -------------------
set "BuildToolPath=%UnrealEnginePath%\Engine\Binaries\DotNET\UnrealBuildTool\UnrealBuildTool.exe"
if "%UnrealVersion:~0,1%"=="4" (
   set "BuildToolPath=%UnrealEnginePath%\Engine\Binaries\DotNET\UnrealBuildTool.exe"
)

"%BuildToolPath%" -ProjectFiles -Game "%CurrentDirectory%..\%ProjectName%.uproject"

if "%AutoOpenSolution%"=="true" (
   echo Opening the generated project...
   echo -------------------
   cmd /c "start %CurrentDirectory%..\%ProjectName%.sln"
)

if "%AutoBuildEditor%"=="true" (
   echo Building solution...
   echo -------------------
   
   "%ProgramFiles%\Microsoft Visual Studio\%VisualStudioYear%\%VisualStudioEdition%\MSBuild\Current\Bin\MSBuild.exe" "%CurrentDirectory%..\%ProjectName%.sln" "/p:Configuration=Development Editor" "/p:Platform=Win64"
   if "%SaveEditorConfigs%"=="true" (
      mkdir "%EditorConfigPath%"
      move "%EditorConfigStoragePath%\SourceControlSettings.ini" "%EditorConfigPath%\SourceControlSettings.ini"
   move "%EditorConfigPath%\DefaultEditor.ini" "%EditorConfigStoragePath%\DefaultEditor.ini"
      move "%EditorConfigStoragePath%\EditorPerProjectUserSettings.ini" "%EditorConfigPath%\EditorPerProjectUserSettings.ini"
   )

   if "%AutoOpenEditor%"=="true" (
      cmd /c start /wait "" "%CurrentDirectory%..\%ProjectName%.uproject"
   )
)


if "%WaitOnEnd%"=="true" (
   pause
)
