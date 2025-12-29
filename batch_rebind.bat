@echo off
REM CONFIGURATION TABLE
REM VERBOSE: 0: NO, 1: BASIC, 2: ULTRA
SET VERBOSE=0
SET DONGLE_BACKUP=1
REM CONFIGURATION TABLE


cd /d "%~dp0"
echo ________                        .__           __________      ___.   .__            .___            
echo \______ \   ____   ____    ____ ^|  ^|   ____   \______   \ ____\_ ^|__ ^|__^| ____    __^| _/___________ 
echo  ^|    ^|  \ /  _ \ /    \  / ___\^|  ^| _/ __ \   ^|       _// __ \^| __ \^|  ^|/    \  / __ ^|/ __ \_  __ \
echo  ^|    `   (  ^<_^> )   ^|  \/ /_/  ^>  ^|_\  ___/   ^|    ^|   \  ___/^| \_\ \  ^|   ^|  \/ /_/ \  ___/^|  ^| \/
echo /_______  /\____/^|___^|  /\___  /^|____/\___  ^>  ^|____^|_  /\___  ^>___  /__^|___^|  /\____ ^|\___  ^>__^|   
echo         \/            \//_____/           \/          \/     \/    \/        \/      \/    \/       
echo script made by El_isra
echo;
echo;
for %%x in (%*) do (
    if "%%x"=="--nobak" ( SET DONGLE_BACKUP=0)
)
for %%a in (kelftwinsigner ps2vmc-tool) do (
        set /A CNT1+=1
    where %%a>nul 2>nul
    if errorlevel 1 (
        echo FATAL ERROR: Could not find '%%a.exe'
        goto fuckoff
    )
)

if not exist "dongles\" (
    mkdir "dongles">nul 2>nul
    echo hello there!
    echo Seems this is the first time youre running the script.
    echo Please, put your arcade VMCs on the new "dongles" folder that was created right now.
    echo Then execute the script again, it will process all the VMCs one by one
    goto fuckoff
)

if %DONGLE_BACKUP% GTR 0 (
    if not exist "dongles_backup\" mkdir "dongles_backup\">nul 2>nul
)

echo choose target device (donor selection)
echo 1: SD2PSX
echo 2: MemcardPro2
echo 3: custom
CHOICE /C 123
if errorlevel 1 set DONOR=SD2PSX
if errorlevel 2 set DONOR=MCPRO2
if errorlevel 3 set DONOR=CUSTOM

if not exist "donor\%DONOR%.DONOR" (
    echo ERROR: Donor file "donor\%DONOR%.DONOR" missing
    goto fuckoff
)

set /A CNT=0
set /A CNTG=0

for %%a in (dongles\*) do (
    echo DONGLE %%a
    title binding %%a
    
    if %VERBOSE% GTR 1 (ps2vmc-tool.exe "%%a" -ls .) else (ps2vmc-tool.exe "%%a" -ls .>nul)
    if errorlevel 0 (
        if %DONGLE_BACKUP% GTR 0 (
            echo - Creating VMC backup
            copy /Y "%%a" "dongles_backup\%%~nxa">nul
        )
        echo - Extracting boot.bin
        ps2vmc-tool.exe "%%a" -x "boot.bin" "boot.bin">nul
        if errorlevel 0 (
            set /A CNT+=1
            echo - Transplanting kbit and kc from donor
            kelftwinsigner "donor\%DONOR%.DONOR" "boot.bin" | findstr "Kbit: Kc:"
            if errorlevel 0 (
                echo - Injecting new boot.bin into VMC
                ps2vmc-tool.exe "%%a" -in "boot.bin" "boot.bin">nul
                if errorlevel 0 (
                    echo - dongle rebound!
                    set /A CNTG+=1
                ) else (
                    echo -- ERROR: failed to copy new boot.bin to VMC
                )
                del "boot.bin">nul 2>nul
            ) else (echo -- Error while binding)
        ) else (
            echo -- 'boot.bin' missing from image, skipping...
            echo [%DATE%][%TIME%]: "%%a"
        )
    )
)
if %CNT% EQU 0 ( echo No valid VMCs inside "dongles" folder )
if %CNTG% GTR 0 ( echo %CNTG% VMCs have been rebound)
:fuckoff
pause