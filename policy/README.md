# Policy

## Gatekeeper

Gatekeeper supports policies for both admission control webhooks - validation and mutation. Only validation policies are in scope for this scenario.

Each validation policy is made up of two parts: constraint templates and constraints. A collection of policies relevant to the capabilities and controls discussed in this repository can be found [here](gatekeeper-policy/README.md).

## Ratify

Ratify is an external data provider for Gatekeeper. It has to composable providers itself -- stores and verifiers. For this situation, the only configured store provider is the Azure Container Registry and that is handled on installation of Ratify on the cluster. Three artifact types which require unique verifiers for handling: Notation signatures, SPDX SBOMs and Trivy vulnerability scan results in SARIF format. The Notation verifier is built into Ratify and configuration is handled on install, like the store provider. The configuration of the SBOM and vulnerability scan result verifiers is done with CRDs as described [here](ratify-verifiers/README.md)
