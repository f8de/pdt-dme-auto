@echo off
setlocal EnableDelayedExpansion

cd /d "%~dp0"

:: ─── USAGE ───────────────────────────────────────────────────────────────────
:: build.bat                   Build with current VERSION
:: build.bat patch             Bump patch then build
:: build.bat minor             Bump minor then build
:: build.bat major             Bump major then build
:: build.bat --no-package      Build EXE, skip deploy packaging
:: build.bat --verbose         Stream PyInstaller output live
:: build.bat patch --no-package

set BUMP=
set EXTRA_FLAGS=

:parse
if "%~1"=="" goto run
if /i "%~1"=="patch" set BUMP=--bump patch & shift & goto parse
if /i "%~1"=="minor" set BUMP=--bump minor & shift & goto parse
if /i "%~1"=="major" set BUMP=--bump major & shift & goto parse
if /i "%~1"=="--no-package" set EXTRA_FLAGS=%EXTRA_FLAGS% --no-package & shift & goto parse
if /i "%~1"=="--verbose" set EXTRA_FLAGS=%EXTRA_FLAGS% --verbose & shift & goto parse
if /i "%~1"=="-v" set EXTRA_FLAGS=%EXTRA_FLAGS% --verbose & shift & goto parse
shift & goto parse

:run
:: ─── HEADER ──────────────────────────────────────────────────────────────────
echo.
echo ==================================================
echo   DME Auto  ^|  Build
echo ==================================================
echo   Started: %DATE% %TIME%
echo.

:: ─── RUN BUILD ───────────────────────────────────────────────────────────────
set BUILD_ARGS=%BUMP% %EXTRA_FLAGS%
python build.py %BUILD_ARGS%
set EXIT_CODE=%ERRORLEVEL%

echo.
echo ==================================================

:: ─── RESULT ──────────────────────────────────────────────────────────────────
if %EXIT_CODE% NEQ 0 (
    echo   [FAILED]  Exit code: %EXIT_CODE%
    echo ==================================================
    echo.
    exit /b %EXIT_CODE%
)

:: Verify EXE actually exists
if not exist "dist\dme-auto.exe" (
    echo   [FAILED]  dist\dme-auto.exe not found after build
    echo ==================================================
    echo.
    exit /b 1
)

:: Show EXE size
for %%F in ("dist\dme-auto.exe") do set EXE_SIZE=%%~zF
set /a EXE_MB=!EXE_SIZE! / 1048576

echo   [OK]  dist\dme-auto.exe  (!EXE_MB! MB^)

for %%F in ("deploy\dme-auto-*.exe") do (
    set DEPLOY_SIZE=%%~zF
    set /a DEPLOY_MB=!DEPLOY_SIZE! / 1048576
    echo   [OK]  %%~nxF  (!DEPLOY_MB! MB^)
)

echo   Finished: %DATE% %TIME%
echo ==================================================
echo.
exit /b 0
