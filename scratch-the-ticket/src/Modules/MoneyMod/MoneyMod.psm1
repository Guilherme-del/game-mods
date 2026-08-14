<#
.SYNOPSIS
    Money modification module for Scratch the Ticket.
.DESCRIPTION
    Reads and modifies the 'Current Money' property in the game save file,
    focusing on diverse and granular options to add to current balance.
#>

$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
$coreGvasPath = Join-Path $scriptDirectory "..\..\Core\GvasHandler.psm1"
Import-Module $coreGvasPath -Force -DisableNameChecking

function Show-FixedMenu {
    Clear-Host
    Write-Host "==========================================================" -ForegroundColor Cyan
    Write-Host "         Definir Saldo Fixo (Substituir Valor)            " -ForegroundColor White
    Write-Host "==========================================================" -ForegroundColor Cyan
    Write-Host ""
    
    $moneyData = Get-GvasProperty -PropertyName "Current Money"
    $formattedMoney = "{0:N2}" -f $moneyData.Value
    Write-Host " Saldo Atual: $formattedMoney" -ForegroundColor Yellow
    Write-Host ""

    Write-Host " 1. Definir para $1.000.000 (1 Mi)"
    Write-Host " 2. Definir para $10.000.000 (10 Mi)"
    Write-Host " 3. Definir para $100.000.000 (100 Mi)"
    Write-Host " 4. Definir para $1.000.000.000 (1 Bi)"
    Write-Host " 5. Definir para $10.000.000.000 (10 Bi)"
    Write-Host " 6. Definir para $100.000.000.000 (100 Bi)"
    Write-Host " 7. Definir para $1.000.000.000.000 (1 Tri)"
    Write-Host " 8. Definir para $10.000.000.000.000 (10 Tri)"
    Write-Host " 9. Definir para $100.000.000.000.000 (100 Tri)"
    Write-Host " C. Digitar valor personalizado"
    Write-Host " V. Voltar"
    Write-Host ""

    $fChoice = Read-Host "Escolha uma opção"
    switch ($fChoice.ToUpper()) {
        "1" { Set-GvasProperty -PropertyName "Current Money" -NewValue 1000000.0 }
        "2" { Set-GvasProperty -PropertyName "Current Money" -NewValue 10000000.0 }
        "3" { Set-GvasProperty -PropertyName "Current Money" -NewValue 100000000.0 }
        "4" { Set-GvasProperty -PropertyName "Current Money" -NewValue 1000000000.0 }
        "5" { Set-GvasProperty -PropertyName "Current Money" -NewValue 10000000000.0 }
        "6" { Set-GvasProperty -PropertyName "Current Money" -NewValue 100000000000.0 }
        "7" { Set-GvasProperty -PropertyName "Current Money" -NewValue 1000000000000.0 }
        "8" { Set-GvasProperty -PropertyName "Current Money" -NewValue 10000000000000.0 }
        "9" { Set-GvasProperty -PropertyName "Current Money" -NewValue 100000000000000.0 }
        "C" {
            $inputVal = Read-Host "Digite a nova quantia de dinheiro desejada"
            if (-not [string]::IsNullOrWhiteSpace($inputVal)) {
                try {
                    $newMoney = [double]$inputVal
                    Set-GvasProperty -PropertyName "Current Money" -NewValue $newMoney
                } catch {
                    Write-Host "Valor numérico inválido." -ForegroundColor Red
                }
            }
        }
        "V" { return }
    }
}

function Show-Menu {
    Clear-Host
    Write-Host "==========================================================" -ForegroundColor Cyan
    Write-Host "            Scratch the Ticket - Money Mod                " -ForegroundColor White
    Write-Host "==========================================================" -ForegroundColor Cyan
    Write-Host ""
    
    Warn-IfGameRunning

    $moneyData = Get-GvasProperty -PropertyName "Current Money"
    if ($null -eq $moneyData) {
        Write-Host "Erro: Não foi possível localizar 'Current Money' no arquivo de save." -ForegroundColor Red
        return
    }

    $formattedMoney = "{0:N2}" -f $moneyData.Value
    Write-Host " Saldo Atual: $formattedMoney" -ForegroundColor Yellow
    Write-Host ""

    Write-Host "--- [ ➕ SOMAR MILHÕES (+Mi) ] ----------------------------" -ForegroundColor Green
    Write-Host "  1. Somar +$1.000.000       (+1 Mi)"
    Write-Host "  2. Somar +$5.000.000       (+5 Mi)"
    Write-Host "  3. Somar +$10.000.000      (+10 Mi)"
    Write-Host "  4. Somar +$50.000.000      (+50 Mi)"
    Write-Host "  5. Somar +$100.000.000     (+100 Mi)"
    Write-Host "  6. Somar +$500.000.000     (+500 Mi)"
    Write-Host ""

    Write-Host "--- [ 💎 SOMAR BILHÕES (+Bi) ] ----------------------------" -ForegroundColor Cyan
    Write-Host "  7. Somar +$1.000.000.000   (+1 Bi)"
    Write-Host "  8. Somar +$5.000.000.000   (+5 Bi)"
    Write-Host "  9. Somar +$10.000.000.000  (+10 Bi)"
    Write-Host " 10. Somar +$50.000.000.000  (+50 Bi)"
    Write-Host " 11. Somar +$100.000.000.000 (+100 Bi)"
    Write-Host " 12. Somar +$500.000.000.000 (+500 Bi)"
    Write-Host ""

    Write-Host "--- [ 🚀 SOMAR TRILHÕES (+Tri) ] --------------------------" -ForegroundColor Magenta
    Write-Host " 13. Somar +$1.000.000.000.000   (+1 Tri)"
    Write-Host " 14. Somar +$10.000.000.000.000  (+10 Tri)"
    Write-Host " 15. Somar +$50.000.000.000.000  (+50 Tri)"
    Write-Host " 16. Somar +$100.000.000.000.000 (+100 Tri)"
    Write-Host ""

    Write-Host "--- [ ⚡ MULTIPLICADORES & SOMAR PERSONALIZADO ] ----------" -ForegroundColor DarkYellow
    Write-Host "  S. Somar quantia personalizada (+X)"
    Write-Host " 2X. Dobrar saldo atual (x2)"
    Write-Host "10X. Multiplicar saldo atual por 10 (x10)"
    Write-Host ""

    Write-Host "--- [ 🎯 DEFINIR SALDO FIXO & OUTROS ] --------------------" -ForegroundColor Gray
    Write-Host "  F. Menu de Definir Saldo Fixo"
    Write-Host "  M. Saldo MÁXIMO ($999 Trilhões)"
    Write-Host "  Z. Zerar saldo ($0)"
    Write-Host "  B. Voltar ao Menu Principal"
    Write-Host ""

    $choice = Read-Host "Escolha uma opção"

    switch ($choice.ToUpper()) {
        # Milhões
        "1"  { Set-GvasProperty -PropertyName "Current Money" -NewValue ($moneyData.Value + 1000000.0) }
        "2"  { Set-GvasProperty -PropertyName "Current Money" -NewValue ($moneyData.Value + 5000000.0) }
        "3"  { Set-GvasProperty -PropertyName "Current Money" -NewValue ($moneyData.Value + 10000000.0) }
        "4"  { Set-GvasProperty -PropertyName "Current Money" -NewValue ($moneyData.Value + 50000000.0) }
        "5"  { Set-GvasProperty -PropertyName "Current Money" -NewValue ($moneyData.Value + 100000000.0) }
        "6"  { Set-GvasProperty -PropertyName "Current Money" -NewValue ($moneyData.Value + 500000000.0) }

        # Bilhões
        "7"  { Set-GvasProperty -PropertyName "Current Money" -NewValue ($moneyData.Value + 1000000000.0) }
        "8"  { Set-GvasProperty -PropertyName "Current Money" -NewValue ($moneyData.Value + 5000000000.0) }
        "9"  { Set-GvasProperty -PropertyName "Current Money" -NewValue ($moneyData.Value + 10000000000.0) }
        "10" { Set-GvasProperty -PropertyName "Current Money" -NewValue ($moneyData.Value + 50000000000.0) }
        "11" { Set-GvasProperty -PropertyName "Current Money" -NewValue ($moneyData.Value + 100000000000.0) }
        "12" { Set-GvasProperty -PropertyName "Current Money" -NewValue ($moneyData.Value + 500000000000.0) }

        # Trilhões
        "13" { Set-GvasProperty -PropertyName "Current Money" -NewValue ($moneyData.Value + 1000000000000.0) }
        "14" { Set-GvasProperty -PropertyName "Current Money" -NewValue ($moneyData.Value + 10000000000000.0) }
        "15" { Set-GvasProperty -PropertyName "Current Money" -NewValue ($moneyData.Value + 50000000000000.0) }
        "16" { Set-GvasProperty -PropertyName "Current Money" -NewValue ($moneyData.Value + 100000000000000.0) }

        # Multiplicadores e personalizado
        "S" {
            $inputVal = Read-Host "Digite a quantia que deseja SOMAR ao saldo atual"
            if (-not [string]::IsNullOrWhiteSpace($inputVal)) {
                try {
                    $toAdd = [double]$inputVal
                    $newMoney = $moneyData.Value + $toAdd
                    Set-GvasProperty -PropertyName "Current Money" -NewValue $newMoney
                } catch {
                    Write-Host "Valor numérico inválido." -ForegroundColor Red
                }
            }
        }
        "2X" {
            $newMoney = $moneyData.Value * 2.0
            Set-GvasProperty -PropertyName "Current Money" -NewValue $newMoney
        }
        "10X" {
            $newMoney = $moneyData.Value * 10.0
            Set-GvasProperty -PropertyName "Current Money" -NewValue $newMoney
        }

        # Fixos e Extras
        "F" {
            Show-FixedMenu
        }
        "M" {
            Set-GvasProperty -PropertyName "Current Money" -NewValue 999999999999999.0
        }
        "Z" {
            Set-GvasProperty -PropertyName "Current Money" -NewValue 0.0
        }
        "B" {
            return
        }
    }
}

Export-ModuleMember -Function Show-Menu
