# Signing keys and certificates

Notation uses x509 certificates. Notation supports two scenarios:

1. Signing and verifying with a self-signed certificate.
2. Signing with a leaf certificate, embedding the full certificate chain in the signature's envelope and verifying with the root (CA) certificate.

Option 2 is the suggested course of action and has been chosen for this exercise -- although nothing as complex as this certificate hierarchy [described by MS Learn](https://learn.microsoft.com/en-us/windows/win32/seccertenroll/about-certificate-hierarchy). Specifically, a root certificate is created along with two leaf signing certificates. All adhere to [the Notation specification requirements](https://github.com/notaryproject/notaryproject/blob/main/specs/signature-specification.md#certificate-requirements). The root certificate is used by Ratify for signature validation. The leaf certificates are used within the pipeline to sign images and artifacts.

If you would rather bring your own certificates, please be sure to review Notation specification as well as the [certificate-related bash script invoked as a part of infrastructure provisioning](../../scripts/infra/steps/certs.sh) to ensure parity and proper environment configuration.

Notation has a plugin framework to enable flexibility when integrating with PKI providers. Currently, there are four signing integrations: Azure Key Vault, HashiCorp Vault, AWS Signer and Venafi CodeSign Protect.

## Azure Key Vault

For Azure Key Vault, leaf certificates must be stored with its certificate chain intact in PEM format.

> [!NOTE]
> Only the certificates used to sign images and artifacts must live in Azure Key Vault. The root certificate is provided to Ratify via CRD to facilitate compatibility with offline CA certificate storage.
