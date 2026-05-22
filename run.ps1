Set-Location -Path $PSScriptRoot

# Find Python
$pyCmd = $null
foreach ($cmd in @('py', 'python', 'python3')) {
    if (Get-Command $cmd -ErrorAction SilentlyContinue) {
        $pyCmd = $cmd
        break
    }
}

if (-not $pyCmd) {
    Write-Host ""
    Write-Host "  Python not found." -ForegroundColor Yellow

    $winget = Get-Command winget -ErrorAction SilentlyContinue
    if ($winget) {
        $ans = Read-Host "  Install Python 3.12 via winget? (y/n)"
        if ($ans -eq 'y') {
            winget install --id Python.Python.3.12 --source winget --silent
            # Reload PATH so python is available immediately
            $env:PATH = [System.Environment]::GetEnvironmentVariable('PATH', 'Machine') + ';' +
                        [System.Environment]::GetEnvironmentVariable('PATH', 'User')
            $pyCmd = 'python'
        } else {
            Write-Host "  Install Python from https://python.org then re-run."
            Read-Host "  Press Enter to exit"
            exit 1
        }
    } else {
        Write-Host "  winget not available. Install Python from https://python.org"
        Read-Host "  Press Enter to exit"
        exit 1
    }
}

& $pyCmd run.py
