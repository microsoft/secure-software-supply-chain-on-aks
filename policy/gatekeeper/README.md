# Provided Gatekeeper Policies

> Some of these policies can be applied at the service level.

## Ratify-facilitated verification

**Goal**: Ratify determines whether a workload can be deployed based upon [its configured policy](../ratify/policy.yaml). The [template](ratifyverification/constraint-template.yaml) includes the external data HTTP request to Ratify and verifies success or failure. The [constraint](ratifyverification/constraint.yaml) sets the enforcement so failure results in denied deployment.

## Registry restriction

**Goal**: only allow images which originate from trusted registries to be deployed. The [template](allowedrepos/constraint-template.yaml) accepts a parameter - a list of acceptable registry domain(s).

## Image digest

**Goal**: only allow deployments in which the image is referenced by digest, not by tag. The [template](requireimagedigest/constraint-template.yaml) does not accept any parameters.
