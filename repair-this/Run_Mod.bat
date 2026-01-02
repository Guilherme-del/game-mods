@echo off
REM Launcher for Repair This! Mod Manager
REM Bypasses PowerShell Execution Policy for this session strictly

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0main.ps1"
