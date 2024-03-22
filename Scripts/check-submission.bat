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
set LogPathFull=%LogPath%\CheckLog.txt

call :CreateLog

set ChangelistNamePragmaOptimize=FIX: pragma optimize
set ChangeListMadePragmaOptimize=false
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
   setlocal enabledelayedexpansion
   set CurrentCheckFile=%%l
   echo #pragma optimize found in: !CurrentCheckFile!
   echo #pragma optimize found in: !CurrentCheckFile! >> "%LogPathFull%"

   call :HandlePragmaOptimizeFound
   start %%l
)

if "%ChangeListMadePragmaOptimize%"=="true" (
   p4 submit -c %ChangeListID%
)
exit /b

:CreateChangelistPragmaOptimize
   set ChangeListMadePragmaOptimize=true
   p4 --field Description="%ChangeListNamePragmaOptimize%" change -o | p4 change -i
   p4 changes -u jwmcconnell -m1>"%LogPath%\temp.txt"
   set /p ChangeListID=<"%LogPath%\temp.txt"
   for /f "delims=Change " %%c in ("%ChangeListID%") do (
      set ChangeListID=%%c
   )
exit /b

:HandlePragmaOptimizeFound
if "%ChangeListMadePragmaOptimize%"=="false" (
   call :CreateChangelistPragmaOptimize
)

p4 edit -c "%ChangeListID%" "!CurrentCheckFile!"
findstr /v "#pragma optimize" "!CurrentCheckFile!" > "%LogPath%\temp.txt"
type "%LogPath%\temp.txt" > "!CurrentCheckFile!"
del "%LogPath%\temp.txt"
exit /b
