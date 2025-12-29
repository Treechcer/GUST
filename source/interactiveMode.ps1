#what was I smoking while makig this? This could've been dome like 100 times easier... This sucks and I'm not fixing it

class inputs {
    [string]$mode
    [string]$message
    [string]$gitURL
    [string]$branch
    [int]$number
    [string]$path
    [string]$release
    [string]$title

    inputs() {
        . "$PSScriptRoot/../gust.ps1" "NOMODE"
        $cfg = getCurrentConf
        $this.mode = $cfg.defaultMode
        $this.message = $cfg.defaultCommitMessage
        $this.gitURL = "NOT SET"
        $this.branch = $cfg.defaultBranch
        $this.number = $cfg.defaultLogLength
        $this.path = $cfg.defaultPath
        $this.release = $cfg.defaultRelease
        $this.title = $cfg.defaultTitle
    }

    [void]execute() {
        . "$PSScriptRoot/../gust.ps1" -m $this.mode -c $this.message -u $this.gitURL -b $this.branch -n $this.number
    }
}

$index = 1
$commands = @(
    ".help", ".run", ".exit", ".clear"
)

$inputVaNames = @(
    "mode", "message", "gitURL", "branch", "number", "path", "release", "title"
)

function startInteractive {
    . "$PSScriptRoot/../gust.ps1" "NOMODE"
    $script:language = getLanguageJSON "english"
    $running = $true
    introWriter
    $inputs = [inputs]::new()

    while ($running) {
        #Write-Host -NoNewline "GUST> Enter command: "
        #$comm = Read-Host
        #$comm = $comm.Trim()
        $run = $true
        while ($run) {
            $key = [System.Console]::ReadKey($true)
            switch ($key.Key) {
                "UpArrow" {
                    if ($index -le 1) {
                        $index = 1
                    }
                    else {
                        $index += -1
                    }
                }
                "DownArrow" {
                    if ($index -ge $commands.Length + 1) {
                        $index = $commands.Length + 1
                    }
                    else {
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
        if ($comm -eq ".exit" -or $comm -eq "3") {
            $running = $false
        }
        elseif ($comm -match "^\.run" -or $comm[0] -eq "2") {
            Clear-Host
            $localIndex = 1
            inputWriter $localIndex $inputs
            $run = $true
            while ($run) {
                if ($localIndex -le 1){
                    $localIndex = 1
                }
                $key = [System.Console]::ReadKey($true)
                switch ($key.Key) {
                    "UpArrow" {
                        if ($localIndex -le 1) {
                            $localIndex = 1
                        }
                        else {
                            $localIndex += -1
                        }
                    }
                    "DownArrow" {
                        if ($localIndex -ge 9) {
                            $localIndex = 9
                        }
                        else {
                            $localIndex += +1
                        }
                    }
                    "Enter" {
                        if ($localIndex -eq 9) {
                            $inputs.execute()
                            $run = $false
                        }
                        else {
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
        elseif ($comm -match "^\.update" -or $comm -eq "5") {
            . "$PSScriptRoot\..\gust.ps1" -update
        }
        elseif ($comm -eq ".help" -or $comm -eq "1") {
            for ($iterator = 0; $iterator -lt $language.gustInteractiveHelp.Count; $iterator++) {
                Write-Host $language.gustInteractiveHelp[$iterator]
            }
            . "$PSScriptRoot\modLoader.ps1"
            $modHelpPages = getHelpPages

            for ($i = 0; $i -lt $modHelpPages.helpPages.Count; $i++){
                if ($modHelpPages[$i].helpPages -ne ""){
                    #Write-Host $modHelpPages[$i].name
                    $len = 35
                    $couter = [Math]::Floor([decimal](($len - $modHelpPages[$i].name.Length -2) / 2))
                    $str = "-" * $couter
                    Write-Host "  $($str) $($modHelpPages[$i].name) $($str)" -foreGroundColor Green
                    Write-Host "  $($modHelpPages[$i].helpPages)";  
                    Write-Host
                }
            }

            Write-Host "$($language.buttonToExit)" -NoNewline -ForegroundColor Yellow
            while ($run) {
                $key = [System.Console]::ReadKey($true)
                switch ($key.Key) {
                    default {
                        $run = $false
                    }
                }
            }
        }
        elseif ($comm -eq ".clear" -or $comm -eq "4") {
            Clear-Host
            introWriter
        }
        else {
            Write-Host "'$($comm)' is not recognised command"
        }
    } 
}

function introWriter {
    Write-Host "--------------------------------------------"
    Write-Host "$($language.interactiveMode) $($Global:version)"
    if ($index -eq 1) {
        Write-Host "$($language.commands):  1) $($language.help)" -ForegroundColor Red
    }
    else {
        Write-Host "$($language.commands):  1) $($language.help)"
    }

    if ($index -eq 2) {
        Write-Host "          2) $($language.run)" -ForegroundColor Red
    }
    else {
        Write-Host "          2) $($language.run)"
    }

    if ($index -eq 3) {
        Write-Host "          3) $($language.exit)" -ForegroundColor Red
    }
    else {
        Write-Host "          3) $($language.exit)"
    }

    if ($index -eq 4) { 
        Write-Host "          4) $($language.clear)" -ForegroundColor Red
    }
    else {
        Write-Host "          4) $($language.clear)"
    }

    if ($index -eq 5) { 
        Write-Host "          5) $($language.update)" -ForegroundColor Red
    }
    else {
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
    }
    else {
        Write-Host "Mode ('m') - $($language.value): $($inputs.mode)"
    }
    if ($localIndex -eq 2) {
        Write-Host "Message ('c') - $($language.value): $($inputs.message)" -ForegroundColor Red
    }
    else {
        Write-Host "Message ('c') - $($language.value): $($inputs.message)"
    }
    if ($localIndex -eq 3) {
        Write-Host "gitURL ('u') - $($language.value): $($inputs.gitURL)" -ForegroundColor Red
    }
    else {
        Write-Host "gitURL ('u') - $($language.value): $($inputs.gitURL)"
    }
    if ($localIndex -eq 4) {
        Write-Host "Branch ('b') - $($language.value): $($inputs.branch)" -ForegroundColor Red
    }
    else {
        Write-Host "Branch ('b') - $($language.value): $($inputs.branch)"
    }
    if ($localIndex -eq 5) {
        Write-Host "Number ('n') - $($language.value): $($inputs.number)" -ForegroundColor Red
    }
    else {
        Write-Host "Number ('n') - $($language.value): $($inputs.number)"
    }


    if ($localIndex -eq 6) {
        Write-Host "Path ('p') - $($language.value): $($inputs.path)" -ForegroundColor Red
    }
    else {
        Write-Host "Path ('p') - $($language.value): $($inputs.path)"
    }
    if ($localIndex -eq 7) {
        Write-Host "Release ('r') - $($language.value): $($inputs.release)" -ForegroundColor Red
    }
    else {
        Write-Host "Release ('r') - $($language.value): $($inputs.release)"
    }
    if ($localIndex -eq 8) {
        Write-Host "Title ('t') - $($language.value): $($inputs.title)" -ForegroundColor Red
    }
    else {
        Write-Host "Title ('t') - $($language.value): $($inputs.title)"
    }


    if ($localIndex -eq 9) {
        Write-Host "$($language.exeCmd)" -ForegroundColor Red
    }
    else {
        Write-Host "$($language.exeCmd)"
    }
    Write-Host "--------------------------------------------"
}