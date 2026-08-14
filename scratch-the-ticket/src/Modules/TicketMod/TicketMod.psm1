<#
.SYNOPSIS
    Ticket Level & Multiplier Modification Module for Scratch the Ticket.
.DESCRIPTION
    Inspects and customizes ticket level multipliers in the game save file.
#>

$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
$coreGvasPath = Join-Path $scriptDirectory "..\..\Core\GvasHandler.psm1"
Import-Module $coreGvasPath -Force -DisableNameChecking

function Show-Menu {
    Clear-Host
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "   Ticket Level & Multipliers Mod         " -ForegroundColor White
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host ""
    
    Warn-IfGameRunning

    $tickets = Get-TicketLevelsList
    if ($tickets.Count -eq 0) {
        Write-Host "Nenhum bilhete encontrado no arquivo de save." -ForegroundColor Red
        return
    }

    Write-Host "=== Bilhetes e Multiplicadores Atuais ===" -ForegroundColor Yellow
    $i = 1
    foreach ($t in $tickets) {
        $color = if ($t.Level -gt 0) { "Green" } else { "DarkGray" }
        Write-Host (" {0,2}. {1,-34} : Nível {2}" -f $i, $t.DisplayName, $t.Level) -ForegroundColor $color
        $i++
    }

    Write-Host ""
    Write-Host " A. Definir TODOS os Bilhetes para Nível 50"
    Write-Host " M. Nível MÁXIMO em TODOS os Bilhetes (Nível 500)"
    Write-Host " B. Voltar ao Menu Principal"
    Write-Host ""

    $choice = Read-Host "Selecione o número do bilhete para editar ou uma opção (A/M/B)"

    if ($choice.ToUpper() -eq 'B') {
        return
    } elseif ($choice.ToUpper() -eq 'A') {
        foreach ($t in $tickets) {
            Set-TicketLevelValue -Blueprint $t.Blueprint -NewLevel 50.0 | Out-Null
        }
        Write-Host "Todos os bilhetes foram definidos para o Nível 50!" -ForegroundColor Green
        return
    } elseif ($choice.ToUpper() -eq 'M') {
        foreach ($t in $tickets) {
            Set-TicketLevelValue -Blueprint $t.Blueprint -NewLevel 500.0 | Out-Null
        }
        Write-Host "Todos os bilhetes foram definidos para o Nível 500 (Máximo)!" -ForegroundColor Green
        return
    }

    try {
        $idx = [int]$choice - 1
        if ($idx -ge 0 -and $idx -lt $tickets.Count) {
            $selected = $tickets[$idx]
            $newVal = Read-Host "Digite o novo nível para '$($selected.DisplayName)'"
            if (-not [string]::IsNullOrWhiteSpace($newVal)) {
                $lvl = [double]$newVal
                Set-TicketLevelValue -Blueprint $selected.Blueprint -NewLevel $lvl
            }
        }
    } catch {
        Write-Host "Entrada inválida." -ForegroundColor Red
    }
}

Export-ModuleMember -Function Show-Menu
