@echo off

Set CEPS_OptaneDevice=CEPS_UtilityFail

for /f "delims=" %%i in ('wmic /namespace:"\\root\HP\InstrumentedBIOS" path HPBIOS_BIOSString where ^(name^="Optane"^) get value /value') do (
    for /f "tokens=1,2 delims==" %%a in ("%%~i") do (
        if /i "%%~b" == "Yes" (
        	set "CEPS_OptaneDevice=True"
        ) else set "CEPS_OptaneDevice="
    )
)
for /f "delims=" %%i in ('wmic /namespace:"\\root\HP\InstrumentedBIOS" path HP_BIOSSetting where ^(name^="Optane"^) get value /value') do (
    for /f "tokens=1,2 delims==" %%a in ("%%~i") do (
        if /i "%%~b" == "Yes" (
        	set "CEPS_OptaneDevice=True"
        ) else set "CEPS_OptaneDevice="
    )
)

ECHO [%DATE%] [%TIME%] Optane Device is "%CEPS_OptaneDevice%"