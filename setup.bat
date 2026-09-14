@echo off
setlocal

REM ===========================================================================
REM  COMManifestStudio - optional setup, for people who will COMMIT here
REM
REM  THERE IS NOTHING TO FETCH. This is a DataFlex 26 workspace, and every
REM  library it uses - Filesystem, DUF, DFAbout, RDCToolsLib and vwin32fh - is
REM  a dependency of COMManifestStudio.sws, pinned by commit in
REM  COMManifestStudio.sws.lock. The Studio fetches them into DfPkg\ the first
REM  time it opens the workspace. Open COMManifestStudio.sws and build; if you
REM  only want to run the program, you can stop reading here.
REM
REM  What this script still does matters only if you intend to commit. The repo
REM  ships an empty baseline database as real files under Data\, so git tracks
REM  them, and your own database edits would otherwise turn up in git status and
REM  could be pushed. skip-local-data.cmd tells git to ignore your copies.
REM ===========================================================================

cd /d "%~dp0"

echo.
echo === COMManifestStudio setup ===
echo Working folder: %CD%
echo.
echo The libraries need nothing from this script - the Studio fetches them into
echo DfPkg\ when it opens COMManifestStudio.sws.
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

if exist "%~dp0skip-local-data.cmd" (
    echo Protecting your local Data\ database from accidental commits...
    call "%~dp0skip-local-data.cmd"
) else (
    echo [NOTE] skip-local-data.cmd not found - skipping local DB protection.
)

echo.
echo === Setup complete ===
echo.
echo Open COMManifestStudio.sws in the Studio and build. Remember to compile as
echo 32-bit ^(see the note in README.md^).
echo.
pause
exit /b 0
