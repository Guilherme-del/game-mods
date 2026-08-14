@echo off
chcp 65001 >nul
title Scratch the Ticket - Mod Manager Suite
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "[Console]::OutputEncoding = [System.Text.Encoding]::UTF8; [Console]::InputEncoding = [System.Text.Encoding]::UTF8; $OutputEncoding = [System.Text.Encoding]::UTF8; & '%~dp0main.ps1'"
if %errorlevel% neq 0 (
    echo.
    echo Pressione qualquer tecla para sair...
    pause >nul
)
