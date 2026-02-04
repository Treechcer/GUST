function issueCreateNew {
    if ($null -eq $who){
        $who = $config.defaultWho
    }

    if ($null -eq $label){
        $label = $config.defaultLabelsIssue
    }

    if ($null -eq $description){
        $description = $config.defaultDescriptionPR
    }

    if ($null -eq $title){
        $title = $config.defaultPRTitle
    }

    gh issue create -a "$who" -b "$description" -t "$title" -l "$label"
}

function issueCheck {
    gh issue list
    Write-Host "`n-----"
    gh issue status
}

function PRCheck {
    gh pr list
    Write-Host "`n-----"
    gh pr status
}

function PRCreate {
    . "$PSScriptRoot\gitFuncs.ps1"
    gitPushCreate

    if ($null -eq $who){
        $who = $config.defaultWho
    }

    if ($null -eq $branch){
        $branch = $config.defaultBranch
    }

    if ($null -eq $description){
        $description = $config.defaultDescriptionPR
    }

    if ($null -eq $title){
        $title = $config.defaultPRTitle
    }

    if ($null -eq $label){
        $label = $config.defaultLabelsPR
    }

    gh pr create -a "$who" -B $branch -b "$description" -t "$title" -l "$label"
}

function createRepo {
    $publicity = ""
    if ($public -or $null -eq $public -or ($public.ToLower()) -eq "true"){
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

    if ($null -eq $branch -or $branch -eq ""){
        $branch = $config.defaultBranch
    }

    $name = $name.Replace(" ", "-")
    
    $remote = "--remote=$($config.defaultRemote)"
    
    #Write-Host git push --set-upstream $($config.defaultRemote) $branch

    git init
    gh repo create $name $publicity $descriptionArgument --source=. $remote
    #git add .
    #git commit -m $config.defaultCommitMessage
    #git push --set-upstream $config.defaultRemote $branch
    #gitPushCreate

    #doesn't work the commitng auto part so you just have to commit it yourself idc

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