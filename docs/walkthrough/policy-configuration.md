# Configure policies in AKS to ensure image integrity

## Overview

A core facet of securing the software supply chain is policy enforcement. This capability ensures only verified and trusted workloads are run in production environments. For the purposes of this exercise, only **signed images** with a **signed SBOM** and a **signed SARIF vulnerability scan result** should be allowed to run in AKS. As seen while [viewing artifacts in the previous step](view-artifacts.md), the Trips application has all the required artifacts while the POI application is lacking.

[Gatekeeper](https://open-policy-agent.github.io/gatekeeper/website/) is a Kubernetes-native policy controller. By creating [validating and mutating admission webhooks](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/) in Kubernetes, it enforces polices using [Open Policy Agent](https://www.openpolicyagent.org/). Gatekeeper can interface with [external data sources](https://open-policy-agent.github.io/gatekeeper/website/docs/externaldata) to consider supplementary information while evaluating policy. In this case, [Ratify](https://ratify.dev/) serves as an external data provider for Gatekeeper and allows policy to interrogate artifacts and relationships between artifacts and images housed within OCI registries.

## Configure Ratify

This walkthrough leverages all three verifiers that Ratify currently ships with. The [Ratify custom resource](https://ratify.dev/docs/ratify-configuration#crds) is used in this guide to configure the verifiers. Each verifier handles the evaluation of a specific type of artifact. Although the verifiers themselves are not decision makers, each is configured to have an opinion on whether a given artifact passes or fails evaluation.

### Notation signature verification

There is a default configuration [CRD for Notation signature verification](https://ratify.dev/docs/reference/crds/verifiers/#notation) that is applied with the Ratify Helm chart installation. However, a custom certificate store is required. The [Notary Project's trust store specification](https://github.com/notaryproject/specifications/blob/main/specs/trust-store-trust-policy.md#trust-store) allows verification with a root x509 certificate. The root CA certificate created during infrastructure provisioning is what will be used to verify the signatures for the image, SBOM and vulnerability scan result. An Inline Certificate Provider CRD must be created with the contents of the certificate by executing the following:

```bash
./scripts/policy/create_certstore_with_ca.sh
```

A CRD to configure the Notation verifier using the created certificate store is required. Since verification is done with the root CA certificate, both the previously describe Trips (`$TRIPS_APP`) and User Profile (`$USER_PROFILE_APP`) would pass verification. For the purpose of this exercise, only Trips (`$TRIPS_APP`) should successfully deploy. By setting the `trustedIdentities` property of the Notation trust policy with the value of the Trips' signing certificate's `Subject`, such policy can be enforced.

Execute the following to generate the Notation verifier CRD:

```bash
./scripts/policy/create_notation_verifier.sh
```

### SBOM verification

For verification of SPDX SBOMs, Ratify provides an [SBOM verifier CRD](https://ratify.dev/docs/reference/crds/verifiers/#sbom). The [CRD](../../policy/ratify/verifier-sbom.yaml) to be applied has an artifact type of `application/spdx+json`. As the SBOM must be signed, the optional parameter `nestedReferences` is provided with the Notation signature artifact type: `application/vnd.cncf.notary.signature`.

### Vulnerability report verification

For verification of Trivy- and Grype-generated SARIF vulnerability scan results, Ratify provides a [vulnerability report CRD](https://ratify.dev/docs/external%20plugins/Verifier/vulnerabilityreport). The [CRD](../../policy/ratify/verifier-vulnscanresult.trivy.yaml) to be applied has an artifact type of `application/sarif+json`. There is also a freshness requirement -- the result must be within the last 24 hours. As the vulnerability scan result must be signed, the optional parameter `nestedReferences` is provided with the Notation signature artifact type: `application/vnd.cncf.notary.signature`.

### Policy

Ratify supports two format options for policy declaration - [config](https://ratify.dev/docs/reference/crds/policies#configpolicy) and [rego](https://ratify.dev/docs/reference/crds/policies#regopolicy). Rego is the same language used in the body of Gatekeeper `ConstraintTemplates` and is a much more powerful option within Ratify. It facilitates crafting nuanced rules which Ratify can enforce while keeping complexity out of the `ConstraintTemplate`.

The `policy` parameter within [CRD](../../policy/ratify/policy.yaml) enforces the following:

- A subject workload must be signed.
- It must have a signed SBOM in SPDX format.
- It must a valid signed vulnerability scan result.
- All signatures must pass Notation's authenticity, integrity and trust verification.

The `passthroughEnabled` parameter determines whether Ratify returns the `verifierReports` to Gatekeeper or just the `isSuccess` value. This is set to `true` as there is no other way to surface details when a workload is denied admission / fails.

### Apply CRDs

Execution of the following will apply all of the above-described resources:

```bash
./scripts/policy/apply_ratify_crds.sh
```

## Configure Gatekeeper

Gatekeeper includes two relevant types of custom resources. A [`ConstraintTemplate`](https://open-policy-agent.github.io/gatekeeper/website/docs/constrainttemplates/) is designed to execute a block of [rego](https://www.openpolicyagent.org/docs/latest/policy-language/) and determine whether the workload should be deployed. A `Constraint` is an implementation of a given template. Constraints provide values for a template's parameters and can be scoped.

Although most of the heavy lifting is done within the Ratify policy configuration, the final `isSuccess` value in the response cannot serve as the sole decision maker. Within the [constraint template](../../policy/gatekeeper/ratifyverification/constraint-template.yaml), if the Ratify response root-level `isSuccess` property equals `false`, this means that the subject lacked reference artifacts. Otherwise, Ratify sets it to `true`. For any / all failing verifier results, the error message is collected. This allows the error message from Gatekeeper to include the unique error message(s) returned from Ratify to more easily inform users _why_ a workload was not deployed. A [constraint](../../policy/gatekeeper/ratifyverification/constraint.yaml) to accompany the constraint template is also required.

The following script will apply the CRDs described above:

```bash
./scripts/policy/apply_gatekeeper_crds.sh
```

> More details as well as suggested baseline constraint templates can be found [here](../../policy/gatekeeper/README.md).

<br/>

[![Deploy sample workloads](https://img.shields.io/badge/Deploy_sample_workloads-f8f8f8?style=for-the-badge&label=Next&labelColor=4051b5)](sample-app-deployment.md)
