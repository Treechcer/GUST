$index = 1
$commands = @(
    ".help", ".run", ".exit", ".clear"
)

function startInteractive{
    . "$PSScriptRoot/gust.ps1" "NOMODE"
    $running = $true
    Clear-Host
    introWriter
    while ($running){
        #Write-Host -NoNewline "GUST> Enter command: "
        #$comm = Read-Host
        #$comm = $comm.Trim()
        $run = $true
        while ($run){
            $key = [System.Console]::ReadKey($true)
            switch ($key.Key) {
                "UpArrow" {
                    $index += -1
                }
                "DownArrow" {
                    $index += +1
                }
                "Enter" {
                    $comm = $commands[$index - 1]
                    Write-Host $comm
                    $run = $false
                }
                default {

                }
            }
            Clear-Host
            introWriter
        }
        if ($comm -eq ".exit" -or $comm -eq "3"){
            $running = $false
        }
        elseif ($comm -match "^\.run" -or $comm[0] -eq "2") {
            #NOT WORKING I HATE THIS HASHFAJFAFHGBLOAHFBAKJFG AL I'LL DO IT ONE DAY I TRUST IN MYSELF
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
    if ($index -eq 1) {
        Write-Host "Commands: 1) .help - help commands" -ForegroundColor Red
    } else {
        Write-Host "Commands: 1) .help - help commands"
    }

    if ($index -eq 2) {
        Write-Host "          2) .run [command] - runs command" -ForegroundColor Red
    } else {
        Write-Host "          2) .run [command] - runs command"
    }

    if ($index -eq 3) {
        Write-Host "          3) .exit - exits interactive mode" -ForegroundColor Red
    } else {
        Write-Host "          3) .exit - exits interactive mode"
    }

    if ($index -eq 4) { 
        Write-Host "          4) .clear - clear the console" -ForegroundColor Red
    } else {
        Write-Host "          4) .clear - clear the console"
    }

    if ($index -eq 5) { 
        Write-Host "          5) .update - updates GUST" -ForegroundColor Red
    } else {
        Write-Host "          5) .update - updates GUST"
    }
    Write-Host "--------------------------------------------"
}