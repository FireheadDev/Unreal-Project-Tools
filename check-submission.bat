@echo off
:: Set current directory to the one specified if one is provided
set CurrentDirectory=%1
if "%1"=="" (
   set CurrentDirectory=%~pd0
)

:: Find Project Name
for %%i in (%CurrentDirectory%..\*) do (
   if "%%~xi"==".uproject" set ProjectName=%%~ni
)

set SourcePath=%CurrentDirectory%..\Source\%ProjectName%
set LogPath=%~pd0\Logs

call :CreateLog
call :PragmaOptimizeCheck
goto :eof




:CreateLog
if exist "%LogPath%\" (
   echo Log folder already exists
) else (
   mkdir "%LogPath%"
)

if exist "%LogPath%\CheckLog.txt" (
   del "%LogPath%\CheckLog.txt"
)
exit /b


:PragmaOptimizeCheck
cd %SourcePath%
for /f "tokens=*" %%l in ('findstr /s /i /m /c:"#pragma optimize" *.*') do (
   echo #pragma optimize found in: %%l
   echo #pragma optimize found in: %%l >> "%LogPath%\CheckLog.txt"
   start %%l
   goto :eof
)
exit /b
