# Configure policies in AKS to ensure image integrity

## Overview

A core facet of securing the software supply chain is policy enforcement. This capability ensures only verified and trusted workloads are run in production environments. For the purposes of this exercise, only **signed images** with a **signed SBOM** and a **signed SARIF vulnerability scan result** should be allowed to run in AKS. As seen while [viewing artifacts in the previous step](view-artifacts.md), the Trips application has all the required artifacts while the POI application is lacking.

[Gatekeeper](https://open-policy-agent.github.io/gatekeeper/website/) is a Kubernetes-native policy controller. By creating [validating and mutating admission webhooks](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/) in Kubernetes, it enforces polices using [Open Policy Agent](https://www.openpolicyagent.org/). Gatekeeper can interface with [external data sources](https://open-policy-agent.github.io/gatekeeper/website/docs/externaldata) to consider supplementary information while evaluating policy. In this case, [Ratify](https://ratify.dev/) serves as an external data provider for Gatekeeper and allows policy to interrogate artifacts and relationships between artifacts and images housed within OCI registries.

## Configure Ratify

Ratify ships with three verifiers which can be configured via the [Ratify custom resource](https://ratify.dev/docs/ratify-configuration#crds).

There is a default configuration [CRD for Notation signature verification](https://ratify.dev/docs/reference/crds/verifiers/#notation) that installs as a part of the Helm chart install of Ratify. This configuration lacks certificates within the `verificationCertStores` parameter. The [Notary Project's trust store specification](https://github.com/notaryproject/specifications/blob/main/specs/trust-store-trust-policy.md#trust-store) allows verification with a root x509 certificate. The root CA certificate created during infrastructure provisioning is what will be used to verify the signatures for the image, SBOM and vulnerability scan result. An Inline Certificate Provider CRD must be created with the contents of the certificate by executing the following:

```bash
./scripts/certs/create_certstore_with_ca.sh
```

The updated [Notation CRD](../../policy/ratify/verifier-signature.notation.yaml) references the cert. store created named `certstore-inline`.

For verification of SPDX SBOMs, Ratify provides an [SBOM verifier CRD](https://ratify.dev/docs/reference/crds/verifiers/#sbom). The [CRD](../../policy/ratify/verifier-sbom.yaml) to be applied has an artifact type of `application/org.example.sbom.v0`. As the SBOM must be signed, the optional parameter `nestedReferences` is provided with the Notation signature artifact type: `application/vnd.cncf.notary.signature`.

Ratify also ships with a generic [JSON schema validator CRD](https://ratify.dev/docs/reference/crds/verifiers/#schemavalidator). It accepts a parameter named `schema`. This parameter is a list of key/value pairs where the key is an IANA media type and the value is the URL for the expected schema definition. The [CRD](../../policy/ratify/verifier-vulnscanresult.trivy.yaml) to be applied is intended to validate that there is a valid SARIF vulnerability scan result for artifacts of type `application/trivy+json`. The configured schema pairs media type `application/sarif+json` with the schema found at [https://json.schemastore.org/sarif-2.1.0-rtm.5.json](https://json.schemastore.org/sarif-2.1.0-rtm.5.json).

Execution of the following will apply the Ratify certificate provider CRD and three above-described verifier CRDs:

```bash
./scripts/policy/apply_ratify_crds.sh
```

## Configure Gatekeeper

Gatekeeper includes two relevant types of custom resources. A [`ConstraintTemplate`](https://open-policy-agent.github.io/gatekeeper/website/docs/constrainttemplates/) is designed to execute a block of [rego](https://www.openpolicyagent.org/docs/latest/policy-language/) and determine whether the workload should be deployed. A `Constraint` is an implementation of a given template. Constraints provide values for a template's parameters and can be scoped.

Three constraint templates with accompanying constraints need to be applied. Each template handles evaluation of a single rule. Within the rego block of each template, the `external_data` function is called which is how Gatekeeper knows to make the HTTP call to Ratify for additional information. The remainder of the block involves parsing Ratify's response object and checking for specific values.

| Rule                                               | ConstraintTemplate                                                                                                              | Constraint                                                                                                    |
|----------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------|
| Image must be signed by Notation                   | [constraint-template.notation.yaml](../../policy/gatekeeper/signedimage/constraint-template.notation.yaml)                      | [constraint.notation.yaml](../../policy/gatekeeper/signedimage/constraint.notation.yaml)                      |
| Image must have a signed SBOM                      | [constraint-template.spdx.notation.yaml](../../policy/gatekeeper/signedsbom/constraint-template.spdx.notation.yaml)             | [constraint.spdx.notation.yaml](../../policy/gatekeeper/signedsbom/constraint.spdx.notation.yaml)             |
| Image must have a signed vulnerability scan result | [constraint-template.trivy.notation.yaml](../../policy/gatekeeper/signedvulnscanresult/constraint-template.trivy.notation.yaml) | [constraint.trivy.notation.yaml](../../policy/gatekeeper/signedvulnscanresult/constraint.trivy.notation.yaml) |

The following script will apply the `Constraint` and `ConstraintTemplate` CRDs described above:

```bash
./scripts/policy/apply_gatekeeper_crds.sh
```

> More details as well as suggested baseline constraint templates can be found [here](../../policy/gatekeeper/README.md).

<br/>

[![Deploy sample workloads](https://img.shields.io/badge/Deploy_sample_workloads-f8f8f8?style=for-the-badge&label=Next&labelColor=4051b5)](sample-app-deployment.md)
