<#
.SYNOPSIS
    Handles registry operations for "Repair This!" modding.
.DESCRIPTION
    Provides functions to read and write values to the game's registry path.
    Abstracts away the specific hash suffixes used by Unity PlayerPrefs.
#>

$RegistryPath = "HKCU:\Software\DefaultCompany\Repair, This!"

function Get-GameRegistryPath {
    return $RegistryPath
}

function Get-GameValue {
    param (
        [Parameter(Mandatory = $true)]
        [string]$KeyPattern
    )

    if (-not (Test-Path $RegistryPath)) {
        Write-Error "Game registry path not found: $RegistryPath"
        return $null
    }

    # Get the registry key object safely
    try {
        $regKey = Get-Item -Path $RegistryPath -ErrorAction Stop
    }
    catch {
        Write-Error "Failed to access registry path: $RegistryPath. Error: $_"
        return $null
    }

    # Find the property name matching the pattern (keys are listed in the .Property member)
    $matchingKey = $regKey.Property | Where-Object { $_ -like "$KeyPattern*" } | Select-Object -First 1

    if ($null -eq $matchingKey) {
        Write-Warning "Key matching pattern '$KeyPattern' not found."
        return $null
    }

    # Read the value specifically
    $val = $regKey.GetValue($matchingKey)

    return @{
        KeyName = $matchingKey
        Value   = $val
    }
}

function Set-GameValue {
    param (
        [Parameter(Mandatory = $true)]
        [string]$KeyPattern,

        [Parameter(Mandatory = $true)]
        [int]$NewValue
    )

    $current = Get-GameValue -KeyPattern $KeyPattern

    if ($null -eq $current) {
        Write-Error "Cannot set value. Key matching '$KeyPattern' not found."
        return
    }

    Set-ItemProperty -Path $RegistryPath -Name $current.KeyName -Value $NewValue
    Write-Host "Successfully updated '$($current.KeyName)' to '$NewValue'." -ForegroundColor Green
}


function Get-GameValues {
    param (
        [Parameter(Mandatory = $true)]
        [string]$KeyPattern
    )

    if (-not (Test-Path $RegistryPath)) {
        return @()
    }

    try {
        $regKey = Get-Item -Path $RegistryPath -ErrorAction Stop
    }
    catch {
        Write-Error "Failed to access registry."
        return @()
    }

    $matchingKeys = $regKey.Property | Where-Object { $_ -like "$KeyPattern*" }
    
    $results = @()
    foreach ($key in $matchingKeys) {
        $val = $regKey.GetValue($key)
        $results += @{
            KeyName = $key
            Value   = $val
        }
    }
    return $results
}

Export-ModuleMember -Function Get-GameValue, Set-GameValue, Get-GameValues
