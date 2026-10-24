#!/usr/bin/env bash
# Chuẩn bị SSH tới VPS trên runner: khoá, known_hosts ghim sẵn, wrapper $RUNNER_TEMP/ssh-vps và $RUNNER_TEMP/scp-vps.
# Danh tính máy chủ kiểm bằng VPS_KNOWN_HOSTS (secret, lấy một lần lúc thiết lập), không ssh-keyscan lúc chạy:
# keyscan mỗi lượt tin bất kỳ máy nào đang trả lời ở địa chỉ đó.
# Địa chỉ, cổng, user là secret của environment nên GitHub che chúng trong log.
#   ssh-vps <lệnh...>                  chạy lệnh trên VPS
#   scp-vps <file...> <thư mục đích>   chép file lên VPS
set -euo pipefail
for name in VPS_SSH_KEY VPS_KNOWN_HOSTS VPS_HOST VPS_PORT VPS_USER; do
  if [[ -z "${!name:-}" ]]; then
    echo "::error::Thiếu secret $name của environment này (chạy scripts/setup-deploy.ps1)."
    exit 1
  fi
done
umask 077
mkdir -p ~/.ssh
printf '%s\n' "$VPS_SSH_KEY" >~/.ssh/deploy_key
printf '%s\n' "$VPS_KNOWN_HOSTS" >~/.ssh/deploy_known_hosts
opts="-i $HOME/.ssh/deploy_key -o IdentitiesOnly=yes -o StrictHostKeyChecking=yes -o UserKnownHostsFile=$HOME/.ssh/deploy_known_hosts -o BatchMode=yes -o ConnectTimeout=30 -o ServerAliveInterval=30 -o ServerAliveCountMax=3"
cat >"$RUNNER_TEMP/ssh-vps" <<EOF
#!/usr/bin/env bash
exec ssh -p $VPS_PORT $opts $VPS_USER@$VPS_HOST "\$@"
EOF
cat >"$RUNNER_TEMP/scp-vps" <<EOF
#!/usr/bin/env bash
dest="\${@: -1}"
set -- "\${@:1:\$#-1}"
exec scp -P $VPS_PORT $opts "\$@" "$VPS_USER@$VPS_HOST:\$dest"
EOF
chmod 700 "$RUNNER_TEMP/ssh-vps" "$RUNNER_TEMP/scp-vps"
"$RUNNER_TEMP/ssh-vps" true
echo "OK    SSH tới VPS (danh tính máy chủ khớp known_hosts đã ghim)"
