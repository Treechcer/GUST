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
    [string]$title # title for relases, like "name" but you have to have github CLI
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
        if (-not $message -and $config.useDefaultCommitMessage) {
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

function branchCreateSwitch {
    $exists = git branch --list $branch

    if ($exists) {
        Write-Host "$branch -- $($language.branchExists)"
        exit 1
    }

    git branch $branch *>$null
    git checkout $branch *>$null
    Write-Host $($language.switched)
    git branch
}

function branchSwitch {
    $exists = git branch --list $branch

    if (-not $exists) {
        Write-Host "$branch -- $($language.branchDoesNotExists)"
        exit 1
    }

    git checkout $branch *>$null
    git branch
}

function branchDelete {
    $exists = git branch --list $branch

    if (-not $exists) {
        Write-Host "$branch -- $($language.branchDoesNotExists)"
        exit 1
    }

    if ($config.forceBranchDelete) {
        $delType = "-D"
    }
    else {
        $delType = "-d"
    }

    & git branch $delType $branch 2>&1
    if ($LASTEXITCODE -ne 0) {
        git branch
        Write-Host "$branch $($language.branchSafe)"
        exit 1
    }
    else {
        Write-Host "$branch $($language.wasDeleted)"
    }
}

function status {
    git status
    git branch
}

function log {
    if (-not $number) {
        $number = $config.defaultLogLength
    }

    git log --oneline -n $number
}

function behaviourCheck {
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
    }
    elseif ($otherModes -match "^p(u(l(l)?)?)?$") {
        $otherModes = "p"
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
    elseif ($otherModes -eq "") {
        $otherModes = $config.defaultMode
    }

    if ($config.runBeforeActions) {
        . "$PSScriptRoot\actions.ps1"
        runActions $false
    }

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
            . "$PSScriptRoot/interactiveMode.ps1"
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
            Write-Host "test"
            release
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
        . "$PSScriptRoot\actions.ps1"
        runActions $true
    }
    addStats
}

function gitIgnore {
    if (Test-Path ".gitignore"){
        $wasFound = $false, $false
        $toFind = "RELEASE", "RELEASE/*"
        $c = (Get-Content ".\.gitignore")
        $nwLineCreate = $true
        for ($j = 0; $j -lt $c.Count; $j++){
            $line = $c[$j]

            if ($j -eq $c.Count -1){
                if (-not $line -match "^[\s]*$"){
                    $nwLineCreate = $false
                }
            }

            for ($i = 0; $i -lt $toFind.Length; $i++){
                if ($line -eq $toFind[$i]){
                    $wasFound[$i] = $true
                }
            }
        }
        
        if ($nwLineCreate){
            "" | Out-File -FilePath ".\.gitignore" -Append -Encoding utf8 -NoNewline
        }

        for ($i = 0; $i -lt $toFind.Length; $i++){
            if (-not $wasFound[$i]){
                $toFind[$i] | Out-File -FilePath ".\.gitignore" -Append -Encoding utf8 
            }
        }
    }
    else {
        New-Item ".\.gitignore"
        "RELEASE" | Out-File -FilePath ".\.gitignore" -Append -Encoding utf8
        "RELEASE/*" | Out-File -FilePath ".\.gitignore" -Append -Encoding utf8
    }
}

function release {
    gitIgnore

    if (Get-Command gh -ErrorAction SilentlyContinue) {
        New-Item RELEASE -ItemType Directory -Force
        if ($null -eq (Get-ChildItem ".\RELEASE\")){
            Write-Host "You have to have your files in .\RELEASE\ that you want to release (files like .exe, .app etc.) that now has been created"
        }
        else{
            $files = Get-ChildItem .\RELEASE -File
            gh release create $($release) $($files) --title "$($title)" --notes "$($message)"
        }
    } else {
        Write-Host "You don't have GitHub CLI, if you want to use release feature to it's fullest install it from here: " + "https://cli.github.com"
        Write-Host "This now just creates tag and pushes it to GitHub without anything specific"

        git tag -a "$($release)" -m $message
        git push origin "$($release)"
    }
}

function description {
    $str = @"
| Name                      | Description                                                                          |
|---------------------------|--------------------------------------------------------------------------------------|
| c(commit)                 | This is configs default. Adds a commit message and pushes to your GitHub repository. |
| b(ranch)s(witch)c(create) | Creates a new branch and switches to the new branch.                                 |
| b(ranch)s(witch)          | Switches to an existing branch.                                                      |
| b(ranch)d(elete)          | Deletes an existing branch.                                                          |
| s(tatus)                  | Shows the status of current branch.                                                  |
| p(ull)                    | Pulls the latest changes from your remote repository.                                |
| l(og)                     | Shows recent commits (default number or set with -number / -n).                      |
| autoCommit                | Use this for automatically commit (Task Scheduler)                                   |
| p(ath)                    | This is used for autoCommit to automatically commit specific folder                  |
| d(escription)             | This shows you this description in terminal                                          |
"@
    Write-Host $str
}

function autoCommit {
    Set-Location $path
    gitPushCreate
}

function holiday {
    #$language
    $now = Get-Date
    if (($now.day -eq 1 -and $now.Month -eq 1) -or ($now.day -eq 31 -and $now.Month -eq 12)) {
        Write-Host $language.newYear
    }
    elseif ($now.day -eq 14 -and $now.Month -eq 2) {
        Write-Host $language.valentine
    }
    elseif ($now.day -eq 8 -and $now.Month -eq 3) {
        Write-Host $language.womenDay
    }
    elseif ($now.day -eq 17 -and $now.Month -eq 3) {
        Write-Host $language.patrickDay
    }
    elseif ($now.day -eq 1 -and $now.Month -eq 4) {
        Write-Host $language.aprilFools
    }
    elseif ($now.day -eq 1 -and $now.Month -eq 5) {
        Write-Host $language.labourDay
    }
    elseif ($now.day -eq 31 -and $now.Month -eq 10) {
        Write-Host $language.haloween
    }
    elseif ($now.day -eq 1 -and $now.Month -eq 11) {
        Write-Host $language.saintDay
    }
    elseif ($now.day -eq 19 -and $now.Month -eq 11) {
        Write-Host $language.manDay
    }
    elseif (($now.day -eq 24 -or $now.day -eq 25) -and $now.Month -eq 12 ) {
        Write-Host $language.christmas
    }
    # I HATE THINGS THAT CHNAGES YEARLY LIKE WHY DON'T YOU JUST IDK HAVE DATE???

    elseif (($now.day -ge 22 -and $now.day -le 28) -and $now.Month -eq 11 -and $now.DayOfWeek -eq "Thursday") {
        Write-Host $language.thanksgivingUSA
    }
    elseif (($now.day -ge 8 -and $now.day -le 14) -and $now.Month -eq 11 -and $now.DayOfWeek -eq "Monday") {
        Write-Host $language.thanksgivingCAN
    }
}

function runModification {
    param(
        [string]$modname
    )

    . "$PSScriptRoot\modLoader.ps1"

    $found = loadMods $modname

    return $found
}

function writeMods {
    . "$PSScriptRoot\modLoader.ps1"

    $names = getNames
    $versions = getVersions
    $gVersions = getGVersions

    $modCount = $names.Length
    $modCount
    $names += getNames "actions"
    $versions += getVersions "actions"
    $gVersions += getGVersions "actions"

    Write-Host ("{0,-4} {1,-25} {2,-12} {3,-12} {4}" -f "#", "$($language.modName)", "$($language.local)", "$($language.gustVer)", "$($language.note)")
    Write-Host ("-" * 70)

    for ($i = 0; $i -lt $names.Length; $i++) {
        $bonus = ""
        $color = "Gray"

        if ($gVersions[$i] -ne $Global:version) {
            $eval = compareModVersions $Global:version $gVersions[$i]

            if ($eval -eq "minor" -and ($eval -ne $true)) {
                $bonus = $language.minorDiff
                $color = "Yellow"
            }
            elseif ($eval -eq "release or major" -and ($eval -ne $true)) {
                $bonus = $language.majorDiff
                $color = "Red"
            }
        }

        if ($i -eq $modCount) {
            Write-Host ""
            Write-Host ("{0,-4} {1,-25} {2,-12} {3,-12} {4}" -f "#", "$($language.actionName)", "$($language.local)", "$($language.gustVer)", "$($language.note)")
            Write-Host ("-" * 70)
            #Write-Host $line -ForegroundColor $color
            $line = ("[{0}] {1,-25} {2,-12} {3,-12} {4}" -f ($i + 1 - $modCount), $names[$i], "($($versions[$i]))", $gVersions[$i], $bonus)
        }
        elseif ($i -gt $modCount) {
            $line = ("[{0}] {1,-25} {2,-12} {3,-12} {4}" -f ($i + 1 - $modCount), $names[$i], "($($versions[$i]))", $gVersions[$i], $bonus)
        }
        else {
            $line = ("[{0}] {1,-25} {2,-12} {3,-12} {4}" -f ($i + 1), $names[$i], "($($versions[$i]))", $gVersions[$i], $bonus)
        }

        Write-Host $line -ForegroundColor $color
    }
}

function update {
    . "$PSScriptRoot\install.ps1" $False
    install
    v = $Global:version
    . "$PSScriptRoot\temp\gust.ps1" "NOMODE"
    Write-Host $(getVersion) $v
    if ($(getVersion) -ne $v) {
        robocopy $PSScriptRoot\temp $PSScriptRoot /E /IS /IT
    }
    Remove-Item -Path $PSScriptRoot/temp -Recurse -Force
}

function getVersion {
    return $Global:version
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

. "$PSScriptRoot\modAPI.ps1"

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