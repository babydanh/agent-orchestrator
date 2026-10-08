param (
    [Parameter(Mandatory=$false)]
    [string]$SessionId = "",

    [Parameter(Mandatory=$false)]
    [string]$Branch = ""
)

$ErrorActionPreference = "Stop"

# 1. Tim Session ID neu chua truyen vao
if (-not $SessionId) {
    $latestSession = Get-ChildItem "$HOME\.omp\agent\sessions" -Filter "*.jsonl" -Recurse -File | 
                     Sort-Object LastWriteTime -Descending | 
                     Select-Object -First 1
    if (-not $latestSession) {
        Write-Error "Khong tim thay session .jsonl nao trong $HOME\.omp\agent\sessions"
        exit 1
    }
    $SessionId = $latestSession.BaseName
}

Write-Host ">>> Session ID duoc chon: $SessionId" -ForegroundColor Cyan

# 2. Xac dinh branch hien tai neu chua truyen
if (-not $Branch) {
    try {
        $Branch = (git branch --show-current).Trim()
    } catch {
        $Branch = "omp/handoff-" + (Get-Date -Format "yyyyMMddHHmmss")
    }
}
Write-Host ">>> Branch dang lam do: $Branch" -ForegroundColor Cyan

# 3. Tao thu muc tam de push len branch omp-sync/sessions
$tempDir = Join-Path $env:TEMP ("omp-sync-" + (Get-Random))
$repoUrl = "https://github.com/babydanh/agent-orchestrator.git"

try {
    Write-Host ">>> Dang dong bo session len branch omp-sync/sessions..." -ForegroundColor Yellow
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

    # Tao thu muc session
    $targetSessionDir = Join-Path $tempDir $SessionId
    New-Item -ItemType Directory -Path $targetSessionDir -Force | Out-Null

    # Copy toan bo file session lien quan
    $sessionFiles = Get-ChildItem "$HOME\.omp\agent\sessions" -Filter "*$SessionId*" -Recurse -File
    foreach ($f in $sessionFiles) {
        Copy-Item $f.FullName -Destination $targetSessionDir -Force
    }

    # Khử token/secret trước khi commit để không bị GitHub chặn push
    Get-ChildItem $targetSessionDir -Recurse -File | ForEach-Object {
        (Get-Content $_.FullName) -replace 'ghp_[a-zA-Z0-9]{36}', '***' `
                                  -replace 'github_pat_[a-zA-Z0-9_]{82}', '***' `
                                  -replace 'sk-or-v1-[a-f0-9]{64}', '***' | 
        Set-Content $_.FullName
    }

    git add .
    $status = git status --porcelain
    if ($status) {
        git commit -m "chore(sync): push local session $SessionId for handoff"
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

Write-Host "`n>>> THONG TIN DE TAO ISSUE / NHAN LENH HANDOFF:" -ForegroundColor Magenta
Write-Host "Branch dở dang: $Branch" -ForegroundColor Yellow
Write-Host "Session-ID: $SessionId" -ForegroundColor Yellow
