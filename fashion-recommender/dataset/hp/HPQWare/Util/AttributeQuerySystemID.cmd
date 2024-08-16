@echo off

set CEPS_SystemID=CEPS_UtilityFail

for /f "delims=" %%i in ('Wmic baseboard get Product /value') do (
    for /f "tokens=1,2 delims==" %%a in ("%%~i") do (
         if /i "%%~a" == "Product" (set "CEPS_SystemID=%%~b") else (set "CEPS_SystemID=")
    )
)

ECHO [%DATE%] [%TIME%] System ID is "%CEPS_SystemID%"