@echo off

set CurrentDirectory=%~1
if "%~1"=="" (
   set CurrentDirectory=%~pd0..\..\..\
)
set SettingsPath=%~pd0..\..\Settings\Variant Settings\unreal-launch.properties

echo %CurrentDirectory%
echo %SettingsPath%

call "%~pd0..\clean-project.bat" "%CurrentDirectory%" "%SettingsPath%"