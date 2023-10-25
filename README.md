# Assure workload integrity in AKS with secure software supply chain

[![Open in GitHub Codespaces](https://img.shields.io/static/v1?style=for-the-badge&label=GitHub+Codespaces&message=Open&color=brightgreen&logo=github)](https://codespaces.new/microsoft/secure-software-supply-chain-on-aks)
[![Open in Dev Container](https://img.shields.io/static/v1?style=for-the-badge&label=Dev+Containers&message=Open&color=blue&logo=visualstudiocode)](https://vscode.dev/redirect?url=vscode://ms-vscode-remote.remote-containers/cloneInVolume?url=https://github.com/microsoft/secure-software-supply-chain-on-aks)

## Overview

This repo offers a step-by-step guide on how to establish centralized control for risk management by creating software supply chain components and employing policies. This walkthrough covers the following aspects of the secure software supply chain:

- Generation of the [software bill of materials (SBOM)](https://www.cisa.gov/sbom) by analyzing source code, dependencies, and container image packages using [Microsoft's SBOM tool](https://github.com/microsoft/sbom-tool).
- Production of vulnerability reports using Aquasec's [Trivy](https://trivy.dev/).
- Signing of both the container image and security artifacts using [Notation](https://notaryproject.dev/).
- Bundling of the signatures, security artifacts, and container image (the software release) using [ORAS](https://oras.land/) .
- Enforcement of policies through [Gatekeeper](https://open-policy-agent.github.io/gatekeeper/website/) and [Ratify](https://ratify.dev/) as part of the admission control process.

### Architecture

The following architecture will be provisioned and configured upon successful completion of the walkthrough. For a more detailed breakdown see [provisioned infrastructure](docs/walkthrough/provisioned-infrastructure.md).

![Solution infrastructure, described further on the page linked above](images/infrastructure.simple.drawio.svg)

## Getting started

### Fork repository

This walkthrough requires the user have certain permissions at the repository level. Fork the repository and work within the fork to make sure all steps can be performed.

### Walkthrough environment

It is highly recommended to leverage the supplied [Visual Studio Code development container](.devcontainer/README.md) or GitHub Codespaces when working with this walkthrough. The devcontainer, which is also used by Codespaces, includes all the required tooling with no additional steps or configuration.

If not utilizing the devcontainer or Codespaces, review the list of [required utilities](.devcontainer/README.md#utilities) and verify each is installed and configured.

### Pipeline options

When working with this walkthrough, there are two pipeline options for building images and artifacts: `Azure Pipelines` and `GitHub Actions`. Each option requires a slightly different configuration.

Please ensure [the walkthrough environment](#walkthrough-environment) is up and running before continuing with either pipeline option.

[![Continue with Azure Pipelines](https://img.shields.io/badge/-Azure_Pipelines-f8f8f8?style=for-the-badge&logo=azuredevops&logoColor=0078D7)](docs/walkthrough/azure-pipelines/README.md)

[![Continue with GitHub Actions](https://img.shields.io/badge/-GitHub_Actions-f8f8f8?style=for-the-badge&logo=github&logoColor=181717)](docs/walkthrough/github-actions/README.md)

## Additional references

- [Technology used in this blueprint](docs/supplemental/technology.md)
- [Glossary](docs/supplemental/glossary.md)
- [Signing keys and certificates](docs/supplemental/signing-keys-and-certificates.md)

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft 
trademarks or logos is subject to and must follow 
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
