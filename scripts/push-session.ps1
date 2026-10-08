param (
    [Parameter(Mandatory=$false)]
    [string]$SessionId = "",

    [Parameter(Mandatory=$false)]
    [string]$Branch = "",

    [Parameter(Mandatory=$false)]
    [string]$TargetRepo = "HethongBackendApi_QuanlyGiaiDau"
)

$ErrorActionPreference = "Stop"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "       OMP CLOUD HANDOFF: 2-WAY SYNC SESSIONS             " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Tim file session moi nhat
$sessionBase = "$HOME\.omp\agent\sessions"
$sessionFile = $null

if ($SessionId) {
    $sessionFile = Get-ChildItem $sessionBase -Filter "*$SessionId*.jsonl" -Recurse -File | Select-Object -First 1
} else {
    $sessionFile = Get-ChildItem $sessionBase -Filter "*.jsonl" -Recurse -File | 
                   Sort-Object LastWriteTime -Descending | 
                   Select-Object -First 1
    if ($sessionFile) {
        $SessionId = $sessionFile.BaseName
    }
}

if (-not $sessionFile) {
    Write-Error "Khong tim thay file session .jsonl nao trong $sessionBase!"
    exit 1
}

# Xac dinh relative path cua session de cloud tai lap dung cay thu muc
$relDir = $sessionFile.DirectoryName.Substring($sessionBase.Length).TrimStart('\', '/')
Write-Host ">>> File Session duoc chon: $($sessionFile.Name)" -ForegroundColor Green
Write-Host ">>> Thu muc phan vung session: $relDir" -ForegroundColor Green
Write-Host ">>> Session ID: $SessionId" -ForegroundColor Green

# 2. Xac dinh branch hien tai va commit/push code do dang
if (-not $Branch) {
    try {
        $Branch = (git branch --show-current).Trim()
    } catch {
        $Branch = ""
    }
    if (-not $Branch) {
        $Branch = "omp/handoff-" + (Get-Date -Format "yyyyMMdd-HHmmss")
    }
}

# Kiem tra xem co code chua commit khong de commit luon
try {
    $gitStatus = git status --porcelain 2>$null
    if ($gitStatus) {
        Write-Host ">>> Phat hien code chua commit tai local, dang commit va push len branch '$Branch'..." -ForegroundColor Yellow
        git checkout -B $Branch
        git add .
        git commit -m "chore(omp): checkpoint before cloud handoff"
        git push -u origin $Branch
        Write-Host ">>> Da push code do dang len branch $Branch thanh cong!" -ForegroundColor Green
    } else {
        Write-Host ">>> Working tree sach, push branch $Branch len remote..." -ForegroundColor Yellow
        git push -u origin $Branch 2>$null
    }
} catch {
    Write-Host ">>> Chu y: Khong the push code tu thu muc hien tai (co the chua phai git repo hoac khong co remote)." -ForegroundColor Yellow
}

# 3. Dong bo Session JSONL len branch omp-sync/sessions tren GitHub
$tempDir = Join-Path $env:TEMP ("omp-sync-" + (Get-Random))
$repoUrl = "https://github.com/babydanh/agent-orchestrator.git"

try {
    Write-Host ">>> Dang dong bo session len branch omp-sync/sessions tren GitHub..." -ForegroundColor Yellow
    git clone --branch omp-sync/sessions --depth 1 $repoUrl $tempDir 2>$null
    if (-not (Test-Path $tempDir)) {
        New-Item -ItemType Directory -Path $tempDir | Out-Null
        Set-Location $tempDir
        git init
        git checkout -b omp-sync/sessions
        git remote add origin $repoUrl
    } else {
        Set-Location $tempDir
    }

    # Tao cau truc thu muc theo dung SessionId kem relative path
    $targetDir = Join-Path $tempDir $SessionId
    if ($relDir) {
        $targetDir = Join-Path $targetDir $relDir
    }
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null

    # Copy toan bo file session lien quan
    Copy-Item $sessionFile.FullName -Destination $targetDir -Force

    # Khử token/secret truoc khi commit de khong bi GitHub chan push
    Get-ChildItem $targetDir -Recurse -File | ForEach-Object {
        (Get-Content $_.FullName) -replace 'ghp_[a-zA-Z0-9]{36}', '***' `
                                  -replace 'github_pat_[a-zA-Z0-9_]{82}', '***' `
                                  -replace 'sk-or-v1-[a-f0-9]{64}', '***' | 
        Set-Content $_.FullName
    }

    git add .
    $status = git status --porcelain
    if ($status) {
        git commit -m "chore(sync): push local session $SessionId ($relDir) for handoff"
        git push origin omp-sync/sessions
        Write-Host ">>> DA DONG BO SESSION LEN BRANCH omp-sync/sessions THANH CONG!" -ForegroundColor Green
    } else {
        Write-Host ">>> Session da duoc dong bo truoc do, khong co thay doi moi." -ForegroundColor Green
    }
} finally {
    if (Test-Path $tempDir) {
        Set-Location $HOME
        Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Write-Host "==========================================================" -ForegroundColor Magenta
Write-Host "BAN GIAO HOAN TAT! MAU ISSUE DE BAN DUNG HOAC GO MCP GITHUB:" -ForegroundColor Magenta
Write-Host "==========================================================" -ForegroundColor Magenta
Write-Host "Repo mục tiêu: $TargetRepo" -ForegroundColor White
Write-Host "Branch dở dang: $Branch" -ForegroundColor White
Write-Host "Session-ID: $SessionId" -ForegroundColor White
Write-Host "Session-Path: $relDir" -ForegroundColor White
Write-Host "==========================================================" -ForegroundColor Magenta
