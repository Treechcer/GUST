function issueCheck {
    #TODO documentation
    gh issue list
    Write-Host "`n-----"
    gh issue status
}

function PRCheck {
    #TODO documentation
    gh pr list
    Write-Host "`n-----"
    gh pr status
}

function PRCreate {
    #TODO documentation

    . "$PSScriptRoot\gitFuncs.ps1"
    gitPushCreate

    if ($null -eq $who){
        $who = $config.defaultWho
    }

    if ($null -eq $branch){
        $who = $config.defaultBranch
    }

    if ($null -eq $description){
        $who = $config.defaultDescriptionPR
    }

    if ($null -eq $title){
        $who = $config.defaultPRTitle
    }

    gh pr create -a $who -B $branch -b $description -t $title
}

function createRepo {
    #TODO document
    $publicity = ""
    if ($public -or $null -eq $public){
        $publicity = "--public"
    }
    else{
        $publicity = "--private"
    }

    $descriptionArgument = ""
    if ($null -ne $description){
        if ($description -match "\s"){
            $descriptionArgument += "-d `"$description`""
        }
        else{
            $descriptionArgument += "-d $description"
        }
    }

    $name = $name.Replace(" ", "-")
    
    $remote = "--remote=$($config.defaultRemote)"

    Write-Host "gh repo create $name $publicity $licenseArg $descriptionArgument --source=. $remote"
    
    git init
    
    gh repo create $name $publicity $licenseArg $descriptionArgument --source=. $remote
}

function release {
    gitIgnore

    if ($null -eq $release){
        $release = $config.defaultRelease
    }

    if ($null -eq $title){
        $title = $config.defaultTitle
    }

    if ($null -eq $message){
        $message = $config.defaultReleaseMessage
    }

    if (Get-Command gh -ErrorAction SilentlyContinue) {
        New-Item RELEASE -ItemType Directory -Force
        if ($null -eq (Get-ChildItem ".\RELEASE\")){
            Write-Host $language.noReleaseFolder
        }
        else{
            $files = Get-ChildItem .\RELEASE -File
            gh release create $($release) $($files) --title "$($title)" --notes "$($message)"
        }
    } else {
        Write-Host $language.noGHCLI + "https://cli.github.com"
        Write-Host $language.tagCreate

        git tag -a "$($release)" -m $message
        git push origin "$($release)"
    }
}