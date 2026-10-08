param (
    [Parameter(Mandatory=$false)]
    [string]$TaskTitle = "Tiep tuc cong viec do dang",

    [Parameter(Mandatory=$false)]
    [string]$TodoPending = "Kiem tra va tiep tuc hoan thien cac tinh nang theo yeu cau."
)

$ErrorActionPreference = "Stop"

Write-Host ">>> KICH HOAT FAST CLOUD HANDOFF (TOI DA 10 GIAY)..." -ForegroundColor Cyan

# 1. Lay thong tin git repo hien tai
$branch = ""
try {
    $branch = (git branch --show-current).Trim()
} catch {}
if (-not $branch) {
    $branch = "omp/handoff-" + (Get-Date -Format "yyyyMMdd-HHmmss")
}

# 2. Commit va push code do dang neu co
try {
    $status = git status --porcelain 2>$null
    if ($status) {
        Write-Host ">>> Commit va push code do dang..." -ForegroundColor Yellow
        git checkout -B $branch
        git add .
        git commit -m "chore(omp): checkpoint before cloud handoff"
        git push -u origin $branch
    } else {
        git push -u origin $branch 2>$null
    }
} catch {
    Write-Host ">>> Bo qua push code local." -ForegroundColor Gray
}

# 3. Tim session .jsonl moi nhat va relative path
$sessionBase = "$HOME\.omp\agent\sessions"
$latestSession = Get-ChildItem $sessionBase -Filter "*.jsonl" -Recurse -File | 
                 Sort-Object LastWriteTime -Descending | 
                 Select-Object -First 1

$sessionId = "session-" + (Get-Date -Format "yyyyMMddHHmmss")
$relDir = ""
if ($latestSession) {
    $sessionId = $latestSession.BaseName
    $relDir = $latestSession.DirectoryName.Substring($sessionBase.Length).TrimStart('\', '/')
}

# 4. Push session truc tiep bang 1 lenh git push (clone depth 1)
$tempDir = Join-Path $env:TEMP ("fast-sync-" + (Get-Random))
$repoUrl = "https://github.com/babydanh/agent-orchestrator.git"

try {
    Write-Host ">>> Dong bo session $sessionId len branch omp-sync/sessions..." -ForegroundColor Yellow
    git clone --branch omp-sync/sessions --depth 1 $repoUrl $tempDir 2>$null
    if (Test-Path $tempDir) {
        Set-Location $tempDir
        $targetDir = Join-Path $tempDir $sessionId
        if ($relDir) { $targetDir = Join-Path $targetDir $relDir }
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
        Copy-Item $latestSession.FullName -Destination $targetDir -Force
        
        # Khử token
        Get-ChildItem $targetDir -Recurse -File | ForEach-Object {
            (Get-Content $_.FullName) -replace 'ghp_[a-zA-Z0-9]{36}', '***' `
                                      -replace 'github_pat_[a-zA-Z0-9_]{82}', '***' `
                                      -replace 'sk-or-v1-[a-f0-9]{64}', '***' | 
            Set-Content $_.FullName
        }
        
        git add .
        if (git status --porcelain) {
            git commit -m "chore(sync): fast sync session $sessionId"
            git push origin omp-sync/sessions
        }
    }
} catch {
    Write-Host ">>> Bo qua push session branch." -ForegroundColor Gray
} finally {
    if (Test-Path $tempDir) {
        Set-Location $HOME
        Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# 5. Tao issue truc tiep bang GitHub CLI (gh) neu co, sieu toc 1 giay!
$body = @"
## 🚀 BÀN GIAO TÁC VỤ LÊN CLOUD (AGENT HANDOFF)

### 📌 Thông tin ngữ cảnh:
- **Repo mục tiêu**: HethongBackendApi_QuanlyGiaiDau
- **Branch dở dang**: $branch
- **Session-ID**: $sessionId
- **Session-Path**: $relDir
- **Thời điểm bàn giao**: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

### ⏳ Các việc CẦN LÀM TIẾP (Pending Checklist):
- [ ] $TodoPending
"@

try {
    Write-Host ">>> Dang tao Issue tren babydanh/agent-orchestrator qua gh cli..." -ForegroundColor Yellow
    $issueUrl = gh issue create --repo "babydanh/agent-orchestrator" --title "[Handoff] $TaskTitle" --body $body 2>$null
    if ($issueUrl) {
        Write-Host ">>> DA BAN GIAO THANH CONG! LINK: $issueUrl" -ForegroundColor Green
        exit 0
    }
} catch {}

Write-Host ">>> Da chuan bi xong noi dung handoff (khong co gh cli thi tao bang MCP)!" -ForegroundColor Green
Write-Host "BRANCH: $branch"
Write-Host "SESSION: $sessionId"
