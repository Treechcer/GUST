<#
Actions from version 0.5.5:
    -Actions are made similarly to mods, check thsi file for how they work
    -Actions have two types of actions, the first one is action that runs before your desired mode and second that runs after your desired mode
    -Actions are for small "modding" already existing mod part, for example if you want after commiting run your webapp you can make action that does that, without having to change defailt logic of GUST or some mod
    -Actions technically have 3rd type, of hybrid where you do something before and after desired mode
    -to make action run before / after specific mode, you take param of boolean type, default name in $isLast, where it's $true is it's the last thing GUST will do 
#>
$actions = @(
    "log"
)

function getActionName{
    return "gustActionShowCase"
}

function versionOfGust{
    return "0.4.3"
}

function getActions{
    return $actions
}

function getActionVersion{
    return "0.1.0"
}

function behaviourSwitchCheck{
    param(
        $name,
        [boolean]$isLast
    )

    switch ($name) {
        "log" {
            if ($isLast){
                Write-Host "actions are working - this last action"
            }
            else{
                Write-Host "actions are working - this is first action"
            }
        }
        Default {
            Write-Host "$name is not correct input"
        }
    }
}