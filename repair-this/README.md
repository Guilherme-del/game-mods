# Repair This! Mod Manager

A simple PowerShell-based mod manager for the game **Repair This!**.
This tool allows you to modify your in-game Money and Stock quantities by editing the game's registry values.

## Features

- **Money Mod**: View and edit your current Player Money.
- **Stock Mod**:
    - View all current stock items.
    - Set ALL stock items to a specific quantity at once.
    - Edit individual stock items by key name.

## Prerequisites

- **Windows OS**: This mod is designed for Windows.
- **PowerShell**: Pre-installed on most Windows systems.
- **The Game**: "Repair This!" must be installed and run at least once to generate the registry keys.

## How to Use

1. **Download/Extract** the mod files to a folder of your choice.
2. Double-click **`Run_Mod.bat`** to start the Mod Manager.
3. Follow the on-screen menu:
    - Select **1** for Money Mod.
    - Select **2** for Stock Mod.
    - Select **Q** to Quit.

## Troubleshooting

- **"Module script not found"**: Ensure the `src` folder is in the same directory as `main.ps1`.
- **"Game registry path not found"**: Make sure you have run the game at least once so it creates the necessary registry keys (`HKCU:\Software\DefaultCompany\Repair, This!`).
- **Permissions**: If the script closes immediately or says "Access Denied", try running `Run_Mod.bat` as Administrator, although it attempts to bypass execution policy automatically.

## Disclaimer

Use this mod at your own risk. Always backup your save data (or remember your previous values) before making drastic changes.
