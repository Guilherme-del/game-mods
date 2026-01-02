<#
.SYNOPSIS
    Money modification module.
.DESCRIPTION
    Uses the Core RegistryHandler to modify the PlayerMoney value.
#>

# Import Core Module (Adjust path relative to this file)
$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
$corePath = Join-Path $scriptDirectory "..\..\Core\RegistryHandler.psm1"
Import-Module $corePath -Force

function Show-Menu {
    Write-Host "=== Money Mod ===" -ForegroundColor Cyan
    
    $moneyData = Get-GameValue -KeyPattern "PlayerMoney"
    
    if ($null -eq $moneyData) {
        Write-Host "Could not find PlayerMoney data." -ForegroundColor Red
        return
    }

    Write-Host "Current Money: $($moneyData.Value)" -ForegroundColor Yellow
    Write-Host ""
    
    $newValue = Read-Host "Enter new money amount (or press Enter to cancel)"
    
    if (-not [string]::IsNullOrWhiteSpace($newValue)) {
        try {
            $intVal = [int]$newValue
            Set-GameValue -KeyPattern "PlayerMoney" -NewValue $intVal
        }
        catch {
            Write-Host "Invalid number input." -ForegroundColor Red
        }
    }
}

Export-ModuleMember -Function Show-Menu
