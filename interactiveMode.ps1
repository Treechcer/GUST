function startInteractive{
    . "$PSScriptRoot/gust.ps1"
    $running = $true
    Clear-Host
    introWriter
    while ($running){
        Write-Host -NoNewline "GUST> Enter command: "
        $comm = Read-Host
        $comm = $comm.Trim()

        if ($comm -eq ".exit" -or $comm -eq "3"){
            $running = $false
        }
        elseif ($comm -match "^.run" -or $comm[0] -eq "2") {
            # DAMN I CAN'T FIGURE THIS OUT!!! I WANT MOD SUPPORT TOO, I CAN DO IT WITHOUT IT EASILY
        }
        elseif ($comm -match "^\.update" -or $comm -eq "5"){
            . "$PSScriptRoot/gust.ps1" -update
        }
        elseif ($comm -eq ".help" -or $comm -eq "1"){
            Write-Host ""
            Write-Host "Available GUST commands:"
            Write-Host "  c [message]         - Commit 'n' push"
            Write-Host "  p                   - GitHub pull abstraction"
            Write-Host "  s                   - Show git status and branches"
            Write-Host "  log [num]           - Show git log (either input num or default count from config)"
            Write-Host "  bcs [branch]        - Create and switch to new branch"
            Write-Host "  bs [branch]         - Switch to existing branch"
            Write-Host "  bd [branch]         - Delete a branch"
            Write-Host "  swp                 - Switch profile"
            Write-Host "  cnp                 - Create new profile"
            Write-Host "  mods                - List mods"
            Write-Host "  update              - Update Gust"
            Write-Host ""
            Write-Host "  ---- INTERACtIVE MODE COMMANDS ----"
            Write-Host "  .help or 1           - Shows this menu"
            Write-Host "  .run [command] or 2  - runs GUST command"
            Write-Host "  .exit or 3           - Quit interactive mode"
            Write-Host "  .clear or 4          - Clears interactive mode"
            Write-Host "  .update or 5         - Updates GUST"
            Write-Host ""
        }
        elseif ($comm -eq ".clear" -or $comm -eq "4"){
            Clear-Host
            introWriter
        }
        else{
            Write-Host "'$($comm)' is not recognised command"
        }
    } 
}

function introWriter {
    Write-Host "--------------------------------------------"
    Write-Host "GUST INTERACTIVE MODE - VER $($Global:version)"
    Write-Host "Commands: 1) .help - help commands"
    Write-Host "          2) .run [command] - runs command"
    Write-Host "          3) .exit - exits interactive mode"
    Write-Host "          4) .clear - clear the console"
    Write-Host "--------------------------------------------"
}