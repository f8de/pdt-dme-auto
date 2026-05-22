Set-Location -Path $PSScriptRoot

# Inject Notion token from Windows SecretManagement vault
try {
    $env:NOTION_TOKEN = Get-Secret -Vault local -Name notion-token -AsPlainText -ErrorAction Stop
} catch {
    Write-Host ""
    Write-Host "  ERROR: Could not retrieve Notion token from vault." -ForegroundColor Red
    Write-Host "  Run setup instructions: .\dmeworks-entry.exe --setup" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "  Press Enter to exit"
    exit 1
}

# Run EXE (or Python fallback for dev)
$exe = Join-Path $PSScriptRoot "dmeworks-entry.exe"
if (Test-Path $exe) {
    & $exe @args
} else {
    # Development fallback
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
    & $pyCmd (Join-Path $PSScriptRoot "entry_all.py") @args
}
