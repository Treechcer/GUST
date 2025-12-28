$modifications = @(

)

function getModificationName {
    return "gustModShowCase"
}

function versionOfGust {
    return "0.4.3"
}

function getModifications {
    return $modifications
}

function getHelpPages {
    $ret = @{
        helpPages = "none                     - This is just mod template, you can telete this mod";
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
        "-" { 

        }
        Default {
            Write-Host "$name is not correct input"
        }
    }
}