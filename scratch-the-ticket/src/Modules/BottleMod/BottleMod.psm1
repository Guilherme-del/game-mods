<#
.SYNOPSIS
    Bottle / Scratch Spray modification module for Scratch the Ticket.
.DESCRIPTION
    Modifies 'HasBottle' and 'BottleLiquidVolume' in the game save file.
#>

$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
$coreGvasPath = Join-Path $scriptDirectory "..\..\Core\GvasHandler.psm1"
Import-Module $coreGvasPath -Force -DisableNameChecking

function Show-Menu {
    Clear-Host
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "     Scratch the Ticket - Bottle Mod      " -ForegroundColor White
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host ""
    
    Warn-IfGameRunning

    $hasBottle = Get-GvasProperty -PropertyName "HasBottle"
    $bottleVolume = Get-GvasProperty -PropertyName "BottleLiquidVolume"

    $bottleStatus = if ($hasBottle.Value) { "Desbloqueado" } else { "Bloqueado" }
    Write-Host " Status do Frasco: $bottleStatus" -ForegroundColor Yellow
    Write-Host " Volume do Líquido: $($bottleVolume.Value)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host " 1. Desbloquear Frasco de Spray (HasBottle = True)"
    Write-Host " 2. Encher Spray (Volume = 100)"
    Write-Host " 3. Super Carga de Spray (Volume = 10.000)"
    Write-Host " 4. Spray Quase Infinito (Volume = 999.999)"
    Write-Host " 5. Definir volume personalizado"
    Write-Host " 6. Desbloquear Frasco + Super Carga (Tudo em 1 clique)"
    Write-Host " B. Voltar ao Menu Principal"
    Write-Host ""

    $choice = Read-Host "Escolha uma opção"

    switch ($choice.ToUpper()) {
        "1" {
            Set-GvasProperty -PropertyName "HasBottle" -NewValue $true
        }
        "2" {
            Set-GvasProperty -PropertyName "BottleLiquidVolume" -NewValue ([double]100.0)
        }
        "3" {
            Set-GvasProperty -PropertyName "BottleLiquidVolume" -NewValue ([double]10000.0)
        }
        "4" {
            Set-GvasProperty -PropertyName "BottleLiquidVolume" -NewValue ([double]999999.0)
        }
        "5" {
            $inputVal = Read-Host "Digite o volume desejado"
            if (-not [string]::IsNullOrWhiteSpace($inputVal)) {
                try {
                    $newVol = [double]$inputVal
                    Set-GvasProperty -PropertyName "BottleLiquidVolume" -NewValue $newVol
                } catch {
                    Write-Host "Valor numérico inválido." -ForegroundColor Red
                }
            }
        }
        "6" {
            Set-GvasProperty -PropertyName "HasBottle" -NewValue $true
            Set-GvasProperty -PropertyName "BottleLiquidVolume" -NewValue ([double]999999.0)
            Write-Host "Frasco desbloqueado e abastecido com sucesso!" -ForegroundColor Green
        }
        "B" {
            return
        }
    }
}

Export-ModuleMember -Function Show-Menu
