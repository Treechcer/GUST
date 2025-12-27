function getMessage {
    return $message
}

function getURL {
    return $gitURL
}

function getOtherModes {
    return $otherModes
}

function getBranch {
    return $branch
}

function getNumber {
    return $number
}

function getUpdate {
    return $update
}

function getInteractive {
    return $interactive
}

function getPath {
    return $path
}

function getRelease {
    return $release
}

function callNormalMode {
    #This function can call normal or standard modes from gust.ps1
    param (
        $mode
    )
    . "$PSScriptRoot\gust.ps1" -m "$mode" -c (getMessage) -u (getURL) -b (getBranch) -n (getNumber)
    #Write-Host "test"
}

function getConfigValue {
    param (
        $valueName
    )

    return ($config.$valueName)
}