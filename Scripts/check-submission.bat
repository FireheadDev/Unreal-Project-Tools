@echo off
:: Set current directory to the one specified if one is provided
set CurrentDirectory=%~1
if "%~1"=="" (
   set CurrentDirectory=%~pd0..\..\
)

set SettingsPath=%~2
if "%~2"=="" (
   set SettingsPath=%~pd0..\Settings\default-settings.properties
)

:: Find Project Name
for %%i in (%CurrentDirectory%..\*) do (
   if "%%~xi"==".uproject" set ProjectName=%%~ni
)

set SourcePath=%CurrentDirectory%\Source\%ProjectName%
set LogPath=%~pd0..\Logs
set LogPathFull=LogPath\CheckLog.txt

call :CreateLog
call :PragmaOptimizeCheck
goto :eof




:CreateLog
if exist "%LogPath%\" (
   echo Log folder already exists
) else (
   mkdir "%LogPath%"
)

if exist "%LogPathFull%" (
   del "%LogPathFull%"
)
exit /b


:PragmaOptimizeCheck
cd %SourcePath%
for /f "tokens=*" %%l in ('findstr /s /i /m /c:"#pragma optimize" *.*') do (
   echo #pragma optimize found in: %%l
   echo #pragma optimize found in: %%l >> "%LogPathFull%"
   start %%l
   goto :eof
)
exit /b
