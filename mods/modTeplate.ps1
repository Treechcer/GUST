$modifications = @(

)

function getModificationName{
    return "gustImportShowcase"
}

function getModifications{
    return $modifications
}

function getModificationVersion{
    return "0.1.0"
}

function behaviourSwitchCheck{
    param(
        $name
    )

    switch ($name) {
        "-" { 

        }
        Default {
            Write-Host "$name is not correct input"
        }
    }
}