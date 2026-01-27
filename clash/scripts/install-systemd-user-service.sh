#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
unit_name="clash-compose.service"
unit_dir="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"

mkdir -p "$unit_dir"

cat >"${unit_dir}/${unit_name}" <<EOF
[Unit]
Description=Clash (Mihomo) via Docker Compose
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=${repo_dir}
ExecStart=/usr/bin/docker compose up -d
ExecStop=/usr/bin/docker compose down
TimeoutStartSec=0

[Install]
WantedBy=default.target
EOF

echo "已写入：${unit_dir}/${unit_name}"

if command -v systemctl >/dev/null 2>&1; then
  systemctl --user daemon-reload || true
  echo "下一步：systemctl --user enable --now ${unit_name}"
else
  echo "WARN 未找到 systemctl，请手动 reload/enable 用户服务。" >&2
fi

