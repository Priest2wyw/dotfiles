#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_dir"

if ! command -v docker >/dev/null 2>&1; then
  echo "docker 未安装或不在 PATH 中" >&2
  exit 1
fi

if [[ -f ./.env ]]; then
  set -a
  # shellcheck disable=SC1091
  source ./.env
  set +a
fi

clash_image="${CLASH_IMAGE:-metacubex/mihomo:latest}"
yacd_image="${YACD_IMAGE:-ghcr.io/haishanh/yacd:master}"

images=("$clash_image" "$yacd_image")

timestamp="$(date +%Y%m%d-%H%M%S)"
out="clash-images-${timestamp}.tar"

echo "准备导出镜像到：$out"
echo "镜像列表："
printf '  - %s\n' "${images[@]}"

missing=()
for img in "${images[@]}"; do
  if ! docker image inspect "$img" >/dev/null 2>&1; then
    missing+=("$img")
  fi
done

if (( ${#missing[@]} > 0 )); then
  echo "本地缺少以下镜像，将尝试拉取："
  printf '  - %s\n' "${missing[@]}"
  for img in "${missing[@]}"; do
    docker pull "$img"
  done
fi

docker save -o "$out" "${images[@]}"
echo "OK 已导出：$repo_dir/$out"
