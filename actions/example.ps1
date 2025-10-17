<#
Actions are made similarly to mods, except I changed "mod" and "mode" with actions or actions.
Actions are usefull because you can run code after any mode, without redefining it, it's possible to do it with default modes
using mods, but actions are more meant for you being able to do them after modded actions, so if somebody
were to make something you like but you want to run some more code after it, you can just make action file for it without changing
the mod itself (which would prevent you from easy mod updates) - also you can modify with actions easily even normal modes,
which this file does with "log" (it HAS to be the name of the input after it changes not before, it can't be regex like in mods).
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
        $name
    )

    switch ($name) {
        "log" { 
            Write-Host "actions are working"
        }
        Default {
            Write-Host "$name is not correct input"
        }
    }
}