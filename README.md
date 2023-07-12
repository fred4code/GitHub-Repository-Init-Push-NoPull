# GitHub Repository Init Push NoPull
The script <b>gitHub-repository-init-push-nopull.ps1</b> is designed to initialize and push to a GitHub repository without the pull operation.
It is best suited for situations where the local directory is the single source of truth, and there is no need to sync with changes that may have been made to the repository on GitHub by others.

## The script will:
1) Authenticate the user on GitHub using a Personal Access Token.
2) Check if a GitHub repository exists with the same name as the current directory.
3) If the repository does not exist, it will create a new private repository on GitHub.
4) Initialize the current directory as a local Git repository, or switch to the 'main' branch if it's already a Git repository.
5) Remove any existing remote repository named 'origin' and add the new GitHub repository as the 'origin'.
6) Stage all changes in the current directory.
7) Commit the changes with a message "My commit".
8) Push the changes to the 'main' branch of the GitHub repository.

## How to use the script:
1) substitute _USER_NAME_, _EMAIL_ and _TOKEN_ with your own values:<br>
-_USER_NAME_ and _EMAIL_ are the one you have in GitHub<br>
-_TOKEN_ is taken from: Settings > Developer Settings > Generate new token > Generate new token (classic).<br>
Than you are asked to give a "Name" for the token, an "Expiration" and a "Select scopes" (check the repo checkbox to have all the repo checkboxes checked)
2) Put this file it in the directory that you want to transform in a git repository
3) Go to directory and run: powershell -File gitHub-repository-init-push-nopull.ps1


## NOTE:
-Sometimes it could ask for authentication other than the token you have insert here.<br>
-Do not change the local working directory name or the name of the repository on GitHub, otherwise the script will not be able to correctly associate your local directory with the GitHub repository, and your commits may not be correctly pushed to GitHub.
