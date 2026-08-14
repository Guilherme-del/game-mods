<#
.SYNOPSIS
    Building & Automation modification module for Scratch the Ticket.
.DESCRIPTION
    Inspects and modifies building quantities in the game save file.
#>

$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
$coreGvasPath = Join-Path $scriptDirectory "..\..\Core\GvasHandler.psm1"
Import-Module $coreGvasPath -Force -DisableNameChecking

function Show-Menu {
    Clear-Host
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "    Buildings & Automation Mod (Império)  " -ForegroundColor White
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host ""
    
    Warn-IfGameRunning

    $buildings = Get-BuildingList
    if ($buildings.Count -eq 0) {
        Write-Host "Nenhuma construção encontrada no arquivo de save." -ForegroundColor Red
        return
    }

    Write-Host "=== Construções Atuais ===" -ForegroundColor Yellow
    $i = 1
    foreach ($b in $buildings) {
        $color = if ($b.Count -gt 0) { "Green" } else { "DarkGray" }
        Write-Host (" {0}. {1,-26} : {2} unidades" -f $i, $b.DisplayName, $b.Count) -ForegroundColor $color
        $i++
    }

    Write-Host ""
    Write-Host " A. Definir +50 em TODAS as construções"
    Write-Host " M. Império Máximo (+500 em TODAS as construções)"
    Write-Host " Z. Zerar todas as construções"
    Write-Host " B. Voltar ao Menu Principal"
    Write-Host ""

    $choice = Read-Host "Selecione o número da construção para editar ou uma opção (A/M/Z/B)"

    if ($choice.ToUpper() -eq 'B') {
        return
    } elseif ($choice.ToUpper() -eq 'A') {
        foreach ($b in $buildings) {
            Set-BuildingCount -BuildingKey $b.Key -NewCount ($b.Count + 50) | Out-Null
        }
        Write-Host "Adicionado +50 unidades a todas as construções!" -ForegroundColor Green
        return
    } elseif ($choice.ToUpper() -eq 'M') {
        foreach ($b in $buildings) {
            Set-BuildingCount -BuildingKey $b.Key -NewCount 500 | Out-Null
        }
        Write-Host "Todas as construções foram definidas para 500 unidades!" -ForegroundColor Green
        return
    } elseif ($choice.ToUpper() -eq 'Z') {
        foreach ($b in $buildings) {
            Set-BuildingCount -BuildingKey $b.Key -NewCount 0 | Out-Null
        }
        Write-Host "Todas as construções foram zeradas." -ForegroundColor Yellow
        return
    }

    try {
        $idx = [int]$choice - 1
        if ($idx -ge 0 -and $idx -lt $buildings.Count) {
            $selected = $buildings[$idx]
            $newVal = Read-Host "Digite a nova quantidade para '$($selected.DisplayName)'"
            if (-not [string]::IsNullOrWhiteSpace($newVal)) {
                $count = [int]$newVal
                Set-BuildingCount -BuildingKey $selected.Key -NewCount $count
            }
        }
    } catch {
        Write-Host "Entrada inválida." -ForegroundColor Red
    }
}

Export-ModuleMember -Function Show-Menu
