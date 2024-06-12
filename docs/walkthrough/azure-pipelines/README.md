# Azure Pipelines walkthrough

> [!IMPORTANT]
> As with all Azure deployments, this will incur associated costs. Remember to [teardown](../teardown.md) all related resources after use to avoid unnecessary costs.

Within this walkthrough, the following will be accomplished:

- Azure resources will be provisioned and configured.
- A new pipeline will be added to the Azure DevOps project. In this pipeline, three workloads will be built, and pertinent security artifacts will be generated.
- Upon deployment:
    1. One workload fails due to lack of security artifacts.
    2. The second workload fails because its security artifacts do not meet policy expectations.
    3. The third and final workload will pass policy checks and deploy successfully.

> [!IMPORTANT]
> This walkthrough describes one approach to ensuring the security and integrity of containerized workloads. It should be viewed as a pathway to potential success rather than a definitive template.

## 1 Azure DevOps setup

> [!NOTE]
> **Assumptions**:
>
> - An Azure DevOps organization and project.
> - Permission to create, view, use and manage service connections as discussed [here](https://learn.microsoft.com/en-us/azure/devops/pipelines/library/service-endpoints?view=azure-devops&tabs=yaml#user-permissions).
> - Azure DevOps organization has access to [workload identity federation for Azure Resource Manager service connection](https://learn.microsoft.com/en-us/azure/devops/pipelines/library/connect-to-azure?view=azure-devops#create-an-azure-resource-manager-service-connection-using-workload-identity-federation)

Azure DevOps will need access to a Github repository, this can be achieved using a service connection. Create a new service connection of type _'Github'_ and ensure the _Grant access permission to all pipelines_ checkbox is checked as seen below.

![Checked checkbox for "Grant access permission to all pipelines" under the Security header](../../../images/ado/grant-access-all-pipelines.jpg)

Learn more about the GitHub service connection options in the _[official documentation](https://learn.microsoft.com/azure/devops/pipelines/library/service-endpoints?view=azure-devops&tabs=yaml#github-service-connection)_.

## 2 Configuration and environment settings

### 2.1 Configuration

Custom variable values scoped to the current environment will be needed to complete steps in the walkthrough. A configuration file template will be used to allow for customization and persistance of these values. A configuration file should be created by running the following:

```bash
cp ./config/ado/.configtemplate ./config/sssc.config
```

After the configuration file is created it will have to be modified for the current environment. Open the configuration file `./config/sssc.config` and populate and/or update all of the applicable variables. For details on configuration values, see the table below.

> [!WARNING]
> When populating values do not use single quotes. If values contain spaces, use double quotes.

| Variable name                 | Required | Description                                                                                                                                            | Default Value                                                                                                                                                                                                                                                                                                  |
|-------------------------------|----------|--------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| AZURE_SUBSCRIPTION_ID         | No       | The Azure subscription used for resource provisioning                                                                                                  | The [default](https://learn.microsoft.com/cli/azure/authenticate-azure-cli#:~:text=After%20you%20sign%20in%2C%20CLI%20commands%20are%20run%20against%20your%20default%20subscription.%20If%20you%20have%20multiple%20subscriptions%2C%20you%20can%20change%20your%20default%20subscription) Azure subscription |
| ADO_GITHUB_SERVICE_CONNECTION | Yes      | The ADO service connection name used to access Github.                                                                                                 |                                                                                                                                                                                                                                                                                                                |
| GITHUB_REPO                   | Yes      | <github-org/repo-name>                                                                                                                                 |                                                                                                                                                                                                                                                                                                                |
| ADO_PROJECT_NAME              | Yes      | Target Azure DevOps project where Azure Pipelines and Variable groups will be deploy                                                                   |                                                                                                                                                                                                                                                                                                                |
| ADO_ORGANIZATION_URL          | Yes      | Target Azure DevOps Organization of Azure DevOps project in this form `https://dev.azure.com/<organization>/`, e.g. <https://dev.azure.com/my_ado_org> |                                                                                                                                                                                                                                                                                                                |
| AZURE_LOCATION                | Yes      | Azure location to provision resources.                                                                                                                 | eastus                                                                                                                                                                                                                                                                                                         |
| PROJECT                       | No       | String used as prefix to names of Azure resources and Azure Pipeline variable group. This should be limited to 10 lowercase alphanumeric characters.   | ssscsample                                                                                                                                                                                                                                                                                                     |
| GATEKEEPER_VERSION            | Yes      | Gatekeeper version to deploy.                                                                                                                          | 3.14.0                                                                                                                                                                                                                                                                                                         |
| RATIFY_VERSION                | Yes      | Ratify version to deploy.                                                                                                                              | 1.12.1                                                                                                                                                                                                                                                                                                         |
| KUBERNETES_VERSION            | Yes      | Kubernetes version to use for created AKS instance.                                                                                                    | 1.27.7                                                                                                                                                                                                                                                                                                         |
| GIT_BRANCH                    | Yes      | This will be used to indicate where the pipeline YAML file can be found as well as when programmatically kicking off the pipeline                      | main                                                                                                                                                                                                                                                                                                           |
| TAGS                          | No       | If there is policy for your Azure subscription requiring tags, provide them formatted as TagName=TagValue. Otherwise, leave as-is.                     |                                                                                                                                                                                                                                                                                                                |

### 2.2 Azure CLI login

[Authenticate to Azure using the Azure CLI](../az-login.md).

### 2.3 Validation and initialization

The following script will validate all required tooling has been installed. There will be no output to the terminal if no issues are found.

```bash
./scripts/setup/verify_prerequisites.sh
```

Initialize the local environment by generating an env file which will be created at the following location `./scripts/config/sssc.env`. The sssc.env file will be created using the values from the earlier configured file `./config/sssc.config` and be updated automatically as needed throughout the walkthrough.

```bash
./scripts/setup/init_environment.sh
```

## 3 Infrastructure provisioning and configuration

### 3.1 Provision Azure resources

All of the necessary resources can now be provisioned. Azure resources will be provisioned and configured as described in [provisioned infrastructure](../provisioned-infrastructure.md).

Run the following script which will provision and configure all of the required infrastructure.

> [!NOTE]
> This script will output status details to the terminal as it progresses. Wait until the script executes successfully to completion before moving onto creation and configuration of Azure Pipelines.

```bash
./scripts/infra/provision.sh
```

### 3.2 Create Azure Pipeline

Run the following script to create a new Azure Pipelines pipeline and variable group. This pipeline will be responsible for **building/generating**, **signing** and **pushing** artifacts which are used later in the walkthrough.

> [!NOTE]
> This script will output status details to the terminal as it progresses. Wait until the script executes successfully to completion before moving onto running the pipeline.

```bash
./scripts/pipelines/ado/provision.sh
```

## 4 Pipeline execution

> [!IMPORTANT]
> Two sample applications, Trips and POI, will be referenced through this walkthrough. These applications have no significance for the walkthrough other than being used for AKS workload deployments and a source for the creation of security artifacts.

Pipeline execution will produce the following artifacts for the previously mentioned sample applications:

For the Trips application:

- The image is **built**, **pushed** to ACR and **signed**.
- An SBOM is **generated**, **attached** to the image and **signed**.
- The release is **scanned for vulnerabilities**.
- The vulnerability scan result is **attached** to the image with OCI annotation `org.opencontainers.image.created` set to the current date and time and **signed**.

For the POI application:

- The image is **built** and **pushed** to ACR.

For the User Profile application:

- The image is **built**, **pushed** to ACR and **signed**.
- An SBOM is **generated**, **attached** to the image and **signed**.
- The release is **scanned for vulnerabilities**.
- The vulnerability scan result is **attached** to the image with OCI annotation `org.opencontainers.image.created` set to two days ago and time and **signed**.

> [!NOTE]
> The key used to sign the Trips image and its artifacts differs from that used for the User Profile and its artifacts. Although both were signed by the same Certificate Authority (CA), they have different Subjects.

Kick off the pipeline by executing the following script. Once the pipeline has started, the status can be viewed in Azure DevOps within the Pipelines section.

```bash
./scripts/pipelines/ado/execute_ado_pipeline.sh
```

If manually triggering the pipeline in the Azure DevOps UI is preferred, a value for the [runtime parameter](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/runtime-parameters?view=azure-devops&tabs=script) _'Variable Group Name'_  is required. The value can be found in the env variable `ADO_VARIABLE_GROUP_NAME` which can be retrieved by running:

```bash
. ./config/sssc.env && echo $ADO_VARIABLE_GROUP_NAME
```

> [!IMPORTANT]
> Ensure the pipeline has successfully completed before continuing to the `View artifacts`. The status can be viewed in Azure DevOps within the Pipelines section.

</br>[![View artifacts](https://img.shields.io/badge/View_artifacts-f8f8f8?style=for-the-badge&label=Next&labelColor=4051b5)](../view-artifacts.md)
