# Thiết lập deploy QuanLyGiaiDau qua repo này (.github/workflows/deploy.yml). Chạy lại bao nhiêu lần cũng được:
# bước nào đã xong (environment có sẵn, secret đã đặt) thì bỏ qua.
#
#   pwsh -File scripts\setup-deploy.ps1 [-BackendRepo <đường dẫn clone Backend>]
#
# Làm gì:
#   1. Tạo environment `production` và `staging`, chỉ cho chạy từ nhánh main của repo này.
#   2. Secret hạ tầng (VPS_HOST, VPS_PORT, VPS_USER, APP_DIR) đọc từ workflow cũ của repo Backend
#      (origin/main deploy.yml, origin/staging deploy-staging.yml); không in giá trị.
#   3. VPS_KNOWN_HOSTS: ssh-keyscan một lần, in fingerprint để bạn đối chiếu.
#   4. Hỏi bạn: khoá SSH deploy, mật khẩu Basic staging, NEXT_PUBLIC_APP_API_KEY (không hiện khi gõ, không lưu ra đĩa).
#   5. Mở trang package GHCR của Backend và Web để bạn cấp quyền Write cho repo này (GitHub không có API cho bước này).
# Giá trị secret đi qua stdin của `gh secret set` (không vào argv), không ghi file, không in. Cần pwsh 7.
param(
    [string]$BackendRepo = "V:\Duancanhan\Project_QuanLyGiaiDau\HethongBackendApi_QuanlyGiaiDau"
)
$ErrorActionPreference = "Stop"
$Repo = "babydanh/agent-orchestrator"
$Envs = @("production", "staging")

function Get-SecretNames([string]$EnvName) {
    $ghArgs = @("secret", "list", "-R", $Repo, "--json", "name", "--jq", ".[].name")
    if ($EnvName) { $ghArgs += @("--env", $EnvName) }
    $out = & gh @ghArgs
    if ($LASTEXITCODE -ne 0) { throw "gh secret list lỗi ($EnvName)" }
    return @($out)
}

# Giá trị đi qua stdin của `gh secret set` (đúng từng byte, không thêm xuống dòng), không nằm trong argv/process list.
function Set-Secret([string]$Name, [string]$Value, [string]$EnvName) {
    if ([string]::IsNullOrWhiteSpace($Value)) { throw "Giá trị $Name rỗng" }
    $psi = [Diagnostics.ProcessStartInfo]::new("gh")
    foreach ($a in @("secret", "set", $Name, "-R", $Repo)) { $psi.ArgumentList.Add($a) }
    if ($EnvName) { $psi.ArgumentList.Add("--env"); $psi.ArgumentList.Add($EnvName) }
    $psi.UseShellExecute = $false
    $psi.RedirectStandardInput = $true
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $p = [Diagnostics.Process]::Start($psi)
    $bytes = [Text.UTF8Encoding]::new($false).GetBytes($Value)
    $p.StandardInput.BaseStream.Write($bytes, 0, $bytes.Length)
    $p.StandardInput.Close()
    $err = $p.StandardError.ReadToEnd()
    $p.WaitForExit()
    if ($p.ExitCode -ne 0) { throw "Không đặt được secret $Name ($EnvName): $err" }
    Write-Host "  Đã đặt $Name$(if ($EnvName) { " ($EnvName)" })"
}

function Read-Hidden([string]$Prompt) {
    $s = Read-Host -AsSecureString $Prompt
    $b = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($s)
    try { return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($b) } finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($b) }
}

function Get-Match([string]$Text, [string]$Pattern, [string]$What) {
    $m = [regex]::Match($Text, $Pattern)
    if (-not $m.Success) { throw "Không tìm thấy $What trong workflow cũ của Backend" }
    return $m.Groups[1].Value
}

cmd /c "gh auth status >nul 2>nul"
if ($LASTEXITCODE -ne 0) { throw "Chưa đăng nhập gh. Chạy: gh auth login" }

Write-Host "== 1. Environment production / staging (chỉ nhánh main)"
foreach ($e in $Envs) {
    gh api -X PUT "repos/$Repo/environments/$e" -F "deployment_branch_policy[protected_branches]=false" `
        -F "deployment_branch_policy[custom_branch_policies]=true" | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "Không tạo được environment $e" }
    $policies = gh api "repos/$Repo/environments/$e/deployment-branch-policies" --jq ".branch_policies[].name"
    if (@($policies) -notcontains "main") {
        gh api -X POST "repos/$Repo/environments/$e/deployment-branch-policies" -f name=main -f type=branch | Out-Null
    }
    Write-Host "  ${e}: OK"
}

Write-Host "== 2. Secret hạ tầng (đọc từ workflow cũ của Backend)"
git -C $BackendRepo fetch -q origin main staging
$prodYml = (git -C $BackendRepo show origin/main:.github/workflows/deploy.yml) -join "`n"
$stagingYml = (git -C $BackendRepo show origin/staging:.github/workflows/deploy-staging.yml) -join "`n"
$infra = @{
    VPS_HOST = Get-Match $stagingYml '(?m)^\s*VPS_HOST:\s*(\S+)' "VPS_HOST"
    VPS_PORT = Get-Match $stagingYml '(?m)^\s*VPS_PORT:\s*"?(\d+)"?' "VPS_PORT"
    VPS_USER = Get-Match $prodYml 'StrictHostKeyChecking=no\s+(\w+)@' "user SSH"
}
$appDir = @{
    production = Get-Match $prodYml '(?m)^\s*cd\s+(/usr/local/lsws/\S+)\s*$' "thư mục prod"
    staging    = Get-Match $stagingYml '(?m)^\s*STAGING_DIR:\s*(\S+)' "thư mục staging"
}
foreach ($e in $Envs) {
    $have = Get-SecretNames $e
    foreach ($k in $infra.Keys) { if ($have -notcontains $k) { Set-Secret $k $infra[$k] $e } }
    if ($have -notcontains "APP_DIR") { Set-Secret "APP_DIR" $appDir[$e] $e }
}

Write-Host "== 3. VPS_KNOWN_HOSTS"
$needKnown = $Envs | Where-Object { (Get-SecretNames $_) -notcontains "VPS_KNOWN_HOSTS" }
if ($needKnown) {
    $scan = (cmd /c "ssh-keyscan -p $($infra.VPS_PORT) $($infra.VPS_HOST) 2>nul") -join "`n"
    if (-not $scan) { throw "ssh-keyscan không lấy được khoá máy chủ (mạng chặn cổng SSH?)" }
    $tmp = New-TemporaryFile
    try {
        Set-Content -Path $tmp -Value $scan -Encoding ascii
        Write-Host "  Fingerprint máy chủ. Đối chiếu nếu được: console nhà cung cấp VPS, lệnh"
        Write-Host "  ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub (ssh-keyscan không tự xác thực máy chủ):"
        ssh-keygen -lf $tmp | ForEach-Object { Write-Host "    $_" }
    } finally { Remove-Item $tmp -Force }
    if ((Read-Host "  Ghim các khoá này cho deploy? (y/n)") -ne "y") { throw "Dừng: chưa ghim known_hosts." }
    foreach ($e in $needKnown) { Set-Secret "VPS_KNOWN_HOSTS" $scan $e }
} else { Write-Host "  Đã có ở cả hai environment." }

Write-Host "== 4. Secret bạn giữ"
$needKey = $Envs | Where-Object { (Get-SecretNames $_) -notcontains "VPS_SSH_KEY" }
if ($needKey) {
    Write-Host "  Khoá SSH riêng (private key) đăng nhập được VPS với user $($infra.VPS_USER)."
    $keyPath = Read-Host "  Đường dẫn file khoá (vd C:\Users\<bạn>\.ssh\id_ed25519)"
    if (-not (Test-Path $keyPath)) { throw "Không thấy file $keyPath" }
    $key = Get-Content -Raw $keyPath
    if ($key -notmatch 'PRIVATE KEY') { throw "File không phải private key" }
    foreach ($e in $needKey) { Set-Secret "VPS_SSH_KEY" $key $e }
    $key = $null
} else { Write-Host "  VPS_SSH_KEY: đã có." }

if ((Get-SecretNames "staging") -notcontains "STAGING_BASIC_AUTH") {
    # Cùng luật với deploy/staging/bootstrap.sh của Backend: sai thì báo ngay ở đây, không đợi deploy đỏ.
    while ($true) {
        $auth = Read-Hidden "  Tên đăng nhập + mật khẩu staging trên MỘT dòng, nối bằng dấu hai chấm (vd admin:MatKhau)"
        $i = $auth.IndexOf(":")
        if ($i -lt 0) { Write-Host "    Thiếu dấu ':' giữa tên đăng nhập và mật khẩu ($($auth.Length) ký tự đã nhập). Nhập lại."; continue }
        if ($auth.Substring(0, $i) -notmatch '^[A-Za-z0-9._@-]+$') { Write-Host "    Tên đăng nhập (phần trước ':') rỗng hoặc có ký tự ngoài chữ, số, . _ @ -. Nhập lại."; continue }
        if ($i -eq $auth.Length - 1) { Write-Host "    Mật khẩu (phần sau ':') đang rỗng. Nhập lại."; continue }
        break
    }
    Set-Secret "STAGING_BASIC_AUTH" $auth "staging"
    $auth = $null
} else { Write-Host "  STAGING_BASIC_AUTH: đã có." }

if ((Get-SecretNames "") -notcontains "NEXT_PUBLIC_APP_API_KEY") {
    Set-Secret "NEXT_PUBLIC_APP_API_KEY" (Read-Hidden "  NEXT_PUBLIC_APP_API_KEY (khoá x-app-key Web gửi lên API)") ""
} else { Write-Host "  NEXT_PUBLIC_APP_API_KEY: đã có." }

Write-Host "== 5. Cấp quyền package GHCR cho repo này"
foreach ($pkg in @("hethongbackendapi_quanlygiaidau", "hethongfrontendweb_qlgiaidau")) {
    $url = "https://github.com/users/babydanh/packages/container/$pkg/settings"
    Write-Host "  Mở $url"
    Write-Host "    Manage Actions access -> Add Repository -> agent-orchestrator -> Role: Write"
    Start-Process $url
    Read-Host "    Xong thì bấm Enter" | Out-Null
}

Write-Host ""
Write-Host "Xong. Thử deploy staging (chờ kết quả):"
Write-Host "  python $HOME\.omp\scripts\orchestrator-deploy.py $BackendRepo --env staging --watch"
