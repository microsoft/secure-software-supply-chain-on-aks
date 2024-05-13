# Policy

[Gatekeeper](https://open-policy-agent.github.io/gatekeeper/website/) can interface with [external data sources](https://open-policy-agent.github.io/gatekeeper/website/docs/externaldata) to provide supplementary information to be considered when evaluating policy. [Ratify](https://ratify.dev/) serves as an external data provider for Gatekeeper and allows policy to be written against OCI registries concerning artifacts and relationships between artifacts and images alike. Both Gatekeeper and Ratify have defined [CustomResourceDefinitions](https://kubernetes.io/docs/tasks/extend-kubernetes/custom-resources/custom-resource-definitions/) to manage aspects of configuration.

## Gatekeeper

Gatekeeper is a validating and mutating [admission control webhook](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/#admission-webhooks) for Kubernetes. Each policy is composed of two parts: [constraint templates](https://open-policy-agent.github.io/gatekeeper/website/docs/howto#constraint-templates) and [constraints](https://open-policy-agent.github.io/gatekeeper/website/docs/howto#constraints).

[This page](gatekeeper-policy/README.md) describes the policies included in this repository.

## Ratify

Ratify has three composable providers -- policy, stores and verifiers. Ratify allows for one, and only one, Policy configuration. Stores, also known as _referrer stores_, are the data sources from which Ratify can retrieve relevant artifacts. The ORAS (OCI Registry As Storage) store is shipped as a part of Ratify. Verifiers are used to inspect and evaluate particular types of artifacts and make a decision regarding an artifact.

[This page](ratify-verifiers/README.md) describes the Ratify CRDs used in the walkthrough.
