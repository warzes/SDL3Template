@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ============================================
echo  SDL3Template - Web (Emscripten) Build
echo ============================================
echo.

set "ROOT=%~dp0"
set "ROOT=%ROOT:~0,-1%"

set "SRC_DIR=%ROOT%\src"
set "OBJ_DIR=%ROOT%\_obj\web"
set "OUT_DIR=%ROOT%\bin\web"
set "OUT_HTML=%OUT_DIR%\index.html"

if exist "D:\develop\emsdk\emsdk_env.bat" (
    set "EMSDK=D:\develop\emsdk"
) else (
    set "EMSDK=C:\develop\emsdk"
)
call "%EMSDK%\emsdk_env.bat" >nul 2>&1

set "CXX=em++"
set "AR=emar"
set "ARFLAGS=rcs"

set "CXXFLAGS=-std=c++17 -Wall -O2 -g"
:: find and add SDL3 port include first so it takes priority over local SDL3 headers
for /d %%D in ("%EMSDK%\upstream\emscripten\cache\ports\sdl3\*") do set "CXXFLAGS=%CXXFLAGS% -I%%D\include"
set "CXXFLAGS=%CXXFLAGS% -I%SRC_DIR%"
set "CXXFLAGS=%CXXFLAGS% -I%SRC_DIR%\3rdparty"

set "CXXFLAGS=%CXXFLAGS% -sUSE_SDL=3"
set "CXXFLAGS=%CXXFLAGS% -sUSE_WEBGL2=1"
set "CXXFLAGS=%CXXFLAGS% -sFULL_ES3=1"
set "CXXFLAGS=%CXXFLAGS% -sMAX_WEBGL_VERSION=2"
set "CXXFLAGS=%CXXFLAGS% -sMIN_WEBGL_VERSION=1"
set "CXXFLAGS=%CXXFLAGS% -sALLOW_MEMORY_GROWTH=1"
set "CXXFLAGS=%CXXFLAGS% -sINITIAL_MEMORY=64MB"
set "CXXFLAGS=%CXXFLAGS% -sMAXIMUM_MEMORY=512MB"
set "CXXFLAGS=%CXXFLAGS% -sEXIT_RUNTIME=1"
set "CXXFLAGS=%CXXFLAGS% -sFORCE_FILESYSTEM=1"
set "CXXFLAGS=%CXXFLAGS% -sASSERTIONS"
set "CXXFLAGS=%CXXFLAGS% -sGL_ASSERTIONS=1"
set "CXXFLAGS=%CXXFLAGS% -sERROR_ON_UNDEFINED_SYMBOLS=0"

set "LDFLAGS=%CXXFLAGS%"

if not exist "%OBJ_DIR%" mkdir "%OBJ_DIR%"
if not exist "%OUT_DIR%" mkdir "%OUT_DIR%"

:: ============================================
:: Helper subroutines
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

set "T_CHG=%TEMP%\dw_3rd.txt"
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
if not "!T_OFS!"=="" ( %AR% %ARFLAGS% "%OBJ_DIR%\3rdparty.a" !T_OFS! )

:: ============================================
:: Target: Engine
:: ============================================
echo.
echo [Engine] --------------------------
set "T_SRC=%SRC_DIR%\Engine"
set "T_OBJ=%OBJ_DIR%\Engine"
if not exist "%T_OBJ%" mkdir "%T_OBJ%"

set "T_CHG=%TEMP%\dw_eng.txt"
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
if not "!T_OFS!"=="" ( %AR% %ARFLAGS% "%OBJ_DIR%\Engine.a" !T_OFS! )

:: ============================================
:: Target: Game
:: ============================================
echo.
echo [Game] ----------------------------
set "T_SRC=%SRC_DIR%\Game"
set "T_OBJ=%OBJ_DIR%\Game"
if not exist "%T_OBJ%" mkdir "%T_OBJ%"

set "T_CHG=%TEMP%\dw_game.txt"
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
if not exist "%OUT_HTML%" ( set "T_LINK=1" ) else (
    for /R "%OBJ_DIR%" %%F in (*.o) do (
        powershell -NoProfile -Command "exit((Get-Item '%%F').LastWriteTimeUtc -gt (Get-Item '%OUT_HTML%').LastWriteTimeUtc)" >nul 2>&1
        if errorlevel 1 set "T_LINK=1"
    )
)
if "!T_LINK!"=="1" (
    echo [Game] Linking...
    set "T_OFS="
    for /R "%OBJ_DIR%" %%F in (*.o) do set "T_OFS=!T_OFS! "%%F""
    %CXX% !T_OFS! %LDFLAGS% -o "%OUT_HTML%"
    if errorlevel 1 ( echo [FAIL] Game link error. & exit /b 1 )
    echo [Game] Linked.
) else ( echo [Game] Up to date. )

echo.
echo ============================================
echo  Build complete: %OUT_HTML%
echo ============================================
