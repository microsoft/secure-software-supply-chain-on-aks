# Technology used

## Azure Container Registry (ACR)

[Azure Container Registry (ACR)](https://azure.microsoft.com/en-us/products/container-registry/) is Azure's OCI-compliant artifact registry. It was [one of the first registries](https://techcommunity.microsoft.com/t5/apps-on-azure-blog/azure-container-registry-the-first-cloud-registry-to-support-the/ba-p/3708998) to be updated to support the OCI v1.1 distribution specification.

## Azure Kubernetes Service (AKS)

[Azure Kubernetes Service (AKS)](https://azure.microsoft.com/en-us/products/kubernetes-service/) is Azure's managed Kubernetes offering.

## Gatekeeper

[Gatekeeper](https://open-policy-agent.github.io/gatekeeper/website/) is a Kubernetes-native policy controller. By hooking into the Kubernetes [validating and mutating](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/), it enforces polices using [Open Policy Agent](https://www.openpolicyagent.org/).

## Key Vault

[Key Vault](https://azure.microsoft.com/en-us/products/key-vault/) is Azure's offering for cryptographic key managemenet.

## Microsoft SBOM Tool

[The Microsoft SBOM Tool](https://github.com/microsoft/sbom-tool) runs against code / filesystems and Linux images to produce a SPDX 2.2-compatible software bill of material (SBOM).

## Notation

[Notation](https://notaryproject.dev/docs/) allows users to sign OCI artifacts and images, store the signature as an OCI artifact within a OCI v1.1 compliant registry and verify the signature(s) associated with a given object in the registry.

### Azure Key Vault provider plugin

The [Azure Key Vault provider](https://github.com/Azure/notation-azure-kv) is a plugin to Notation to enable usage of certificates housed within Azure Key Vault.

## OCI specification updates

The updates included in [v1.1 of the OCI image and distribution specifications](https://opencontainers.org/posts/blog/2023-07-07-summary-of-upcoming-changes-in-oci-image-and-distribution-specs-v-1-1/) have codified storing non-image artifacts in OCI registries. Additionally, there is now support for explicitly-defined hierarchial relationships between artifacts within a given OCI 1.1-compliant registry. Within the manifest, the `subject` field is used to indicate the parent artifact. The `referrers` endpoint can be used to query the child artifacts for a given digest.

## ORAS

[ORAS](https://oras.land/docs/) enables users to push and pull non-image artifacts to and from OCI registries. This CLI also facilitates building and discovering relationships between images and artifacts within OCI v1.1 compliant registries.

## ORAS Project OCI Registry

Prior to the finalization of the OCI 1.1 specification updates, the ORAS Project created a [custom OCI registry](https://github.com/oras-project/distribution/pkgs/container/registry) to support development and testing of the OCI Artifact specification. This proposed separate specification was discarded in favor of updating the OCI Image specification to broadly support the `subject` field and `artifact type`. The ORAS registry is currently used as a local registry within the CI/CD pipeline so the artifact bundle can be created locally and pushed in a single step to Azure Container Registry.

## Ratify

Gatekeeper can interface with [external data sources](https://open-policy-agent.github.io/gatekeeper/website/docs/externaldata) to provide supplementary information to be considered when evaluating policy. In this case, [Ratify](https://ratify.dev/) serves as an external data provider for Gatekeeper and allows policy to be written against OCI registries concerning artifacts and relationships between artifacts and images alike.

## Static Analysis Results Interchange Format (SARIF)

[Static Analysis Results Interchange Format (SARIF)](https://sarifweb.azurewebsites.net/) is an industry standard format designed to capture the output of static analysis tools. It is [approved](https://www.oasis-open.org/news/announcements/static-analysis-results-interchange-format-sarif-v2-1-0-is-approved-as-an-oasis-s/) by [OASIS](https://www.oasis-open.org/).

## Trivy

[Trivy](https://github.com/aquasecurity/trivy) is an open source vulnerability scanner from Aquasec. It can be run against file systems and/or container images. Although it supports a variety of output formats, SARIF is the format leveraged by this repository.
