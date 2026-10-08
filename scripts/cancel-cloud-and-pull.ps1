param (
    [Parameter(Mandatory=$false)]
    [string]$Branch = "",

    [Parameter(Mandatory=$false)]
    [string]$IssueNumber = ""
)

$ErrorActionPreference = "Stop"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "    CANCEL CLOUD & AUTO PULL TO LOCAL (1-COMMAND SYNC)    " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# Doc Token tu mcp.json
$mcpJsonPath = "$HOME\.omp\agent\mcp.json"
$token = ""
if (Test-Path $mcpJsonPath) {
    try {
        $mcp = Get-Content $mcpJsonPath -Raw | ConvertFrom-Json
        $token = $mcp.mcpServers.github.env.GITHUB_PERSONAL_ACCESS_TOKEN
    } catch {}
}

if (-not $token) {
    Write-Warning "Khong tim thay GitHub Token trong mcp.json! Se bo qua buoc huy GitHub Actions API."
}

$headers = @{
    "Authorization" = "Bearer $token"
    "Accept" = "application/vnd.github+json"
    "User-Agent" = "PowerShell-CancelCloud"
}

# 1. Tim va Huy ngay lap tuc moi Workflow dang chay tren GitHub Actions
if ($token) {
    try {
        Write-Host ">>> Dang kiem tra cac workflow GitHub Actions dang chay..." -ForegroundColor Yellow
        $runsUrl = "https://api.github.com/repos/babydanh/agent-orchestrator/actions/runs?status=in_progress"
        $runs = Invoke-RestMethod -Uri $runsUrl -Headers $headers
        
        # Kiem tra ca queued
        $queuedUrl = "https://api.github.com/repos/babydanh/agent-orchestrator/actions/runs?status=queued"
        $queued = Invoke-RestMethod -Uri $queuedUrl -Headers $headers

        $allRuns = @($runs.workflow_runs) + @($queued.workflow_runs)

        if ($allRuns.Count -gt 0) {
            foreach ($r in $allRuns) {
                Write-Host ">>> Dang HUY Workflow Run ID: $($r.id) ($($r.name))..." -ForegroundColor Red
                $cancelUrl = "https://api.github.com/repos/babydanh/agent-orchestrator/actions/runs/$($r.id)/cancel"
                Invoke-RestMethod -Uri $cancelUrl -Method Post -Headers $headers | Out-Null
                Write-Host ">>> DA HUY THANH CONG WORKFLOW $($r.id) TREN GITHUB ACTIONS!" -ForegroundColor Green
            }
        } else {
            Write-Host ">>> Khong co workflow nao dang chay tren cloud." -ForegroundColor Gray
        }
    } catch {
        Write-Warning "Loi khi goi GitHub API huy workflow: $($_.Exception.Message)"
    }
}

# 2. Xac dinh Branch de keo code do ve
if (-not $Branch) {
    try {
        $Branch = (git branch --show-current).Trim()
    } catch {}
}

if ($Branch) {
    try {
        Write-Host ">>> Dang keo code do dang tu remote branch '$Branch' ve may..." -ForegroundColor Cyan
        git fetch origin $Branch 2>$null
        git pull origin $Branch
        Write-Host ">>> DA PULL CODE DO DANG VE LOCAL THANH CONG!" -ForegroundColor Green
    } catch {
        Write-Warning "Khong the pull code tu branch '$Branch'. (Co the chua co commit moi tren remote)."
    }
}

# 3. Keo phien Session JSONL ve de OMP tiep tuc mach chat
$repoUrl = "https://github.com/babydanh/agent-orchestrator.git"
$tempDir = Join-Path $env:TEMP ("omp-pull-sync-" + (Get-Random))

try {
    Write-Host ">>> Dang kiem tra va keo session moi nhat tu branch omp-sync/sessions..." -ForegroundColor Yellow
    git clone --branch omp-sync/sessions --depth 1 $repoUrl $tempDir 2>$null
    if (Test-Path $tempDir) {
        $destBase = "$HOME\.omp\agent\sessions"
        
        # Tim folder session moi nhat vua duoc cap nhat
        $latestSessionFolder = Get-ChildItem $tempDir -Directory | 
                               Sort-Object LastWriteTime -Descending | 
                               Select-Object -First 1

        if ($latestSessionFolder) {
            Write-Host ">>> Phat hien session moi nhat tren mây ($($latestSessionFolder.Name)), dang khoi phuc ve local..." -ForegroundColor Green
            Copy-Item "$($latestSessionFolder.FullName)\*" -Destination $destBase -Recurse -Force
            Write-Host ">>> DA KEO VA HOAN TAT PHUC HOI SESSION VE MAY!" -ForegroundColor Green
        }
    }
} catch {
    Write-Warning "Khong the keo session tu branch omp-sync/sessions: $($_.Exception.Message)"
} finally {
    if (Test-Path $tempDir) {
        Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Write-Host "==========================================================" -ForegroundColor Green
Write-Host "TAT CA DA XONG! CLOUD DA HUY - CODE VA SESSION DA VE MAY!" -ForegroundColor Green
Write-Host "Bay gio ban chi can go: omp --resume la lam tiep luon!" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
