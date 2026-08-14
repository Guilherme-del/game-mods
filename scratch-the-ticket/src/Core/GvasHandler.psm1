<#
.SYNOPSIS
    Unreal Engine 5.7 GVAS Binary Save Handler for "Scratch the Ticket".
.DESCRIPTION
    High-performance binary parser and modifier for Scratch the Ticket save games.
#>

$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
$backupModule = Join-Path $scriptDirectory "BackupManager.psm1"
if (Test-Path $backupModule) {
    Import-Module $backupModule -Force -DisableNameChecking
}

function Get-SaveFolderPath {
    return Join-Path $env:LOCALAPPDATA "LotteryTicket\Saved\SaveGames"
}

function Get-SaveFilePath {
    param (
        [string]$FileName = "SaveGameDefault_Release.sav"
    )
    $folder = Get-SaveFolderPath
    return Join-Path $folder $FileName
}

function Test-GameRunning {
    $proc = Get-Process -Name "LotteryTicket*", "*ticket*" -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -match "LotteryTicket" }
    return ($null -ne $proc -and $proc.Count -gt 0)
}

function Stop-GameProcess {
    $procs = Get-Process -Name "LotteryTicket*", "*ticket*" -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -match "LotteryTicket" }
    if ($procs) {
        foreach ($p in $procs) {
            Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue
        }
        Start-Sleep -Milliseconds 800
        Write-Host "[Sistema] O jogo 'Scratch the Ticket' foi fechado com sucesso!" -ForegroundColor Green
        return $true
    } else {
        Write-Host "[Sistema] O jogo já está fechado." -ForegroundColor Yellow
        return $false
    }
}

function Start-GameProcess {
    Write-Host "[Sistema] Iniciando 'Scratch the Ticket' via Steam..." -ForegroundColor Cyan
    Start-Process "steam://rungameid/4626940"
}

function Warn-IfGameRunning {
    if (Test-GameRunning) {
        Write-Host "=================================================================" -ForegroundColor Yellow
        Write-Host " [ATENÇÃO CRÍTICA] O JOGO ESTÁ ABERTO EM EXECUÇÃO NO MOMENTO!" -ForegroundColor Red
        Write-Host " A Unreal Engine mantém o dinheiro na memória RAM do jogo." -ForegroundColor Yellow
        Write-Host " Se você alterar o save com o jogo aberto, o jogo sobrescreverá" -ForegroundColor Yellow
        Write-Host " suas alterações ao salvar automaticamente ou ao fechar!" -ForegroundColor Yellow
        Write-Host ""
        Write-Host " 👉 RECOMENDADO: Feche o jogo, aplique o mod e abra o jogo." -ForegroundColor Cyan
        Write-Host "=================================================================" -ForegroundColor Yellow
        Write-Host ""
    }
}

function Find-PropertyOffsetInBytes {
    param (
        [byte[]]$Data,
        [string]$PropName
    )
    $propBytes = [System.Text.Encoding]::ASCII.GetBytes($PropName + [char]0)
    $lenBytes = [BitConverter]::GetBytes([int]($PropName.Length + 1))
    $target = $lenBytes + $propBytes

    for ($i = 0; $i -le $Data.Length - $target.Length; $i++) {
        $found = $true
        for ($j = 0; $j -lt $target.Length; $j++) {
            if ($Data[$i + $j] -ne $target[$j]) { $found = $false; break }
        }
        if ($found) {
            return $i
        }
    }
    return -1
}

function Get-GvasProperty {
    param (
        [string]$SaveFileName = "SaveGameDefault_Release.sav",
        [Parameter(Mandatory = $true)]
        [string]$PropertyName
    )

    $savePath = Get-SaveFilePath -FileName $SaveFileName
    if (-not (Test-Path $savePath)) {
        Write-Error "Save file not found at: $savePath"
        return $null
    }

    $bytes = [System.IO.File]::ReadAllBytes($savePath)
    $offset = Find-PropertyOffsetInBytes -Data $bytes -PropName $PropertyName
    if ($offset -lt 0) {
        return $null
    }

    $nameLen = [BitConverter]::ToInt32($bytes, $offset)
    $typeStart = $offset + 4 + $nameLen
    $typeLen = [BitConverter]::ToInt32($bytes, $typeStart)
    $typeStr = [System.Text.Encoding]::ASCII.GetString($bytes, $typeStart + 4, $typeLen - 1)

    if ($typeStr -eq "DoubleProperty") {
        $valOffset = $typeStart + 4 + $typeLen + 4 + 4 + 1
        $val = [BitConverter]::ToDouble($bytes, $valOffset)
        return [PSCustomObject]@{
            PropertyName = $PropertyName
            PropertyType = $typeStr
            Value        = $val
            ValueOffset  = $valOffset
            SavePath     = $savePath
        }
    } elseif ($typeStr -eq "BoolProperty") {
        $valOffset = $typeStart + 4 + $typeLen + 8
        $val = ($bytes[$valOffset] -eq 1)
        return [PSCustomObject]@{
            PropertyName = $PropertyName
            PropertyType = $typeStr
            Value        = $val
            ValueOffset  = $valOffset
            SavePath     = $savePath
        }
    } elseif ($typeStr -eq "IntProperty") {
        $valOffset = $typeStart + 4 + $typeLen + 4 + 4 + 1
        $val = [BitConverter]::ToInt32($bytes, $valOffset)
        return [PSCustomObject]@{
            PropertyName = $PropertyName
            PropertyType = $typeStr
            Value        = $val
            ValueOffset  = $valOffset
            SavePath     = $savePath
        }
    } elseif ($typeStr -eq "FloatProperty") {
        $valOffset = $typeStart + 4 + $typeLen + 4 + 4 + 1
        $val = [BitConverter]::ToSingle($bytes, $valOffset)
        return [PSCustomObject]@{
            PropertyName = $PropertyName
            PropertyType = $typeStr
            Value        = $val
            ValueOffset  = $valOffset
            SavePath     = $savePath
        }
    } elseif ($typeStr -eq "Int64Property") {
        $valOffset = $typeStart + 4 + $typeLen + 4 + 4 + 1
        $val = [BitConverter]::ToInt64($bytes, $valOffset)
        return [PSCustomObject]@{
            PropertyName = $PropertyName
            PropertyType = $typeStr
            Value        = $val
            ValueOffset  = $valOffset
            SavePath     = $savePath
        }
    }

    return [PSCustomObject]@{
        PropertyName = $PropertyName
        PropertyType = $typeStr
        Value        = $null
        ValueOffset  = $typeStart
        SavePath     = $savePath
    }
}

function Set-GvasProperty {
    param (
        [string]$SaveFileName = "SaveGameDefault_Release.sav",
        [Parameter(Mandatory = $true)]
        [string]$PropertyName,
        [Parameter(Mandatory = $true)]
        $NewValue
    )

    $prop = Get-GvasProperty -SaveFileName $SaveFileName -PropertyName $PropertyName
    if ($null -eq $prop) {
        Write-Error "Property '$PropertyName' not found in $SaveFileName"
        return $false
    }

    Create-SaveBackup -TargetSaveName $SaveFileName -Reason "Before_$PropertyName" | Out-Null

    $bytes = [System.IO.File]::ReadAllBytes($prop.SavePath)

    switch ($prop.PropertyType) {
        "DoubleProperty" {
            $doubleVal = [double]$NewValue
            $valBytes = [BitConverter]::GetBytes($doubleVal)
            [Array]::Copy($valBytes, 0, $bytes, $prop.ValueOffset, 8)
        }
        "BoolProperty" {
            $boolVal = if ($NewValue -is [bool]) { $NewValue } else { [bool]::Parse($NewValue) }
            $bytes[$prop.ValueOffset] = if ($boolVal) { 1 } else { 0 }
        }
        "IntProperty" {
            $intVal = [int]$NewValue
            $valBytes = [BitConverter]::GetBytes($intVal)
            [Array]::Copy($valBytes, 0, $bytes, $prop.ValueOffset, 4)
        }
        "FloatProperty" {
            $floatVal = [float]$NewValue
            $valBytes = [BitConverter]::GetBytes($floatVal)
            [Array]::Copy($valBytes, 0, $bytes, $prop.ValueOffset, 4)
        }
        "Int64Property" {
            $int64Val = [long]$NewValue
            $valBytes = [BitConverter]::GetBytes($int64Val)
            [Array]::Copy($valBytes, 0, $bytes, $prop.ValueOffset, 8)
        }
        default {
            Write-Error "Unsupported PropertyType for direct setting: $($prop.PropertyType)"
            return $false
        }
    }

    [System.IO.File]::WriteAllBytes($prop.SavePath, $bytes)
    Write-Host "[GvasHandler] Definido '$PropertyName' = $NewValue com sucesso!" -ForegroundColor Green
    return $true
}

function Get-BuildingList {
    param (
        [string]$SaveFileName = "SaveGameDefault_Release.sav"
    )

    $savePath = Get-SaveFilePath -FileName $SaveFileName
    if (-not (Test-Path $savePath)) { return @() }

    $bytes = [System.IO.File]::ReadAllBytes($savePath)
    $str = [System.Text.Encoding]::ASCII.GetString($bytes)

    $buildings = @(
        @{ Key = "SpyBuilding";  Name = "Agência de Espionagem" },
        @{ Key = "Bakery";       Name = "Padaria" },
        @{ Key = "Hacker";       Name = "Central Hacker" },
        @{ Key = "MayorBuild";   Name = "Prefeitura" },
        @{ Key = "SolarPower";   Name = "Usina Solar" },
        @{ Key = "Sputnik";      Name = "Satélite Sputnik" },
        @{ Key = "SpaceShip";    Name = "Nave Espacial" },
        @{ Key = "Planets";      Name = "Planetas" },
        @{ Key = "Apartment";    Name = "Apartamento" }
    )

    $results = @()
    foreach ($b in $buildings) {
        $idx = $str.IndexOf($b.Key)
        if ($idx -ge 0) {
            $chunk = $str.Substring($idx, [Math]::Min(300, $str.Length - $idx))
            $countIdx = $chunk.IndexOf("count_")
            if ($countIdx -ge 0) {
                $absCountIdx = $idx + $countIdx
                $intPropIdx = $str.IndexOf("IntProperty", $absCountIdx)
                if ($intPropIdx -ge 0) {
                    $valOffset = $intPropIdx + 11 + 1 + 4 + 4 + 1
                    $countVal = [BitConverter]::ToInt32($bytes, $valOffset)
                    $results += [PSCustomObject]@{
                        Key         = $b.Key
                        DisplayName = $b.Name
                        Count       = $countVal
                        ValueOffset = $valOffset
                    }
                }
            }
        }
    }
    return $results
}

function Set-BuildingCount {
    param (
        [string]$SaveFileName = "SaveGameDefault_Release.sav",
        [Parameter(Mandatory = $true)]
        [string]$BuildingKey,
        [Parameter(Mandatory = $true)]
        [int]$NewCount
    )

    $buildings = Get-BuildingList -SaveFileName $SaveFileName
    $target = $buildings | Where-Object { $_.Key -eq $BuildingKey }
    if ($null -eq $target) {
        Write-Error "Building '$BuildingKey' not found in save."
        return $false
    }

    Create-SaveBackup -TargetSaveName $SaveFileName -Reason "Building_${BuildingKey}" | Out-Null

    $savePath = Get-SaveFilePath -FileName $SaveFileName
    $bytes = [System.IO.File]::ReadAllBytes($savePath)
    $valBytes = [BitConverter]::GetBytes($NewCount)
    [Array]::Copy($valBytes, 0, $bytes, $target.ValueOffset, 4)
    [System.IO.File]::WriteAllBytes($savePath, $bytes)

    Write-Host "[GvasHandler] Quantidade de '$($target.DisplayName)' alterada para $NewCount!" -ForegroundColor Green
    return $true
}

function Get-TicketLevelsList {
    param (
        [string]$SaveFileName = "SaveGameDefault_Release.sav"
    )

    $savePath = Get-SaveFilePath -FileName $SaveFileName
    if (-not (Test-Path $savePath)) { return @() }

    $bytes = [System.IO.File]::ReadAllBytes($savePath)
    $str = [System.Text.Encoding]::ASCII.GetString($bytes)
    $idx = $str.IndexOf("Ticket Levels")
    if ($idx -lt 0) { return @() }

    $results = @()
    $matches = [regex]::Matches($str.Substring($idx, [Math]::Min(3000, $str.Length - $idx)), "BP_[A-Za-z0-9_]+_C")
    foreach ($m in $matches) {
        $tIdx = $idx + $m.Index
        $tEnd = $tIdx + $m.Length
        $valOffset = $tEnd + 1
        $val = [BitConverter]::ToDouble($bytes, $valOffset)
        
        $cleanName = $m.Value -replace "^BP_", "" -replace "_C$", "" -replace "_Ticket", "" -replace "_Tier", " Tier "
        $results += [PSCustomObject]@{
            Blueprint   = $m.Value
            DisplayName = $cleanName
            Level       = [Math]::Round($val, 2)
            ValueOffset = $valOffset
        }
    }
    return $results
}

function Set-TicketLevelValue {
    param (
        [string]$SaveFileName = "SaveGameDefault_Release.sav",
        [Parameter(Mandatory = $true)]
        [string]$Blueprint,
        [Parameter(Mandatory = $true)]
        [double]$NewLevel
    )

    $tickets = Get-TicketLevelsList -SaveFileName $SaveFileName
    $target = $tickets | Where-Object { $_.Blueprint -eq $Blueprint }
    if ($null -eq $target) {
        Write-Error "Ticket Blueprint '$Blueprint' not found."
        return $false
    }

    Create-SaveBackup -TargetSaveName $SaveFileName -Reason "TicketLevel" | Out-Null

    $savePath = Get-SaveFilePath -FileName $SaveFileName
    $bytes = [System.IO.File]::ReadAllBytes($savePath)
    $valBytes = [BitConverter]::GetBytes($NewLevel)
    [Array]::Copy($valBytes, 0, $bytes, $target.ValueOffset, 8)
    [System.IO.File]::WriteAllBytes($savePath, $bytes)

    Write-Host "[GvasHandler] Nível do bilhete '$($target.DisplayName)' alterado para $NewLevel!" -ForegroundColor Green
    return $true
}

function Unlock-AllGameTickets {
    param (
        [string]$SaveFileName = "SaveGameDefault_Release.sav"
    )

    $savePath = Get-SaveFilePath -FileName $SaveFileName
    if (-not (Test-Path $savePath)) { return $false }

    Create-SaveBackup -TargetSaveName $SaveFileName -Reason "UnlockAllTickets" | Out-Null

    $bytes = [System.IO.File]::ReadAllBytes($savePath)
    $str = [System.Text.Encoding]::ASCII.GetString($bytes)
    $idx = $str.IndexOf("TicketUnlockData")
    if ($idx -lt 0) {
        Write-Error "TicketUnlockData not found in save."
        return $false
    }

    $chunk = $str.Substring($idx, [Math]::Min(15000, $str.Length - $idx))
    $lockedMatches = [regex]::Matches($chunk, "IsLocked_")
    $unlockedCount = 0

    foreach ($m in $lockedMatches) {
        $absIdx = $idx + $m.Index
        $boolPropIdx = $str.IndexOf("BoolProperty", $absIdx)
        if ($boolPropIdx -ge 0) {
            $valOffset = $boolPropIdx + 12 + 1 + 4 + 4
            $bytes[$valOffset] = 0 # False (Unlocked)
            $unlockedCount++
        }
    }

    [System.IO.File]::WriteAllBytes($savePath, $bytes)
    Write-Host "[GvasHandler] $unlockedCount tipos de bilhetes desbloqueados com sucesso!" -ForegroundColor Green
    return $true
}

Export-ModuleMember -Function Get-SaveFolderPath, Get-SaveFilePath, Test-GameRunning, Stop-GameProcess, Start-GameProcess, Warn-IfGameRunning, `
    Get-GvasProperty, Set-GvasProperty, Get-BuildingList, Set-BuildingCount, `
    Get-TicketLevelsList, Set-TicketLevelValue, Unlock-AllGameTickets
