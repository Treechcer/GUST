#This mod adds a way to commit and posts onto your bluesky, you have to add your blueky handle and API key into `bluesky.json`


$modifications = @(
    "b(s(k)?)?"
)

function getModificationName{
    return "bluesky Poster"
}

function versionOfGust{
    return "0.3.3"
}

function getModificationVersion{
    return "0.1.0"
}

function getModifications{
    return $modifications
}

function behaviourSwitchCheck{
    param(
        $name
    )

    switch ($name) {
        "bsk" {
            $bluesky = "$PSScriptRoot/bluesky.json"

            if (Test-Path $bluesky){
                $bsk = Get-Content $bluesky | ConvertFrom-Json

                $BSkyAuthKey = "$($bsk.API)"
                $BSkyAccount = "$($bsk.handle)"

                $Body =
@"
    {
        "identifier": "$BSkyAccount",
        "password": "$BSkyAuthKey"
}
"@ # I had to make this... I'm not converting it from to JSON (yes I'm that lazy) 
    
                $BSkyAuthResponse = Invoke-RestMethod -Uri "https://bsky.social/xrpc/com.atproto.server.createSession" -Method Post -Body $Body -ContentType "application/json" 
                
                $AuthHeader = @{
                    "Authorization" = "Bearer $($BSkyAuthResponse.accessJwt)"
                    "Content-Type"  = "application/json"
                }
                
                $repository = git config --get remote.origin.url

                $repoName = $repository.split("/")[$repository.split("/").Count - 1]
                $name = $repository.split("/")[$repository.split("/").Count - 2]
                $commitMessage = (getMessage)

                $isPrivate = curl "https://api.github.com/repos/$name/$repoName" | ConvertFrom-Json

                #Write-Host "$($isPrivate.language)"

                if ($isPrivate.language -eq "PowerShell"){
                    $tags = @("#PowerShell", "#Scripting", "#Automation", "#Shell")
                }
                elseif ($isPrivate.language -eq "lua") {
                    $tags = @("#Lua", "#Love2D", "#IndieDev", "#GameDev")
                }
                elseif ($isPrivate.language -eq "python") {
                    $tags = @("#Python", "#Programming", "#Automation", "#Scripting")
                }
                else{
                    Write-Host "Incorrect language, not set up"
                    exit
                }

                if ($isPrivate.private){
                    Write-Host "this is private repo"
                    Write-Host "⚠️ ⚠️ ⚠️"
                    exit
                }

                $text = "Pushed new updates to $repoName!`nWith commit message as '$($commitMessage)'`n $repository`n`n#GitHub #Coding #DevLog $($tags[0]) $($tags[1]) $($tags[2]) $($tags[3])"
                
                if ($text.Length -gt 300){
                    Write-Host "Input is too long, it can't be more than 300 characters"
                    Write-Host ($text.Length)
                    exit
                }
                
                $emojiCount = 0
                $PostBody = @{
                    repo = $BSkyAccount
                    collection = "app.bsky.feed.post"
                    record = @{
                        text = $text
                        createdAt = (Get-Date).ToString("o")
                        langs = @("en-US")
                        facets = @(
                            @{
                                index = @{
                                    byteStart = $text.IndexOf($repository) + ($emojiCount * 2)
                                    byteEnd = $text.IndexOf($repository) + $repository.Length + ($emojiCount * 2)
                                }
                                features = @(
                                    @{
                                        "`$type" = "app.bsky.richtext.facet#link"
                                        uri = $repository
                                    }
                                )
                            },
                            @{
                                index = @{
                                    byteStart = $text.IndexOf("#GitHub") + ($emojiCount * 2)
                                    byteEnd = $text.IndexOf("#GitHub") + "#GitHub".Length + ($emojiCount * 2)
                                }
                                features = @(
                                    @{
                                        "`$type" = "app.bsky.richtext.facet#tag"
                                        tag = "GitHub"
                                    }
                                )
                            },
                            @{
                                index = @{
                                    byteStart = $text.IndexOf("#DevLog") + ($emojiCount * 2)
                                    byteEnd   = $text.IndexOf("#DevLog") + "#DevLog".Length + ($emojiCount * 2)
                                }
                                features = @(
                                    @{
                                        "`$type" = "app.bsky.richtext.facet#tag"
                                        tag = "DevLog"
                                    }
                                )
                            },
                            @{
                                index = @{
                                    byteStart = $text.IndexOf("#Coding") + ($emojiCount * 2)
                                    byteEnd   = $text.IndexOf("#Coding") + "#Coding".Length + ($emojiCount * 2)
                                }
                                features = @(
                                    @{
                                        "`$type" = "app.bsky.richtext.facet#tag"
                                        tag = "Coding"
                                    }
                                )
                            },
                            @{
                                index = @{
                                    byteStart = $text.IndexOf("$($tags[0])") + ($emojiCount * 2)
                                    byteEnd   = $text.IndexOf("$($tags[0])") + "$($tags[0])".Length + ($emojiCount * 2)
                                }
                                features = @(
                                    @{
                                        "`$type" = "app.bsky.richtext.facet#tag"
                                        tag = "$($tags[0].split('#')[1])"
                                    }
                                )
                            },
                            @{
                                index = @{
                                    byteStart = $text.IndexOf("$($tags[1])") + ($emojiCount * 2)
                                    byteEnd   = $text.IndexOf("$($tags[1])") + "$($tags[1])".Length + ($emojiCount * 2)
                                }
                                features = @(
                                    @{
                                        "`$type" = "app.bsky.richtext.facet#tag"
                                        tag = "$($tags[1].split('#')[1])"
                                    }
                                )
                            },
                            @{
                                index = @{
                                    byteStart = $text.IndexOf("$($tags[2])") + ($emojiCount * 2)
                                    byteEnd   = $text.IndexOf("$($tags[2])") + "$($tags[2])".Length + ($emojiCount * 2)
                                }
                                features = @(
                                    @{
                                        "`$type" = "app.bsky.richtext.facet#tag"
                                        tag = "$($tags[2].split('#')[1])"
                                    }
                                )
                            },
                            @{
                                index = @{
                                    byteStart = $text.IndexOf("$($tags[3])") + ($emojiCount * 2)
                                    byteEnd   = $text.IndexOf("$($tags[3])") + "$($tags[3])".Length + ($emojiCount * 2)
                                }
                                features = @(
                                    @{
                                        "`$type" = "app.bsky.richtext.facet#tag"
                                        tag = "$($tags[3].split('#')[1])"
                                    }
                                )
                            }
                        )
                    }
                } | ConvertTo-Json -Depth 10 -Compress

                $APIUrl = "https://bsky.social/xrpc/com.atproto.repo.createRecord"
                $BSkyResponse = Invoke-RestMethod -Uri $APIUrl -Method Post -Headers $AuthHeader -Body $PostBody
                
                callNormalMode "commit"
            }
            else{
                Write-Host "you don't have 'bluesky.json'"
            }
        }
        Default {
            Write-Host "$name is not correct input"
        }
    }
}