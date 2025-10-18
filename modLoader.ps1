function loadMods {
    param(
        [string]$modname
    )

    $mods = Get-ChildItem -Path "$PSScriptRoot\mods" -Filter *.ps1

    $found = $false
    
    $language = getLanguageObject

    foreach ($mod in $mods){
        . $mod.FullName
        foreach ($modRegs in (getModifications)){
            if ($modname -match $modRegs){

                $modRegs = ($modRegs -replace "[^a-zA-Z]", "")

                $eval = compareModVersions $Global:version (versionOfGust)

                if ($eval -eq "release or major" -and ($eval -ne $true)){
                    Write-Host "⚠️ ⚠️ ⚠️"
                    Write-Host "$($language.modNotComapatible)"
                    Write-Host "$($language.modWasWritten) $(versionOfGust)"
                    Write-Host "$($language.youHave) $($Global:version)"
                    Write-Host "⚠️ ⚠️ ⚠️"
                }
                elseif ($eval -eq "minor" -and ($eval -ne $true)){
                    Write-Host "⚠️ ⚠️ ⚠️"
                    Write-Host "$($language.minorModDifference)"
                    Write-Host "$($language.someIncopabilities)"
                    Write-Host "⚠️ ⚠️ ⚠️"
                }
                
                behaviourSwitchCheck $modRegs
                $found = $true
                break
            }
        }
    }

    return $found
}

function compareModVersions {
    param (
        $version1,
        $version2
    )

    $releaseG = $version1.split(".")[0]
    $updateG = $version1.split(".")[1]
    $minorG = $version1.split(".")[2]

    $releaseM = $version2.split(".")[0]
    $updateM = $version2.split(".")[1]
    $minorM = $version2.split(".")[2]
    if (($updateG -ne $updateM) -or ($releaseG -ne $releaseM)){
        return "release or major"
    }
    elseif ($minorG -ne $minorM){
        return "minor"
    }

    return $true
}

function getNames{
    param(
        $folder = "mods"
    )

    $mods = Get-ChildItem -Path "$PSScriptRoot\$folder" -Filter *.ps1

    $names = @()

    if ($folder -eq "mods"){
        $f = "getModificationName"
    }
    elseif ($folder -eq "actions"){
        $f = "getActionName"
    }

    foreach ($mod in $mods){
        . $mod.FullName
        $names += & $f
    }

    return $names
}

function getVersions{
    param(
        $folder = "mods"
    )
    $mods = Get-ChildItem -Path "$PSScriptRoot\$folder" -Filter *.ps1

    if ($folder -eq "mods"){
        $f = "getModificationVersion"
    }
    elseif ($folder -eq "actions"){
        $f = "getActionVersion"
    }

    $versions = @()

    foreach ($mod in $mods){
        . $mod.FullName
        $versions += & $f
    }

    return $versions
}

function getGVersions{
    param(
        $folder = "mods"
    )
    $mods = Get-ChildItem -Path "$PSScriptRoot\$folder" -Filter *.ps1

    if ($folder -eq "mods"){
        $f = "versionOfGust"
    }
    elseif ($folder -eq "actions"){
        $f = "versionOfGust"
    }

    $versions = @()

    foreach ($mod in $mods){
        . $mod.FullName
        $versions += & $f
    }

    return $versions
}