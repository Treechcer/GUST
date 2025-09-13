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

                behaviourSwitchCheck $modRegs
                break
            }
        }
    }
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