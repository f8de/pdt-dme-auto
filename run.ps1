Set-Location -Path $PSScriptRoot

$exe = Join-Path $PSScriptRoot "dme-auto.exe"
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
