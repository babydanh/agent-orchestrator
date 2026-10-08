param (
    [Parameter(Mandatory=$false)]
    [string]$IssueNumber = "",

    [Parameter(Mandatory=$false)]
    [string]$Branch = "",

    [Parameter(Mandatory=$false)]
    [string]$SessionId = ""
)

$ErrorActionPreference = "Stop"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "       OMP CLOUD HANDOFF: 2-WAY PULL SESSIONS & CODE      " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Pull code tu git branch do dang ve thu muc hien tai
if (-not $Branch) {
    try {
        $Branch = (git branch --show-current).Trim()
    } catch {
        $Branch = ""
    }
}

if ($Branch) {
    try {
        Write-Host ">>> Dang cap nhat code moi nhat tu remote branch '$Branch'..." -ForegroundColor Cyan
        git pull origin $Branch
        Write-Host ">>> Da cap nhat code thanh cong!" -ForegroundColor Green
    } catch {
        Write-Host ">>> Chu y: Khong the pull tu branch '$Branch'. Hay kiem tra lai ten branch hoac git remote." -ForegroundColor Yellow
    }
}

# 2. Keo toan bo lich su session tu branch omp-sync/sessions tren GitHub ve local
if ($IssueNumber -or $SessionId) {
    $tempDir = Join-Path $env:TEMP ("omp-pull-" + (Get-Random))
    $repoUrl = "https://github.com/babydanh/agent-orchestrator.git"

    try {
        Write-Host ">>> Dang ket noi toi branch omp-sync/sessions tren GitHub..." -ForegroundColor Yellow
        git clone --branch omp-sync/sessions --depth 1 $repoUrl $tempDir 2>$null
        
        $targetFound = $false
        $destBase = "$HOME\.omp\agent\sessions"

        # Kiem tra theo thu muc issue-<number> (Cloud sinh ra sau khi hoan thanh)
        if ($IssueNumber) {
            $issueFolder = Join-Path $tempDir "issue-$IssueNumber"
            if (Test-Path $issueFolder) {
                Write-Host ">>> Phat hien session duoc dong bo tu issue-$IssueNumber, dang sao chep ve local..." -ForegroundColor Green
                Copy-Item "$issueFolder\*" -Destination $destBase -Recurse -Force
                $targetFound = $true
            }
        }

        # Kiem tra theo ma SessionId cu the
        if ($SessionId) {
            $sessionFolder = Join-Path $tempDir $SessionId
            if (Test-Path $sessionFolder) {
                Write-Host ">>> Phat hien thu muc session $SessionId, dang khoi phuc ve local..." -ForegroundColor Green
                Copy-Item "$sessionFolder\*" -Destination $destBase -Recurse -Force
                $targetFound = $true
            }
        }

        if ($targetFound) {
            Write-Host ">>> DA PHUC HOI PHIEN LAM VIEC VE LOCAL THANH CONG 100%!" -ForegroundColor Green
            Write-Host ">>> Bay gio ban chi can mo OMP tai thu muc du an va go: omp --resume de tiep tuc phien!" -ForegroundColor Green
        } else {
            Write-Host ">>> Khong tim thay ban ghi session tuong ung tren branch omp-sync/sessions." -ForegroundColor Yellow
        }
    } finally {
        if (Test-Path $tempDir) {
            Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
} else {
    Write-Host ">>> Ban chua truyen -IssueNumber hoac -SessionId. Neu muon tai session tu mây ve, hay truyen tham so (vi du: -IssueNumber 14)." -ForegroundColor Yellow
}
