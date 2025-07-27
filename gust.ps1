param(
    [string]$message,   # commit message
    [string]$gitURL     # URL, not necessary if you have alread "git add ."
)

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

if ($gitURL){
    git init *> $null
    git remote add origin "$gitURL.git" *> $null
    git pull origin main --allow-unrelated-histories *> $null
    git push --set-upstream origin main *> $null
}

$errAdd = git add . *> $null

$errCom = git commit -m "$message" *> $null

git push *> $null