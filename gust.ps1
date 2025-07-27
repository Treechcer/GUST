param(
    [string]$message,   # commit message
    [string]$gitURL     # URL, not necessary if you have alread "git add ."
)

#test

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

$errAdd = git add .

if ($errAdd -match "fatal: not a git repository") {
    git init
    git add .
}

$errCom = git commit -m "$message"

$errPus = git push 2>&1
if ($errPus -match "fatal: No configured push destination."){
    git remote add origin "$gitURL"
    git push
    Write-Host "$errPus"
}