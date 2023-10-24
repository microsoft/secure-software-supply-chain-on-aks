# Signing keys and certificates

Notation uses x509 certificates. The recommendation is to have a certificate chain -- although nothing as complex as this certificate hierarchy [described by MS Learn](https://learn.microsoft.com/en-us/windows/win32/seccertenroll/about-certificate-hierarchy). This solution uses a root CA certificate and a leaf certificate. Both adhere to [the Notation specification requirements](https://github.com/notaryproject/notaryproject/blob/main/specs/signature-specification.md#certificate-requirements). The leaf certificate is used within the pipeline to sign images and artifacts. The root CA certificate is used by Ratify to validate the signature.

If you would rather bring your own certificates, please be sure to review Notation specification as well as the [bash scripts for certificate creation in this repository](../scripts/infra/certs/README.md) to ensure parity.

## Azure Key Vault

Notation has a plugin framework to enable flexibility when integrating with PKI providers. For Azure Key Vault, the leaf certificate must be stored as a certificate chain in PEM format.

> [!NOTE]
> Only the certificate used to sign images and artifacts must live in Azure Key Vault. The CA certificate is provided to Ratify via CRD to ensure compatibility with offline storage of such certificates.
