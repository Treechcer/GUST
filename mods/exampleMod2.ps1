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
            . "$PSScriptRoot\..\gust.ps1"
            status
        }
        Default {
            Write-Host "$name is not correct input"
        }
    }
}