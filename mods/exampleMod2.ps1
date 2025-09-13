$modifications = @(
    "gustImport"
)

function getModificationName{
    return "gustImportShowcase"
}

function getModifications{
    return $modifications
}

function behaviourSwitchCheck{
    param(
        $name
    )

    switch ($name) {
        "gustImport" { 
            # This makes mod able to call other mods
            . "$PSScriptRoot\..\gust.ps1" -m "status"
        }
        Default {
            Write-Host "$name is not correct input"
        }
    }
}