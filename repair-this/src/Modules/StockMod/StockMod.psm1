<#
.SYNOPSIS
    Stock modification module.
.DESCRIPTION
    Allows editing of 'StockModel' registry keys.
#>

# Import Core Module
$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
$corePath = Join-Path $scriptDirectory "..\..\Core\RegistryHandler.psm1"
Import-Module $corePath -Force

function Show-Menu {
    while ($true) {
        Clear-Host
        Write-Host "=== Stock Mod ===" -ForegroundColor Cyan
        
        $stocks = Get-GameValues -KeyPattern "StockModel"
        
        if ($stocks.Count -eq 0) {
            Write-Host "No StockModel keys found." -ForegroundColor Red
            Pause
            return
        }

        # Sort nicely (A0-A5, M0-M5, S0-S5)
        $stocks = $stocks | Sort-Object KeyName

        Write-Host "Found $($stocks.Count) stock items." -ForegroundColor Gray
        Write-Host "Current Values:"
        $stocks | ForEach-Object { Write-Host "  $($_.KeyName): $($_.Value)" -ForegroundColor Gray }
        
        Write-Host ""
        Write-Host "1. Set ALL Stocks to a value"
        Write-Host "2. Edit a Specific Stock item"
        Write-Host "B. Back"
        Write-Host ""
        
        $choice = Read-Host "Select an option"
        
        switch ($choice) {
            '1' {
                $val = Read-Host "Enter new quantity for ALL stocks"
                if ($val -match '^\d+$') {
                    foreach ($s in $stocks) {
                        Set-GameValue -KeyPattern $s.KeyName -NewValue ([int]$val)
                    }
                    Write-Host "Update Complete!" -ForegroundColor Green
                    Pause
                }
            }
            '2' {
                $itemKey = Read-Host "Enter the exact Key Name (e.g. StockModelA0)"
                # Basic check if it exists in our list
                $exists = $stocks | Where-Object { $_.KeyName -like "$itemKey*" }
                if ($exists) {
                    $val = Read-Host "Enter new quantity"
                    if ($val -match '^\d+$') {
                        Set-GameValue -KeyPattern $itemKey -NewValue ([int]$val)
                        Pause
                    }
                }
                else {
                    Write-Host "Item not found." -ForegroundColor Red
                    Pause
                }
            }
            'B' { return }
            'b' { return }
        }
    }
}

Export-ModuleMember -Function Show-Menu
