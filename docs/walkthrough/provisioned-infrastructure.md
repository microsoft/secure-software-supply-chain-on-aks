# Provisioned resources

The following resources are provisioned and configured for this walkthrough:

In Azure:

- Resource Group
  - Azure Container Registry (ACR)
    - SKU: Standard
  - Azure Kubernetes Service (AKS)
    - OIDC issuer enabled
    - Workload Identity enabled
    - Tier: Free
    - Gatekeeper installed via [Helm](https://helm.sh/)
    - Ratify installed via [Helm](https://helm.sh/)
    - The kubelet identity is granted access to ACR
  - Azure Key Vault
    - RBAC enabled
    - SKU: Standard
    - Within: 1 x509 certificate for Notation. _Further details can be found [here](../supplemental/signing-keys-and-certificates.md)_
  
In Microsoft Entra ID (formerly known as Azure AD):

- An [app registration + service principal](https://learn.microsoft.com/en-us/azure/active-directory/develop/app-objects-and-service-principals?tabs=azure-cli)
  - The app registration is used to enable appropriate access and grant permissions to the chosen pipeline
  - The service principal is an owner of the resource group and has crypto and secrets permissions for the provisioned Key Vault
- A [user-assigned managed identity](https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview) for use by Ratify
  - Federated credentials are established for use by [AKS workload identity](https://learn.microsoft.com/en-us/azure/aks/workload-identity-overview)
  - The managed identity is granted access to ACR

![A resource group containing the icons for AKS, ACR and Key Vault. An app registration in Microsoft Entra ID. A line from the app registration to the resource group labeled "owner" to indicate ownership of the resource group by the underlying service principal. A second line from the app registration to Key Vault labeled crypto and secrets permissions to indicate the assigned roles granted to enable Notation to sign artifacts within the pipeline.](../../images/infrastructure.pipeline.drawio.svg)

![A box labeled AKS with the icons for Gatekeeper, Ratify, AKS workload identity and Kubernetes kubelet. Both Ratify and Gatekeeper are installed on the cluster. The Ratify icon has a dashed line to the icon for AKS workload identity which itself has a line to the user-assigned managed identity within Microsoft Entra ID. This is to indicate how workload identity enables the Ratify workload to impersonate the user-assigned managed identity. The icon for kubelet has a line connecting to ACR labeled "pull permissions" which allows images to be pulled from the private registry into the AKS cluster. The user-assigned managed identity icon also has a line connecting to ACR labeled "pull permissions" to allow Ratify to retrieve artifacts from the private registry.](../../images/infrastructure.environment.drawio.svg)

> [!NOTE]
> The above resources are provisioned and configured for the purpose of this walkthrough. The resources are not intended for production use and may not adhere to best practices.
>
> For production use, it is recommended to enable private endpoints to ensure traffic between applicable resources is routed through the Azure backbone network. For more information see:
>
> - [Azure Private Link](https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-overview)
> - [Azure Private Link network architecture](https://learn.microsoft.com/en-us/azure/architecture/guide/aks/aks-firewall)
> - [Baseline architecture for an Azure Kubernetes Service (AKS) cluster](https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/containers/aks/baseline-aks)
