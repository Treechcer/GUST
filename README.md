# Gust – Git Utility Something Tool (PowerShell)

**Gust** is a PowerShell script that automates common Git tasks for your GitHub repository (managing branches, pushing etc.) with all being configurable in `config.json`.

## Table Of Contents (TOC)

- [Gust – Git Utility Something Tool (PowerShell)](#gust--git-utility-something-tool-powershell)
  - [Table Of Contents (TOC)](#table-of-contents-toc)
  - [Features](#features)
  - [Parameters](#parameters)
  - [Mode parameters](#mode-parameters)
  - [configurations](#configurations)
  - [Prerequisites](#prerequisites)
  - [Usage](#usage)
  - [Profiles](#profiles)
    - [Stats](#stats)
    - [Project Folder Structure](#project-folder-structure)
  - [Set Up To Call GUST Globally](#set-up-to-call-gust-globally)
    - [automatic setup (recommended)](#automatic-setup-recommended)
    - [manual GitHub clone](#manual-github-clone)
  - [Modding Support](#modding-support)
    - [Mod Structure](#mod-structure)
    - [Example Mods](#example-mods)
  - [Action Support](#action-support)
    - [Action Structure](#action-structure)
    - [Example actions](#example-actions)
  - [Mod / action API](#mod--action-api)
  - [Final Note](#final-note)

## Features

- Verifies if the user has set `user.name` and `user.email` (global and local) - or set their name and email in config with `"changeNameGlobal" : true` (default is false)
- Initializes a `new` Git repository if one doesn't exists
- Adds and commits changes  
- Pushes to the selected branch (default is `main`)
- A most of things being configurable in `config.json`
- Supports multiple "modes" (mode is what the script will do when you run GUST) - including modes: branch switching, branch creating, etc.
- Allows setting default message for commit messages
- Support short aliases for inputs (more on that later)
- Adds a `remote origin` (or any other depends on config) and `pulls with --allow-unrelated-histories`

## Parameters

| Parameter   | Required  | Description | Aliases  |
|-------------|---------- |-------------| -------- |
| message     | Sometimes                                  | Your commit message you want to use                                                                                                           | -c (as commit message) |
| gitURL      | Only required when initializing repository | The GitHub repository URL (omit .git at the end it will be added automatically)                                                               | -u (as URL)            |
| otherModes  | most of the time                           | This is used to change the mode you want to do, also it has configurable default value `"defaultMode" : "c"`                                  | -m (as mode)           |
| branch      | no                                         | this is for working branches, it has default configurable in config under `"defaultBranch" : "main",`in some cases as `main`                  | -b                     |
| number      | no                                         | this is used when you need some number as an input (now it's only used in log, it has default configurable in config `"defaultLogLength" : 5,`| -n                     |

## Mode parameters

|Name | Description |
|-----|-------------|
| c(commit)                 | This is configs default. Adds a commit message and pushes to your GitHub repository. |
| b(ranch)s(witch)c(create) | Creates a new branch and switches to the new branch.                                 |
| b(ranch)s(witch)          | Switches to an existing branch.                                                      |
| b(ranch)d(elete)          | Deletes an existing branch.                                                          |
| s(tatus)                  | Shows the status of current branch.                                                  |
| p(ull)                    | Pulls the latest changes from your remote repository.                                |
| l(og)                     | Shows recent commits (default number or set with -number / -n).                      |

## configurations

```json
{
    "defaultBranch" : "main",
    "defaultRemote" : "origin",
    "userName" : "$null",
    "userEmail" : "$null",
    "changeNameGlobal" : false,
    "autoPullBeforePush": true,
    "defaultCommitMessage" : "small fixes",
    "forceBranchDelete": false,
    "defaultLogLength" : 5,
    "defaultMode" : "c",
    "runModification" : true,
    "runActions" : true
}
```

| key | description |
| --- | ----------- |
| defaultBranch        | Default branch to push to.                                                                                                                                                  |
| defaultRemote        | Default git remote name.                                                                                                                                                    |
| userName             | Used if no git config is set for user.name.                                                                                                                                 |
| userEmail            | Used if no git config is set for user.email.                                                                                                                                |
| changeNameGlobal     | Boolean value that makes the name / email change global or local (to enable name changing you have to change the userEmail to your email address and userName to your name) |
| autoPullBeforePush   | If `True` this sets if you automatically pull before pushing.                                                                                                               |
| defaultCommitMessage | Used as no commit message is inputted.                                                                                                                                      |
| forceBranchDelete    | If `true` uses `-D` (force deletes) branches.                                                                                                                               |
| defaultLogLength     | Number of commits shown when using the `log` mode.                                                                                                                          |
| defaultMode          | Default mode used when no mode is inputted.                                                                                                                                 |
|runModifications| Defaults to `true`, when it's true mods are enabled and can be executed.|
|runActions| Defaults to `true`, when it's true actions are enabled and will be executed.|

## Prerequisites

- [Git](https://git-scm.com/) installed on your system
- User has configured name and email configured:

git config --global user.name "Your Name"  
git config --global user.email "your@email.com"

> Note: To configure local configuration instead, remove `--global`.
> Note: this can also be setup as automatic action if you set `userName`, `userEmail` to change your name locally, if you want it globally you can change to true `changeNameGlobal` in your config file.

## Usage

```powershell
.\gust.ps1 -c "commit message" -u "URL" 
```

This is an example of pushing and setting up remote code to your GitHub repository.

---

```powershell
.\gust.ps1 -c "Refactor UI"
```

This is an example of committing to an already established repository.

---

``` powershell
.\gust.ps1 -m "bcs" -b "coolBranch"
```

this is example of creating a new branch and switching to the branch

---

```powershell
.\gust.ps1 -m "bs" -b "main"
```

This is example of switching to a already existing branch.

---

```powershell
.\gust.ps1 -m "bd" -b "coolBranch"
```

This is example of deleting a existing branch.

---

```powershell
.\gust.ps1 -m "s"
```

This is example of showing git status.

---

```powershell
.\gust.ps1 -m "log" -n 8
```

This is example of showing the log provided the length of how much you want (in this you'l see 8 things in the log).

---

```powershell
.\gust.ps1 -c "Bug fixes"
```

This is showcase you don't need to use `-m` dor mode because you have default mode in config (which defaults to `c` - commit mode).

---

```powershell
.\gust.ps1 --update
```

This automatically updates to the newest version of GUST, by using github commits and downloading from there. This might download unstable version.

## Profiles

GUST has it's own profile manager, in `/profiles` is folder for every profile you have currently locally on your disc (in default it comes with `default` profile), you can create as many you want.

```powershell
gust -m "swp"
```

This is used to switch profiles from your current profile to other profile that exists.

---

```powershell
gust -m "cnp"
```

This is used for creating a new profile that doesn't exists.

> Note : you can't change configs with GUST in version 0.4.0 for now, so you have to change it by hand in `/profiles/'profileName'/config.json`.

### Stats

Every profile has `stats.json` in their respective folder, it counts how many times you used any command.

> Note: it doesn't have any CLI output or any usage in version 0.4.0, it might have in future or you can write mod for it.

### Project Folder Structure

```plaintext
  GUST/
    actions/
      actionTemplate.ps1
      example.ps1
    mods/
      bluesky.ps1
      exampleMod.ps1
      exampleMod2.ps1
      modTeplate.ps1
      NASupload.ps1
      twitter.ps1
    profiles/
      default/
        stats.json
        config.json
      Custom/
        stats.json
        config.json
    .gitignore
    actions.ps1
    config.json # THIS FILE WILL BE DELETED LATER !!!
    gust.cmd
    gust.ps1
    install.ps1
    LICENSE
    modAPI.ps1
    modLoader.ps1
    README.md
```

## Set Up To Call GUST Globally

### automatic setup (recommended)

1. Download file `install.ps1` from this repository.
2. Add it into your desired folder where you want GUST to be saved and downloaded.
3. After that run the file and it will automatically download and set itself into Path in Windows.

> Note: no linux support for automatic download, because I have no idea how that would work or even if

After this GUST should be fully working and you should be able to use it.

### manual GitHub clone

You can make gust.ps1 callable from anywhere by adding its directory to your PATH environment variable.

For example, if the script is located at: `C:\downloads\gust\gust.ps1`

Then add the following path to your system's PATH variable: `C:\downloads\gust\`

> Note: last `\` is necesery for it to work

After that, you can run the script using:

gust -c "Your commit message"

> Note: If you delete the `gust.cmd` file, you'll need to call the script explicitly using `gust.ps1`. In that case, include the full path or ensure the .ps1 file extension is recognized in your environment.

## Modding Support

GUST supports **mods** (external PowerShell scripts) to extend its functionality.  
Each mod must follow a strict structure and expose specific functions so GUST can load and execute them.

### Mod Structure

A mod is a `.ps1` file placed in the `mods/` directory.  
It must define these functions:

- **versionOfGust** → return GUST version the mod is for
- **getModificationName** → returns the mod’s name  
- **getModificationVersion** → returns the mod’s version  
- **getModifications** → returns a list of regex/string patterns that the mod recognizes as valid "modes"  
- **behaviourSwitchCheck** → main function called when a mode matches

> Function names **must not be changed**. Renaming them will break the mod system.

### Example Mods

There are already example mods included in the repository:

- `mods/exampleMod1.ps1` (mod tester)
- `mods/exampleMod2.ps1` (gust importer)

You can use these as a reference to see how mods are structured.

A reusable template is also provided in:

- `mods/modTemplate.ps1`

This file can be copied and modified to create your own mods quickly.

## Action Support

GUST supports **actions** (external PowerShell scripts, similar to mods) to extend its functionality.  
Each action file must follow a strict structure and expose specific functions so GUST can load and execute them.

### Action Structure

A action file is a `.ps1` file placed in the `actions/` directory.  
It must define these functions:

- **versionOfGust** → return GUST version the mod is for
- **getActionName** → returns the action’s name  
- **getActionVersion** → returns the action’s version  
- **getActions** → returns a list of string names that the mod recognizes as valid "modes"  
- **behaviourSwitchCheck** → main function called when a mode matches

> Function names **must not be changed**. Renaming them will break the action system.

### Example actions

There are already example actions included in the repository:

- `actions/actionExample.ps1` (action tester)

You can use these as a reference to see how actions are structured.

A reusable template is also provided in:

- `actions/actionTemplate.ps1`

This file can be copied and modified to create your own mods quickly.

## Mod / action API

Mod API is stored in the file `modAPI.ps1`.  
For now, it is only used as an easy way to access user inputs and GUST functionality from the main GUST script.

| Function       | Description |
|----------------|-------------|
| getMessage     | Returns the input for commit message. |
| getURL         | Returns the input for repository URL. |
| getOtherModes  | Returns the input for mode string. |
| getBranch      | Returns the input for branch name. |
| getNumber      | Returns the input for numeric input (used in log)|
| callNormalMode | Executes a normal mode with the parameters you passed to GUST. |
| getConfigValue | Return any value in config variable / config.json. |

## Final Note

This was made mainly for my use, because these are most of the commands I use and it streamlines most of my committing to github.
