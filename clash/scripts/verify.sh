#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_dir"

if ! command -v docker >/dev/null 2>&1; then
  echo "docker 未安装或不在 PATH 中" >&2
  exit 1
fi

if ! docker compose version >/dev/null 2>&1; then
  echo "docker compose 不可用（需要 Docker Compose v2 插件）" >&2
  exit 1
fi

expand_path() {
  local path="$1"
  if [[ "$path" == "~" ]]; then
    echo "$HOME"
    return
  fi
  if [[ "$path" == "~/"* ]]; then
    echo "$HOME/${path#~/}"
    return
  fi
  echo "$path"
}

clash_config_dir="$(expand_path "${CLASH_CONFIG_DIR:-~/.config/clash}")"
clash_config_file="$clash_config_dir/config.yaml"

if [[ ! -f "$clash_config_file" ]]; then
  echo "未找到配置文件：$clash_config_file" >&2
  echo "请创建并放置你的 Clash 配置到该路径（默认挂载到容器 /root/.config/mihomo/config.yaml）。" >&2
  exit 1
fi

echo "OK 配置文件：$clash_config_file"

echo "OK Compose 语法检查：docker compose config"
docker compose config >/dev/null

echo "检查容器状态（需要能访问 Docker daemon）..."
docker compose ps

clash_mixed_port="${CLASH_MIXED_PORT:-30002}"
clash_ctrl_port="${CLASH_CTRL_PORT:-30001}"
yacd_web_port="${YACD_WEB_PORT:-30000}"

if command -v ss >/dev/null 2>&1; then
  echo "检查端口监听：$clash_mixed_port / $clash_ctrl_port / $yacd_web_port"
  ss -lnt | awk '{print $4}' | grep -Eq ":(${clash_mixed_port}|${clash_ctrl_port}|${yacd_web_port})\\b" \
    && echo "OK 端口已监听" \
    || echo "WARN 未检测到端口监听（可能服务未启动或端口映射变化）"
fi

echo "完成。"
