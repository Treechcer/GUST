function runActions{
    . "$PSScriptRoot\modAPI.ps1"
    . "$PSScriptRoot\modLoader.ps1"
    $mode = getOtherModes
    
    $actionsF = Get-ChildItem -Path "$PSScriptRoot\actions" -Filter *.ps1
    foreach ($mod in $actionsF){
        . $mod.FullName
        foreach ($actions in (getActions)){
            if ($actions -eq $mode){
                $eval = compareModVersions $Global:version (versionOfGust)
                if ($eval -eq "release or major" -and ($eval -ne $true)){
                    Write-Host "⚠️ ⚠️ ⚠️"
                    Write-Host "This mod might not be compatible"
                    Write-Host "This mod was written for version $(versionOfGust)"
                    Write-Host "You have $($Global:version)"
                    Write-Host "⚠️ ⚠️ ⚠️"
                }
                elseif ($eval -eq "minor" -and ($eval -ne $true)){
                    Write-Host "⚠️ ⚠️ ⚠️"
                    Write-Host "mod isn't updated to the newest minor version"
                    Write-Host "it might have some incompatibilities"
                    Write-Host "⚠️ ⚠️ ⚠️"
                }

                behaviourSwitchCheck $actions
            }
        }
    }
}