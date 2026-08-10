#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
timestamp="$(date +%Y%m%d-%H%M%S)"

link_path() {
  local src="$1"
  local dst="$2"

  mkdir -p "$(dirname "$dst")"

  if [[ -L "$dst" ]]; then
    local current
    current="$(readlink "$dst")"
    if [[ "$current" == "$src" ]]; then
      echo "OK 已存在链接：$dst -> $src"
      return
    fi
  fi

  if [[ -e "$dst" || -L "$dst" ]]; then
    local backup="${dst}.bak-${timestamp}"
    echo "备份：$dst -> $backup"
    mv "$dst" "$backup"
  fi

  ln -s "$src" "$dst"
  echo "已链接：$dst -> $src"
}

echo "Repo: $repo_root"
echo "XDG_CONFIG_HOME: $config_home"

# Clash
clash_src="$repo_root/.config/clash"
clash_dst="$config_home/clash"

if [[ -f "$clash_dst/config.yaml" && ! -f "$clash_src/config.yaml" ]]; then
  echo "检测到已有 Clash 配置：$clash_dst/config.yaml"
  echo "迁移到仓库目录（git 默认忽略）：$clash_src/config.yaml"
  mkdir -p "$clash_src"
  cp -a "$clash_dst/config.yaml" "$clash_src/config.yaml"
fi

link_path "$clash_src" "$clash_dst"

# systemd user unit
link_path "$repo_root/.config/systemd/user/clash-compose.service" \
  "$config_home/systemd/user/clash-compose.service"

# uv
link_path "$repo_root/.config/uv" \
  "$config_home/uv"

# scripts
link_path "$repo_root/.config/scripts" \
  "$config_home/scripts"

echo
echo "下一步："
echo "  1) 编辑 Clash 配置：$config_home/clash/config.yaml"
echo "  2) 启动：cd $config_home/clash && docker compose up -d"
echo "  3) 自动启动（systemd 用户服务）：$config_home/clash/scripts/install-systemd-user-service.sh"
echo "  4) 启用脚本入口：在 ~/.bashrc 加一行：source $config_home/scripts/bootstrap.sh"
