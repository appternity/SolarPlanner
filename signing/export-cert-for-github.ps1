param(
    [Parameter(Mandatory = $true)]
    [string]$PfxPassword,

    # Output path for the PFX file (default: alongside this script)
    [string]$OutFile = ""
)

$ErrorActionPreference = 'Stop'

# Resolve output path (PSScriptRoot can be empty in some invocation modes)
if (-not $OutFile) {
    if ($PSScriptRoot) {
        $OutFile = Join-Path $PSScriptRoot "solarplanner.pfx"
    } else {
        $OutFile = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "solarplanner.pfx"
    }
}

Write-Host "=== SolarPlanner cert export for GitHub Actions ===" -ForegroundColor Cyan
Write-Host ""

# --- 1. Locate the certificate -------------------------------------------
$cert = Get-ChildItem Cert:\CurrentUser\My | Where-Object {
    $_.Subject -like '*SolarPlanner*'
} | Select-Object -First 1

if (-not $cert) {
    Write-Error "No code-signing certificate found in Cert:\CurrentUser\My."
    exit 1
}

Write-Host "Found certificate: $($cert.Subject)" -ForegroundColor Green
Write-Host "  Thumbprint : $($cert.Thumbprint)"
Write-Host "  Expires    : $($cert.NotAfter)"

# --- 2. Export to PFX -----------------------------------------------------
$securePwd = ConvertTo-SecureString -AsPlainText -Force $PfxPassword

Export-PfxCertificate `
    -Cert      $cert.PSPath `
    -FilePath  $OutFile `
    -Password  $securePwd | Out-Null

Write-Host "`nPFX exported to: $OutFile" -ForegroundColor Green

# --- 3. Print base64 for GitHub secret ------------------------------------
$bytes = [IO.File]::ReadAllBytes($OutFile)
$b64   = [Convert]::ToBase64String($bytes)

Write-Host "`n=== CERT_PFX_BASE64 (copy the line below into GitHub) ===" -ForegroundColor Cyan
Write-Host $b64
Write-Host "=== CERT_PFX_PASSWORD is: '$PfxPassword' ===" -ForegroundColor Cyan
Write-Host "`nGitHub path: Settings -> Secrets and variables -> Actions" -ForegroundColor DarkGray

# --- 4. Cleanup prompt -----------------------------------------------------
Write-Host "`nDelete the local PFX file? (Y/n) " -NoNewline
$ans = Read-Host
if ($ans -ne 'n' -and $ans -ne 'N') {
    Remove-Item $OutFile -Force
    Write-Host "Deleted $OutFile" -ForegroundColor Yellow
} else {
    Write-Host "Kept: $OutFile" -ForegroundColor Yellow
}
