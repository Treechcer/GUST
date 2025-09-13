# This mod is just a test to check if mods are enabled and working.
# Run "gust -m 'modTest'" to verify that mods are active.
# WARNING: function names: getModificationName, getModifications, and behaviourSwitchCheck must NOT be changed, or the mod will break the whole thing.

$modifications = @(
    # List of all modes this mod recognizes.
    # Uses regex, so you can either:
    # - specify the exact mode name
    # - or use a pattern, e.g., '^a(n(y)?)?' which matches a, an, or any
    "^m(o(d(T(e(s(t)?)?)?)?)?)?"
)

function getModificationName{
    # Returns the name of the mod (can be used for a mod manager or similar)
    # Currently not used anywhere
    return "modTester"
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
            # (or use dot-sourcing, you can use predefined GUST functions)
        }
        Default {
            Write-Host "$name is not correct input"
        }
    }
}