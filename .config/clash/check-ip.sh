#!/usr/bin/env bash
set -e

source "$(dirname "$0")/env.sh"

MODE="${1:-direct}"

IP_SERVICES=(
  "https://api.myip.com"
  "https://ifconfig.me"
  "https://ipinfo.io/json"
)

pick_service() {
  for svc in "${IP_SERVICES[@]}"; do
    if curl -s --max-time 5 "$svc" >/dev/null; then
      echo "$svc"
      return
    fi
  done
  echo ""
}

SERVICE=$(pick_service)

if [[ -z "$SERVICE" ]]; then
  echo "❌ No IP service reachable"
  exit 1
fi

echo "== IP Check =="
echo "Mode     : $MODE"
echo "Service  : $SERVICE"
echo

case "$MODE" in
  direct)
    echo "[DIRECT] Public IP:"
    curl -s "$SERVICE"
    ;;

  proxy)
    echo "[PROXY - internal] Public IP:"
    curl -s \
      -x "http://${CLASH_BIND_IP}:${CLASH_PROXY_PORT_IN}" \
      "$SERVICE"
    ;;

  external)
    echo "[PROXY - external] Public IP:"
    curl -s \
      -x "http://${CLASH_EXTERNAL_IP}:${CLASH_PROXY_PORT_OUT}" \
      "$SERVICE"
    ;;

  *)
    echo "Usage:"
    echo "  $0 [direct|proxy|external]"
    exit 1
    ;;
esac

echo
echo "== Done =="

