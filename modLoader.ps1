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