function loadMods {
    param(
        [string]$modname
    )

    $mods = Get-ChildItem -Path "$PSScriptRoot\mods" -Filter *.ps1

    foreach ($mod in $mods){
        . $mod.FullName
        foreach ($modRegs in (getModifications)){
            if ($modname -match $modRegs){

                $modRegs = ($modRegs -replace "[^a-zA-Z]", "")

                $eval = compareModVersions $Global:version (versionOfGust)

                if ($eval -eq "release or major"){
                    Write-Host "⚠️ ⚠️ ⚠️"
                    Write-Host "This mod might not be compatible"
                    Write-Host "This mod was written for version $(versionOfGust)"
                    Write-Host "You have $($Global:version)"
                    Write-Host "⚠️ ⚠️ ⚠️"
                }
                elseif ($eval -eq "minor"){
                    Write-Host "⚠️ ⚠️ ⚠️"
                    Write-Host "mod isn't updated to the newest minor version"
                    Write-Host "it might have some incompatibilities"
                    Write-Host "⚠️ ⚠️ ⚠️"
                }
                
                behaviourSwitchCheck $modRegs

                break
            }
        }
    }
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
    if (($updateG -ne $updateM) -and ($releaseG -ne $releaseM)){
        return "release or major"
    }
    elseif ($minorG -ne $minorM){
        return "minor"
    }

    return $true
}

function getNames{
    $mods = Get-ChildItem -Path "$PSScriptRoot\mods" -Filter *.ps1

    $names = @()

    foreach ($mod in $mods){
        . $mod.FullName
        $names += getModificationName
    }

    return $names
}

function getVersions{
    $mods = Get-ChildItem -Path "$PSScriptRoot\mods" -Filter *.ps1

    $versions = @()

    foreach ($mod in $mods){
        . $mod.FullName
        $versions += getModificationVersion
    }

    return $versions
}

function getGVersions{
    $mods = Get-ChildItem -Path "$PSScriptRoot\mods" -Filter *.ps1

    $versions = @()

    foreach ($mod in $mods){
        . $mod.FullName
        $versions += versionOfGust
    }

    return $versions
}