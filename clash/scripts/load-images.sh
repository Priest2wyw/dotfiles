#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_dir"

if ! command -v docker >/dev/null 2>&1; then
  echo "docker 未安装或不在 PATH 中" >&2
  exit 1
fi

target="${1:-images}"

load_one() {
  local tar_file="$1"
  echo "docker load -i $tar_file"
  docker load -i "$tar_file"
}

if [[ -d "$target" ]]; then
  mapfile -t tars < <(find "$target" -maxdepth 1 -type f -name '*.tar' -print | sort)
  if (( ${#tars[@]} == 0 )); then
    echo "目录中未找到 .tar：$target" >&2
    exit 1
  fi
  for tar_file in "${tars[@]}"; do
    load_one "$tar_file"
  done
elif [[ -f "$target" ]]; then
  load_one "$target"
else
  echo "路径不存在：$target" >&2
  echo "用法：$0 [images/ 或具体 tar 文件]" >&2
  exit 1
fi

echo "OK 镜像已加载"

