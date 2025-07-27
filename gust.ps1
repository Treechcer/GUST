param(
    [Alias("c")]
    [string]$message,   # commit message

    [Alias("u")]
    [string]$gitURL,     # URL, not necessary if you have alread "git add ."

    [Alias("m")]
    [string]$otherModes, # this adds more possibilities / "modes"

    [Alias("b")]
    [string]$branch # this is the name of the branch you'll use if you do branch create switch (bcs) mode
)

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
        Write-Host "--------------------------------------------------------------------------------------------------"
        Write-Host "Please set your username and/or email with:"
        Write-Host "git config --global user.name 'your name'"
        Write-Host "git config --global user.email 'your email'"
        Write-Host ""
        Write-Host "If you want to set local email and username, just skip '--global' and you'll set them for your repository"
        Write-Host "--------------------------------------------------------------------------------------------------"
        exit 1
    }
}

function gitPushCreate{
    if ($gitURL){
        git init 1>$null 3>$null 4>$null 5>$null 6>$null
        git remote add origin "$gitURL.git" 1>$null 3>$null 4>$null 5>$null 6>$null
        git pull origin main --allow-unrelated-histories 1>$null 3>$null 4>$null 5>$null 6>$null
        git push --set-upstream origin main 1>$null 3>$null 4>$null 5>$null 6>$null
    }

    $errAdd = git add . 1>$null 3>$null 4>$null 5>$null 6>$null

    $errCom = git commit -m "$message" 1>$null 3>$null 4>$null 5>$null 6>$null

    git push 1>$null 3>$null 4>$null 5>$null 6>$null
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

    $err0 = git branch -d $branch 2>&1
    if ($LASTEXITCODE -ne 0){
        git branch
        Write-Host "$branch could not be safely delted"
    }
    else{
        Write-Host "$branch was deleted"
    }
}

function behaviourCheck{
    #$otherModes
    switch ($otherModes){
        "" { # just git add, commit and push :)
            gitPushCreate
        }
        "bcs" { # branch create switch
            branchCreateSwitch
        }
        "bs" { # branch switch
            branchSwitch
        }
        "bd" { # branch delte
            branchDelete
        }
    }
}

checkUser
behaviourCheck