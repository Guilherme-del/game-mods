<#
.SYNOPSIS
    Tool & Equipment Unlocker Module for Scratch the Ticket.
.DESCRIPTION
    Unlocks special tools: Flashlight, Microscope, Ether Coin, and Bottle.
#>

$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
$coreGvasPath = Join-Path $scriptDirectory "..\..\Core\GvasHandler.psm1"
Import-Module $coreGvasPath -Force -DisableNameChecking

function Show-Menu {
    Clear-Host
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "     Tool & Equipment Unlocker Mod        " -ForegroundColor White
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host ""
    
    Warn-IfGameRunning

    $tools = @(
        @{ Key = "HasFlashlight";  Name = "Lanterna (Flashlight)" },
        @{ Key = "HasMicroscope";  Name = "Microscópio (Microscope)" },
        @{ Key = "HasEtherCoin";   Name = "Moeda de Éter (Ether Coin)" },
        @{ Key = "HasBottle";      Name = "Frasco de Spray (Bottle)" }
    )

    Write-Host "=== Status Atual das Ferramentas ===" -ForegroundColor Yellow
    foreach ($t in $tools) {
        $prop = Get-GvasProperty -PropertyName $t.Key
        $status = if ($prop.Value) { "[ DESBLOQUEADO ]" } else { "[ BLOQUEADO ]" }
        $color = if ($prop.Value) { "Green" } else { "DarkGray" }
        Write-Host (" {0,-32} : {1}" -f $t.Name, $status) -ForegroundColor $color
    }

    Write-Host ""
    Write-Host " 1. Alternar / Desbloquear Lanterna"
    Write-Host " 2. Alternar / Desbloquear Microscópio"
    Write-Host " 3. Alternar / Desbloquear Moeda de Éter"
    Write-Host " 4. Alternar / Desbloquear Frasco de Spray"
    Write-Host " 5. Desbloquear TODAS as Ferramentas (1 Clique)"
    Write-Host " B. Voltar ao Menu Principal"
    Write-Host ""

    $choice = Read-Host "Escolha uma opção"

    switch ($choice.ToUpper()) {
        "1" {
            $cur = Get-GvasProperty -PropertyName "HasFlashlight"
            Set-GvasProperty -PropertyName "HasFlashlight" -NewValue (-not $cur.Value)
        }
        "2" {
            $cur = Get-GvasProperty -PropertyName "HasMicroscope"
            Set-GvasProperty -PropertyName "HasMicroscope" -NewValue (-not $cur.Value)
        }
        "3" {
            $cur = Get-GvasProperty -PropertyName "HasEtherCoin"
            Set-GvasProperty -PropertyName "HasEtherCoin" -NewValue (-not $cur.Value)
        }
        "4" {
            $cur = Get-GvasProperty -PropertyName "HasBottle"
            Set-GvasProperty -PropertyName "HasBottle" -NewValue (-not $cur.Value)
        }
        "5" {
            Set-GvasProperty -PropertyName "HasFlashlight" -NewValue $true
            Set-GvasProperty -PropertyName "HasMicroscope" -NewValue $true
            Set-GvasProperty -PropertyName "HasEtherCoin" -NewValue $true
            Set-GvasProperty -PropertyName "HasBottle" -NewValue $true
            Write-Host "Todas as ferramentas foram desbloqueadas com sucesso!" -ForegroundColor Green
        }
        "B" {
            return
        }
    }
}

Export-ModuleMember -Function Show-Menu
