@echo off
setlocal enabledelayedexpansion

REM ===========================================================================
REM  COMManifestStudio - one-time setup
REM
REM  The libraries this workspace needs are NOT stored in this repository (see
REM  .gitignore). This script provides them, and it behaves differently by
REM  machine so that one arrangement serves both maintainer and user:
REM
REM    * If a shared RDC library pool sits next to this workspace (a sibling
REM      ..\Libraries folder carrying the marker file .rdc-library-pool), it
REM      makes Libraries\ a JUNCTION to that pool. One shared, editable copy:
REM      a fix made in a library here is a fix in the pool.
REM
REM    * Otherwise it CLONES the libraries it needs (Filesystem,
REM      DUF, DFAbout, RDCToolsLib, vwin32fh) into this workspace's own
REM      Libraries\ folder - isolated, self-contained, and it never writes
REM      anywhere outside this workspace, so it cannot disturb libraries you
REM      already have elsewhere. DUF is cloned from Library-DUF (the current
REM      framework repo; the old DbUpdateFramework repo is superseded by it).
REM
REM  Note: DFAbout, RDCToolsLib and vwin32fh used to be reached through DUF's
REM  own nested Libraries\ folder. DUF no longer nests them, so this workspace
REM  declares all six as flat siblings - which is what its source has always
REM  used anyway (cRDC* classes, vWin32fh.pkg and the About dialog).
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
    REM No shared pool. Clone the flat library set into this workspace's own
    REM Libraries\ - never writes outside this workspace. Note the folder name
    REM and the repo name differ for Filesystem (repo is Library-cFilesystem).
    call :CloneLib Filesystem   Library-cFilesystem
    call :CloneLib DUF          Library-DUF
    call :CloneLib DFAbout      Library-DFAbout
    call :CloneLib RDCToolsLib  Library-RDCToolsLib
    call :CloneLib vwin32fh     Library-vwin32fh
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
echo Libraries\ is ready. Open COMManifestStudio25.0.sws in the Studio and
echo build. Remember to compile as 32-bit ^(see the note in README.md^).
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
