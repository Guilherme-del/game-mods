<#
.SYNOPSIS
    Main Entry Point for "Repair This! Mod Manager"
#>

$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
$modulesPath = Join-Path $scriptDirectory "src\Modules"

function Show-MainMenu {
    Clear-Host
    Write-Host "=============================" -ForegroundColor Magenta
    Write-Host " Repair This! Mod Manager" -ForegroundColor White
    Write-Host "=============================" -ForegroundColor Magenta
    Write-Host ""
    
    # Dynamically find available modules
    $modules = Get-ChildItem -Path $modulesPath -Directory
    
    $i = 1
    foreach ($mod in $modules) {
        Write-Host "$i. $($mod.Name)"
        $i++
    }
    Write-Host "Q. Quit"
    Write-Host ""
    
    $selection = Read-Host "Select a module"
    
    if ($selection -eq 'Q' -or $selection -eq 'q') {
        exit
    }
    
    try {
        $index = [int]$selection - 1
        if ($index -ge 0 -and $index -lt $modules.Count) {
            $selectedMod = $modules[$index]
            $modScript = Join-Path $selectedMod.FullName "$($selectedMod.Name).psm1"
            
            if (Test-Path $modScript) {
                Import-Module $modScript -Force
                Show-Menu  # Assumes every module implements Show-Menu
                Pause
                Show-MainMenu
            } else {
                Write-Error "Module script not found: $modScript"
                Pause
                Show-MainMenu
            }
        }
    } catch {
        # Invalid input, just reload menu
        Show-MainMenu
    }
}

Show-MainMenu
