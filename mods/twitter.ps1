$modifications = @(
    "t(w(i(t(t(e(r)?)?)?)?)?)?"
)

function getModificationName{
    return "twitter uploader"
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
        "twitter" { 
            #someday... later tho
        }
        Default {
            Write-Host "$name is not correct input"
        }
    }
}