@echo off

set CEPS_PrimaryDiskId=CEPS_UtilityFail
set CEPS_PrimaryDiskModel=CEPS_UtilityFail
set CEPS_PrimaryDiskType=CEPS_UtilityFail
set CEPS_PrimaryDiskSizeInGB=CEPS_UtilityFail
set CEPS_PrimaryDiskBusType=CEPS_UtilityFail
set CEPS_PrimaryDiskBusTypeName=CEPS_UtilityFail

ECHO [%DATE%] [%TIME%] Disk Info

for /f "delims=" %%i in ('Wmic.exe /namespace:\\root\Microsoft\Windows\Storage path MSFT_Disk where "BootFromDisk=true" get Number /value') do (
    for /f "tokens=1,2 delims==" %%a in ("%%~i") do (
        if /i "%%~a" == "Number" (set "CEPS_PrimaryDiskId=%%~b") else (set "CEPS_PrimaryDiskId=")
    )
)
if not defined CEPS_PrimaryDiskId ECHO Could not found the primary boot disk. &GOTO:eof

ECHO [%DATE%] [%TIME%] Primary Disk Id is "%CEPS_PrimaryDiskId%"

for /f "delims=" %%i in ('Wmic.exe /namespace:\\root\Microsoft\Windows\Storage path MSFT_PhysicalDisk where "SpindleSpeed=0 AND DeviceId=%CEPS_PrimaryDiskId%" get Model /value') do (
    for /f "tokens=1,2 delims==" %%a in ("%%~i") do (
       	if /i "%%~a" == "Model" (set "CEPS_PrimaryDiskType=SSD" &set "CEPS_PrimaryDiskModel=%%~b") else (set "CEPS_PrimaryDiskType=HDD" &set "CEPS_PrimaryDiskModel=%%~b")
    )
)

for /f "delims=" %%i in ('Wmic.exe /namespace:\\root\Microsoft\Windows\Storage path MSFT_PhysicalDisk where "DeviceId=%CEPS_PrimaryDiskId%" get BusType /value') do (
    for /f "tokens=1,2 delims==" %%a in ("%%~i") do (
       	if /i "%%~a" == "BusType" (set "CEPS_PrimaryDiskBusType=%%~b") else (set "CEPS_PrimaryDiskBusType=")
    )
)

if exist "C:\Program Files (x86)" (
	ECHO [%DATE%] [%TIME%] Machine is 64bit
	for /f "tokens=2,3 delims=,= " %%i in ('%~dp0disktype_x64.exe') do (
		set "CEPS_PrimaryDiskSizeInGB=%%~j"
	)
) else (
	for /f "tokens=2,3 delims=,= " %%i in ('%~dp0disktype_x86.exe') do (
		set "CEPS_PrimaryDiskSizeInGB=%%~j"
	)
)

REM mapping table for Bus Type
IF /I "%CEPS_PrimaryDiskBusType%"=="0" Set CEPS_PrimaryDiskBusTypeName=Unknown
IF /I "%CEPS_PrimaryDiskBusType%"=="1" Set CEPS_PrimaryDiskBusTypeName=SCSI
IF /I "%CEPS_PrimaryDiskBusType%"=="2" Set CEPS_PrimaryDiskBusTypeName=ATAPI
IF /I "%CEPS_PrimaryDiskBusType%"=="3" Set CEPS_PrimaryDiskBusTypeName=ATA
IF /I "%CEPS_PrimaryDiskBusType%"=="4" Set CEPS_PrimaryDiskBusTypeName=1394
IF /I "%CEPS_PrimaryDiskBusType%"=="5" Set CEPS_PrimaryDiskBusTypeName=SSA
IF /I "%CEPS_PrimaryDiskBusType%"=="6" Set CEPS_PrimaryDiskBusTypeName=Fibre Channel
IF /I "%CEPS_PrimaryDiskBusType%"=="7" Set CEPS_PrimaryDiskBusTypeName=USB
IF /I "%CEPS_PrimaryDiskBusType%"=="8" Set CEPS_PrimaryDiskBusTypeName=RAID
IF /I "%CEPS_PrimaryDiskBusType%"=="9" Set CEPS_PrimaryDiskBusTypeName=iSCSI
IF /I "%CEPS_PrimaryDiskBusType%"=="10" Set CEPS_PrimaryDiskBusTypeName=SAS
IF /I "%CEPS_PrimaryDiskBusType%"=="11" Set CEPS_PrimaryDiskBusTypeName=SATA
IF /I "%CEPS_PrimaryDiskBusType%"=="12" Set CEPS_PrimaryDiskBusTypeName=SD
IF /I "%CEPS_PrimaryDiskBusType%"=="13" Set CEPS_PrimaryDiskBusTypeName=MMC
IF /I "%CEPS_PrimaryDiskBusType%"=="14" Set CEPS_PrimaryDiskBusTypeName=Virtual
IF /I "%CEPS_PrimaryDiskBusType%"=="15" Set CEPS_PrimaryDiskBusTypeName=File Backed Virtual
IF /I "%CEPS_PrimaryDiskBusType%"=="16" Set CEPS_PrimaryDiskBusTypeName=Storage Spaces
IF /I "%CEPS_PrimaryDiskBusType%"=="17" Set CEPS_PrimaryDiskBusTypeName=NVMe
IF /I "%CEPS_PrimaryDiskBusType%"=="18" Set CEPS_PrimaryDiskBusTypeName=Microsoft Reserved

ECHO [%DATE%] [%TIME%] Primary Disk ID is "%CEPS_PrimaryDiskId%"
ECHO [%DATE%] [%TIME%] Primary Disk Model is "%CEPS_PrimaryDiskModel%"
ECHO [%DATE%] [%TIME%] Primary Disk Type is "%CEPS_PrimaryDiskType%"
ECHO [%DATE%] [%TIME%] Primary Disk Size is "%CEPS_PrimaryDiskSizeInGB%GB"
ECHO [%DATE%] [%TIME%] Primary Disk Bus Type is "%CEPS_PrimaryDiskBusTypeName%" (%CEPS_PrimaryDiskBusType%)