# Deploy workloads

Now that the chosen pipeline has run, [the images and attached artifacts have been reviewed](view-artifacts.md) and [Gatekeeper and Ratify have been configured to enforce policy in AKS](policy-configuration.md), it is time to see it all in action.

To ensure all of the previously set environment variables are set for the current session they must be imported.

```bash
. ./config/sssc.env
```

## Deploy unsigned workload lacking security artifacts

Deploy the POI workload. This deployment should fail as the image is not signed and it lacks both a signed SBOM and a signed vulnerability scan result.

```bash
kubectl run poi --image=$POI_APP
```

Failed output shown in the terminal should resemble:

```txt
Error from server (Forbidden): admission webhook "validation.gatekeeper.sh" denied the request: [ratify-constraint] Subject sssc76iepacr.azurecr.io/poi@sha256:5d1b188c81d2fb48ba0ae90394d2cd247f58bdf44dcb86a68039a3b01a4014a7 failed verification: Subject lacks reference artifacts
```

## Deploy signed workload with required signed security artifacts signed by an invalid certificate subject

Deploy the User Profile workload. This deployment should fail. Although the image has all the required artifacts (signatures, SBOMs, and vulnerability scan results), the signing certificate's subject is not a trusted identity. The [bash script that generated it](../../scripts/certs/create_alt_signing_cert_kv.sh) has set the subject to "C=US, ST=WA, L=Seattle, O=My Company, OU=My Other Org, CN=alt.example.com".

```bash
kubectl run userprofile --image=$USER_PROFILE_APP
```

Failure output in the terminal should resemble:

```txt
Error from server (Forbidden): admission webhook "validation.gatekeeper.sh" denied the request: [ratify-constraint] Subject sssc76iepacr.azurecr.io/userprofile@sha256:67bb89aa1dfc2833d6406366da5bc460fd608af535f7b3d9216abeedac5bf9f3 failed verification: Original Error: (Original Error: (signing certificate from the digital signature does not match the X.509 trusted identities [map["C":"US" "CN":"pipeline.example.com" "L":"Redmond" "O":"My Company" "OU":"My Org" "ST":"WA"]] defined in the trust policy "default"), Error: verify plugin failure, Code: VERIFY_PLUGIN_FAILURE, Plugin Name: verifier-notation, Component Type: verifier, Documentation: https://ratify.dev/docs/troubleshoot/verifier/notation, Detail: failed to verify signature of digest), Error: verify reference failure, Code: VERIFY_REFERENCE_FAILURE, Plugin Name: verifier-notation, Component Type: verifier; vulnerability report validation failed: report is older than maximum age:[24h]
```

Although the error message does include the specific distinct failures, use `kubectl logs` to get Ratify logs for the User Profile deployment to view the full results.

```bash
kubectl logs -l app.kubernetes.io/name=ratify --namespace gatekeeper-system --tail 100
```

The output should include:

```diff
{
  "verifierReports": [
    {
      "subject": "sssc76iepacr.azurecr.io/userprofile@sha256:c805416f73236ea64d8e3f670387ef162457db5d6c38b9716dcd46f93e0951db",
+      "referenceDigest": "sha256:cd4fb8d3c64c5a985cf652fc3ee82bd45d543ba2590250e7d23aaebdf194178e",
+      "artifactType": "application/sarif+json",
      "verifierReports": [
        {
-          "isSuccess": false,
-          "message": "vulnerability report validation failed: report is older than maximum age:[24h]",
          "name": "verifier-vuln",
          "extensions": {
            "createdAt": "2024-03-19T21:40:27Z"
          }
        }
      ],
      "nestedReports": [
        {
+          "subject": "sssc76iepacr.azurecr.io/userprofile@sha256:cd4fb8d3c64c5a985cf652fc3ee82bd45d543ba2590250e7d23aaebdf194178e",
          "referenceDigest": "sha256:19738200ccc916c9e27e9eb22b1a08f59145a669b80c45cd2e11683122eff513",
+          "artifactType": "application/vnd.cncf.notary.signature",
          "verifierReports": [
            {
-              "isSuccess": false,
-              "message": "Original Error: (Original Error: (signing certificate from the digital signature does not match the X.509 trusted identities [map[\"C\":\"US\" \"CN\":\"pipeline.example.com\" \"L\":\"Redmond\" \"O\":\"My Company\" \"OU\":\"My Org\" \"ST\":\"WA\"]] defined in the trust policy \"default\"), Error: verify plugin failure, Code: VERIFY_PLUGIN_FAILURE, Plugin Name: verifier-notation, Component Type: verifier, Documentation: https://ratify.dev/docs/troubleshoot/verifier/notation, Detail: failed to verify signature of digest), Error: verify reference failure, Code: VERIFY_REFERENCE_FAILURE, Plugin Name: verifier-notation, Component Type: verifier",
              "name": "verifier-notation",
              "type": "notation",
              "extensions": null
            }
          ],
          "nestedReports": []
        }
      ]
    },
    {
      "subject": "sssc76iepacr.azurecr.io/userprofile@sha256:c805416f73236ea64d8e3f670387ef162457db5d6c38b9716dcd46f93e0951db",
+      "referenceDigest": "sha256:379050a1e89d10852237cebff10f51df38bf3f234f7115f11f9f64159b23fe48",
+      "artifactType": "application/spdx+json",
      "verifierReports": [
        {
+          "isSuccess": true,
+          "message": "SBOM verification success. No license or package violation found.",
          "name": "verifier-sbom",
          "extensions": {
            "creationInfo": {
              "created": "2024-03-21T21:40:23Z",
              "creators": [
                "Organization: UserProfile",
                "Tool: Microsoft.SBOMTool-1.1.5"
              ]
            }
          }
        }
      ],
      "nestedReports": [
        {
+          "subject": "sssc76iepacr.azurecr.io/userprofile@sha256:379050a1e89d10852237cebff10f51df38bf3f234f7115f11f9f64159b23fe48",
          "referenceDigest": "sha256:d946e31b3144d2513e0e0d31fddaf5303b7264bcbdcdc77faae6c56a6abd0263",
+          "artifactType": "application/vnd.cncf.notary.signature",
          "verifierReports": [
            {
-              "isSuccess": false,
-              "message": "Original Error: (Original Error: (signing certificate from the digital signature does not match the X.509 trusted identities [map[\"C\":\"US\" \"CN\":\"pipeline.example.com\" \"L\":\"Redmond\" \"O\":\"My Company\" \"OU\":\"My Org\" \"ST\":\"WA\"]] defined in the trust policy \"default\"), Error: verify plugin failure, Code: VERIFY_PLUGIN_FAILURE, Plugin Name: verifier-notation, Component Type: verifier, Documentation: https://ratify.dev/docs/troubleshoot/verifier/notation, Detail: failed to verify signature of digest), Error: verify reference failure, Code: VERIFY_REFERENCE_FAILURE, Plugin Name: verifier-notation, Component Type: verifier",
              "name": "verifier-notation",
              "type": "notation",
              "extensions": null
            }
          ],
          "nestedReports": []
        }
      ]
    },
    {
      "subject": "sssc76iepacr.azurecr.io/userprofile@sha256:c805416f73236ea64d8e3f670387ef162457db5d6c38b9716dcd46f93e0951db",
      "referenceDigest": "sha256:820a77543bf40c18b2ff58626a020f25fe41155cc235ff4c4cd22c0af887e6c7",
+      "artifactType": "application/vnd.cncf.notary.signature",
      "verifierReports": [
        {
-          "isSuccess": false,
-          "message": "Original Error: (Original Error: (signing certificate from the digital signature does not match the X.509 trusted identities [map[\"C\":\"US\" \"CN\":\"pipeline.example.com\" \"L\":\"Redmond\" \"O\":\"My Company\" \"OU\":\"My Org\" \"ST\":\"WA\"]] defined in the trust policy \"default\"), Error: verify plugin failure, Code: VERIFY_PLUGIN_FAILURE, Plugin Name: verifier-notation, Component Type: verifier, Documentation: https://ratify.dev/docs/troubleshoot/verifier/notation, Detail: failed to verify signature of digest), Error: verify reference failure, Code: VERIFY_REFERENCE_FAILURE, Plugin Name: verifier-notation, Component Type: verifier",
          "name": "verifier-notation",
          "type": "notation",
          "extensions": null
        }
      ],
      "nestedReports": []
    }
  ]
}
```

## Deploy signed workload with required signed security artifacts

Deploy the Trips workload. This deployment should succeed as the image has signatures, SBOMs, and vulnerability scan results.

```bash
kubectl run trips --image=$TRIPS_APP
```

Successful deployment output shown in the terminal should resemble:

```txt
pod/trips created
```

Use `kubectl logs` to get Ratify logs for the Trips deployment

```bash
kubectl logs -l app.kubernetes.io/name=ratify --namespace gatekeeper-system --tail 100
```

The output should include:

```diff
{
  "isSuccess": true,
  "verifierReports": [
    {
      "subject": "sssc76iepacr.azurecr.io/trips@sha256:434bd05b87b860f6d9999fe8b411905a3b67da066bf0e1da3b9b24b4eb0b6786",
      "referenceDigest": "sha256:17016349a4922cb903360db0866556c83d53cde56c7cec39017da5d86c6271cd",
+      "artifactType": "application/vnd.cncf.notary.signature",
      "verifierReports": [
        {
+          "isSuccess": true,
          "message": "signature verification success",
          "name": "verifier-notation",
          "extensions": {
+            "Issuer": "CN=ca.example.com,OU=My Org,O=My Company,L=Redmond,ST=WA,C=US",
+            "SN": "CN=pipeline.example.com,OU=My Org,O=My Company,L=Redmond,ST=WA,C=US"
          }
        }
      ],
      "nestedReports": []
    },
    {
      "subject": "sssc76iepacr.azurecr.io/trips@sha256:434bd05b87b860f6d9999fe8b411905a3b67da066bf0e1da3b9b24b4eb0b6786",
+      "referenceDigest": "sha256:dda62802a61c18e522064397ed30ba7df1d584e729a23b5c422cacdeac58f546",
+      "artifactType": "application/spdx+json",
      "verifierReports": [
        {
+          "isSuccess": true,
          "message": "SBOM verification success. No license or package violation found.",
          "name": "verifier-sbom",
          "extensions": {
            "creationInfo": {
              "created": "2024-03-21T21:40:03Z",
              "creators": [
                "Organization: Trips",
                "Tool: Microsoft.SBOMTool-1.1.5"
              ]
            }
          }
        }
      ],
      "nestedReports": [
        {
+          "subject": "sssc76iepacr.azurecr.io/trips@sha256:dda62802a61c18e522064397ed30ba7df1d584e729a23b5c422cacdeac58f546",
          "referenceDigest": "sha256:bd6726db787d2d5dddbe70e28b17da86426fc753ae65472aa68d414d114dc0d4",
+          "artifactType": "application/vnd.cncf.notary.signature",
          "verifierReports": [
            {
+              "isSuccess": true,
              "message": "signature verification success",
              "name": "verifier-notation",
              "extensions": {
+                "Issuer": "CN=ca.example.com,OU=My Org,O=My Company,L=Redmond,ST=WA,C=US",
+                "SN": "CN=pipeline.example.com,OU=My Org,O=My Company,L=Redmond,ST=WA,C=US"
              }
            }
          ],
          "nestedReports": []
        }
      ]
    },
    {
      "subject": "sssc76iepacr.azurecr.io/trips@sha256:434bd05b87b860f6d9999fe8b411905a3b67da066bf0e1da3b9b24b4eb0b6786",
+      "referenceDigest": "sha256:0fa57fd42b011e650040f3b6d3e3e68b19a7643333671a61854cc4507bcd10a4",
+      "artifactType": "application/sarif+json",
      "verifierReports": [
        {
+          "isSuccess": true,
+          "message": "vulnerability report validation succeeded",
          "name": "verifier-vuln",
          "extensions": {
            "createdAt": "2024-03-21T21:40:10Z",
            "scanner": "trivy"
          }
        }
      ],
      "nestedReports": [
        {
+          "subject": "sssc76iepacr.azurecr.io/trips@sha256:0fa57fd42b011e650040f3b6d3e3e68b19a7643333671a61854cc4507bcd10a4",
          "referenceDigest": "sha256:b93c9f5b3bc9598392a47125960c813ca947882e1c59687352f8d37fa2c286ba",
+          "artifactType": "application/vnd.cncf.notary.signature",
          "verifierReports": [
            {
+              "isSuccess": true,
              "message": "signature verification success",
              "name": "verifier-notation",
              "extensions": {
+                "Issuer": "CN=ca.example.com,OU=My Org,O=My Company,L=Redmond,ST=WA,C=US",
+                "SN": "CN=pipeline.example.com,OU=My Org,O=My Company,L=Redmond,ST=WA,C=US"
              }
            }
          ],
          "nestedReports": []
        }
      ]
    }
  ]
}
```

## Teardown

Proceed to teardown to clean up all resources created during the walkthrough.

<br/>

[![Teardown](https://img.shields.io/badge/Teardown-f8f8f8?style=for-the-badge&label=Finally&labelColor=4051b5)](teardown.md)
