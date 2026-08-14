<#
.SYNOPSIS
    Save Game Backup & Restore Manager for Scratch the Ticket.
.DESCRIPTION
    Provides snapshot creation, listing, and one-click rollback for game saves.
#>

$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
$coreBackupPath = Join-Path $scriptDirectory "..\..\Core\BackupManager.psm1"
Import-Module $coreBackupPath -Force -DisableNameChecking

function Show-Menu {
    Clear-Host
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "     Save Game Backup & Restore Mod       " -ForegroundColor White
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host ""

    $backups = Get-SaveBackups

    Write-Host "=== Backups Disponíveis ===" -ForegroundColor Yellow
    if ($backups.Count -eq 0) {
        Write-Host " (Nenhum backup encontrado no momento)" -ForegroundColor DarkGray
    } else {
        $i = 1
        foreach ($b in $backups | Select-Object -First 10) {
            Write-Host (" {0,2}. {1} ({2:N0} KB - {3})" -f $i, $b.Name, ($b.Length / 1KB), $b.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss"))
            $i++
        }
    }

    Write-Host ""
    Write-Host " C. Criar Novo Ponto de Backup (Manual)"
    Write-Host " S. Criar Snapshot Completo de Todos os Saves"
    Write-Host " R. Restaurar um Backup da lista"
    Write-Host " O. Abrir pasta de backups no Windows Explorer"
    Write-Host " B. Voltar ao Menu Principal"
    Write-Host ""

    $choice = Read-Host "Escolha uma opção"

    switch ($choice.ToUpper()) {
        "C" {
            $reason = Read-Host "Digite uma descrição/motivo para o backup (opcional)"
            if ([string]::IsNullOrWhiteSpace($reason)) { $reason = "Manual" }
            Create-SaveBackup -Reason $reason | Out-Null
            Write-Host "Backup criado com sucesso!" -ForegroundColor Green
        }
        "S" {
            Backup-AllSaves -Reason "ManualSnapshot" | Out-Null
            Write-Host "Snapshot completo de todos os saves criado!" -ForegroundColor Green
        }
        "R" {
            if ($backups.Count -eq 0) {
                Write-Host "Nenhum backup disponível para restauração." -ForegroundColor Red
                return
            }
            $num = Read-Host "Digite o número do backup que deseja restaurar"
            try {
                $idx = [int]$num - 1
                if ($idx -ge 0 -and $idx -lt $backups.Count) {
                    $selected = $backups[$idx]
                    $confirm = Read-Host "Tem certeza que deseja restaurar '$($selected.Name)'? (S/N)"
                    if ($confirm.ToUpper() -eq 'S') {
                        Restore-SaveBackup -BackupFilePath $selected.FullName | Out-Null
                    }
                }
            } catch {
                Write-Host "Entrada inválida." -ForegroundColor Red
            }
        }
        "O" {
            $saveDir = Join-Path $env:LOCALAPPDATA "LotteryTicket\Saved\SaveGames\ModBackups"
            if (Test-Path $saveDir) {
                Start-Process "explorer.exe" $saveDir
            }
        }
        "B" {
            return
        }
    }
}

Export-ModuleMember -Function Show-Menu
