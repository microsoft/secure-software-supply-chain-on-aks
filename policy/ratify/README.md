# Ratify configuration

As mentioned, Ratify provides three customer resource definitions to facilitate configuration. The following are applied and configured "for free" as a part of Helm chart installation:

    - ORAS store. There can be only one store of a given type so this ORAS store is used to connect to all OCI registries. As deployed in this walkthrough, the ORAS store is configured to use [Microsoft Entra Workload ID](https://learn.microsoft.com/en-us/azure/aks/workload-identity-overview?tabs=dotnet); other authentication options for both Azure and AWS are available.
    - A basic Notation verifier. No certificate stores are configured and the trust policy is generic.
    - A generic rego-based policy. Passthrough mode is not enabled meaning Ratify sets the `isSuccess` property in the response and does not return the verification results. It requires that there be at least 1 artifact verification result and that all verifier checks succeeded/passed.

Of the default CRDs, only the ORAS store will be left as-is. In addition to overwriting the policy and Notation verifier, an SBOM verifier, a vulnerability scan verifier and a certificate store CRD will be applied.

## Notation verifier

### Certificate Store

This CRD is used to provide Ratify with an x509 CA certificate to use for Notation signature validation. It is generated with [scripts/policy/create_certstore_with_ca.sh](../../scripts/policy/create_certstore_with_ca.sh) to concatenate the contents of the root CA certificate created in the walkthrough into the appropriately formatted YAML file.

### Verifier configuration

This CRD is used to configure the Notation plugin with the desired [Notation trust store(s) and trust policy](https://github.com/notaryproject/specifications/blob/main/specs/trust-store-trust-policy.md). It is generated with [scripts/policy/create_notation_verifier.sh](../../scripts/policy/create_notation_verifier.sh). Of note, the `Subject` of the signing certificate used to sign the Trips application, which is stored as environment variable `SIGN_CERT_SUBJECT`, is provided as the single value in the `trustedIdentities` collection. This ensures that workloads not signed by a leaf certificate with that `Subject` will be denied admission and cannot be deployed into the cluster.

## Policy

The [policy.yaml](policy.yaml) file is an implementation of Ratify's rego policy provider. Each subject workload must meet the following criteria:

- It is signed.
- It has a signed SBOM in SPDX format.
- It has a valid signed vulnerability scan result.
- All signatures pass Notation's authenticity, integrity and trust verification.

## SBOM verifier

The [verifier-sbom.yaml](verifier-sbom.yaml) file configured the SBOM verifier. It will be used for verification of all artifacts with `artifactType` of `application/spdx+json`. The `nestedReferences` parameter ensures Ratify checks for a signature for the SBOM.

## Vulnerability Report verifier

The [verifier-vulnscanresult.trivy.yaml](verifier-vulnscanresult.trivy.yaml) file configures the Vulnerability Report verifier. It is used for verification of all artifacts with `artifactType` or `application/sarif+json`. The `nestedReferences` parameter ensures Ratify checks for a signature for the report. The `maximumAge` parameter has a value of `24h`. This means that the workload must have a vulnerability result that was executed within the last day based upon the value of the `org.opencontainers.image.created` OCI annotation for the scan result artifact.
