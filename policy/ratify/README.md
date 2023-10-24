# Ratify verifier plugins

[Gatekeeper](https://open-policy-agent.github.io/gatekeeper/website/) can interface with [external data sources](https://open-policy-agent.github.io/gatekeeper/website/docs/externaldata) to provide supplementary information to be considered when evaluating policy. [Ratify](https://ratify.dev/) serves as an external data provider for Gatekeeper and allows policy to be written against OCI registries concerning artifacts and relationships between artifacts and images alike. For flexible configuration options, Ratify has defined [CustomResourceDefinitions](https://kubernetes.io/docs/tasks/extend-kubernetes/custom-resources/custom-resource-definitions/) to manage various plugin configurations.

## SBOM

The [SBOM CRD](verifier-sbom.yaml) configures the plugin named `sbom` for artifact type `application/org.example.sbom.v0`.

## Vulnerability scan result

The [Trivy CRD](verifier-vulnscanresult.trivy.yaml) configured the plugin named `schemavalidator` for artifact type `application/trivy+json`. The schema validator plugin accepts a key-value pair associating content type with its schema. In this instance, the schema for content type `application/sarif+json` can be downloaded from [https://json.schemastore.org/sarif-2.1.0-rtm.5.json](https://json.schemastore.org/sarif-2.1.0-rtm.5.json).
