# Tooling scripts

For additional details on the specific tools, including external links to respective sites, please see [Technology](../../docs/supplemental/technology.md)

| Script                                       | Description                               | Used Where?                                                                                                      |
|----------------------------------------------|-------------------------------------------|------------------------------------------------------------------------------------------------------------------|
| [install_oras.sh](install_oras.sh)           | Installs ORAS                             | [install_tooling.sh](install_tooling.sh)                                                                         |
| [install_sbom_tool.sh](install_sbom_tool.sh) | Installs Microsoft SBOM tool              | [install_tooling.sh](install_tooling.sh) and [GitHub workflow](../../.github/workflows/sssc.linux.notation.yaml) |
| [install_trivy.sh](install_trivy.sh)         | Installs Trivy                            | [install_tooling.sh](install_tooling.sh)                                                                         |
| [install_notation.sh](install_notation.sh)   | Installs Notation                         | [install_tooling.sh](install_tooling.sh)                                                                         |
| [install_tooling.sh](install_tooling.sh)     | Executes required tooling install scripts | [Azure DevOps pipeline](../../.azdevops/sssc.linux.notation.yaml) \*\*\*                                         |

> [!NOTE]
> \*\*\* The following available GitHub Actions in place of install scripts: [setup-oras](https://github.com/oras-project/setup-oras) and [notation-action](https://github.com/notaryproject/notation-action). AquaSec provides the [trivy-action](https://github.com/aquasecurity/trivy-action) which handles installation and execution in one step.
