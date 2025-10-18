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
    $script:language = getLanguageJSON "english"
    $running = $true
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
                    if ($index -lt 1){
                        $index = 1
                    }
                    else{
                        $index += -1
                    }
                }
                "DownArrow" {
                    if ($index -ge $commands.Length + 1){
                        $index = $commands.Length + 1
                    }
                    else{
                        $index += +1
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
                        if ($localIndex -lt 1){
                            $localIndex = 1
                        }
                        else{
                            $localIndex += -1
                        }
                    }
                    "DownArrow" {
                        if ($localIndex -ge 6){
                            $localIndex = 6
                        }
                        else{
                            $localIndex += +1
                        }
                    }
                    "Enter" {
                        if ($localIndex -eq 6){
                            $inputs.execute()
                            $run = $false
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
            for ($iterator = 0; $iterator -lt $language.gustInteractiveHelp.Count; $iterator++) {
                Write-Host $language.gustInteractiveHelp[$iterator]
            }
            Write-Host "$($language.buttonToExit)" -NoNewline
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

function introWriter {
    Write-Host "--------------------------------------------"
    Write-Host "$($language.interactiveMode) $($Global:version)"
    if ($index -eq 1) {
        Write-Host "$($language.commands):  1) $($language.help)" -ForegroundColor Red
    } else {
        Write-Host "$($language.commands): 1) $($language.help)"
    }

    if ($index -eq 2) {
        Write-Host "          2) $($language.run)" -ForegroundColor Red
    } else {
        Write-Host "          2) $($language.run)"
    }

    if ($index -eq 3) {
        Write-Host "          3) $($language.exit)" -ForegroundColor Red
    } else {
        Write-Host "          3) $($language.exit)"
    }

    if ($index -eq 4) { 
        Write-Host "          4) $($language.clear)" -ForegroundColor Red
    } else {
        Write-Host "          4) $($language.clear)"
    }

    if ($index -eq 5) { 
        Write-Host "          5) $($language.update)" -ForegroundColor Red
    } else {
        Write-Host "          5) $($language.update)"
    }
    Write-Host "--------------------------------------------"
}

function inputWriter {
    param(
        $localIndex,
        $inputs
    )
    Write-Host "--------------------------------------------"
    Write-Host "$($language.pressEnter)"
    Write-Host "$($language.propertyChange)"
    if ($localIndex -eq 1) {
        Write-Host "Mode ('m') - $($language.value): $($inputs.mode)" -ForegroundColor Red
    } else {
        Write-Host "Mode ('m') - $($language.value): $($inputs.mode)"
    }
    if ($localIndex -eq 2) {
        Write-Host "Message ('c') - $($language.value): $($inputs.message)" -ForegroundColor Red
    } else {
        Write-Host "Message ('c') - $($language.value): $($inputs.message)"
    }
    if ($localIndex -eq 3) {
        Write-Host "gitURL ('u') - $($language.value): $($inputs.gitURL)" -ForegroundColor Red
    } else {
        Write-Host "gitURL ('u') - $($language.value): $($inputs.gitURL)"
    }
    if ($localIndex -eq 4) {
        Write-Host "Branch ('b') - $($language.value): $($inputs.branch)" -ForegroundColor Red
    } else {
        Write-Host "Branch ('b') - $($language.value): $($inputs.branch)"
    }
    if ($localIndex -eq 5) {
        Write-Host "Number ('n') - $($language.value): $($inputs.number)" -ForegroundColor Red
    } else {
        Write-Host "Number ('n') - $($language.value): $($inputs.number)"
    }
    if ($localIndex -eq 6) {
        Write-Host "$($language.exeCmd)" -ForegroundColor Red
    } else {
        Write-Host "$($language.exeCmd)"
    }
    Write-Host "--------------------------------------------"
}