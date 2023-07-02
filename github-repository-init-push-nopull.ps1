<#
This powershell script github-repository-init-push-nopull.ps1 is licensed under the MIT License.
See http://opensource.org/licenses/MIT for more information.
    
Copyright (c) 2023 fred4code
#>

<#
The script gitHub-repository-init-push-nopull.ps1 is designed to initialize and push to a GitHub repository without the pull operation.
It is best suited for situations where the local directory is the single source of truth, and there is no need to sync with changes that may have been made to the repository on GitHub by others.
#>

<#
The script will:
1) Authenticate the user on GitHub using a Personal Access Token.
2) Check if a GitHub repository exists with the same name as the current directory.
3) If the repository does not exist, it will create a new private repository on GitHub.
4) Initialize the current directory as a local Git repository, or switch to the 'main' branch if it's already a Git repository.
5) Remove any existing remote repository named 'origin' and add the new GitHub repository as the 'origin'.
6) Stage all changes in the current directory.
7) Commit the changes with a message "My commit".
8) Push the changes to the 'main' branch of the GitHub repository.
#>

<#
How to use the script:
1) substitute _USER_NAME_, _EMAIL_ and _TOKEN_ with your own values
-_USER_NAME_ and _EMAIL_ are the one you have in GitHub
-_TOKEN_ is taken from: Settings > Developer Settings > Generate new token > Generate new token (classic).
Than you are asked to give a "Name" for the token, an "Expiration" and a "Select scopes" (check the repo checkbox to have all the repo checkboxes checked)
2) Put this file it in the directory that you want to transform in a git repository
3) Go to directory and run: powershell -File gitHub-repository-init-push-nopull.ps1
#>

<#
NOTE: Sometimes it could ask for authentication other than the token you have insert here.
NOTE: Do not change the local working directory name or the name of the repository on GitHub, otherwise the script will not be able to correctly associate your local directory with the GitHub repository, and your commits may not be correctly pushed to GitHub.
#>


$userName = "_USER_NAME_"
$email = "_EMAIL_"
$token = "_TOKEN_"


# The name of this script file
$scriptName = [System.IO.Path]::GetFileName($PSCommandPath)


# Create (or overwrite) a .gitignore file in the current directory
# and add an entry to ignore the script file
Set-Content ".gitignore" -Value $scriptName


# Get the directory name where this script file is located.
$folderName = Split-Path -Path (Get-Location) -Leaf


# Check for spaces
if ($folderName -match '\s') {
    Write-Host "The folder name contains spaces, which are not allowed in a GitHub repository name."
    return
}
# Check the length
if ($folderName.Length -gt 100) {
    Write-Host "The folder name is too long to be a GitHub repository name. Please use a shorter folder name."
    return
}
# Check for invalid characters
if ($folderName -notmatch '^[a-zA-Z0-9\.\-_]+$') {
    Write-Host "The folder name contains invalid characters. Only alphanumeric characters, dots, hyphens, and underscores are allowed in a GitHub repository name."
    return
}


# 'Get-Module' retrieves the status of modules in your PowerShell environment.
# '-ListAvailable' flag tells it to return all modules that are installed on your system, not just those currently loaded into your session.
# '-Name' parameter is used to filter the returned modules by name. In this case, we're looking for the 'PowerShellForGitHub' module.
# If the 'PowerShellForGitHub' module is not found, then the 'Install-Module' cmdlet is used to install it only for the current user.
if (!(Get-Module -ListAvailable -Name 'PowerShellForGitHub')) {
    Install-Module -Name PowerShellForGitHub -Scope CurrentUser
}


# 'New-Object' is used to create an instance of a .NET or COM object. 
# In this case, it's being used to create an instance of the 'System.Management.Automation.PSCredential' class, 
# which represents a set of security credentials in PowerShell. 
# Typically, when creating a PSCredential object, you would provide a username and password. However, 
# when you're authenticating with GitHub using a Personal Access Token (PAT), the username is not utilized. 
# Therefore, the string "username is ignored" is used here as a placeholder. The real authentication information is 
# the Personal Access Token, which is stored in the '$token' variable and passed as the second argument 
# to the PSCredential constructor. This token is first converted into a SecureString using 'ConvertTo-SecureString'.
# The constructed PSCredential object, which encapsulates the Personal Access Token required for GitHub authentication, 
# is then stored in the '$cred' variable.
$secureToken = ConvertTo-SecureString -String $token -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential "username is ignored", $secureToken


# 'Set-GitHubAuthentication' from the PowerShellForGitHub module is used to authenticate with GitHub for the current session. 
# This allows you to interact with the GitHub API through the script, which can be used to manage repositories, issues, pull requests, and more.
# '-Credential' parameter is used to specify your GitHub credentials, which are stored in the '$cred' variable.
# '-SessionOnly' flag specifies that the authentication should only last for the current session. This means that when your PowerShell session ends, you will no longer 
# be authenticated with GitHub and will need to authenticate again in your next session.
# need to see, so this sends that output to null, effectively discarding it.
Set-GitHubAuthentication -Credential $cred -SessionOnly


# 'Get-GitHubRepository' from the PowerShellForGitHub module is used to retrieve information about GitHub repositories.
# By default, it returns information about all repositories for the authenticated user.
# '|' symbol passes the list of repositories to 'Where-Object'.
# 'Where-Object' is used to filter the list of repositories checing if the name of the current repository is equal to the name of your folder ('$folderName').
# The result of this line is stored in the '$repo' variable. If a repository with the same name as your folder exists, '$repo' will contain its information. 
# If no such repository exists, '$repo' will be $null.
$repo = Get-GitHubRepository | Where-Object {$_.name -eq $folderName}


# Checks if the '$repo' variable is null.
# If no repository was found, then this block of code is executed to create a new GitHub repository.
# 'New-GitHubRepository' from the PowerShellForGitHub module is used to create a new repository.
# '-Name' parameter specifies the name of the new repository, which is set to the name of the current folder ('$folderName').
# repository and makes the repository ready to be cloned or pushed to.
# '-Private' parameter makes the new repository private, which means only you and collaborators you invite will be able to see the repository.
if ($null -eq $repo) {

    $repo = New-GitHubRepository -Name $folderName -Private

}



# 'git config' command is used to set configuration options for your Git installation, 
# '--global' flag specifies that the configuration should apply to all repositories on your system.
# These options are stored in a configuration file in your home directory called '.gitconfig'.
# (e.g. .gitconfig file in Windows systems is found in the directory: C:\Users\_YOUR_USER_NAME)
# Here, you're setting the 'user.email' and 'user.name' configuration options. These values are used to 
# identify you as the author when you commit changes. In this script, you're setting them to the 
# values of the $email and $userName variables respectively. 
# When you commit changes, Git will use these values to attach your name and email to the commit. 
# This information is used in the commit history to show who made each commit.
git config --global user.email $email
git config --global user.name $userName


# 'Test-Path' checks whether a path exists in the file system.
# Here, it is checking for a .git directory in the current folder. The .git directory is where 
# Git stores all the information about the repository, including commit logs, branch information, and more.
# Only if the .git directory is present, the folder is considered a Git repository and you can use it with Git.
# If the .git directory does not exist, it will be created by the 'git init' command.
if (!(Test-Path -Path .git)) {
    # 'git init' command creates a new Git repository. It can be used to convert an existing, unversioned project 
    # to a Git repository or initialize a new, empty repository. Executing this command will create a new .git 
    # subdirectory in the current working directory.
    git init

    # 'git branch -M main' command creates a new branch named 'main' and immediately switches to it. 
    # The '-M' option will cause the branch to be created if it does not already exist, or renamed if it does. 
    # This ensures that our first commit will be on the 'main' branch, which is the default branch for new repositories on GitHub.
    git branch -M main
}
else {
    # If the .git directory does exist, this means the current directory is already a Git repository.
    # Then the 'git checkout main' command is executed to ensure we are on the 'main' branch before making any commits.
    # 'git checkout main' is used to switch to the 'main' branch in your local repository. 
    # In Git, a 'branch' is essentially a unique set of code changes with a unique name. 
    # The 'main' branch is usually where all changes eventually get merged into. 
    # By running this command, you're ensuring that all the following Git operations 
    # are being done on the 'main' branch.
    git checkout main
}


# 'git remote remove' command is used to remove a remote URL from your repository. 
# 'origin' is the default name given to the remote repository from where you've cloned. 
# It's the shortcut for your remote repository's URL. Here, we're removing this remote connection
# if it exists. This can be helpful if the 'origin' is currently pointing to a wrong or outdated URL. 
# After this command, 'origin' will not be associated with any remote repository.
git remote remove origin


# 'git remote add' is a command that creates a new connection record to a remote repository. 
# After adding a remote, you'll be able to use 'origin' as a convenient shortcut for the full remote repository URL in other git commands. 
# 'origin' is the name conventionally given to the remote repository you've cloned from.
# The argument that follows is the URL of your GitHub repository, constructed by concatenating your username and the repository name.
# After this command, you can use 'origin' in other git commands to refer to your GitHub repository.
git remote add origin ("https://github.com/" + $userName + "/" + $folderName + ".git")


# Get the current repository information from GitHub
$currentRepo = Get-GitHubRepository | Where-Object {$_.name -eq $folderName}

# Check if the repository still exists with the same name. If it doesn't, do not make the commit otherwise make the commit.
if ($null -ne $currentRepo) {
    # Adding all files in the current directory to Git's tracking system
    git add .

    # Committing the changes with a message
    git commit -m "My commit"

    # Pushing to the main branch of your GitHub repository
    git push origin main
} else {
    Write-Host "The name of the local directory does not match the name of the GitHub repository. No commit was made."
}