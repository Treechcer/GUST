$modifications = @(
    "t(w(i(t(t(e(r)?)?)?)?)?)?"
)

function getModificationName {
    return "twitter uploader"
}

function versionOfGust {
    return "0.4.3"
}

function getModifications {
    return $modifications
}

function getHelpPages {
    $ret = @{
        helpPages = "twitter                  - Never made it";
        name = getModificationName
    }
    
    return $ret
}

function getModificationVersion {
    return "0.1.0"
}

function behaviourSwitchCheck {
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