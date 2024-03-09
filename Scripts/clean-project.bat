@echo offtxt

:: Set current directory to the one specified if one is provided
set CurrentDirectory=%1
if "%1"=="" (
   set CurrentDirectory=%~pd0..\..\
)

set SettingsPath=%2
if "%2"=="" (
   set SettingsPath=%~pd0..\Settings\default-settings.properties
)

echo Getting settings from properties file...
echo Getting settings from properties file... >> "%LogPathFull%"
echo -------------------
echo ------------------- >> "%LogPathFull%"

:: Parse members of the properties file
for /F "tokens=2 delims==" %%a in ('findstr /I "UnrealEnginePath=" "%SettingsPath%"') do set UnrealEnginePath=%%a
for /F "tokens=2 delims==" %%a in ('findstr /I "WaitOnEnd=" "%SettingsPath%"') do set WaitOnEnd=%%a
for /F "tokens=2 delims==" %%a in ('findstr /I "AutoOpenSolution=" "%SettingsPath%"') do set AutoOpenSolution=%%a
for /F "tokens=2 delims==" %%a in ('findstr /I "AutoOpenEditor=" "%SettingsPath%"') do set AutoOpenEditor=%%a
for /F "tokens=2 delims==" %%a in ('findstr /I "AutoBuildEditor=" "%SettingsPath%"') do set AutoBuildEditor=%%a
for /F "tokens=2 delims==" %%a in ('findstr /I "SaveEditorConfigs=" "%SettingsPath%"') do set SaveEditorConfigs=%%a
for /F "tokens=2 delims==" %%a in ('findstr /I "VisualStudioYear=" "%SettingsPath%"') do set VisualStudioYear=%%a
for /F "tokens=2 delims==" %%a in ('findstr /I "VisualStudioEdition=" "%SettingsPath%"') do set VisualStudioEdition=%%a

:: Find Project Name
for %%i in (%CurrentDirectory%.\*) do (
   if "%%~xi"==".uproject" set ProjectName=%%~ni
)

set UnrealVersion=%UnrealEnginePath:~-4%
if "%UnrealVersion:~0,1%"=="_" (
   set UnrealVersion=%UnrealEnginePath:~-3%
)

set LogPath=%~pd0..\Logs
set LogPathFull=LogPath\CleanLog.txt

echo Found Unreal Project: %ProjectName%
echo Found Unreal Project: %ProjectName% >> "%LogPathFull%"
echo Unreal Version Detected: %UnrealVersion%
echo Unreal Version Detected: %UnrealVersion% >> "%LogPathFull%"
echo Found Unreal Install at: %UnrealEnginePath%
echo Found Unreal Install at: %UnrealEnginePath% >> "%LogPathFull%"
echo -------------------
echo ------------------- >> "%LogPathFull%"
echo Visual Studio Version: Visual Studio %VisualStudioYear% %VisualStudioEdition%
echo Visual Studio Version: Visual Studio %VisualStudioYear% %VisualStudioEdition% >> "%LogPathFull%"
echo -------------------
echo ------------------- >> "%LogPathFull%"
echo WaitOnEnd: %WaitOnEnd%
echo WaitOnEnd: %WaitOnEnd% >> "%LogPathFull%"
echo AutoOpenSolution: %AutoOpenSolution%
echo AutoOpenSolution: %AutoOpenSolution% >> "%LogPathFull%"
echo AutoOpenEditor: %AutoOpenEditor%
echo AutoOpenEditor: %AutoOpenEditor% >> "%LogPathFull%"
echo AutoBuildEditor: %AutoBuildEditor%
echo AutoBuildEditor: %AutoBuildEditor% >> "%LogPathFull%"
echo SaveEditorConfigs: %SaveEditorConfigs%
echo SaveEditorConfigs: %SaveEditorConfigs% >> "%LogPathFull%"


set BuildConfiguration=Development Editor
set EditorConfigStoragePath="%~pd0..\Config"
set EditorConfigPath="%CurrentDirectory%.\Saved\Config\WindowsEditor"
if "%UnrealVersion:~0,1%"=="4" (
   set EditorConfigPath="%CurrentDirectory%.\Saved\Config\Windows"
)

echo ----------------------------------------------------------------------------------------------
echo ---------------------------------------------------------------------------------------------- >> "%LogPathFull%"


:: Clean folders for proper regeneration
if "%SaveEditorConfigs%"=="true" (
   mkdir %EditorConfigStoragePath%
   move "%EditorConfigPath%\SourceControlSettings.ini" "%EditorConfigStoragePath%\SourceControlSettings.ini"
   move "%EditorConfigPath%\DefaultEditor.ini" "%EditorConfigStoragePath%\DefaultEditor.ini"
   move "%EditorConfigPath%\EditorPerProjectUserSettings.ini" "%EditorConfigStoragePath%\EditorPerProjectUserSettings.ini"
)

echo Deleting saved folder
echo Deleting saved folder >> "%LogPathFull%"
rmdir /S /Q %CurrentDirectory%.\Saved

echo Deleting binaries folder
echo Deleting binaries folder >> "%LogPathFull%"
rmdir /S /Q %CurrentDirectory%.\Binaries

echo Deleting intermediate folder
echo Deleting intermediate folder >> "%LogPathFull%"
rmdir /S /Q %CurrentDirectory%.\Intermediate

echo Deleting editor folders
echo Deleting editor folders >> "%LogPathFull%"
rmdir /S /Q %CurrentDirectory%.\.idea
rmdir /S /Q %CurrentDirectory%.\.vs

echo Deleting platforms folder
echo Deleting platforms folder >> "%LogPathFull%"
rmdir /S /Q %CurrentDirectory%.\Platforms

echo Deleting derived data cache
echo Deleting derived data cache >> "%LogPathFull%"
rmdir /S /Q %CurrentDirectory%.\DerivedDataCache

echo Deleting solution
echo Deleting solution >> "%LogPathFull%"
del /F /Q %CurrentDirectory%.\*.vsconfig
del /F /Q %CurrentDirectory%.\*.sln
del /F /Q %CurrentDirectory%.\*.DotSettings.user

echo Cleanup complete
echo Cleanup complete >> "%LogPathFull%"

echo ----------------------------------------------------------------------------------------------
echo ---------------------------------------------------------------------------------------------- >> "%LogPathFull%"

:: Generate project files
echo Generating project files...
echo Generating project files... >> "%LogPathFull%"
echo -------------------
echo ------------------- >> "%LogPathFull%"
set "BuildToolPath=%UnrealEnginePath%\Engine\Binaries\DotNET\UnrealBuildTool\UnrealBuildTool.exe"
if "%UnrealVersion:~0,1%"=="4" (
   set "BuildToolPath=%UnrealEnginePath%\Engine\Binaries\DotNET\UnrealBuildTool.exe"
)

"%BuildToolPath%" -ProjectFiles -Game "%CurrentDirectory%.\%ProjectName%.uproject"

if "%AutoOpenSolution%"=="true" (
   echo Opening the generated project...
   echo Opening the generated project... >> "%LogPathFull%"
   echo -------------------
   echo ------------------- >> "%LogPathFull%"
   cmd /c "start %CurrentDirectory%.\%ProjectName%.sln"
)

if "%AutoBuildEditor%"=="true" (
   echo Building solution...
   echo Building solution... >> "%LogPathFull%"
   echo -------------------
   echo ------------------- >> "%LogPathFull%"
   
   "%ProgramFiles%\Microsoft Visual Studio\%VisualStudioYear%\%VisualStudioEdition%\MSBuild\Current\Bin\MSBuild.exe" "%CurrentDirectory%.\%ProjectName%.sln" "/p:Configuration=Development Editor" "/p:Platform=Win64"
   if "%SaveEditorConfigs%"=="true" (
      mkdir "%EditorConfigPath%"
      move "%EditorConfigStoragePath%\SourceControlSettings.ini" "%EditorConfigPath%\SourceControlSettings.ini"
   move "%EditorConfigPath%\DefaultEditor.ini" "%EditorConfigStoragePath%\DefaultEditor.ini"
      move "%EditorConfigStoragePath%\EditorPerProjectUserSettings.ini" "%EditorConfigPath%\EditorPerProjectUserSettings.ini"
   )

   if "%AutoOpenEditor%"=="true" (
      cmd /c start /wait "" "%CurrentDirectory%.\%ProjectName%.uproject"
   )
)


if "%WaitOnEnd%"=="true" (
   pause
)
