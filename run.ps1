param([switch]$Setup)

Set-Location -Path $PSScriptRoot

$encFile = "$env:APPDATA\pdt\doppler.enc"

# ── First-time setup ──────────────────────────────────────────────────────────
if ($Setup) {
    $secure    = Read-Host "Doppler service token" -AsSecureString
    $encrypted = ConvertFrom-SecureString $secure   # DPAPI — tied to this user + machine
    New-Item -ItemType Directory -Force "$env:APPDATA\pdt" | Out-Null
    Set-Content $encFile $encrypted
    Write-Host ""
    Write-Host "  Token encrypted and saved to $encFile" -ForegroundColor Green
    Write-Host "  (DPAPI-encrypted: only readable by this Windows user on this machine)" -ForegroundColor DarkGray
    Write-Host ""
    exit 0
}

# ── Decrypt Doppler token ─────────────────────────────────────────────────────
if (-not (Test-Path $encFile)) {
    Write-Host ""
    Write-Host "  ERROR: Doppler token not configured." -ForegroundColor Red
    Write-Host "  Run setup: .\run.ps1 --setup" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "  Press Enter to exit"
    exit 1
}

try {
    $secure          = Get-Content $encFile | ConvertTo-SecureString -ErrorAction Stop
    $bstr            = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
    $env:DOPPLER_TOKEN = [Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
} catch {
    Write-Host ""
    Write-Host "  ERROR: Could not decrypt Doppler token." -ForegroundColor Red
    Write-Host "  Re-run setup: .\run.ps1 --setup" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "  Press Enter to exit"
    exit 1
}

# ── Launch app ────────────────────────────────────────────────────────────────
$exe = Join-Path $PSScriptRoot "dmeworks-entry.exe"
if (Test-Path $exe) {
    & $exe @args
} else {
    $pyCmd = $null
    foreach ($cmd in @('py', 'python', 'python3')) {
        if (Get-Command $cmd -ErrorAction SilentlyContinue) {
            $pyCmd = $cmd
            break
        }
    }
    if (-not $pyCmd) {
        Write-Host "  Python not found. Build the EXE first: python build.py" -ForegroundColor Red
        exit 1
    }
    & $pyCmd (Join-Path $PSScriptRoot "run.py") @args
}
