# Provided Gatekeeper Policies

> Some of these policies can be applied at the service level.

## Signed

**Goal**: only allow signed images to be deployed.

For Notation signatures, not only must the signature validation pass Ratify, but the certificate's issuing authority against a provided value. The [template](signedimage/constraint-template.notation.yaml) ensures the following:

1. No errors were thrown by the system (Gatekeeper + Ratify).
2. Ratify did not catch and return errors.
3. A signature was found in the registry attached to the image, passed Ratify's validation based on the configured certificate store _and_ the issuer in Ratify's response matches the parameterized value.

The [constraint](signedimage/constraint.notation.yaml) provides the subject of the CA created in the scripts [here](../../scripts/certs/create-ca.sh) as `issuer`.

## Signed SBOM

**Goal**: only allow images with signed SBOMs to be deployed. Ratify includes a SBOM verifier plugin to validate SPDX SBOMs.

For SBOMs signed by Notation, the [template](signedsbom/constraint-template.spdx.notation.yaml) checks for the following:

1. No errors were thrown by the system (Gatekeeper + Ratify).
2. Ratify did not catch and return errors.
3. The SBOM verifier succeeded in validating an attached SBOM. _This includes checking that the artifact is a valid SPDX SBOM._
4. The successful SBOM result has an attached signature which passed Ratify's validation _and_ the issuer in the response matches the parameterized value.

The [constraint](signedsbom/constraint.spdx.notation.yaml) provides the subject of the CA created in the scripts [here](../../scripts/certs/create-ca.sh) as `issuer`.

## Signed vulnerability scan result

**Goal**: only allow images with signed valid vulnerability scan results to be deployed. The validity of the result report is determined via schema validation. The schema validator verifier is configured as "for _artifact type x_, the valid schema is _y_". The configuration CRD for the verifier can be found [here](../ratify-verifiers/verifier-vulnscanresult.trivy.yaml) .

For Trivy scans signed by Notation, the [template](signedvulnscanresult/constraint-template.trivy.notation.yaml) checks for the following:

1. No errors were thrown by the system (Gatekeeper + Ratify).
2. Ratify did not catch and return errors.
3. The schema validator verifier succeeded in validating an artifact with type `application/trivy+json`.
4. The successful schema validation result has an attached signature which passed Ratify's validation _and_ the issuer in the response matches the parameterized value.

The [constraint](signedvulnscanresult/constraint.trivy.notation.yaml) provides the subject of the CA created in the scripts [here](../../scripts/certs/create-ca.sh) as `issuer`.

## Registry restriction

**Goal**: only allow images which originate from trusted registries to be deployed. The [template](allowedrepos/constraint-template.yaml) accepts a parameter - a list of acceptable registry domain(s).

## Image digest

**Goal**: only allow deployments in which the image is referenced by digest, not by tag. The [template](requireimagedigest/constraint-template.yaml) does not accept any parameters.
