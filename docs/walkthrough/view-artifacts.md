# View hierarchical relationships between artifacts in ACR

> [!IMPORTANT]
> Ensure the pipeline has successfully completed before continuing.

The updates included in [v1.1 of the OCI image and distribution specifications](https://opencontainers.org/posts/blog/2023-07-07-summary-of-upcoming-changes-in-oci-image-and-distribution-specs-v-1-1/) have codified storing non-image artifacts in OCI registries. Additionally, there is now support for explicitly-defined hierarchial relationships between artifacts within a given OCI 1.1-compliant registry. Within the manifest, the `subject` field is used to indicate the parent artifact. The `referrers` endpoint can be used to query the child artifacts for a given digest.

[ORAS](https://oras.land/) is a command-line tool which facilitates building and viewing these hierarchial relationships.

## Overview

Following the execution of either the [Azure Pipelines pipeline](azure-pipelines/README.md#run-azure-pipeline) or [GitHub Actions workflow](github-actions/README.md#run-github-workflow), two images were pushed to Azure Container Registry. One app, Trips, has attached artifacts; specifically, a signature, a signed SBOM and a signed vulnerability scan result. The other, POI, has no artifacts.  As the traversal of these relationships is an integral part of enforcing policy on deployment, the steps described provide a visualization of the Trips artifact bundle and how it contrasts with POI's lack of artifacts.

## Set local session env vars

To ensure all of the previously set environment variables are set for the current session they must be imported.

```bash
. ./config/sssc.env
```

## Login to Azure Container Registry

The [devcontainer](../../.devcontainer/README.md) does not include Docker as there are known compatibility issues with Docker features and macOS M1 & M2 chips. Using the `--expose-token` param allows login to ACR without Docker or Moby. More details on `--expose-token` can be found [here](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-authentication?tabs=azure-cli#az-acr-login-with---expose-token).

```bash
TOKEN=$(az acr login --expose-token -n $ACR_NAME --query accessToken -o tsv)
echo $TOKEN | oras login $ACR_LOGIN_SERVER -u 00000000-0000-0000-0000-000000000000 --password-stdin
```

## Trips

Verify Trips has expected artifacts attached with ORAS.

```bash
SIGNED_IMG=$ACR_LOGIN_SERVER/trips:v1
oras discover -o tree $SIGNED_IMG
```

Output should resemble:

```txt
    sssczmskwoacr.azurecr.io/trips@sha256:5881e31b68a3912036a133c3cb6321a7b33de91c30dc8cc73f290b662e9e8c6e
    ├── application/trivy+json
    │   └── sha256:a818876327b867e012b7f82567ab9df56b903de61d0f0353ae0b916b2743cb23
    │       └── application/vnd.cncf.notary.signature
    │           └── sha256:b121f2987279a899d0e5d958a97d4051b659857e191454a196d3213fef779402
    ├── application/org.example.sbom.v0
    │   └── sha256:e1272dfa6c36cbdc5ade2f67350d9e1fb55e7b5634d0b05131ab2868b04ce4bc
    │       └── application/vnd.cncf.notary.signature
    │           └── sha256:a54822dc4d1ea785e23543cd78b6063249ae335d7304a995f36803f3b03b7f88
    └── application/vnd.cncf.notary.signature
        └── sha256:1c8d586ff8f24a8e62888cd903c3b7592bd4473a711e461b073bf5e94195bc8d
```

> Even though the tag was provided, ORAS translates tag to digest for display

The `-tree` output format displays the hierarchial relationships as displayed below:

![Within a container registry is an image. The image has 3 nested or child artifacts - a signature, a software bill of materials (SBOM) and a vulnerability scan result. The child SBOM has its own nested signature. The child vulnerability scan result has its own nested signature.](../../images/acr-oci-artifacts.drawio.svg)

## POI

Verify POI image lacks any attached artifacts using ORAS.

```bash
UNSIGNED_IMG=$ACR_LOGIN_SERVER/poi:v1
oras discover -o tree $UNSIGNED_IMG
```

Output should resemble:

```txt
sssczmskwoacr.azurecr.io/poi@sha256:ef027856e50f0f15e7bddb7d2232f28a8afad19c71413f9b5beefdbe095c3d57
```

<br/>

[![Configure policy](https://img.shields.io/badge/Configure_policy-f8f8f8?style=for-the-badge&label=Next&labelColor=4051b5)](policy-configuration.md)
