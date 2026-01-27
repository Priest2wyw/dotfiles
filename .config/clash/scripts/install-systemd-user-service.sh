#!/usr/bin/env bash
set -euo pipefail

unit_name="clash-compose.service"
script_dir="$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
repo_root="$(cd -P -- "${script_dir}/../../.." && pwd -P)"
src_unit="${repo_root}/.config/systemd/user/${unit_name}"
unit_dir="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"

mkdir -p "$unit_dir"

if [[ ! -f "$src_unit" ]]; then
  echo "未找到 unit 文件：$src_unit" >&2
  exit 1
fi

ln -sfn "$src_unit" "${unit_dir}/${unit_name}"

echo "已链接：${unit_dir}/${unit_name} -> ${src_unit}"

if command -v systemctl >/dev/null 2>&1; then
  systemctl --user daemon-reload || true
  systemctl --user enable --now "${unit_name}"
  echo "OK 已启用并启动：${unit_name}"
else
  echo "WARN 未找到 systemctl，请手动 reload/enable 用户服务。" >&2
fi
