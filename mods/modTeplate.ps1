$modifications = @(

)

function getModificationName{
    return "gustModShowCase"
}

function versionOfGust{
    return "0.3.2"
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