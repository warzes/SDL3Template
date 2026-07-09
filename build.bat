@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ============================================
echo  SDL3Template - Build Script (GCC/MinGW)
echo ============================================
echo.

set "ROOT=%~dp0"
set "ROOT=%ROOT:~0,-1%"

set "SRC_DIR=%ROOT%\src"
set "BIN_DIR=%ROOT%\bin"
set "OBJ_DIR=%ROOT%\_obj\gcc"
set "LIB_DIR=%ROOT%\_lib\gcc"

set "CXX=g++"
set "AR=ar"
set "ARFLAGS=rcs"

set "CXXFLAGS=-std=c++17 -Wall -O2 -g"
set "CXXFLAGS=%CXXFLAGS% -I%SRC_DIR%"
set "CXXFLAGS=%CXXFLAGS% -I%SRC_DIR%\3rdparty"

set "LDFLAGS=-mconsole -LC:\msys64\ucrt64\lib -lSDL3"

if not exist "%BIN_DIR%" mkdir "%BIN_DIR%"
if not exist "%OBJ_DIR%" mkdir "%OBJ_DIR%"
if not exist "%LIB_DIR%" mkdir "%LIB_DIR%"

:: ============================================
:: Helper subroutines (defined early)
:: ============================================
goto :start_build

:: compile_one src_file obj_dir src_base  -> compiles one file
:compile_one
set "CO_SRC=%~1"
if "!CO_SRC:~-1!"==" " set "CO_SRC=!CO_SRC:~0,-1!"
set "CO_OBJ=%~2"
set "CO_BASE=%~3"
set "CO_RP=!CO_SRC:%CO_BASE%=!"
if "!CO_RP:~0,1!"=="\" set "CO_RP=!CO_RP:~1!"
set "CO_OF=!CO_OBJ!\!CO_RP:\=.!.o"
"%CXX%" %CXXFLAGS% -c "!CO_SRC!" -o "!CO_OF!" > "!CO_OF!.log" 2>&1
if errorlevel 1 ( type "!CO_OF!.log" & exit /b 1 )
exit /b 0

:start_build

:: ============================================
:: Target: 3rdparty
:: ============================================
echo.
echo [3rdparty] ------------------------
set "T_SRC=%SRC_DIR%\3rdparty"
set "T_OBJ=%OBJ_DIR%\3rdparty"
if not exist "%T_OBJ%" mkdir "%T_OBJ%"

set "T_CHG=%TEMP%\dc_3rd.txt"
type nul > "%T_CHG%"
for /R "%T_SRC%" %%F in (*.cpp) do (
    set "FN=%%~nxF"
    if /I not "!FN!"=="stdafx.cpp" (
        set "SF=%%F"
        set "RP=!SF:%T_SRC%=!"
        if "!RP:~0,1!"=="\" set "RP=!RP:~1!"
        set "OF=%T_OBJ%\!RP:\=.!.o"
        if not exist "!OF!" ( >>"%T_CHG%" echo !SF! ) else (
            powershell -NoProfile -Command "exit((Get-Item '!SF!').LastWriteTimeUtc -gt (Get-Item '!OF!').LastWriteTimeUtc)" >nul 2>&1
            if errorlevel 1 >>"%T_CHG%" echo !SF!
        )
    )
)
set "T_CNT=0"
for /f "usebackq delims=" %%F in ("%T_CHG%") do set /a T_CNT+=1
if %T_CNT% gtr 0 (
    echo [3rdparty] Compiling %T_CNT% file^(s^)...
    for /f "usebackq delims=" %%F in ("%T_CHG%") do (
        call :compile_one "%%F" "%T_OBJ%" "%T_SRC%"
        if errorlevel 1 exit /b 1
    )
) else ( echo [3rdparty] No files to compile. )
echo [3rdparty] Archiving...
set "T_OFS="
for /R "%T_OBJ%" %%F in (*.o) do set "T_OFS=!T_OFS! "%%F""
if not "!T_OFS!"=="" ( %AR% %ARFLAGS% "%LIB_DIR%\3rdparty.lib" !T_OFS! )

:: ============================================
:: Target: Engine
:: ============================================
echo.
echo [Engine] --------------------------
set "T_SRC=%SRC_DIR%\Engine"
set "T_OBJ=%OBJ_DIR%\Engine"
if not exist "%T_OBJ%" mkdir "%T_OBJ%"

set "T_CHG=%TEMP%\dc_eng.txt"
type nul > "%T_CHG%"
for /R "%T_SRC%" %%F in (*.cpp) do (
    set "FN=%%~nxF"
    if /I not "!FN!"=="stdafx.cpp" (
        set "SF=%%F"
        set "RP=!SF:%T_SRC%=!"
        if "!RP:~0,1!"=="\" set "RP=!RP:~1!"
        set "OF=%T_OBJ%\!RP:\=.!.o"
        if not exist "!OF!" ( >>"%T_CHG%" echo !SF! ) else (
            powershell -NoProfile -Command "exit((Get-Item '!SF!').LastWriteTimeUtc -gt (Get-Item '!OF!').LastWriteTimeUtc)" >nul 2>&1
            if errorlevel 1 >>"%T_CHG%" echo !SF!
        )
    )
)
set "T_CNT=0"
for /f "usebackq delims=" %%F in ("%T_CHG%") do set /a T_CNT+=1
if %T_CNT% gtr 0 (
    echo [Engine] Compiling %T_CNT% file^(s^)...
    for /f "usebackq delims=" %%F in ("%T_CHG%") do (
        call :compile_one "%%F" "%T_OBJ%" "%T_SRC%"
        if errorlevel 1 exit /b 1
    )
) else ( echo [Engine] No files to compile. )
echo [Engine] Archiving...
set "T_OFS="
for /R "%T_OBJ%" %%F in (*.o) do set "T_OFS=!T_OFS! "%%F""
if not "!T_OFS!"=="" ( %AR% %ARFLAGS% "%LIB_DIR%\Engine.lib" !T_OFS! )

:: ============================================
:: Target: Game
:: ============================================
echo.
echo [Game] ----------------------------
set "T_SRC=%SRC_DIR%\Game"
set "T_OBJ=%OBJ_DIR%\Game"
set "T_EXE=%BIN_DIR%\Game.exe"
if not exist "%T_OBJ%" mkdir "%T_OBJ%"

set "T_CHG=%TEMP%\dc_game.txt"
type nul > "%T_CHG%"
for /R "%T_SRC%" %%F in (*.cpp) do (
    set "FN=%%~nxF"
    if /I not "!FN!"=="stdafx.cpp" (
        set "SF=%%F"
        set "RP=!SF:%T_SRC%=!"
        if "!RP:~0,1!"=="\" set "RP=!RP:~1!"
        set "OF=%T_OBJ%\!RP:\=.!.o"
        if not exist "!OF!" ( >>"%T_CHG%" echo !SF! ) else (
            powershell -NoProfile -Command "exit((Get-Item '!SF!').LastWriteTimeUtc -gt (Get-Item '!OF!').LastWriteTimeUtc)" >nul 2>&1
            if errorlevel 1 >>"%T_CHG%" echo !SF!
        )
    )
)
set "T_CNT=0"
for /f "usebackq delims=" %%F in ("%T_CHG%") do set /a T_CNT+=1
if %T_CNT% gtr 0 (
    echo [Game] Compiling %T_CNT% file^(s^)...
    for /f "usebackq delims=" %%F in ("%T_CHG%") do (
        call :compile_one "%%F" "%T_OBJ%" "%T_SRC%"
        if errorlevel 1 exit /b 1
    )
) else ( echo [Game] No files to compile. )

:: Link
set "T_LINK=0"
if not exist "%T_EXE%" ( set "T_LINK=1" ) else (
    for %%F in ("%T_OBJ%\*.o") do (
        powershell -NoProfile -Command "exit((Get-Item '%%F').LastWriteTimeUtc -gt (Get-Item '%T_EXE%').LastWriteTimeUtc)" >nul 2>&1
        if errorlevel 1 set "T_LINK=1"
    )
)
if "!T_LINK!"=="1" (
    echo [Game] Linking...
    set "T_OFS="
    for /R "%T_OBJ%" %%F in (*.o) do set "T_OFS=!T_OFS! "%%F""
    set "T_LIBS="
    for /R "%LIB_DIR%" %%F in (*.lib) do set "T_LIBS=!T_LIBS! "%%F""
    %CXX% !T_OFS! !T_LIBS! %LDFLAGS% -o "%T_EXE%"
    if errorlevel 1 ( echo [FAIL] Game link error. & exit /b 1 )
    echo [Game] Linked.
) else ( echo [Game] Up to date. )

:: SDL3.dll
echo.
if exist "%BIN_DIR%\SDL3.dll" ( echo [DLL] SDL3.dll found. ) else (
    if exist "C:\msys64\ucrt64\bin\SDL3.dll" (
        copy /Y "C:\msys64\ucrt64\bin\SDL3.dll" "%BIN_DIR%" >nul
        echo [DLL] SDL3.dll copied from MSYS2.
    ) else ( echo [DLL] SDL3.dll not found. Copy it manually. )
)

echo.
echo ============================================
echo  Build complete: %BIN_DIR%\Game.exe
echo ============================================
