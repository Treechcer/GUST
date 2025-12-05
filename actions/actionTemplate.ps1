$actions = @(

)

function getActionName {
    return "gustActionTemplate"
}

function versionOfGust {
    return "$Global:version"
}

function getActions {
    return $actions
}

function getActionVersion {
    return "0.1.0"
}

function behaviourSwitchCheck {
    param(
        $name,
        $isLast
    )

    switch ($name) {
        "" { 

        }
        Default {
            Write-Host "$name is not correct input"
        }
    }
}