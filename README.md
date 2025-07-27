# Gust – Git Utility Something Tool (PowerShell)

**Gust** is a PowerShell script that automates pushing your code to a GitHub repository.

## Features

- Verifies if user has something under `user name and email` (global and local)
- Initializes a `new` Git repository `if you provide URL`
- Adds a `remote origin` and `pulls with --allow-unrelated-histories`
- Adds all changes, commits with a message, and pushes to the `main` branch

## Usage

```powershell
.\gust.ps1 -message "Your commit message" -gitURL "https://github.com/username/repository"
```

### Parameters

| Parameter   | Required | Description |
|-------------|----------|-------------|
| -message    | Yes      | Your commit message |
| -gitURL     | No       | URL of your repository (don't add '`.git`' at the end, it's automatically in) |

## Prerequisites

- Installed [Git](https://git-scm.com/)
- User has configured name and email configured:

```powershell
git config --global user.name "Your Name"  
git config --global user.email "your@email.com"
```

> To set local configuration instead, remove `--global`.

## Notes

- If -gitURL is provided:
  - Initializes the repository if not already initialized
  - Sets `origin` as the remote
  - Pulls from `origin/main` using `--allow-unrelated-histories`
  - Pushes and sets upstream to main

- If -gitURL is not provided, only git add, commit, and push are executed.

## Usage example

.\gust.ps1 -message "Initial commit" -gitURL "https://github.com/Treechcer/GUST"

or you can add it to your `environmental variables` to `PATH` the folder you downloaded GUST into, for example if you had GUST in your disk `C` and in folder structure like `C:\downloads\gust\gust.ps1` you have to add to PATH `C:\downloads\gust`, after this you can call just `gust -message ...` (if you delete the gust.cmd you have to call it by using `gust.ps1` and your PATH would look like `C:\downloads\gust\gust.ps1`)

## Last words

This was made mainly for my use, because these are most of the commands I use and it streamlines most of my committing to github.