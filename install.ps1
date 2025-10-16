param(
    [Boolean]$install = $True
)

function install{
    mkdir temp
    git clone https://github.com/Treechcer/GUST temp
}

function installAuto {
    install
    robocopy $PSScriptRoot\temp $PSScriptRoot /E /IS /IT
    Remove-Item -Path $PSScriptRoot/temp -Recurse -Force
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($currentPath -notlike "*$PSScriptRoot*") {
        [Environment]::SetEnvironmentVariable("Path", "$currentPath;$PSScriptRoot", "User")
        Write-Host "Gust, from folder $PSScriptRoot was added do PATH. Restart your terminal."
    }
    else{
        Write-Host "Already in path"
    }
}

if ($install){
    installAuto
}