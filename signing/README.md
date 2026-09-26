# Code Signing — SolarPlanner

This folder contains everything needed to sign the Windows release build and
establish trust on end-user machines.

## Why

The app is for private use (no public distribution), so a **self-signed
certificate** is sufficient. Signing achieves two things:

1. **Integrity** — Windows verifies the binary hasn't been tampered with since
   signing (SHA-256 hash + Authenticode signature).
2. **SmartScreen suppression** — once the self-signed root is in the machine's
   *Trusted Root Certification Authorities* store, Windows no longer shows the
   "Unknown publisher" warning.

## Files in this folder

| File | Purpose | Tracked? |
|------|---------|----------|
| `solarplanner-trust.cer` | Public certificate (no private key). Shipped with the release; installed by `install-trust.bat`. | ✅ yes |
| `solarplanner.pfx` | **Private key + cert** (password-protected). Used only by CI to sign. Never committed. | ❌ gitignored |
| `install-trust.bat` | One-click installer: imports the `.cer` into `LocalMachine\Root`. Run as admin on each target machine. | ✅ yes |
| `export-cert-for-github.ps1` | Helper script: exports the PFX from your local cert store and prints its base64 for pasting into GitHub Secrets. | ✅ yes |

## How it works (end-to-end)

```
┌─────────────────────────────────────────────────────────────────────┐
│  YOUR MACHINE (one-time setup)                                      │
│                                                                     │
│  1. Generate self-signed cert (already done, CN=Appternity          │
│     SolarPlanner, EKU=Code Signing, valid to 2031)                  │
│     → lives in Cert:\CurrentUser\My                                 │
│                                                                     │
│  2. Run export-cert-for-github.ps1:                                 │
│     .\export-cert-for-github.ps1 -PfxPassword "YourSecret"          │
│     → prints base64 string                                          │
│                                                                     │
│  3. Paste into GitHub:                                              │
│     Settings → Secrets and variables → Actions                      │
│       CERT_PFX_BASE64   = <the long base64 string>                  │
│       CERT_PFX_PASSWORD = YourSecret                                │
└───────────────────────────────┬─────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│  GITHUB ACTIONS (every build)                                       │
│                                                                     │
│  .github/workflows/windows-build.yml                                │
│    ├── "Decode signing certificate"                                 │
│    │     Reads CERT_PFX_BASE64 secret → writes cert.pfx to          │
│    │     $RUNNER_TEMP. Skips gracefully if secret is empty.         │
│    ├── "Sign executable and DLLs"                                   │
│    │     signtool sign /fd SHA256 + Digicert timestamp              │
│    │     → signs solar_planner.exe and all *.dll in Release/        │
│    │     signtool verify /pa → confirms signature is valid          │
│    ├── "Bundle trust files with release"                            │
│    │     Copies solarplanner-trust.cer + install-trust.bat          │
│    │     into the release folder (so users get them in the zip)     │
│    └── "Upload Windows executable bundle as artifact"               │
└───────────────────────────────┬─────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│  END-USER MACHINE (one-time per machine)                            │
│                                                                     │
│  From the release zip:                                              │
│    solar_planner.exe          ← signed binary                       │
│    *.dll                      ← signed DLLs                         │
│    solarplanner-trust.cer     ← public cert (no private key)        │
│    install-trust.bat          ← one-click installer                 │
│                                                                     │
│  Right-click install-trust.bat → "Run as administrator"             │
│    → certutil -addstore Root solarplanner-trust.cer                 │
│    → from now on, Windows trusts the signature, no SmartScreen      │
└─────────────────────────────────────────────────────────────────────┘
```

## GitHub Secrets reference

| Secret | Value | Where it's used |
|--------|-------|-----------------|
| `CERT_PFX_BASE64` | Base64-encoded `.pfx` file (cert + private key) | `windows-build.yml` → "Decode signing certificate" step |
| `CERT_PFX_PASSWORD` | Password that protects the PFX file | `windows-build.yml` → "Sign executable and DLLs" step (passed to signtool) |

Both are **repository-level** secrets. No GitHub *environment* is needed.
If either secret is missing/empty, the build **succeeds unsigned** (the steps
exit 0 with a skip message).

## Re-generating the certificate

If you ever need to start over (lost PFX, cert expired, etc.):

```powershell
# 1. Remove old cert from your store
Get-ChildItem Cert:\CurrentUser\My | Where-Object { $_.Subject -like '*SolarPlanner*' } | Remove-Item

# 2. Generate a new self-signed code-signing cert
$cert = New-SelfSignedCertificate `
    -Subject "CN=Appternity SolarPlanner" `
    -KeyUsage DigitalSignature `
    -FriendlyName "SolarPlanner Code Signing" `
    -CertStoreLocation Cert:\CurrentUser\My `
    -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.3",
                     "2.5.29.19={text}") `
    -NotAfter (Get-Date).AddYears(5)

# 3. Export the public cert for distribution
Export-Certificate -Cert $cert -FilePath "signing\solarplanner-trust.cer"

# 4. Re-run the export script to get new GitHub secret values
.\export-cert-for-github.ps1 -PfxPassword "NewSecret"

# 5. Update CERT_PFX_BASE64 and CERT_PFX_PASSWORD in GitHub
```

## Security notes

- **`solarplanner.pfx` contains the private key.** It is gitignored
  (`signing/*.pfx`) and must never be committed, emailed, or stored in plain
  text. The only copy that exists outside your machine is the base64 string
  inside GitHub's encrypted secrets store.
- The `.cer` file in this folder is **public** — it contains no secret and is
  safe to ship with every release.
- The Digicert timestamp (`/tr http://timestamp.digicert.com`) ensures the
  signature remains valid even after the certificate expires, as long as it was
  signed while the cert was still valid.
