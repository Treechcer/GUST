function gitPushCreate {
    git pull --no-edit

    if ($gitURL) {
        if (-not $branch) {
            $branch = $config.defaultBranch
        }

        if (-not (Test-Path -Path ".git" -PathType Container)) {
            git init
        }

        git branch -M $branch

        if (-not ("$gitURL" -match "\\.git")){
            $gitURL = $gitURL + ".git"
        }
        
        #$gitURL

        git remote add $config.defaultRemote "$gitURL"

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

    git push --set-upstream $config.defaultRemote $branch

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

    git checkout "$branch"
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

function revertCommit {
    git revert HEAD -m "$message"
    git push
}

function autoCommit {
    if ($null -eq $path){
        $path = $config.defaultPath
    }

    Set-Location $path
    gitPushCreate
}