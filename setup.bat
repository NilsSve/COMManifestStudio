@echo off
setlocal enabledelayedexpansion

REM ===========================================================================
REM  COMManifestStudio - one-time setup
REM
REM  This is a DataFlex 26 workspace, and its libraries arrive two ways.
REM
REM    * DUF, and with it DFAbout, RDCToolsLib and vwin32fh, are declared as
REM      dependencies in COMManifestStudio.sws. The Studio's package handler
REM      fetches them when the workspace is opened and unpacks them into
REM      DfPkg\, pinned to the commits recorded in COMManifestStudio.sws.lock.
REM      This script does nothing for those - there is nothing to do.
REM
REM    * Filesystem is still read from Libraries\, and that is what this
REM      script provides:
REM
REM        - If a shared RDC library pool sits next to this workspace (a
REM          sibling ..\Libraries folder carrying the marker file
REM          .rdc-library-pool), it makes Libraries\ a JUNCTION to that pool.
REM          One shared, editable copy: a fix made in a library here is a fix
REM          in the pool.
REM
REM        - Otherwise it CLONES Filesystem into this workspace's own
REM          Libraries\ folder - isolated, self-contained, and it never writes
REM          anywhere outside this workspace, so it cannot disturb libraries
REM          you already have elsewhere.
REM
REM  Only Filesystem is cloned. The other four are not, on purpose: a second
REM  copy of a library the compiler never reads is what makes Go-to-Definition
REM  open the wrong file and a fix land where nothing builds it.
REM
REM  Re-run any time Libraries\ looks missing or out of date.
REM ===========================================================================

cd /d "%~dp0"

echo.
echo === COMManifestStudio setup ===
echo Working folder: %CD%
echo.

where git >nul 2>nul
if errorlevel 1 (
    echo [ERROR] Git was not found on your PATH.
    echo         Install Git ^(or the GitHub Desktop app^), reopen the
    echo         command prompt, and run setup.bat again.
    echo.
    pause
    exit /b 1
)

if exist "..\Libraries\.rdc-library-pool" (
    REM ------------------------------------------------------------------ pool
    if exist "Libraries" (
        echo Libraries\ already present - assuming it is linked. Skipping.
    ) else (
        echo Shared library pool found next door - linking Libraries\ to it...
        mklink /J "Libraries" "..\Libraries" >nul
        if errorlevel 1 (
            echo.
            echo [ERROR] Could not create the junction to ..\Libraries.
            echo         Create it by hand with:
            echo             mklink /J "%CD%\Libraries" "%CD%\..\Libraries"
            echo.
            pause
            exit /b 1
        )
        echo Linked: Libraries  -^>  ..\Libraries
    )
) else (
    REM --------------------------------------------------------------- isolated
    REM No shared pool. Clone Filesystem into this workspace's own Libraries    REM - never writes outside this workspace. Note that the folder name and
    REM the repo name differ here (the repo is Library-cFilesystem).
    call :CloneLib Filesystem   Library-cFilesystem
)

echo.
if exist "%~dp0skip-local-data.cmd" (
    echo Protecting your local Data\ database from accidental commits...
    call "%~dp0skip-local-data.cmd"
) else (
    echo [NOTE] skip-local-data.cmd not found - skipping local DB protection.
)

echo.
echo === Setup complete ===
echo.
echo Libraries\ is ready. Open COMManifestStudio.sws in the Studio and build.
echo The Studio fetches the remaining libraries into DfPkg\ the first time it
echo opens the workspace, so give it a moment before the first compile.
echo Remember to compile as 32-bit ^(see the note in README.md^).
echo If Libraries\ is a junction to the shared pool, editing a library file
echo here edits the pool - there is no separate copy to drift.
echo.
pause
exit /b 0

REM ---------------------------------------------------------------------------
REM  :CloneLib <folder-name> <github-repo-name>
REM ---------------------------------------------------------------------------
:CloneLib
if not exist "Libraries\%~1\.git" (
    echo Cloning %~1 into Libraries\ ...
    git clone https://github.com/NilsSve/%~2.git "Libraries\%~1"
    if errorlevel 1 (
        echo.
        echo [ERROR] Could not clone %~2.
        echo         Check your connection and that you can reach:
        echo           https://github.com/NilsSve/%~2.git
        echo.
        pause
        exit /b 1
    )
) else (
    echo Updating Libraries\%~1 ...
    git -C "Libraries\%~1" pull --ff-only
)
exit /b 0
