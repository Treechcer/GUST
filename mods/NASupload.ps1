#this is example code for my use, it uplaods specific files to my NAS / server.

# 1 -> normal commit 
# 2 -> move specific files to NAS to serverScripts 

$modifications = @(
    "NAS"
)

function getModificationName {
    return "NAS-uploader"
}

function versionOfGust {
    return "0.4.3"
}

function getModificationVersion {
    return "0.1.0"
}

function getModifications {
    return $modifications
}

function getHelpPages {
    return "NAS                      - Uplaods locally to my NAS"
}

function behaviourSwitchCheck {
    param(
        $name
    )

    switch ($name) {
        "NAS" { 
            . "$PSScriptRoot\..\modAPI.ps1" #you have use this for mod API calls

            $message = getMessage
            $message
            if ($message -ne "") {
                . "$PSScriptRoot\..\gust.ps1" -m "c" -c $message
            }

            $NAS = "\\192.168.0.209\nas\serverScripts"

            $PC = ".\serverScripts"

            robocopy $PC $NAS /E /XO /XD ".git" /XF ".git" ".gitignore"

            $PC = ".\webAPI"

            $NAS = "\\192.168.0.209\nas\serverScripts\webAPI"

            robocopy $PC $NAS /E /XO /XD ".git" /XF ".git" ".gitignore"
        }
        Default {
            Write-Host "$name is not correct input"
        }
    }
}