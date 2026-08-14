<#
.SYNOPSIS
    Main Entry Point for "Scratch the Ticket" Mod Manager
.DESCRIPTION
    Interactive CLI Mod Manager for Scratch the Ticket (Unreal Engine 5.7).
#>

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding  = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
$modulesPath = Join-Path $scriptDirectory "src\Modules"
$coreGvasPath = Join-Path $scriptDirectory "src\Core\GvasHandler.psm1"

if (Test-Path $coreGvasPath) {
    Import-Module $coreGvasPath -Force -DisableNameChecking
}

function Show-MainMenu {
    Clear-Host
    Write-Host "==========================================================" -ForegroundColor Magenta
    Write-Host "        Scratch the Ticket - Mod Manager Suite            " -ForegroundColor White
    Write-Host "==========================================================" -ForegroundColor Magenta
    
    $isGameRunning = Test-GameRunning
    if ($isGameRunning) {
        Write-Host " [Status do Jogo] EM EXECUÇÃO (Online / Aberto)" -ForegroundColor Green
        Write-Host " (Dica: Feche o jogo com a opção 'K' antes de modificar o save!)" -ForegroundColor Yellow
    } else {
        Write-Host " [Status do Jogo] Fechado / Pronto para Modificar" -ForegroundColor Cyan
    }
    Write-Host "----------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host ""

    # Dynamically find available modules
    $modules = Get-ChildItem -Path $modulesPath -Directory

    $i = 1
    foreach ($mod in $modules) {
        $displayName = switch ($mod.Name) {
            "MoneyMod"        { "Dinheiro & Saldo (Money Mod)" }
            "BottleMod"       { "Frasco & Spray Raspador (Bottle Mod)" }
            "ToolUnlockerMod" { "Ferramentas Especiais (Lanterna, Microscópio, Moeda)" }
            "BuildingMod"     { "Construções & Automação (Império)" }
            "TicketMod"       { "Níveis & Multiplicadores de Bilhetes" }
            "UnlockAllMod"    { "Desbloquear Tudo (Full Unlocker)" }
            "SaveBackupMod"   { "Gerenciador de Backups & Restauração" }
            default           { $mod.Name }
        }
        Write-Host (" {0,2}. {1}" -f $i, $displayName)
        $i++
    }
    Write-Host ""
    Write-Host "----------------------------------------------------------" -ForegroundColor DarkGray
    if ($isGameRunning) {
        Write-Host "  K. Fechar Jogo Agora (Garante que as alterações sejam aplicadas)" -ForegroundColor Yellow
    } else {
        Write-Host "  L. Iniciar Jogo pela Steam (Launch Game)" -ForegroundColor Cyan
    }
    Write-Host "  Q. Sair (Quit)"
    Write-Host ""

    $selection = Read-Host "Selecione uma opção"

    if ($selection.ToUpper() -eq 'Q') {
        Clear-Host
        Write-Host "Até a próxima! Bom jogo!" -ForegroundColor Cyan
        exit
    } elseif ($selection.ToUpper() -eq 'K') {
        Stop-GameProcess | Out-Null
        Start-Sleep -Milliseconds 600
        Show-MainMenu
        return
    } elseif ($selection.ToUpper() -eq 'L') {
        Start-GameProcess | Out-Null
        Start-Sleep -Milliseconds 600
        Show-MainMenu
        return
    }

    try {
        $index = [int]$selection - 1
        if ($index -ge 0 -and $index -lt $modules.Count) {
            $selectedMod = $modules[$index]
            $modScript = Join-Path $selectedMod.FullName "$($selectedMod.Name).psm1"

            if (Test-Path $modScript) {
                Import-Module $modScript -Force -DisableNameChecking
                Show-Menu
                Write-Host ""
                Write-Host "Pressione qualquer tecla para continuar..." -ForegroundColor DarkGray
                $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                Show-MainMenu
            } else {
                Write-Error "Script do módulo não encontrado: $modScript"
                Pause
                Show-MainMenu
            }
        } else {
            Show-MainMenu
        }
    } catch {
        Show-MainMenu
    }
}

Show-MainMenu
