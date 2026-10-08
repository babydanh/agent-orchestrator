param (
    [Parameter(Mandatory=$false)]
    [string]$IssueNumber = "",

    [Parameter(Mandatory=$false)]
    [string]$Branch = ""
)

$ErrorActionPreference = "Stop"

# 1. Neu co branch git du an dang lam, pull code ve truoc
if (-not $Branch) {
    try {
        $Branch = (git branch --show-current).Trim()
    } catch {
        $Branch = ""
    }
}

if ($Branch) {
    Write-Host ">>> Dang cap nhat code tu remote branch: $Branch..." -ForegroundColor Cyan
    git pull origin $Branch
}

# 2. Neu can keo ca lich su session tu branch omp-sync/sessions
if ($IssueNumber) {
    $tempDir = Join-Path $env:TEMP ("omp-pull-" + (Get-Random))
    $repoUrl = "https://github.com/babydanh/agent-orchestrator.git"

    try {
        Write-Host ">>> Dang tai session issue-$IssueNumber tu branch omp-sync/sessions..." -ForegroundColor Yellow
        git clone --branch omp-sync/sessions --depth 1 $repoUrl $tempDir 2>$null
        $sourceDir = Join-Path $tempDir "issue-$IssueNumber"
        if (Test-Path $sourceDir) {
            $destDir = "$HOME\.omp\agent\sessions"
            Copy-Item "$sourceDir\*" -Destination $destDir -Recurse -Force
            Write-Host ">>> DA KEO VA PHUC HOI SESSION issue-$IssueNumber VE LOCAL THANH CONG!" -ForegroundColor Green
            Write-Host ">>> Ban co the mo terminal va go: omp --resume de tiep tuc phien!" -ForegroundColor Green
        } else {
            Write-Host ">>> Khong tim thay thu muc issue-$IssueNumber tren branch omp-sync/sessions." -ForegroundColor Yellow
        }
    } finally {
        if (Test-Path $tempDir) {
            Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}
