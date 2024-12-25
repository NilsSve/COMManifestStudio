@echo off
xcopy Data_backup\* Data\ /E /H /C /I
echo Data files restored.