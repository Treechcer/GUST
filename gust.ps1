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
    [int]$number         # this is for any input that needs number, it has some default based on context
)

$Global:version = "0.4.0"

#$config = Get-Content $configPath | ConvertFrom-Json
#
#$jsonContent = $config | ConvertTo-Json -Depth 3
#
#$jsonContent | Set-Content -Path "$PSScriptRoot/config.json" -Encoding UTF8

function checkUser{
    $username = git config --global user.name
    $useremail = git config --global user.email

    if (-not $username) {
        $username = git config user.name
    }
    if (-not $useremail) {
        $useremail = git config user.email
    }

    if (-not $username -or -not $useremail) {
        if ($config.userEmail -eq $null -and $config.userName -eq $null){
            Write-Host "--------------------------------------------------------------------------------------------------"
            Write-Host "Please set your username and/or email with:"
            Write-Host "git config --global user.name 'your name'"
            Write-Host "git config --global user.email 'your email'"
            Write-Host ""
            Write-Host "If you want to set local email and username, just skip '--global' and you'll set them for your repository"
            Write-Host "--------------------------------------------------------------------------------------------------"
            exit 1
        }
        else{
            if ($config.changeNameGlobal){
                Write-Host "setting your name and email globaly to $($config.userName) and $($config.userEmail)"
                git config --global user.name "$config.userName"
                git config --global user.email "$config.userEmail"
            }
            else{
                Write-Host "setting your name and email localy to $($config.userName) and $($config.userEmail)"
                git config user.name "$config.userName"
                git config user.email "$config.userEmail"
            }
        }
    }
}

function gitPushCreate {
    git pull --no-edit

    if ($gitURL) {
        if (-not $branch) {
            $branch = $config.defaultBranch
        }

        if (-not (Test-Path -Path ".git" -PathType Container)) {
            git init
        }

        git remote add $config.defaultRemote "$gitURL.git"

        if ($config.autoPullBeforePush) {
            git pull $config.defaultRemote $branch --allow-unrelated-histories
        }

        git add .
        if (-not $message) {
            $message = $config.defaultCommitMessage
        }

        git commit -m "$message" *>$null
        git push --set-upstream $config.defaultRemote $branch
    }
    else {
        git add .
        if (-not $message) {
            $message = $config.defaultCommitMessage
        }

        git commit -m "$message" *>$null
        git push
    }
}

function branchCreateSwitch{
    $exists = git branch --list $branch

    if ($exists){
        Write-Host "$branch -- exist, did not create a new one"
        exit 1
    }

    $err0 = git branch $branch *>$null
    $err1 = git checkout $branch *>$null
    Write-Host "switched"
    git branch
}

function branchSwitch{
    $exists = git branch --list $branch

    if (-not $exists){
        Write-Host "$branch -- does not exist"
        exit 1
    }

    $err0 = git checkout $branch *>$null
    git branch
}

function branchDelete{
    $exists = git branch --list $branch

    if (-not $exists){
        Write-Host "$branch -- does not exist"
        exit 1
    }

    if ($config.forceBranchDelete){
        $delType = "-D"
    }
    else{
        $delType = "-d"
    }

    $err0 = & git branch $delType $branch 2>&1
    if ($LASTEXITCODE -ne 0){
        git branch
        Write-Host "$branch could not be safely delted"
        exit 1
    }
    else{
        Write-Host "$branch was deleted"
    }
}

function status{
    git status
    git branch
}

function log{
    if (-not $number){
        $number = $config.defaultLogLength
    }

    git log --oneline -n $number
}

function behaviourCheck{
    if ($otherModes -match "^b(r(a(n(c(h)?)?)?)?)?"){
        if ($otherModes -match "d(e(l(e(t(e)?)?)?)?)?$"){
            $otherModes = "bd"
        }
        elseif($otherModes -match "c(r(e(a(t(e)?)?)?)?)?" -and $otherModes -match "s(w(i(t(c(h)?)?)?)?)?"){
            $otherModes = "bcs"
        }
        elseif($otherModes -match "s(w(i(t(c(h)?)?)?)?)?$"){
            $otherModes = "bs"
        }
    }
    elseif ($otherModes -match "^s(w(i(t(c(h)?)?)?)?)?"){
        if ($otherModes -match "p(r(o(f(i(l(e)?)?)?)?)?)?"){
            $otherModes = "swp"
        }
    }
    elseif ($otherModes -match "^c(r(e(a(t(e)?)?)?)?)?"){
        if ($otherModes -match "n(e(w)?)?"){
            if ($otherModes -match "p(r(o(f(i(l(e)?)?)?)?)?)?"){
                $otherModes = "cnp"
            }
        }
    }
    elseif ($otherModes -match "^p(u(l(l)?)?)?$"){
        $otherModes = "p"
    }
    elseif ($otherModes -match "^c(o(m(m(i(t)?)?)?)?)?$"){
        $otherModes = "c"
    }
    elseif ($otherModes -match "^l(o(g)?)?$"){
        $otherModes = "log"
    }
    elseif ($otherModes -match "^s(t(a(t(u(s)?)?)?)?)?$"){
        $otherModes = "s"
    }
    elseif($otherModes -match "^l(i(s(t)?)?)?$"){
        $otherModes = "l"
    }
    elseif($otherModes -match "^u(p(d(a(t(e)?)?)?)?)?$" -or $otherModes -match "-update"){
        $otherModes = "up"
    }
    elseif ($otherModes -eq "NOMODE") {
        $otherModes = "NOMODE"
    }
    elseif ($otherModes -eq ""){
        $otherModes = $config.defaultMode
    }

    switch ($otherModes){
        "c" { # just git add, commit and push :)
            gitPushCreate
        }
        "bcs" { # branch create switch
            branchCreateSwitch
        }
        "bs" { # branch switch
            branchSwitch
        }
        "bd" { # branch delete
            branchDelete
        }
        "s" { # status + branch
            status
        }
        "p" { # git pull
            git pull
        }
        "log"{
            log
        }
        "l"{
            writeMods
        }
        "up"{
            update
        }
        "NOMODE"{

        }
        "swp"{
            swp
        }
        "cnp"{
            cnp
        }
        default {
            if ($config.runModification){
                runModification $otherModes
            }
            else{
                Write-Host "$otherModes is not correct input"
                exit
            }
        }
    }
    if ($config.runActions){
        . "$PSScriptRoot\actions.ps1"
        runActions
    }
    addStats
}

function runModification {
    param(
        [string]$modname
    )

    . "$PSScriptRoot\modLoader.ps1"

    loadMods $modname
}

function writeMods {
    . "$PSScriptRoot\modLoader.ps1"

    $names = getNames
    $versions = getVersions
    $gVersions = getGVersions

    $names += getNames "actions"
    $versions += getVersions "actions"
    $gVersions += getGVersions "actions"

    Write-Host ("{0,-4} {1,-25} {2,-12} {3,-12} {4}" -f "#", "Name", "Local", "GUST Ver.", "Note")
    Write-Host ("-"*70)

    for ($i = 0; $i -lt $names.Length; $i++) {
        $bonus = ""
        $color = "Gray"

        if ($gVersions[$i] -ne $Global:version) {
            $eval = compareModVersions $Global:version $gVersions[$i]

            if ($eval -eq "minor" -and ($eval -ne $true)) {
                $bonus = "Minor versions differ"
                $color = "Yellow"
            }
            elseif ($eval -eq "release or major" -and ($eval -ne $true)) {
                $bonus = "Release or major versions differ"
                $color = "Red"
            }
        }

        $line = ("[{0}] {1,-25} {2,-12} {3,-12} {4}" -f ($i + 1), $names[$i], "($($versions[$i]))", $gVersions[$i], $bonus)

        Write-Host $line -ForegroundColor $color
    }
}

function update {
    . "$PSScriptRoot\install.ps1" $False
    install
    v = $Global:version
    . "$PSScriptRoot\temp\gust.ps1" "NOMODE"
    Write-Host $(getVersion) $v
    if ($(getVersion) -ne $v){
        robocopy $PSScriptRoot\temp $PSScriptRoot /E /IS /IT
    }
    Remove-Item -Path $PSScriptRoot/temp -Recurse -Force
}

function getVersion {
    return $Global:version
}

function swp{
    $okayName = $true
    while ($okayName){
        $name = Read-Host "what is the name of profile you want to switch to? if you want to terminate this type /q"

        if ($name -eq "/q"){
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

function cnp{
    $okayName = $true
    while ($okayName){
        $name = Read-Host "how do you want to name your profile? if you want to terminate this type /q"

        if ($name -eq "/q"){
            break
        }

        $profileName = Get-Content "$PSScriptRoot/profiles/profiles.json" | ConvertFrom-Json
        $profileName.current = $name

        try {
            $config = Get-Content "$PSScriptRoot/profiles/$($profileName.current)/config.json" -ErrorAction Stop | ConvertFrom-Json
            Write-Host "Profile already exists"
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

    $profileName = Get-Content "$PSScriptRoot/profiles/profiles.json" | ConvertFrom-Json
    
    try {
        $config = Get-Content "$PSScriptRoot/profiles/$($profileName.current)/config.json" -ErrorAction Stop | ConvertFrom-Json   
    }
    catch {
        $profileName.current = "default"
        $profileName = $profileName | ConvertTo-Json -Depth 3
        $profileName | Set-Content -Path "$PSScriptRoot/profiles/profiles.json" -Encoding UTF8
    }

    return "$PSScriptRoot/profiles/$($profileName.current)/config.json"

}

function addStats{
    $profile = Get-Content "$PSScriptRoot/profiles/profiles.json" | ConvertFrom-Json
    
    $config = Get-Content "$PSScriptRoot/profiles/$($profile.current)/stats.json" -ErrorAction Stop | ConvertFrom-Json
    if ($config.PSObject.Properties.Match($otherModes).Count -eq 0) {
        $config | Add-Member -MemberType NoteProperty -Name $otherModes -Value 0
    }
    $config.$otherModes += 1
    $config = $config | ConvertTo-Json -Depth 3
    $config | Set-Content -Path "$PSScriptRoot/profiles/$($profile.current)/stats.json" -Encoding UTF8 
}

function getDefaultConf{
    $config = [PSCustomObject]@{
        defaultBranch = "main";
        defaultRemote = "origin";
        userName = $null;
        userEmail = $null;
        changeNameGlobal = false;
        autoPullBeforePush = true;
        defaultCommitMessage = "small fixes";
        forceBranchDelete = false;
        defaultLogLength = 5;
        defaultMode = "c";
        runModification = $true;
        runActions = $true
    }

    return $config
}

function getDefaultStats{
    $stats = [PSCustomObject]@{
        
    }

    return $stats
}

. "$PSScriptRoot\modAPI.ps1"

$configPath = $(profileCheck)

if (Test-Path $configPath){
    $config = Get-Content $configPath | ConvertFrom-Json
}
else{
    $config = [PSCustomObject]@{
        defaultBranch = "main";
        defaultRemote = "origin";
        userName = $null;
        userEmail = $null;
        changeNameGlobal = false;
        autoPullBeforePush = true;
        defaultCommitMessage = "small fixes";
        forceBranchDelete = false;
        defaultLogLength = 5;
        defaultMode = "c";
        runModification = $true;
        runActions = $true
    }

    $jsonContent = $config | ConvertTo-Json -Depth 3

    $jsonContent | Set-Content -Path "$PSScriptRoot/config.json" -Encoding UTF8

}

checkUser
behaviourCheck