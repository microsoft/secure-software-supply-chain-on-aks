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
oras discover -o tree $TRIPS_APP
```

Output should resemble:

```txt
ssscqaq79acr.azurecr.io/trips@sha256:935bb665fb4f8e798fcf093dd70a99b71559cf46c4b3da6de0efb492f2157749
├── application/sarif+json
│   └── sha256:81cb7f7c34708aa9ac63c0e7c4bc99ca35f072bde255db322bbd320ddb8f6157
│       └── application/vnd.cncf.notary.signature
│           └── sha256:8326586d0411404369ccdb66a8e410a84f2d4a9c6fec54ba7f407bfb20ee5a2c
├── application/spdx+json
│   └── sha256:563622a9766138a2c391fcddb6575a66fef56d6f478bc7ffa7bd10f61142766c
│       └── application/vnd.cncf.notary.signature
│           └── sha256:73999f3deddc3d9dd2943dd745f1c45a3f0876fa2506d1b00e663e3b27ddf9c2
└── application/vnd.cncf.notary.signature
    └── sha256:7799979688cbceb60154b2122a6c32122a2835e0c76b5e89748560de62b2c9aa
```

> Even though the tag was provided, ORAS translates tag to digest for display

The `-tree` output format displays the hierarchial relationships as displayed below:

![Within a container registry is an image. The image has 3 nested or child artifacts - a signature, a software bill of materials (SBOM) and a vulnerability scan result. The child SBOM has its own nested signature. The child vulnerability scan result has its own nested signature.](../../images/acr-oci-artifacts.drawio.svg)

## User Profile

Like Trips, the User Profile image should be signed and have attached artifacts.

```bash
oras discover -o tree $USER_PROFILE_APP
```

Output should resemble:

```txt
ssscqaq79acr.azurecr.io/userprofile@sha256:67bb89aa1dfc2833d6406366da5bc460fd608af535f7b3d9216abeedac5bf9f3
├── application/sarif+json
│   └── sha256:25062d314e2d4a2815bf3ddb374771385d54c81e9b3d6fb28c77f7a1bffa5421
│       └── application/vnd.cncf.notary.signature
│           └── sha256:ac8961d3eece7c78d9ed3799fade00e8670b1d86b5f51611fcc91731314d89db
├── application/spdx+json
│   └── sha256:ad1f11cebdc069592ec4f00e7426bcf9cc032f74b17bfb3e4528fd450e2ab043
│       └── application/vnd.cncf.notary.signature
│           └── sha256:c4415bccb3e6c2d7680cab18e5671265fbb0f949980078abdd6dfc48c3792663
└── application/vnd.cncf.notary.signature
    └── sha256:fa488510740c53975c08b7aaca97906f4900b65c24b98020a6dabea4a5dcf0ac
```

## POI

Verify POI image lacks any attached artifacts using ORAS.

```bash
oras discover -o tree $POI_APP
```

Output should resemble:

```txt
ssscqaq79acr.azurecr.io/poi@sha256:8622885115a0cc578bffc278962bc3f9e6d4199315de9b0f0f0a88c911bc114d
```

<br/>

[![Configure policy](https://img.shields.io/badge/Configure_policy-f8f8f8?style=for-the-badge&label=Next&labelColor=4051b5)](policy-configuration.md)
