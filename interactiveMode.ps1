class inputs{
    [string]$mode
    [string]$message
    [string]$gitURL
    [string]$branch
    [int]$number

    inputs() {
        . "$PSScriptRoot/gust.ps1" "NOMODE"
        $cfg = getCurrentConf
        $this.mode = $cfg.defaultMode
        $this.message = $cfg.defaultCommitMessage
        $this.gitURL = "NOT SET"
        $this.branch = $cfg.defaultBranch
        $this.number = $cfg.defaultLogLength
    }

    [void]execute(){
        . "$PSScriptRoot/gust.ps1" -m $this.mode -c $this.message -u $this.gitURL -b $this.branch -n $this.number
    }
}

$index = 1
$commands = @(
    ".help", ".run", ".exit", ".clear"
)

$inputVaNames = @(
    "mode", "message", "gitURL", "branch", "number"
)

function startInteractive{
    . "$PSScriptRoot/gust.ps1" "NOMODE"
    $running = $true
    Clear-Host
    introWriter

    $inputs = [inputs]::new()

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

                    if ($index -lt 1){
                        $index = 1
                    }
                }
                "DownArrow" {
                    $index += +1
                    if ($index -ge $commands.Length + 1){
                        $index = $commands.Length + 1
                    }
                }
                "Enter" {
                    $comm = $commands[$index - 1]
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
            Clear-Host
            $localIndex = 1
            inputWriter $localIndex $inputs
            $run = $true
            while ($run){
                $key = [System.Console]::ReadKey($true)
                switch ($key.Key) {
                    "UpArrow" {
                        $localIndex += -1

                        if ($localIndex -lt 1){
                            $localIndex = 1
                        }
                    }
                    "DownArrow" {
                        $localIndex += +1
                        if ($localIndex -ge 6){
                            $localIndex = 6
                        }
                    }
                    "Enter" {
                        if ($localIndex -eq 6){
                            $inputs.execute()
                            $run = $false
                            $running = $false
                        }
                        else{
                            $inputs.PSObject.Properties[$inputVaNames[$localIndex - 1]].Value = Read-Host "Input your value"
                        }
                    }
                    default {

                    }
                }
                Clear-Host
                inputWriter $localIndex $inputs
            }
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
            Write-Host "  ---- INTERACTIVE MODE COMMANDS ----"
            Write-Host "  .help or 1           - Shows this menu"
            Write-Host "  .run [command] or 2  - runs GUST command"
            Write-Host "  .exit or 3           - Quit interactive mode"
            Write-Host "  .clear or 4          - Clears interactive mode"
            Write-Host "  .update or 5         - Updates GUST"
            Write-Host ""
            Write-Host "Press any button to exit." -NoNewline
            while ($run){
                $key = [System.Console]::ReadKey($true)
                switch ($key.Key) {
                    default {
                        $run = $false
                    }
                }
            }
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

function execute{

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

function inputWriter {
    param(
        $localIndex,
        $inputs
    )
    Write-Host "--------------------------------------------"
    Write-Host "Press enter to change the value"
    Write-Host "of property you want to change"
    if ($localIndex -eq 1) {
        Write-Host "Mode ('m') - Value: $($inputs.mode)" -ForegroundColor Red
    } else {
        Write-Host "Mode ('m') - Value: $($inputs.mode)"
    }
    if ($localIndex -eq 2) {
        Write-Host "Message ('c') - Value: $($inputs.message)" -ForegroundColor Red
    } else {
        Write-Host "Message ('c') - Value: $($inputs.message)"
    }
    if ($localIndex -eq 3) {
        Write-Host "gitURL ('u') - Value: $($inputs.gitURL)" -ForegroundColor Red
    } else {
        Write-Host "gitURL ('u') - Value: $($inputs.gitURL)"
    }
    if ($localIndex -eq 4) {
        Write-Host "Branch ('b') - Value: $($inputs.branch)" -ForegroundColor Red
    } else {
        Write-Host "Branch ('b') - Value: $($inputs.branch)"
    }
    if ($localIndex -eq 5) {
        Write-Host "Number ('n') - Value: $($inputs.number)" -ForegroundColor Red
    } else {
        Write-Host "Number ('n') - Value: $($inputs.number)"
    }
    if ($localIndex -eq 6) {
        Write-Host "Execute command" -ForegroundColor Red
    } else {
        Write-Host "Execute command"
    }
    Write-Host "--------------------------------------------"
}