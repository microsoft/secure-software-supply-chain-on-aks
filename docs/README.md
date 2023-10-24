# Getting started

## Fork repository

This walkthrough requires the user have certain permissions at the repository level. Fork the repository and work within the fork to make sure all steps can be performed.

## Walkthrough environment

It is highly recommended to leverage the supplied [Visual Studio Code development container](../.devcontainer/README.md) or GitHub Codespaces when working with this walkthrough. The devcontainer, which is also used by Codespaces, includes all the required tooling with no additional steps or configuration.

If not utilizing the devcontainer or Codespaces, review the list of [required utilities](../.devcontainer/README.md#utilities) and verify each is installed and configured.

### Pipeline options

When working with this walkthrough, there are two pipeline options for building images and artifacts: `Azure Pipelines` and `GitHub Actions`. Each option requires a slightly different configuration.

Please ensure [the walkthrough environment](#walkthrough-environment) is up and running before continuing with either pipeline option.

[![Continue with Azure Pipelines](https://img.shields.io/badge/-Azure_Pipelines-f8f8f8?style=for-the-badge&logo=azuredevops&logoColor=0078D7)](walkthrough/azure-pipelines/README.md)

[![Continue with GitHub Actions](https://img.shields.io/badge/-GitHub_Actions-f8f8f8?style=for-the-badge&logo=github&logoColor=181717)](walkthrough/github-actions/README.md)
