<#
.SYNOPSIS
    Unlock All module for Scratch the Ticket.
.DESCRIPTION
    Unlocks all cards, tickets, mini-games, and equipment.
#>

$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
$coreGvasPath = Join-Path $scriptDirectory "..\..\Core\GvasHandler.psm1"
Import-Module $coreGvasPath -Force -DisableNameChecking

function Show-Menu {
    Clear-Host
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "    Unlock All Mod (Desbloqueio Total)    " -ForegroundColor White
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host ""
    
    Warn-IfGameRunning

    Write-Host "Opções de Desbloqueio:" -ForegroundColor Yellow
    Write-Host " 1. Desbloquear TODOS os Bilhetes e Raspadinhas"
    Write-Host " 2. Desbloquear TODAS as Ferramentas (Lanterna, Microscópio, Frasco, Moeda)"
    Write-Host " 3. DESBLOQUEAR TUDO (Bilhetes + Ferramentas + Super Saldo + Spray)"
    Write-Host " B. Voltar ao Menu Principal"
    Write-Host ""

    $choice = Read-Host "Escolha uma opção"

    switch ($choice.ToUpper()) {
        "1" {
            Unlock-AllGameTickets | Out-Null
            Write-Host "Todos os bilhetes foram desbloqueados com sucesso!" -ForegroundColor Green
        }
        "2" {
            Set-GvasProperty -PropertyName "HasFlashlight" -NewValue $true | Out-Null
            Set-GvasProperty -PropertyName "HasMicroscope" -NewValue $true | Out-Null
            Set-GvasProperty -PropertyName "HasEtherCoin" -NewValue $true | Out-Null
            Set-GvasProperty -PropertyName "HasBottle" -NewValue $true | Out-Null
            Write-Host "Todas as ferramentas foram desbloqueadas com sucesso!" -ForegroundColor Green
        }
        "3" {
            Unlock-AllGameTickets | Out-Null
            Set-GvasProperty -PropertyName "HasFlashlight" -NewValue $true | Out-Null
            Set-GvasProperty -PropertyName "HasMicroscope" -NewValue $true | Out-Null
            Set-GvasProperty -PropertyName "HasEtherCoin" -NewValue $true | Out-Null
            Set-GvasProperty -PropertyName "HasBottle" -NewValue $true | Out-Null
            Set-GvasProperty -PropertyName "BottleLiquidVolume" -NewValue ([double]999999.0) | Out-Null
            Set-GvasProperty -PropertyName "Current Money" -NewValue ([double]1000000000000.0) | Out-Null
            Write-Host "DESBLOQUEIO TOTAL APLICADO COM SUCESSO!" -ForegroundColor Green
        }
        "B" {
            return
        }
    }
}

Export-ModuleMember -Function Show-Menu
