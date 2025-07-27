# Gust – Git Utility Something Tool (PowerShell)

**Gust** is a PowerShell script that automates pushing your code to a GitHub repository.

## Features

- Verifies if user has something under `user name and email` (global and local)
- Initializes a `new` Git repository `if you provide URL`
- Adds a `remote origin` and `pulls with --allow-unrelated-histories`
- Adds all changes, commits with a message, and pushes to the `main` branch

## Usage

.\gust.ps1 -message "Your commit message" -gitURL "https://github.com/username/repository"

### Parameters

| Parameter   | Required | Description |
|-------------|----------|-------------|
| -message    | Yes      | Your commit message you want to use you'll use|
| -gitURL     | No       | The GitHub repository URL (omit .git at the end – it is added automatically) |

## Prerequisites

- [Git](https://git-scm.com/) installed on your system
- User has configured name and email configured:

git config --global user.name "Your Name"  
git config --global user.email "your@email.com"

> Note: To configure local configuration instead, remove `--global`.

## Behavior Details

- When -gitURL is provided and `NO` mode:
  - Initializes the repository if not already initialized
  - Sets `origin` as the remote
  - Pulls from `origin/main` using `--allow-unrelated-histories`
  - Pushes and sets upstream to main

- When -gitURL is not provided:
  - Only git add, git commit, and git push are executed

## Examples

.\gust.ps1 -c "Initial commit" -u "https://github.com/Treechcer/GUST"

Alternatively, you can make gust.ps1 callable from anywhere by adding its directory to your PATH environment variable.

For example, if the script is located at:

C:\downloads\gust\gust.ps1

Then add the following path to your system's PATH variable:

C:\downloads\gust\

> Note: last `\` is necesery for it to work

After that, you can run the script using:

gust -c "Your commit message"

> Note: If you delete the accompanying gust.cmd file, you'll need to call the script explicitly using `gust.ps1`. In that case, include the full path or ensure the .ps1 file extension is recognized in your environment.

## Final Note

This was made mainly for my use, because these are most of the commands I use and it streamlines most of my committing to github.