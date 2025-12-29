function getVersion {
    return $Global:version
}

function holiday {
    #$language
    $now = Get-Date
    if (($now.day -eq 1 -and $now.Month -eq 1) -or ($now.day -eq 31 -and $now.Month -eq 12)) {
        Write-Host $language.newYear
    }
    elseif ($now.day -eq 14 -and $now.Month -eq 2) {
        Write-Host $language.valentine
    }
    elseif ($now.day -eq 8 -and $now.Month -eq 3) {
        Write-Host $language.womenDay
    }
    elseif ($now.day -eq 17 -and $now.Month -eq 3) {
        Write-Host $language.patrickDay
    }
    elseif ($now.day -eq 1 -and $now.Month -eq 4) {
        Write-Host $language.aprilFools
    }
    elseif ($now.day -eq 1 -and $now.Month -eq 5) {
        Write-Host $language.labourDay
    }
    elseif ($now.day -eq 31 -and $now.Month -eq 10) {
        Write-Host $language.haloween
    }
    elseif ($now.day -eq 1 -and $now.Month -eq 11) {
        Write-Host $language.saintDay
    }
    elseif ($now.day -eq 19 -and $now.Month -eq 11) {
        Write-Host $language.manDay
    }
    elseif (($now.day -eq 24 -or $now.day -eq 25) -and $now.Month -eq 12 ) {
        Write-Host $language.christmas
    }
    # I HATE THINGS THAT CHNAGES YEARLY LIKE WHY DON'T YOU JUST IDK HAVE DATE???

    elseif (($now.day -ge 22 -and $now.day -le 28) -and $now.Month -eq 11 -and $now.DayOfWeek -eq "Thursday") {
        Write-Host $language.thanksgivingUSA
    }
    elseif (($now.day -ge 8 -and $now.day -le 14) -and $now.Month -eq 11 -and $now.DayOfWeek -eq "Monday") {
        Write-Host $language.thanksgivingCAN
    }
}

function gitIgnore {
    if (Test-Path ".gitignore"){
        $wasFound = $false, $false
        $toFind = "RELEASE", "RELEASE/*"
        $c = (Get-Content ".\.gitignore")
        $nwLineCreate = $true
        for ($j = 0; $j -lt $c.Count; $j++){
            $line = $c[$j]

            if ($j -eq $c.Count -1){
                if (-not $line -match "^[\s]*$"){
                    $nwLineCreate = $false
                }
            }

            for ($i = 0; $i -lt $toFind.Length; $i++){
                if ($line -eq $toFind[$i]){
                    $wasFound[$i] = $true
                }
            }
        }
        
        if ($nwLineCreate){
            "" | Out-File -FilePath ".\.gitignore" -Append -Encoding utf8 -NoNewline
        }

        for ($i = 0; $i -lt $toFind.Length; $i++){
            if (-not $wasFound[$i]){
                $toFind[$i] | Out-File -FilePath ".\.gitignore" -Append -Encoding utf8 
            }
        }
    }
    else {
        New-Item ".\.gitignore"
        "RELEASE" | Out-File -FilePath ".\.gitignore" -Append -Encoding utf8
        "RELEASE/*" | Out-File -FilePath ".\.gitignore" -Append -Encoding utf8
    }
}

function description {
    $str = @"
 ------------------------------------------------------------------------------------------------------------------
|                                                      Modes                                                       |
 ------------------------------------------------------------------------------------------------------------------ 
| Name                      | Description                                                                          |
|---------------------------|--------------------------------------------------------------------------------------|
| c(ommit)                  | This is configs default. Adds a commit message and pushes to your GitHub repository. |
| b(ranch)s(witch)c(create) | Creates a new branch and switches to the new branch.                                 |
| b(ranch)s(witch)          | Switches to an existing branch.                                                      |
| b(ranch)d(elete)          | Deletes an existing branch.                                                          |
| s(tatus)                  | Shows the status of current branch.                                                  |
| p(ull)                    | Pulls the latest changes from your remote repository.                                |
| l(og)                     | Shows recent commits (default number or set with -number / -n).                      |
| autoCommit                | Use this for automatically commit (Task Scheduler)                                   |
| d(escription)             | This shows you this description in terminal                                          |
 ------------------------------------------------------------------------------------------------------------------
"@
    Write-Host $str
}

function writeMods {
    . "$PSScriptRoot\source\modLoader.ps1"

    $names = getNames
    $versions = getVersions
    $gVersions = getGVersions

    $modCount = $names.Length
    $modCount
    $names += getNames "actions"
    $versions += getVersions "actions"
    $gVersions += getGVersions "actions"

    Write-Host ("{0,-4} {1,-25} {2,-12} {3,-12} {4}" -f "#", "$($language.modName)", "$($language.local)", "$($language.gustVer)", "$($language.note)")
    Write-Host ("-" * 70)

    for ($i = 0; $i -lt $names.Length; $i++) {
        $bonus = ""
        $color = "Gray"

        if ($gVersions[$i] -ne $Global:version) {
            $eval = compareModVersions $Global:version $gVersions[$i]

            if ($eval -eq "minor" -and ($eval -ne $true)) {
                $bonus = $language.minorDiff
                $color = "Yellow"
            }
            elseif ($eval -eq "release or major" -and ($eval -ne $true)) {
                $bonus = $language.majorDiff
                $color = "Red"
            }
        }

        if ($i -eq $modCount) {
            Write-Host ""
            Write-Host ("{0,-4} {1,-25} {2,-12} {3,-12} {4}" -f "#", "$($language.actionName)", "$($language.local)", "$($language.gustVer)", "$($language.note)")
            Write-Host ("-" * 70)
            #Write-Host $line -ForegroundColor $color
            $line = ("[{0}] {1,-25} {2,-12} {3,-12} {4}" -f ($i + 1 - $modCount), $names[$i], "($($versions[$i]))", $gVersions[$i], $bonus)
        }
        elseif ($i -gt $modCount) {
            $line = ("[{0}] {1,-25} {2,-12} {3,-12} {4}" -f ($i + 1 - $modCount), $names[$i], "($($versions[$i]))", $gVersions[$i], $bonus)
        }
        else {
            $line = ("[{0}] {1,-25} {2,-12} {3,-12} {4}" -f ($i + 1), $names[$i], "($($versions[$i]))", $gVersions[$i], $bonus)
        }

        Write-Host $line -ForegroundColor $color
    }
}

function update {
    . "$PSScriptRoot\install.ps1" $False
    install
    v = $Global:version
    . "$PSScriptRoot\temp\gust.ps1" "NOMODE"
    Write-Host $(getVersion) $v
    if ($(getVersion) -ne $v) {
        robocopy $PSScriptRoot\temp $PSScriptRoot /E /IS /IT
    }
    Remove-Item -Path $PSScriptRoot\temp -Recurse -Force
}