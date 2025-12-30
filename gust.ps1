param(
    [Alias("m")]
    [string]$otherModes, # this adds more possibilities / "modes"

    [Alias("c")]
    [string]$message,    # commit message

    [Alias("u")]
    [string]$gitURL,     # URL, not necessary if you have alread "git add ."

    [Alias("b")]
    [string]$branch,     # this is the name of the branch you'll use if you do branch create switch (bcs) mode

    [Alias("n")]
    [int]$number,        # this is for any input that needs number, it has some default based on context

    [switch]$update,

    [Alias("i")]
    [switch]$interactive,

    [Alias("p")]
    [string]$path, # this has to be absolute path

    [Alias("r")]
    [string]$release, # this this is for github releases, you can make a new release from this! this will be the name of it

    [Alias("t")]
    [string]$title, # title for relases, like "name" but you have to have github CLI

    [Alias("na")]
    [string]$name, #name for repo creation

    [Alias("pu")]
    [switch]$public, #if repo is public

    [Alias("d")]
    [string]$description, # for repo decription

    [Alias("w")]
    [string]$who #used for githubCLI for PRs
)

$Global:version = "0.5.8"

#$config = Get-Content $configPath | ConvertFrom-Json
#
#$jsonContent = $config | ConvertTo-Json -Depth 3
#
#$jsonContent | Set-Content -Path "$PSScriptRoot/config.json" -Encoding UTF8

function checkUser {
    $username = git config --global user.name
    $useremail = git config --global user.email

    if (-not $username) {
        $username = git config user.name
    }
    if (-not $useremail) {
        $useremail = git config user.email
    }

    if (-not $username -or -not $useremail) {
        if ($null -eq $config.userEmail -and $null -eq $config.userName) {
            Write-Host "--------------------------------------------------------------------------------------------------"
            Write-Host $language.logInPrompt[0]
            Write-Host $language.logInPrompt[1]
            Write-Host $language.logInPrompt[2]
            Write-Host ""
            Write-Host $language.logInPrompt[3]
            Write-Host "--------------------------------------------------------------------------------------------------"
            exit 1
        }
        else {
            if ($config.changeNameGlobal) {
                Write-Host "$($language.globalSettingEmailName[0]) $($config.userName) $($language.and) $($config.userEmail)"
                git config --global user.name "$config.userName"
                git config --global user.email "$config.userEmail"
            }
            else {
                Write-Host "$($language.globalSettingEmailName[1]) $($config.userName) $($language.and) $($config.userEmail)"
                git config user.name "$config.userName"
                git config user.email "$config.userEmail"
            }
        }
    }
}

function behaviourCheck {
    . "$PSScriptRoot\source\funcs.ps1"
    . "$PSScriptRoot\source\gitFuncs.ps1"

    holiday

    $release = $release.Replace(" ","-")

    if ($interactive) {
        $otherModes = "interactive"
    }
    elseif ($otherModes -match "^u(p(d(a(t(e)?)?)?)?)?$" -or $otherModes -match "-update" -or $update) {
        $otherModes = "up"
    }
    elseif ($otherModes -match "^b(r(a(n(c(h)?)?)?)?)?") {
        if ($otherModes -match "d(e(l(e(t(e)?)?)?)?)?$") {
            $otherModes = "bd"
        }
        elseif ($otherModes -match "c(r(e(a(t(e)?)?)?)?)?" -and $otherModes -match "s(w(i(t(c(h)?)?)?)?)?") {
            $otherModes = "bcs"
        }
        elseif ($otherModes -match "s(w(i(t(c(h)?)?)?)?)?$") {
            $otherModes = "bs"
        }
    }
    elseif ($otherModes -match "^s(w(i(t(c(h)?)?)?)?)?") {
        if ($otherModes -match "p(r(o(f(i(l(e)?)?)?)?)?)?") {
            $otherModes = "swp"
        }
    }
    elseif ($otherModes -match "^c(r(e(a(t(e)?)?)?)?)?") {
        if ($otherModes -match "n(e(w)?)?") {
            if ($otherModes -match "p(r(o(f(i(l(e)?)?)?)?)?)?") {
                $otherModes = "cnp"
            }
        }
        if ($otherModes -match "r(e(p(o)?)?)?$"){
            $otherModes = "cr"
        }
    }
    elseif ($otherModes -match "^p(u(l(l)?)?)?$") {
        $otherModes = "p"
    }
    elseif ($otherModes -match "^p(u(l(l)?)?)?") {
        if ($otherModes -match "r(e(q(u(e(s(t)?)?)?)?)?)?"){
            if ($otherModes -match "c(e(c(k)?)?)?$"){
                $otherModes = "prc"
            }
        }
        if ($otherModes -match "c(r(e(a(t(e)?)?)?)?)?$"){
            $otherModes = "prcreate"
        }
    }
    elseif ($otherModes -match "^c(o(m(m(i(t)?)?)?)?)?$") {
        $otherModes = "c"
    }
    elseif ($otherModes -match "^l(o(g)?)?$") {
        $otherModes = "log"
    }
    elseif ($otherModes -match "^s(t(a(t(u(s)?)?)?)?)?$") {
        $otherModes = "s"
    }
    elseif ($otherModes -match "^l(i(s(t)?)?)?$") {
        $otherModes = "l"
    }
    elseif ($otherModes -eq "NOMODE") {
        $otherModes = "NOMODE"
    }
    elseif ($otherModes -eq "autoCommit") {
        $otherModes = "AC"
    }
    elseif ($otherModes -match "^d(e(s(c(r(i(p(t(i(o(n)?)?)?)?)?)?)?)?)?)?$") {
        $otherModes = "D"
    }
    elseif ($otherModes -match "^r(e(l(e(a(s(e)?)?)?)?)?)?$") {
        $otherModes = "R"
    }
    elseif ($otherModes -match "^r(e(v(e(r(t)?)?)?)?)?") {
        if ($otherModes -match "c(o(m(m(i(t)?)?)?)?)?$") {
            $otherModes = "rc"
        }
    }
    elseif ($otherModes -match "^i(s(s(u(e)?)?)?)?"){
        if ($otherModes -match "c(h(e(c(k)?)?)?)?$"){
            $otherModes = "ic"
        }
    }
    elseif ($otherModes -eq "") {
        $otherModes = $config.defaultMode
    }

    if ($config.runBeforeActions) {
        . "$PSScriptRoot\source\actions.ps1"
        runActions $false
    }

    . "$PSScriptRoot\source\githubCliFuncs.ps1"

    switch ($otherModes) {
        "c" {
            # just git add, commit and push :)
            gitPushCreate
        }
        "bcs" {
            # branch create switch
            branchCreateSwitch
        }
        "bs" {
            # branch switch
            branchSwitch
        }
        "bd" {
            # branch delete
            branchDelete
        }
        "s" {
            # status + branch
            status
        }
        "p" {
            # git pull
            git pull
        }
        "log" {
            log
        }
        "l" {
            writeMods
        }
        "up" {
            update
        }
        "NOMODE" {
            exit
        }
        "swp" {
            swp
        }
        "cnp" {
            cnp
        }
        "interactive" {
            . "$PSScriptRoot\source\interactiveMode.ps1"
            startInteractive
            exit
        }
        "AC" {
            autoCommit
        }
        "D"{
            description
        }
        "R"{
            release
        }
        "cr"{
            createRepo
        }
        "prc"{
            PRCheck
        }
        "rc"{
            revertCommit
        }
        "prcreate"{
            PRCreate
        }
        "ic"{
            issueCheck
        }
        default {
            if ($config.runModification) {
                $found = runModification $otherModes

                if (-not $found) {
                    Write-Host "$otherModes $($language.notCorrectInput)"
                    exit
                }
            }
            else {
                Write-Host "$otherModes $($language.notCorrectInput)"
                exit
            }
        }
    }

    if ($config.runAfterActions) {
        . "$PSScriptRoot\source\actions.ps1"
        runActions $true
    }
    addStats
}

function runModification {
    param(
        [string]$modname
    )

    . "$PSScriptRoot\source\modLoader.ps1"

    $found = loadMods $modname

    return $found
}

function swp {
    $okayName = $true
    while ($okayName) {
        $name = Read-Host "$(language.profileSwitch) /q"

        if ($name -eq "/q") {
            break
        }

        $profileName = Get-Content "$PSScriptRoot/profiles/profiles.json" | ConvertFrom-Json
        $profileName.current = $name

        try {
            $config = Get-Content "$PSScriptRoot/profiles/$($profileName.current)/config.json" -ErrorAction Stop | ConvertFrom-Json
            $okayName = $false
        }
        catch {
            $profileName.current = "default"
            $profileName = $profileName | ConvertTo-Json -Depth 3
            $profileName | Set-Content -Path "$PSScriptRoot/profiles/profiles.json" -Encoding UTF8
        }
    }
}

function cnp {
    $okayName = $true
    while ($okayName) {
        $name = Read-Host "$($language.profileName) /q"

        if ($name -eq "/q") {
            break
        }

        $profileName = Get-Content "$PSScriptRoot/profiles/profiles.json" | ConvertFrom-Json
        $profileName.current = $name

        try {
            $config = Get-Content "$PSScriptRoot/profiles/$($profileName.current)/config.json" -ErrorAction Stop | ConvertFrom-Json
            Write-Host "$($language.profileExists)"
        }
        catch {
            $profileName.current = "$name"
            $profileName = $profileName | ConvertTo-Json -Depth 3
            $profileName | Set-Content -Path "$PSScriptRoot/profiles/profiles.json" -Encoding UTF8

            mkdir $PSScriptRoot/profiles/$name
            $pConf = getDefaultConf | ConvertTo-Json -Depth 3
            $pConf | Set-Content -Path "$PSScriptRoot/profiles/$name/config.json" -Encoding UTF8

            $pStats = getDefaultStats | ConvertTo-Json -Depth 3
            $pStats | Set-Content -Path "$PSScriptRoot/profiles/$name/stats.json" -Encoding UTF8

            $okayName = $false
        }   
    }
}

function profileCheck {
    #$files = Get-ChildItem -Path "$PSScriptRoot/profiles" -File

    if (-not (Test-Path "$PSScriptRoot/profiles/profiles.json")) {
        $d = getDefaultProfiles
        $d = $d | ConvertTo-Json -Depth 3
        $d | Set-Content -Path "$PSScriptRoot/profiles/profiles.json" -Encoding UTF8
    }

    $profileName = Get-Content "$PSScriptRoot/profiles/profiles.json" | ConvertFrom-Json
    $ret = "$PSScriptRoot/profiles/$($profileName.current)/config.json"
    try {
        $config = Get-Content "$PSScriptRoot/profiles/$($profileName.current)/config.json" -ErrorAction Stop | ConvertFrom-Json   
    }
    catch {
        $ret = "$PSScriptRoot/profiles/default/config.json"
        $profileName.current = "default"
        $profileName = $profileName | ConvertTo-Json -Depth 3
        $profileName | Set-Content -Path "$PSScriptRoot/profiles/profiles.json" -Encoding UTF8
    }

    return $ret

}

function addStats {
    $profileF = Get-Content "$PSScriptRoot/profiles/profiles.json" | ConvertFrom-Json
    
    $config = Get-Content "$PSScriptRoot/profiles/$($profileF.current)/stats.json" -ErrorAction Stop | ConvertFrom-Json
    if ($config.PSObject.Properties.Match($otherModes).Count -eq 0) {
        $config | Add-Member -MemberType NoteProperty -Name $otherModes -Value 0
    }
    $config.$otherModes += 1
    $config = $config | ConvertTo-Json -Depth 3
    $config | Set-Content -Path "$PSScriptRoot/profiles/$($profileF.current)/stats.json" -Encoding UTF8 
}

function getDefaultConf {
    $config = [PSCustomObject]@{
        defaultBranch           = "main";
        defaultRemote           = "origin";
        userName                = $null;
        userEmail               = $null;
        changeNameGlobal        = $false;
        autoPullBeforePush      = $true;
        useDefaultCommitMessage = $false;
        defaultCommitMessage    = "small fixes";
        forceBranchDelete       = $false;
        defaultLogLength        = 5;
        defaultMode             = "c";
        runModification         = $true;
        runAfterActions         = $true;
        runBeforeActions        = $true;
        language                = "english";
        defaultRelease          = "1.0.0";
        defaultTitle            = "Realsed";
        defaultPath             = "Set this value in config!!";
        defaultReleaseMessage   = "released";
        defaultWho              = "@me";
        defaultDescriptionPR    = "PR created";
        defaultPRTitle          = "PR";
    }

    return $config
}

function getCurrentConf {
    return $config
}

function getDefaultProfiles {
    $profileD = [PSCustomObject]@{
        current = "default";
    }

    return $profileD
}

function getDefaultStats {
    $stats = [PSCustomObject]@{
        
    }

    return $stats
}

function getLanguageJSON {
    param(
        $languageName
    )
    if (-not (Test-Path $PSScriptRoot/languages/$($config.language).json)) {
        $config.language = "english"
        $configPath = $(profileCheck)
        $config = getDefaultConf

        $jsonContent = $config | ConvertTo-Json -Depth 3

        $jsonContent | Set-Content -Path $configPath -Encoding UTF8

        return Get-Content $PSScriptRoot/languages/english.json | ConvertFrom-Json
    }
    else {
        return Get-Content $PSScriptRoot/languages/$($config.language).json | ConvertFrom-Json
    }
}

function validadateConfig {
    param (
        $config
    )

    $defaultCFG = getDefaultConf
    
    $defaultCFG | ConvertTo-Json -Depth 5 | Out-Null
    $config | ConvertTo-Json -Depth 5 | Out-Null

    $keys1 = $defaultCFG.PSObject.Properties.Name
    $keys2 = $config.PSObject.Properties.Name

    for ($i = 0; $i -lt $keys1.Length; $i++) {
        if (-not ($keys2 -contains $keys1[$i])) {
            $key = $keys1[$i]
            $config | Add-Member -MemberType NoteProperty -Name $keys1[$i] -Value $defaultCFG.$key -Force
        }
    }

    $config | ConvertTo-Json -Depth 5 | Out-Null
    
    writeToCurrentConf $config

    return $config
}

function writeToCurrentConf {
    param (
        $newConf
    )

    $profileF = Get-Content "$PSScriptRoot/profiles/profiles.json" | ConvertFrom-Json
    
    $config = $newConf | ConvertTo-Json -Depth 3
    $config | Set-Content -Path "$PSScriptRoot/profiles/$($profileF.current)/config.json" -Encoding UTF8 
}

function getLanguageObject {
    return $language
}

. "$PSScriptRoot\source\modAPI.ps1"

$configPath = $(profileCheck)

if (Test-Path $configPath) {
    $config = Get-Content $configPath | ConvertFrom-Json
}
else {
    $config = getDefaultConf

    $jsonContent = $config | ConvertTo-Json -Depth 3

    $jsonContent | Set-Content -Path $configPath -Encoding UTF8

}

$language = getLanguageJSON

$config = validadateConfig $config # updating config adds uncecesarry things to profile configs that won't be used but whatever it's not really that big problem

checkUser
behaviourCheck