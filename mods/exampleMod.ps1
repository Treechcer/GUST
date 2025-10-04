# This mod is just a test to check if mods are enabled and working.
# Run "gust -m 'modTest'" to verify that mods are active.
# WARNING: function names: getModificationName, getModifications, behaviourSwitchCheck andversionOfGust must NOT be changed, or the mod will break the whole thing.

$modifications = @(
    # List of all modes this mod recognizes.
    # Uses regex, so you can either:
    # - specify the exact mode name
    # - or use a pattern, e.g., '^a(n(y)?)?' which matches a, an, or any
    "^m(o(d(T(e(s(t)?)?)?)?)?)?"
)

function versionOfGust{
    # This return the version gust had when you made mod, it's there to know for compatibility and other things (because modAPI might be rewriten etc.)
    return "$Global:version" # you shouldn't do this because it makes it harder to know if your mod is broken because of changes in mod API but this mod won't change nor uses modAPID much
}

function getModificationName{
    # Returns the name of the mod (this is used for "mod manager")
    return "modTester"
}

function getModificationVersion{
    return "1.0.0"
}

function getModifications{
    # Returns all modes (as regEx / string) this mod provides
    return $modifications
}

function behaviourSwitchCheck{
    param(
        # Function must have a single input: the mode name
        $name
    )

    # Performs actions based on the mode name
    switch ($name) {
        "modTest" {
            Write-Host "mods work"
            # Any PowerShell action can go here but you have to implement them yourself 
            # (or you can with modAPI now call any 'normalMode' functions, it's in modAPI.ps1)
            # in newer version there's file 'modAPI.ps1' which contains SOME API for modding
        }
        Default {
            Write-Host "$name is not correct input"
        }
    }
}