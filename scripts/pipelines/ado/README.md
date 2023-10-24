# Pipelines

## Azure Pipelines

| Script                                   | Description                                                                                                                                                                |
|------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `create_ado_service_connection_azure.sh` | Creates a federated credential for the Microsoft Entra ID (formerly known as Azure AD) Application Registration to allow Azure Pipelines to interact with Azure resources. |
| `create_ado_variables.sh`                | Creates an Azure Pipelines variable group with required variables.                                                                                                         |
| `create_ado_pipeline.sh`                 | Creates a pipeline in Azure Pipelines based upon the pipeline YAML file within the GitHub repository.                                                                      |
| `execute_ado_pipeline.sh`                | Runs the configured pipeline.                                                                                                                                              |
| `provision.sh`                           | Orchestrates the running of all needed scripts.                                                                                                                            |
