$modifications = @(
    "gustImport"
)

function getModificationName{
    return "gustImportShowcase"
}

function versionOfGust{
    return "$Global:version" # you shouldn't do this because it makes it harder to know if your mod is broken because of changes in mod API but this mod won't change nor uses modAPID much
}

function getModifications{
    return $modifications
}

function getHelpPages {
    $ret = @{
        helpPages = "gustImport               - Calls normal mode from inside of mod";
        name = getModificationName
    }
    
    return $ret
}

function getModificationVersion{
    return "1.0.0"
}

function behaviourSwitchCheck{
    param(
        $name
    )

    switch ($name) {
        "gustImport" { 
            # This makes mod able to call other mods

            # This example calls "status" but it can call ANY mode
            . "$PSScriptRoot\..\source\modAPI.ps1"
            callNormalMode "status"
        }
        Default {
            Write-Host "$name is not correct input"
        }
    }
}