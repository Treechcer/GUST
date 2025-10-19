function runActions{
    param (
        [boolean] $isLast
    )
    . "$PSScriptRoot\modAPI.ps1"
    . "$PSScriptRoot\modLoader.ps1"

    $mode = getOtherModes
    $language = getLanguageObject    
    $actionsF = Get-ChildItem -Path "$PSScriptRoot\actions" -Filter *.ps1
    foreach ($mod in $actionsF){
        . $mod.FullName
        foreach ($actions in (getActions)){
            if ($actions -eq $mode){
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

                behaviourSwitchCheck $actions $isLast
            }
        }
    }
}