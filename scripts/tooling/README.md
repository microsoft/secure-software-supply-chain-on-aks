# Tooling scripts

For additional details on the specific tools, including external links to respective sites, please see [Technology](../../docs/supplemental/technology.md)

| Script                                       | Description                                | Used Where?                                                                                                      |
|----------------------------------------------|--------------------------------------------|------------------------------------------------------------------------------------------------------------------|
| [install-notation.sh](install-notation.sh)   | Notation and the Azure Key Vault provider  | [install-tooling.sh](install-tooling.sh) and [GitHub workflow](../../.github/workflows/sssc.linux.notation.yaml) |
| [install-oras.sh](install-oras.sh)           | Installs ORAS                              | [install-tooling.sh](install-tooling.sh)                                                                         |
| [install-sbom-tool.sh](install-sbom-tool.sh) | Installs Microsoft SBOM tool               | [install-tooling.sh](install-tooling.sh) and [GitHub workflow](../../.github/workflows/sssc.linux.notation.yaml) |
| [install-trivy.sh](install-trivy.sh)         | Installs Trivy                             | [install-tooling.sh](install-tooling.sh) and [GitHub workflow](../../.github/workflows/sssc.linux.notation.yaml) |
| [install-tooling.sh](install-tooling.sh)     | Executes all above tooling install scripts | [Azure DevOps pipeline](../../.azdevops/sssc.linux.notation.yaml)                                                |
