<#
.SYNOPSIS
    Backup and restore management for Scratch the Ticket save games.
#>

$saveDirectory = Join-Path $env:LOCALAPPDATA "LotteryTicket\Saved\SaveGames"
$backupDirectory = Join-Path $saveDirectory "ModBackups"

function Ensure-BackupDirectory {
    if (-not (Test-Path $backupDirectory)) {
        New-Item -ItemType Directory -Path $backupDirectory -Force | Out-Null
    }
}

function Create-SaveBackup {
    param (
        [string]$TargetSaveName = "SaveGameDefault_Release.sav",
        [string]$Reason = "Auto"
    )

    Ensure-BackupDirectory

    $savePath = Join-Path $saveDirectory $TargetSaveName
    if (-not (Test-Path $savePath)) {
        Write-Warning "Save file not found at: $savePath"
        return $null
    }

    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($TargetSaveName)
    $backupFileName = "${baseName}_${timestamp}_${Reason}.sav.bak"
    $backupPath = Join-Path $backupDirectory $backupFileName

    Copy-Item -Path $savePath -Destination $backupPath -Force
    Write-Host "[Backup] Backup created successfully: $backupFileName" -ForegroundColor Green
    return $backupPath
}

function Backup-AllSaves {
    param (
        [string]$Reason = "FullSnapshot"
    )

    Ensure-BackupDirectory

    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $snapshotDir = Join-Path $backupDirectory "Snapshot_${timestamp}_${Reason}"
    New-Item -ItemType Directory -Path $snapshotDir -Force | Out-Null

    $savFiles = Get-ChildItem -Path $saveDirectory -Filter "*.sav" -File
    foreach ($file in $savFiles) {
        Copy-Item -Path $file.FullName -Destination $snapshotDir -Force
    }

    Write-Host "[Backup] Full save snapshot saved to: $snapshotDir" -ForegroundColor Green
    return $snapshotDir
}

function Get-SaveBackups {
    Ensure-BackupDirectory
    return Get-ChildItem -Path $backupDirectory -Filter "*.bak" | Sort-Object LastWriteTime -Descending
}

function Restore-SaveBackup {
    param (
        [Parameter(Mandatory = $true)]
        [string]$BackupFilePath,
        [string]$TargetSaveName = "SaveGameDefault_Release.sav"
    )

    if (-not (Test-Path $BackupFilePath)) {
        Write-Error "Backup file does not exist: $BackupFilePath"
        return $false
    }

    # Make safety copy of current save before replacing
    Create-SaveBackup -TargetSaveName $TargetSaveName -Reason "PreRestoreSafety" | Out-Null

    $targetPath = Join-Path $saveDirectory $TargetSaveName
    Copy-Item -Path $BackupFilePath -Destination $targetPath -Force
    Write-Host "[Restore] Restored $TargetSaveName from $BackupFilePath" -ForegroundColor Green
    return $true
}

Export-ModuleMember -Function Create-SaveBackup, Backup-AllSaves, Get-SaveBackups, Restore-SaveBackup, Ensure-BackupDirectory
