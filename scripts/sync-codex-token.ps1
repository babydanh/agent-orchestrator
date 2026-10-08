$ErrorActionPreference = "Stop"

Write-Host ">>> DANG DONG BO TOKEN CODEX OAUTH (LUNA) LEN GITHUB SECRET..." -ForegroundColor Cyan

# 1. Trich xuat token Codex OAuth tu agent.db local
$py = "D:\DevTools\Python312\python.exe"
$b64Token = & $py -c "
import sqlite3, os, base64
p = os.path.expanduser('~/.omp/agent/agent.db')
con = sqlite3.connect(p)
cur = con.cursor()
cur.execute(\"SELECT data FROM auth_credentials WHERE provider = 'openai-codex'\")
r = cur.fetchone()
if r:
    print(base64.b64encode(r[0].encode()).decode())
"

if (-not $b64Token) {
    Write-Error "Khong tim thay token openai-codex trong agent.db local!"
    exit 1
}

# 2. Doc PAT tu mcp.json
$mcpJsonPath = "$HOME\.omp\agent\mcp.json"
$pat = ""
if (Test-Path $mcpJsonPath) {
    $mcp = Get-Content $mcpJsonPath -Raw | ConvertFrom-Json
    $pat = $mcp.mcpServers.github.env.GITHUB_PERSONAL_ACCESS_TOKEN
}

# 3. Luu token vao clipboard hoac cap nhat truc tiep
Set-Clipboard -Value $b64Token
Write-Host ">>> DA COPY CHUOI BASE64 VAO CLIPBOARD CUA BAN (DA SAN SANG PASTE)!" -ForegroundColor Green
Write-Host ">>> Neu muon cap nhat len GitHub Secret:" -ForegroundColor Yellow
Write-Host "1. Vao: https://github.com/babydanh/agent-orchestrator/settings/secrets/actions" -ForegroundColor White
Write-Host "2. Tim hoac tao moi Secret ten: OMP_CODEX_AUTH" -ForegroundColor White
Write-Host "3. Bam Ctrl + V de Paste chuoi vua duoc copy vao Value -> Bam Save la xong vinh vien!" -ForegroundColor White
