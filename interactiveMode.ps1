function startInteractive{
    . "$PSScriptRoot/gust.ps1"
    $running = $true
    while ($running){
        Write-Host "stop?"
        $test = Read-Host
        if ($test -eq "stop"){
            $running = $false
        } 
    } 
}