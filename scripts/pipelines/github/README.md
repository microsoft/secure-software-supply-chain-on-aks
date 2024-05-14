# Pipelines

## GitHub Actions

| Script                                  | Description                                                                                                                                               |
|-----------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------|
| `create_github_federated_credential.sh` | Creates a federated credential for the Microsoft Entra ID Application Registration to allow the GitHub Actions workflow to interact with Azure resources. |
| `create_github_variables.sh`            | Configures a GitHub environment with required secrets and variables.                                                                                      |
| `execute_github_workflow.sh`            | Triggers a `workflow_dispatch` event and kicks off the GitHub workflow.                                                                                   |
| `provision.sh`                          | Orchestrates the running of all needed scripts.                                                                                                           |
