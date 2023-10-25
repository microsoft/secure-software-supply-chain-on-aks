# GitHub Workflow walkthrough

> [!IMPORTANT]
> As with all Azure deployments, this will incur associated costs. Remember to [teardown](../teardown.md) all related resources after use to avoid unnecessary costs.

## Description

At the end of this walkthrough the following high-level tasks will have been completed:

- Provisioned and configured all necessary Azure resource
- A new GitHub Workflow which generates artifacts
- A failed AKS workload deployment due to policy violations
- A successful AKS workload deployment with no policy violations

> [!IMPORTANT]
> This walkthrough describes one approach to ensuring the security and integrity of containerized workloads. It should be viewed as a pathway to potential success rather than a definitive template.

## Configuration and environment settings

> [!NOTE]
> **Assumptions**:
>
> - Workflows are enabled. _The Actions tab in the GitHub UI will provide instructions how to do so._
> - [GitHub Environments](https://docs.github.com/en/rest/deployments/environments?apiVersion=2022-11-28#:~:text=Environments%2C%20environment%20secrets,for%20public%20repositories) are available. This feature requires either the repository is public _or_ the user account has GitHub Pro, GitHub Team, or GitHub Enterprise.

### Configuration

Custom variable values scoped to the current environment will be needed to complete steps in the walkthrough. A configuration file template will be used to allow for customization and persistance of these values. A configuration file should be created by running the following:

```bash
cp ./config/github/.configtemplate ./config/sssc.config
```

After the configuration file is created it will have to be modified for the current environment. Open the configuration file `./config/sssc.config` and populate and/or update all of the applicable variables. For details on configuration values, see the table below.

> [!WARNING]
> When populating values do not use single quotes. If values contain spaces use double quotes.

| Variable name         | Required | Description                                                                                                                               | Default Value                                                                                                                                                                                                                                                                                                         |
|-----------------------|----------|-------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| AZURE_SUBSCRIPTION_ID | No       | The Azure subscription used for resource provisioning                                                                                     | The [default](https://learn.microsoft.com/en-us/cli/azure/authenticate-azure-cli#:~:text=After%20you%20sign%20in%2C%20CLI%20commands%20are%20run%20against%20your%20default%20subscription.%20If%20you%20have%20multiple%20subscriptions%2C%20you%20can%20change%20your%20default%20subscription.) Azure subscription |
| GITHUB_REPO           | Yes      | <github-org/repo-name>                                                                                                                    |                                                                                                                                                                                                                                                                                                                       |
| AZURE_LOCATION        | Yes      | Azure location to provision resources.                                                                                                    | eastus                                                                                                                                                                                                                                                                                                                |
| PROJECT               | No       | String used as prefix to names of Azure resources and GitHub environment. This should be limited to 10 lowercase alphanumeric characters. | ssscsample                                                                                                                                                                                                                                                                                                            |
| GATEKEEPER_VERSION    | Yes      | Gatekeeper version to install.                                                                                                            | 3.11.0                                                                                                                                                                                                                                                                                                                |
| RATIFY_VERSION        | Yes      | Ratify version to install.                                                                                                                | 1.7.0                                                                                                                                                                                                                                                                                                                 |
| KUBERNETES_VERSION    | Yes      | Kubernetes version to install.                                                                                                            | 1.26.3                                                                                                                                                                                                                                                                                                                |
| GIT_BRANCH            | Yes      | This will be used to indicate where the workflow YAML file can be found as well as when programmatically kicking off the workflow         | main                                                                                                                                                                                                                                                                                                                  |
| TAGS                  | No       | If there is policy for your Azure subscription requiring tags, provide them formatted as TagName=TagValue. Otherwise, leave as-is.        |                                                                                                                                                                                                                                                                                                                       |

### Azure CLI login

[Authenticate to Azure using the Azure CLI](../az-login.md).

### Validation and initialization

The following script will validate all required tooling has been installed. There will be no output to the terminal if no issues are found.

```bash
./scripts/setup/verify_prerequisites.sh
```

Initialize the local environment by generating an env file which will be created at the following location `./scripts/config/sssc.env`. The sssc.env file will be created using the values from the earlier configured file `./config/sssc.config` and be updated automatically as needed throughout the walkthrough.

```bash
./scripts/setup/init_environment.sh
```

## Infrastructure provisioning and configuration

To leverage the GitHub CLI authentication will be required. Follow [these instructions](./gh-auth.md) for authenticating to GitHub.

### Provision Azure resources

All of the necessary resources can now be provisioned. Azure resources will be provisioned and configured as described in [provisioned infrastructure](../provisioned-infrastructure.md).

Run the following script which will provision and configure all of the required infrastructure.

> [!NOTE]
> This script will output status details to the terminal as it progresses. Wait until the script executes successfully to completion before moving onto creation and configuration of the GitHub workflow.

```bash
./scripts/infra/provision.sh
```

### Create GitHub Workflow

Run the following script to create a new GitHub Actions workflow and environment. This workflow will be responsible for **building/generating**, **signing** and **pushing** artifacts which are used later in the walkthrough.

> [!NOTE]
> This script will output status details to the terminal as it progresses. Wait until the script executes successfully to completion before moving onto running the workflow.

```bash
./scripts/pipelines/github/provision.sh
```

## Pipeline execution

> [!IMPORTANT]
> Two sample applications, Trips and POI, will be referenced through this walkthrough. These applications have no significance for the walkthrough other than being used for AKS workload deployments and a source for the creation of security artifacts.

Pipeline execution will produce the following artifacts for the previously mentioned sample applications:

For the Trips application:

- An image is **built** and **pushed** to a local OCI registry.
- An software bill of materials (SBOM) is **generated** and **attached** to the image in the local registry.
- The release is **scanned** for vulnerabilities. The resulting output is **attached** to the image in the local registry.
- The image, SBOM, and vulnerability scan result are all **signed** with Notation. _Notation automatically attaches signatures to the subject in the registry._
- The entire bundle (image + signature, SBOM + signature, and vulnerability scan result + signature) is **copied** from the local registry to ACR using ORAS.

For the POI application:

- An image is **built** and **pushed** to a local OCI registry.
- The image **copied** from the local registry to ACR using ORAS.

Trigger the workflow by executing the following script. Once the workflow has started, the status can be viewed in GitHub UI in the Actions tab.

```bash
./scripts/pipelines/github/execute_github_workflow.sh
```

If manually triggering the workflow in the GitHub UI is preferred, a value for [input](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#onworkflow_dispatchinputs) _'Environment name'_ is required. The value can be found in the env variable `GITHUB_DEPLOYMENT_ENV_NAME` which can be retrieved by running:

```bash
. ./config/sssc.env && echo $GITHUB_DEPLOYMENT_ENV_NAME
```

> [!IMPORTANT]
> Ensure the workflow has successfully completed before continuing to the `View artifacts`. The status can be viewed in GitHub in the Actions tab.

</br>[![View artifacts](https://img.shields.io/badge/View_artifacts-f8f8f8?style=for-the-badge&label=Next&labelColor=4051b5)](../view-artifacts.md)
