# Configuration and environment variables

## CI_CD_PLATFORM

The chosen platform on which to configure and run the exercise.

The value is hard-coded within each .configtemplate: "ado" for ![Azure Pipelines](../images/icons/ado-pipeline.svg) or "github" for ![GitHub Actions](../images/icons/gh-actions.svg) respectively. This is then copied into sssc.config.

**Script references**:

- [setup/init_environment.sh](../scripts/setup/init_environment.sh): if "ado", then checks are performed to ensure values are provided for the ADO-specific variables.
- [infra/teardown.sh](../scripts/infra/teardown.sh): determines what pipeline resources to delete.

> [!NOTE]
> After a successful run with one platform, feel free to switch to the other platform by updating the value in `sssc.env`. If GitHub Actions was run first, copy the `ADO_`-prefixed fields from the [ADO `.configtemplate`](ado/.configtemplate) and provide the appropriate values prior to running this sample with Azure Pipelines.

## AZURE_SUBSCRIPTION_ID

The Azure subscription used for resource provisioning.

There is an option to set in "sssc.config". If not provided, the [default](https://learn.microsoft.com/cli/azure/authenticate-azure-cli#:~:text=After%20you%20sign%20in%2C%20CLI%20commands%20are%20run%20against%20your%20default%20subscription.%20If%20you%20have%20multiple%20subscriptions%2C%20you%20can%20change%20your%20default%20subscription) Azure subscription will be used.

**Script references**:

- [init_environment.sh](../scripts/setup/init_environment.sh): if not already set, retrieves the id with `az account show --output json | jq -r '.id'` and sets the value with the output
- [infra/provision.sh](../scripts/infra/provision.sh): sets subscription for Azure CLI using `az account set --subscription` and executes the following:
  - [infra/steps/app_registration.sh](../scripts/infra/steps/app_registration.sh): used to scope permissions for resource group ownership for CI/CD pipeline identity
  - [infra/steps/aks.sh](../scripts/infra/steps/aks.sh): used to scope ACR pull permissions for Ratify identity
  - [infra/steps/keyvault.sh](../scripts/infra/steps/keyvault.sh): used to scope Key Vault permissions for CI/CD pipeline identity and the current user
- [pipelines/github/create_github_variables.sh](../scripts/pipelines/github/create_github_variables.sh): set a secret with the same name in the created GitHub environment for use with the Azure CLI login action

## AZURE_LOCATION

The name of the Azure region in which to create resources.

The script below will output the available regions. Use the "Name" column value.

```bash
az account list-locations -o table
```

There is an option to set in "sssc.config". If not provided, "eastus" will be used.

**Script references**:

- [init_environment.sh](../scripts/setup/init_environment.sh): sets to "eastus" if not already set
- infra/provision.sh
  - [infra/steps/resource_group.sh](../scripts/infra/steps/resource_group.sh): sets the location for the provisioned resource group
  - [infra/steps/aks.sh](../scripts/infra/steps/aks.sh): sets the location for the provisioned AKS cluster

## TAGS

Many Azure resources support additional metadata elements called "tags" [to ease organization and management](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources). Some organizations enforce policy surrounding tagging.

> [!IMPORTANT]
> This must only be set if there are policies requiring specific values when provisioning resources within the target subscription.

There is an option to set in "sssc.config". If none is provided, it stays empty for the entire run.

**Script references**:

- [init_environment.sh](../scripts/setup/init_environment.sh): explicitly set to empty if not already set
- infra/provision.sh
  - [infra/steps/resource_group.sh](../scripts/infra/steps/resource_group.sh): sets the tags value of the created resource group; leaving it empty leaves the field unset
  - [infra/steps/acr.sh](../scripts/infra/steps/acr.sh): sets the tags value of the create container registry; leaving it empty leaves the field unset
  - [infra/steps/aks.sh](../scripts/infra/steps/aks.sh): sets the tags value of the created cluster; leaving it empty leaves the field unset
  - [infra/steps/keyvault.sh](../scripts/infra/steps/keyvault.sh): sets the tags value of the created key vault; leaving it empty leaves the field unset

## GITHUB_REPO

The `<org-or-username>/<repo-name>` of the active fork.

> [!IMPORTANT]
> Ensure this is a repository for which you have `Contributor` or higher access and permissions.

It must be set in "sssc.config".

**Script references**:

- [init_environment.sh](../scripts/setup/init_environment.sh): exits with error if not set
- [infra/provision.sh](../scripts/infra/provision.sh): creates and sets `GITHUB_REPO_URL` ( `https://github.com/${GITHUB_REPO}`)
- [infra/teardown.sh](../scripts/infra/teardown.sh): used to delete the intended GitHub environment when GitHub Actions are used
- pipelines/github/provision.sh
  - [pipelines/github/create_github_federated_credential.sh](../scripts/pipelines/github/create_github_federated_credential.sh): used as a part of the `subject` for the federated credential
  - [pipelines/github/create_github_variables.sh](../scripts/pipelines/github/create_github_variables.sh): provided as a parameter to the GitHub CLI to ensure variables and secrets are created in the appropriate repository

## GIT_BRANCH

The current working branch. This will be used for CI/CD pipeline creation and/or execution.

There is an option to set in "sssc.config". If not provided, "main" will be used.

**Script references**:

- [setup/init_environment.sh](../scripts/setup/init_environment.sh): checks and sets value.
- pipelines/ado/provision.sh
  - [pipelines/ado/create_ado_pipeline.sh](../scripts/pipelines/ado/create_ado_pipeline.sh): indicates which branch in the provided GitHub repository that Azure Pipelines can find YAML file.
- [pipelines/ado/execute_ado_pipeline.sh](../scripts/pipelines/ado/execute_ado_pipeline.sh): indicates the target branch for the pipeline run.
- [pipelines/github/execute_github_workflow.sh](../scripts/pipelines/github/execute_github_workflow.sh): indicates the target branch for the workflow run.

## ADO_ORGANIZATION_URL

The target Azure DevOps Organization of Azure DevOps project in this form `https://dev.azure.com/<organization>/`, e.g. <https://dev.azure.com/my_ado_org>

It must be set in "sssc.config" when `CI_CD_PLATFORM` is "ado" ![Azure Pipelines](../images/icons/ado-pipeline.svg).

**Script references**:

- [setup/init_environment.sh](../scripts/setup/init_environment.sh): if `CI_CD_PLATFORM` equal "ado", checks and sets value when it exists. Otherwise, exits with error.
- [pipelines/ado/provision.sh](../scripts/pipelines/ado/provision.sh): sets the default organization for the DevOps extension of the Azure CLI.
  - [pipelines/ado/create_ado_service_connection_azure.sh](../scripts/pipelines/ado/create_ado_service_connection_azure.sh): used in conjunction with `ADO_PROJECT_NAME` to get the target project ID.

## ADO_PROJECT_NAME

The target Azure DevOps project within the Azure DevOps organization indicated in `ADO_ORGANIZATION_URL` where Azure Pipelines pipelines and variable groups will be deployed.

It must be set in "sssc.config" when `CI_CD_PLATFORM` is "ado" ![Azure Pipelines](../images/icons/ado-pipeline.svg).

**Script references**:

- [setup/init_environment.sh](../scripts/setup/init_environment.sh): if `CI_CD_PLATFORM` equal "ado", checks and sets value when it exists. Otherwise, exits with error.
- [pipelines/ado/provision.sh](../scripts/pipelines/ado/provision.sh): sets the default project for the DevOps extension of the Azure CLI.
  - [pipelines/ado/create_ado_service_connection_azure.sh](../scripts/pipelines/ado/create_ado_service_connection_azure.sh): used in conjunction with `ADO_ORGANIZATION_URL` to get the target project ID.

## ADO_GITHUB_SERVICE_CONNECTION

The ADO service connection name used to access the GitHub repository. [Service connections/endpoints in Azure DevOps](https://learn.microsoft.com/en-us/azure/devops/pipelines/library/service-endpoints?view=azure-devops&tabs=yaml). [GitHub service connection details](https://learn.microsoft.com/azure/devops/pipelines/library/service-endpoints?view=azure-devops&tabs=yaml#github-service-connection).

It must be set in "sssc.config" when `CI_CD_PLATFORM` is "ado" ![Azure Pipelines](../images/icons/ado-pipeline.svg). There is a [manual step](../docs/walkthrough/azure-pipelines/README.md#manually-create-github-service-connection) described at the beginning of the Azure Pipelines walkthrough covering creation of the service connection.

**Script references**:

- [setup/init_environment.sh](../scripts/setup/init_environment.sh): if `CI_CD_PLATFORM` equals "ado", checks and sets value when it exists. Otherwise, exits with error.
- pipelines/ado/provision.sh
  - [pipelines/ado/create_ado_pipeline.sh](../scripts/pipelines/ado/execute_ado_pipeline.sh): used to retrieve the ID for the service connection so that Azure Pipelines has access to pull the YAML file from the GitHub repository.

## KUBERNETES_VERSION

The version of Kubernetes that AKS should be running.

> [!IMPORTANT]
> Ratify is compatible with Kubernetes v1.20 or higher. Keep this in mind if changing from the provided default.

There is an option to set in "sssc.config". If not provided, "1.27.7" will used.

**Script references**:

- [setup/init_environment](../scripts/setup/init_environment.sh): checks and sets value; uses the default if none provided.
- infra/provision.sh
  - [infra/steps/aks.sh](../scripts/infra/steps/aks.sh): used as the value of the `--kubernetes-version` flag as a part of the `az aks create` command.

## GATEKEEPER_VERSION

The Helm chart version of Gatekeeper to be deployed. _Helm chart versions and GitHub releases are one-to-one._

> [!IMPORTANT]
> Ratify is compatible with OPA Gatekeeper v3.10 or higher. Keep this in mind if changing from the provided default.

There is an option to set in "sssc.config". If not provided, "3.14.0" will used.

**Script references**:

- [setup/init_environment.sh](../scripts/setup/init_environment.sh): checks and sets value; uses the default if none provided.
- infra/provision.sh
  - [infra/steps/helm_charts.sh](../scripts/infra/steps/helm_charts.sh): indicates which version of the Gatekeeper Helm chart should be installed and is a parameter for the Helm install of Ratify.

## RATIFY_VERSION

The Helm chart version of Ratify to be deployed. _The Helm chart version will probably not match the applicable GitHub release._

There is an option to set in "sssc.config". If not provided, "1.12.1" will be used. _Changing this value is not recommended as there is an increased risk of CRDs and configuration incompatibility due to the breaking changes between Helm chart versions 1.12.0 / 1.12.1 and older or newer releases._

**Script references**:

- [setup/init_environment.sh](../scripts/setup/init_environment.sh): checks and sets value; uses the default if none provided.
- infra/provision.sh
  - [infra/steps/helm_charts.sh](../scripts/infra/steps/helm_charts.sh): indicates which version of the Ratify Helm chart should be installed.

## PROJECT

A string of lowercase alphanumeric characters to be used when naming created resources.

There is an option to set in "sssc.config". If not provided, "ssscsample" will be used.

**Script references**:

- [setup/init_environment.sh](../scripts/setup/init_environment.sh): checks and sets value; uses the default if none provided.
- [infra/provision.sh](../scripts/infra/provision.sh): combined with `DEPLOYMENT_ID` to set unique `PROJECT_NAME` (`${PROJECT}-${DEPLOYMENT_ID}`).

## GITHUB_REPO_URL

The full URL for the working GitHub repository.

It is set as a part of infrastructure provisioning by combining "<https://github.com/>" with the value of `GITHUB_REPO`.

**Script references**:

- [infra/provision.sh](../scripts/infra/provision.sh): Set using `GITHUB_REPO` (`https://github.com/${GITHUB_REPO}`)
- [pipelines/ado/create_ado_pipeline.sh](../scripts/pipelines/ado/create_ado_pipeline.sh): Used as a parameter to tell Azure DevOps where to find the source pipeline YAML from which to create the Azure Pipelines pipeline.

## DEPLOYMENT_ID

A random alphanumeric string. It is 5 characters in length. Alpha characters are all lowercase.

It is generated the first time the sssc.env file is created.

**Script references**:

- [setup/init_environment.sh](../scripts/setup/init_environment.sh): checks and sets value accordingly.
- [infra/provision.sh](../scripts/infra/provision.sh): combined with `PROJECT` to set unique `PROJECT_NAME` (`${PROJECT}-${DEPLOYMENT_ID}`). Also combined with "sssc" to create unique `RESOURCE_PREFIX` (`sssc${DEPLOYMENT_ID}`).

## PROJECT_NAME

A unique string used for consistent naming across various resources created as a part of this walkthrough. This both makes it clear what resources are associated with this exercise and allows for programmatic cleanup once complete.

It is set as a part of infrastructure provisioning by combining `PROJECT` and `DEPLOYMENT_ID`

**Script references**:

- [infra/provision.sh](../scripts/infra/provision.sh): value is set as `${PROJECT}-${DEPLOYMENT_ID}`.
  - [infra/steps/app_registration.sh](../scripts/infra/steps/app_registration.sh): used as the display name for the Microsoft Entra ID app registration created to allow the relevant CI/CD platform to push to Azure.
  - [infra/steps/resource_group.sh](../scripts/infra/steps/resource_group.sh): combined with "-rg" to form the name of the resource group to be created (`${PROJECT_NAME}-rg`)
- [infra/teardown.sh](../scripts/infra/teardown.sh): used as the constant value to search on to identify the relevant resources to be deleted.
- [pipelines/ado/provision.sh](../scripts/pipelines/ado/provision.sh): used as the value of `ADO_VARIABLE_GROUP_NAME`. the prefix of the value for `ADO_AZURE_SERVICE_CONNECTION`.
  - [pipelines/ado/create_ado_pipeline.sh](../scripts/pipelines/ado/create_ado_pipeline.sh):
- [pipelines/github/provision.sh](../scripts/pipelines/github/provision.sh): used as the value for`GITHUB_DEPLOYMENT_ENV_NAME`
  - [pipelines/github/create_github_federated_credential.sh](../scripts/pipelines/github/create_github_federated_credential.sh): used as the friendly/display name of the federated credential.

## RESOURCE_PREFIX

A unique string used as a prefix for most Azure resources. The key exception is the resource group which includes the `PROJECT_NAME` instead.

It is set as a part of infrastructure provisioning by combining "sssc" with `DEPLOYMENT_ID`.

**Script references**:

- [infra/provision.sh](../scripts/infra/provision.sh): value is set as `sssc${DEPLOYMENT_ID}`
  - [infra/steps/acr.sh](../scripts/infra/steps/acr.sh): used to name the provisioned ACR: `${RESOURCE_PREFIX}acr`.
  - [infra/steps/aks.sh](../scripts/infra/steps/aks.sh): used to name the provisioned AKS cluster (`${RESOURCE_PREFIX}aks`), the user-managed managed identity for Ratify (`${RESOURCE_PREFIX}RatifyAksIdentity`) and the federated credential for use by workload identity in the AKS cluster (`${RESOURCE_PREFIX}RatifyFederatedIdentityCredentials`) so the Ratify pod can authenticate as the user-managed managed identity.
  - [infra/steps/keyvault.sh](../scripts/infra/steps/keyvault.sh): used to name the provisioned Key Vault  `${RESOURCE_PREFIX}kv`.

## RESOURCE_GROUP_NAME

The name of the resource group created.

It is set as a part of infrastructure provisioning by combining `RESOURCE_PREFIX` with "rg".

**Script references**:

- infra/provision.sh
  - [infra/steps/resource_group.sh](../scripts/infra/steps/resource_group.sh): if not set,defined as `${RESOURCE_PREFIX}-rg` and an Azure resource group is created with the generated name.
  - [infra/steps/acr.sh](../scripts/infra/steps/acr.sh): provided to set the resource group in which to provision a container registry.
  - [infra/steps/aks.sh](../scripts/infra/steps/aks.sh): provided to set the resource group in which to provision a cluster as well as for scoping the identity and federated credential for Ratify and granting the `acrPull` role to the appropriate container registry for the Ratify identity.
  - [infra/steps/app_registration.sh](../scripts/infra/steps/app_registration.sh): used when providing ownership of the resource group to the created Microsoft Entra ID app registration used by the given pipeline platform to interact with ACR.
  - [infra/steps/keyvault.sh](../scripts/infra/steps/keyvault.sh): provided to set the resource group in which to provision a vault and used for scoping roles assigned to the current user and the pipeline app registration.
  - [infra/steps/helm_charts.sh](../scripts/infra/steps/helm_charts.sh): used to retrieve the credentials for the AKS cluster to facilitate installation of Gatekeeper and Ratify
- pipelines/ado/provision.sh
  - [pipelines/ado/create_ado_variables.sh](../scripts/pipelines/ado/create_ado_variables.sh): resource group is one of the variables created for use in the pipeline.
- pipelines/github/provision.sh
  - [pipelines/github/create_github_variables.sh](../scripts/pipelines/github/create_github_variables.sh): resource group is one of the variables created for use in the workflow.

## ACR_NAME

The name of the created Azure Container Registry.

It is set as a part of infrastructure provisioning by combining `RESOURCE_PREFIX` with "acr".

**Script references**:

- infra/provision.sh
  - [infra/steps/acr.sh](../scripts/infra/steps/acr.sh):if not set,defined as `${RESOURCE_PREFIX}acr` and an ACR is created with the generated name.
  - [infra/steps/aks.sh](../scripts/infra/steps/aks.sh): provided as a parameter when provisioning an AKS cluster to auto-attach the cluster to the given container registry.
- pipelines/ado/provision.sh
  - [pipelines/ado/create_ado_variables.sh](../scripts/pipelines/ado/create_ado_variables.sh): ACR name is one of the variables created for use in the pipeline.
- pipelines/github/provision.sh
  - [pipelines/github/create_github_variables.sh](../scripts/pipelines/github/create_github_variables.sh): ACR name is one of the variables created for use in the workflow.

## ACR_LOGIN_SERVER

The valid URI for logging into ACR.

This is a property included in the output of `az acr create`.

**Script references**:

- infra/provision.sh
  - [infra/steps/acr.sh](../scripts/infra/steps/acr.sh): set with the value parsed from the output of the `az acr create` command.
- pipelines/ado/provision.sh
  - [pipelines/ado/create_ado_variables.sh](../scripts/pipelines/ado/create_ado_variables.sh): login server is one of the variables created for use in the pipeline.
- pipelines/github/provision.sh
  - [pipelines/github/create_github_variables.sh](../scripts/pipelines/github/create_github_variables.sh): login server is one of the variables created for use in the workflow.

**Docs references**:

- [Walkthrough: View hierarchical relationships between artifacts in ACR](../docs/walkthrough/view-artifacts.md): This value is used to login to ACR with ORAS
- [Walkthrough: Deploy workloads](../docs/walkthrough/sample-app-deployment.md): This value prefixes the image name to form the URL of the images to be deployed to the cluster

## ENTRA_APP_ID

The GUID identifier for the Microsoft Entra ID app registration used by the pipeline.

It is set as a part of infrastructure provisioning.

**Script references**:

- infra/provision.sh
  - [infra/steps/app_registration.sh](../scripts/infra/steps/app_registration.sh): if not set, creates a new app registration named `PROJECT_NAME`
- pipelines/ado/provision.sh
  - [pipelines/ado/create_ado_service_connection_azure.sh](../scripts/pipelines/ado/create_ado_service_connection_azure.sh): a service connection / service endpoint is created to allow federated credentials are created for the app registration to facilitate interaction with Azure resources in Azure Pipelines pipelines.
- pipelines/github/provision.sh
  - [pipelines/github/create_github_federated_credential.sh](../scripts/pipelines/github/create_github_federated_credential.sh): federated credentials are created for the app registration which explicitly grant GitHub workflows to interact with Azure resources when executing within the specified environment(`GITHUB_DEPLOYMENT_ENV_NAME`) .
  - [pipelines/github/create_github_variables.sh](../scripts/pipelines/github/create_github_variables.sh): a secret named "ENTRA_APP_ID" is created within the GitHub environment (`GITHUB_DEPLOYMENT_ENV_NAME`) with this value. The secret is referenced within the GitHub workflow when authenticating with the Azure CLI.

## SERVICE_PRINCIPAL_ID

The GUID identifier for the service principal created for the Microsoft Entra ID app registration (`ENTRA_APP_ID`).

It is set as a part of infrastructure provisioning.

**Script references**:

- infra/provision.sh
  - [infra/steps/app_registration.sh](../scripts/infra/steps/app_registration.sh): when `ENTRA_APP_ID` is not set, a new app registration is created. Then, a service principal is created for the newly created app registration. The id of the service principal is the value of this variable. The service principal is then assigned as owner of the created resource group.
  - [infra/steps/keyvault.sh](../scripts/infra/steps/keyvault.sh): the service principal is assigned the following roles for the created Key Vault: secrets user, crypto user and key vault reader.

## AKS_NAME

The name of the created Azure Kubernetes Service.

It is set as a part of infrastructure provisioning by combining `RESOURCE_PREFIX` with "aks".

**Script references**:

- infra/provision.sh
  - [infra/steps/aks.sh](../scripts/infra/steps/aks.sh):if not set, defined as `${RESOURCE_PREFIX}aks` and an AKS is created with the generated name.
  - [infra/steps/helm_charts.sh](../scripts/infra/steps/helm_charts.sh): used to retrieve the credentials for the AKS cluster to facilitate installation of Gatekeeper and Ratify
- pipelines/ado/provision.sh
  - [pipelines/ado/create_ado_variables.sh](../scripts/pipelines/ado/create_ado_variables.sh): AKS name is one of the variables created for use in the pipeline.
- pipelines/github/provision.sh
  - [pipelines/github/create_github_variables.sh](../scripts/pipelines/github/create_github_variables.sh): AKS name is one of the variables created for use in the workflow.

## AKS_OIDC_ISSUER

The URL of the cluster issuer (external identity provider).

It is set as a part of infrastructure provisioning.

**Script references**:

- infra/provision.sh
  - [infra/steps/aks.sh](../scripts/infra/steps/aks.sh): set with the value parsed from the output of the `az aks create` command. It is provided as the parameter for "issuer" when creating the federated credential for the user-managed identity Ratify leverages through [workload identity](https://learn.microsoft.com/en-us/azure/aks/workload-identity-overview?tabs=dotnet#how-it-works)

## RATIFY_CLIENT_ID

The GUID `clientId` of the user-assigned managed identity for Ratify.

It is created as a part of infrastructure provisioning and is the value of the `clientId` property of the output of `az identity create`.

**Script references**:

- infra/provision.sh
  - [infra/steps/aks.sh](../scripts/infra/steps/aks.sh): if not set, then it is retrieved from the output of creating a new user-managed identity named `${RESOURCE_PREFIX}RatifyAksIdentity` is created. Federated credentials are generated for use by [Workload Identity in AKS](https://learn.microsoft.com/en-us/azure/aks/workload-identity-overview?tabs=dotnet). As this will be the identity associated with the Ratify, it is assigned the `acrPull` role.
  - [infra/steps/helm_charts.sh](../scripts/infra/steps/helm_charts.sh): passed as the value for the `azureWorkloadIdentity.clientId` parameter when installing the Ratify helm chart.

## KEY_VAULT_NAME

The name of the created Azure Key Vault.

It is set as a part of infrastructure provisioning by combining `RESOURCE_PREFIX` with "kv".

**Script references**:

- infra/provision.sh
  - [infra/steps/keyvault.sh](../scripts/infra/steps/keyvault.sh):if not set, defined as `${RESOURCE_PREFIX}kv` and a vault is created with the generated name. It is also used for scoping roles assigned to the current user and the pipeline app registration.
  - [infra/steps/certs.sh](../scripts/infra/steps/certs.sh): used to check if a signing certificate already exists.
    - [certs/create_signing_cert_kv.sh](../scripts/certs/create_signing_cert_kv.sh): a CSR (certificate signing request) is created in the Key Vault with the provided name. Following the CA signing the request, Key Vault completes the request resulting in a leaf certificate being created and stored within.

## CA_CERT_SUBJECT

The `Subject` of the Certificate Authority which signs the certificate signing requests to create the signing certificates.

It is set as a part of infrastructure provisioning.

**Script references**:

- infra/provision.sh
  - [infra/steps/certs.sh](../scripts/infra/steps/certs.sh): if not set, defined as `/C=US/ST=WA/L=Redmond/O=Company ${PROJECT_NAME}/CN=${PROJECT_NAME} Certificate Authority`.
    - [certs/create_ca.sh](../scripts/certs/create_ca.sh): Passed in as the value of the `-subj` parameter as a part of the OpenSSL command to create the certificate for the CA key.

## SIGN_CERT_SUBJECT

The `Subject` of the signing certificate used to sign the successful workload (the Trips application) and its artifacts.

It is set as a part of infrastructure provisioning.

**Script references**:

- infra/provision.sh
  - [infra/steps/certs.sh](../scripts/infra/steps/certs.sh): if not set, defined as `C=US, ST=WA, L=Redmond, O=Company ${PROJECT_NAME}, OU=Org A, CN=pipeline.example.com`
    - [certs/create_signing_cert_kv.sh](../scripts/certs/create_signing_cert_kv.sh): provided as the value for `subject` as a part of the JSON policy used to create the CSR in Azure Key Vault.
- [policy/create_notation_verifier.sh](../scripts/policy/create_notation_verifier.sh): prefixed with `x509.subject:`, the only value in the `trustedIdentities` collection of the Notation trust policy.

## ALT_CERT_SUBJECT

The `Subject` of the signing certificate used to sign one of the failing workloads (the User Profile application) and its artifacts.

It is set as a part of infrastructure provisioning.

**Script references**:

- infra/provision.sh
  - [infra/steps/certs.sh](../scripts/infra/steps/certs.sh): if not set, defined as `C=US, ST=WA, L=Redmond, O=Company ${PROJECT_NAME}, OU=Org B, CN=alt.example.com`.
    - [certs/create_alt_signing_cert_kv.sh](../scripts/certs/create_alt_signing_cert_kv.sh): provided as the value for `subject` as a part of the JSON policy used to create the CSR in Azure Key Vault.

## SIGNING_CERT_NAME

The name of the x509 certificate used to sign the successful workload (the Trips application) and its artifacts.

It is set as a part of infrastructure provisioning.

**Script references**:

- infra/provision.sh
  - [infra/steps/certs.sh](../scripts/infra/steps/certs.sh): if no `SIGNING_KEY_ID` exists, set as `${PROJECT_NAME}-pipeline-cert`.
    - [certs/create_signing_cert_kv.sh](../scripts/certs/create_signing_cert_kv.sh): used as the file name for the CSR, the name of the certificate within Azure Key Vault and as the file name for the output PEM file containing the certificate.

## ALT_SIGNING_CERT_NAME

The name of the x509 certificate used to sign one of the failing workloads (the User Profile application) and its artifacts.

It is set as a part of infrastructure provisioning.

**Script references**:

- infra/provision.sh
  - [infra/steps/certs.sh](../scripts/infra/steps/certs.sh): if no `ALT_SIGNING_KEY_ID` exists, set as `${PROJECT_NAME}-pipeline-cert-alt`.
    - [certs/create_alt_signing_cert_kv.sh](../scripts/certs/create_signing_cert_kv.sh): used as the file name for the CSR, the name of the certificate within Azure Key Vault and as the file name for the output PEM file containing the certificate.

## SIGNING_KEY_ID

The unique identifier of the signing certificate stored in Key Vault and used to sign artifacts for the successful workload (Trips) in the pipeline.

It is set as a part of infrastructure provisioning.

**Script references**:

- infra/provision.sh
  - [infra/steps/certs.sh](../scripts/infra/steps/certs.sh): if not set, a leaf certificate for signing is created.
  - [certs/create_signing_cert_kv.sh](../scripts/certs/create_signing_cert_kv.sh): upon successful creation of the x509 certificate in Azure Key Vault, this value is set using the `kid` property of the output.
- pipelines/ado/provision.sh
  - [pipelines/ado/create_ado_variables.sh](../scripts/pipelines/ado/create_ado_variables.sh): a variable with the same name is created for use for signing with Notation within the Azure Pipelines pipeline.
- pipelines/github/provision.sh
  - [pipelines/github/create_github_variables.sh]: a variable with the same name is created for use for signing with Notation within the Github Actions workflow.

## ALT_SIGNING_KEY_ID

The unique identifier of the signing certificate stored in Key Vault and used to sign artifacts for one of the unsuccessful workload (User Profil) in the pipeline.

It is set as a part of infrastructure provisioning.

**Script references**:

- infra/provision.sh
  - [infra/steps/certs.sh](../scripts/infra/steps/certs.sh): if not set, then a leaf certificate for signing is created.
  - [certs/create_alt_signing_cert_kv.sh](../scripts/certs/create_alt_signing_cert_kv.sh): upon successful creation of the x509 certificate in Azure Key Vault, this value is set using the `kid` property of the output.
- pipelines/ado/provision.sh
  - [pipelines/ado/create_ado_variables.sh](../scripts/pipelines/ado/create_ado_variables.sh): a variable with the same name is created for use for signing with Notation within the Azure Pipelines pipeline.
- pipelines/github/provision.sh
  - [pipelines/github/create_github_variables.sh]: a variable with the same name is created for use for signing with Notation within the Github Actions workflow.

## ADO_AZURE_SERVICE_CONNECTION

The name of the ADO service connection used to access the Azure resources within the Azure Pipelines pipeline. [Service connections/endpoints in Azure DevOps](https://learn.microsoft.com/en-us/azure/devops/pipelines/library/service-endpoints?view=azure-devops&tabs=yaml).

Set when the Azure service connection is created combining `PROJECT_NAME` with "-asc"  when `CI_CD_PLATFORM` is "ado" ![Azure Pipelines](../images/icons/ado-pipeline.svg)

**Script references**:

- [pipelines/ado/provision.sh](../scripts/pipelines/ado/provision.sh): set as `${PROJECT_NAME}-asc`
  - [pipelines/ado/create_ado_service_connection_azure.sh](../scripts/pipelines/ado/create_ado_service_connection_azure.sh): if a service connection does not exist with the expected name, a new service connection is created with this name to allow a given Azure Pipelines pipeline to interact with Azure resources.
  - [pipelines/ado/create_ado_variables.sh](../scripts/pipelines/ado/create_ado_variables.sh): a variable is named `AZURE_SERVICE_CONNECTION` is created and this is the value it is given. `AZURE_SERVICE_CONNECTION` is then referenced within pipeline YAML when authenticating with the Azure CLI.

## ADO_VARIABLE_GROUP_NAME

The variable group containing all relevant and required pipeline variables.

Set as a part of pipeline provisioning when `CI_CD_PLATFORM` is "ado" ![Azure Pipelines](../images/icons/ado-pipeline.svg) with the same value as `PROJECT_NAME`.

**Script references**:

- [pipelines/ado/provision.sh](../scripts/pipelines/ado/provision.sh): set as `PROJECT_NAME`
  - [pipelines/ado/create_ado_variables.sh](../scripts/pipelines/ado/create_ado_variables.sh): if a variable group with the expected name exists, it is deleted and a new one is created. The created variable group houses values required for pipeline execution.
- [pipelines/ado/execute_ado_pipeline.sh](../scripts/pipelines/ado/execute_ado_pipeline.sh): provided as a required parameter `variableGroupName` ("Variable Group Name").

**Docs references**:

- [Walkthrough: Azure Pipelines - Pipeline execution](../docs/walkthrough/azure-pipelines/README.md#pipeline-execution): if the choice is made to execute the pipeline manually rather than via script, the Azure Pipelines GUI will prompt for the required parameter "Variable Group Name" (`variableGroupName`). The value can be found in this environment variable.

## PIPELINE_NAME

The friendly name for the Azure Pipelines pipeline to be executed.

Set as a part of pipeline provisioning when `CI_CD_PLATFORM` is "ado" ![Azure Pipelines](../images/icons/ado-pipeline.svg). It is a combination of `PROJECT_NAME` and the file name of the YAML pipeline definition.

**Script references**:

- pipelines/ado/provision.sh
  - [pipelines/ado/create_ado_pipeline.sh](../scripts/pipelines/ado/create_ado_pipeline.sh): set as `${PROJECT_NAME}-sssc.linux.notation.yaml`
- [pipelines/ado/execute_ado_pipeline.sh](../scripts/pipelines/ado/execute_ado_pipeline.sh): provided as a required parameter to indicate which pipeline to run

## GITHUB_DEPLOYMENT_ENV_NAME

The name of the created GitHub Environment. GitHub Environments allow clean grouping of variables and secrets and facilitate the possibility of multiple unique runs without requiring starting fresh.

Set as a part of pipeline provisioning when `CI_CD_PLATFORM` is "github" ![GitHub Actions](../images/icons/gh-actions.svg) with the same value as `PROJECT_NAME`.

**Script references**:

- [pipelines/github/provision.sh](../scripts/pipelines/github/provision.sh): set as `PROJECT_NAME`
  - [pipelines/github/create_github_variables.sh](../scripts/pipelines/github/create_github_variables.sh): a GitHub environment is created with the provided name. Every variable and secret required for workflow execution is set and associated with the environment.
  - [pipelines/github/create_github_federated_credential](../scripts/pipelines/github/create_github_federated_credential.sh): the GitHub environment name is used to scope access to the Microsoft Entra ID app registration so only workflows in a GitHub repository running against/within the specified environment are granted access to Azure resources.
- [pipelines/github/execute_github_workflow.sh](../scripts/pipelines/github/execute_github_workflow.sh): provided as a required input to indicate which environment a workflow should execute against or within to specify which variables and secrets should be used.

**Docs references**:

- [Walkthrough: GitHub -- Pipeline execution](../docs/walkthrough/github-actions/README.md#create-github-workflow):  if the choice is made to trigger the workflow manually rather than via script, the GitHub Actions GUI will prompt for the required input "Environment Name" (`environment_name`). The value can be found in this environment variable.

## WORKFLOW_FILE

The file name of the GitHub Actions workflow to be executed.

Set as a part of pipeline provisioning when `CI_CD_PLATFORM` is "github" ![GitHub Actions](../images/icons/gh-actions.svg) and hard-coded to match the file in the workflows directory - `.github/workflows/`.

**Script references**:

- [pipelines/github/provision.sh](../scripts/pipelines/github/provision.sh): set with the expected file name "sssc.linux.notation.yaml"
- [pipelines/github/execute_github_workflow.sh](../scripts/pipelines/github/execute_github_workflow.sh): provided as a required parameter to run the workflow with the GitHub CLI
