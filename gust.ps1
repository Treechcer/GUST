param(
    [Alias("c")]
    [string]$message,    # commit message

    [Alias("u")]
    [string]$gitURL,     # URL, not necessary if you have alread "git add ."

    [Alias("m")]
    [string]$otherModes, # this adds more possibilities / "modes"

    [Alias("b")]
    [string]$branch,     # this is the name of the branch you'll use if you do branch create switch (bcs) mode

    [Alias("n")]
    [int]$number         # this is for any input that needs number, it has some default based on context
)

$configPath = "$PSScriptRoot/config.json"

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
        defaultMode = "c"
    }
}

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

function gitPushCreate{
    git pull --no-edit

    if ($gitURL){
        if (-not $branch){
            $branch = $config.defaultBranch
        }

        if (-not (Test-Path -Path ".git" -PathType Container)) {
            git init
        }

        git remote add $config.defaultRemote "$gitURL.git"

        if (config.autoPullBeforePush){
            git pull $config.defaultRemote $branch --allow-unrelated-histories 
        }
        git push --set-upstream $config.defaultRemote $branch 
    }

    $errAdd = git add . 

    if (-not $message){
        $message = $config.defaultCommitMessage
    }

    $errCom = git commit -m "$message" 

    git push 
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
    #$otherModes

    if ($otherModes -match "b(r(a(n(c(h)?)?)?)?)?"){
        if ($otherModes -match "d(e(l(e(t(e)?)?)?)?)?"){
            $otherModes = "bd"
        }
        elseif($otherModes -match "c(r(e(a(t(e)?)?)?)?)?" -and $otherModes -match "s(w(i(t(c(h)?)?)?)?)?"){
            $otherModes = "bsc"
        }
        elseif($otherModes -match "s(w(i(t(c(h)?)?)?)?)?"){
            $otherModes = "bs"
        }
    }
    elseif ($otherModes -match "p(u(l(l)?)?)?"){
        $otherModes = "p"
    }
    elseif ($otherModes -match "c(o(m(m(i(t)?)?)?)?)?"){
        $otherModes = "c"
    }
    elseif ($otherModes -match "l(o(g)?)?"){
        $otherModes = "log"
    }
    elseif ($otherModes -match "s(t(a(t(u(s)?)?)?)?)?"){
        $otherModes = "s"
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
        default {
            Write-Host "$otherModes is not correct input"
        }
    }
}

checkUser
behaviourCheck