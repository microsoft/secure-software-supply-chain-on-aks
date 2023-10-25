# GitHub CLI auth

To leverage the GitHub CLI there are two options for authenticating, either via a GitHub token or via ssh/http authentication. Choose which authentication method you would like to use and follow the instructions below.

## Token authentication

A GitHub token will be required for reading/writing secrets and variable, and running workflows. [Create a new fine-grained GitHub token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens) scoped to the forked repository.

Set the following permissions when creating the token:

- Actions - Read & write
- Environment - Read & write
- Secrets - Read & write
- Variables - Read & write
- Workflows - Read & write

Once the token has been created, export it as an environment variable. This will allow the gh CLI to use the token for authentication.

```bash
export GITHUB_TOKEN=<token>

```

## SSH/HTTP authentication

To login using the gh CLI and ensure scopes are properly set, run the following command with will logout, re-login, and clear GITHUB_TOKEN env variable.

```bash
gh auth logout && GITHUB_TOKEN= && gh auth login -w
```
