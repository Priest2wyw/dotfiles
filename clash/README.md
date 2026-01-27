# Clash (Mihomo) + YACD（Docker Compose）

用 Docker Compose 在本机启动：

- `metacubex/mihomo`（Clash Meta / Mihomo 内核，提供代理端口与控制端口）
- `yacd`（Web UI）

## 你需要做什么

1) 准备 Clash 配置文件：默认读取 `~/.config/clash/config.yaml`
2) 确认端口不冲突（默认：代理 `30002`，控制端口 `30001`，YACD Web `30000`）
3) 启动 compose

> 如果你的 `config.yaml` 里开启了 `secret:`，访问控制端口需要带鉴权（见下方验证章节）。

## 配置

项目使用 `.env` 配置镜像/端口（可按需修改）：

- `CLASH_IMAGE`：默认 `metacubex/mihomo:latest`
- `CLASH_CONFIG_DIR`：默认 `~/.config/clash`
- `CLASH_MIXED_PORT`：默认 `30002`（映射到容器 `7890`）
- `CLASH_CTRL_PORT`：默认 `30001`（映射到容器 `9090`）
- `YACD_WEB_PORT`：默认 `30000`

`config.yaml` 关键项（建议至少确认这些值，否则端口映射可能无法从宿主机访问）：

```yaml
mixed-port: 7890
external-controller: 0.0.0.0:9090
# secret: "可选，开启后访问控制端口需要鉴权"
```

## 如何启动

```bash
docker compose up -d
```

常用命令：

```bash
docker compose ps
docker compose logs -f --tail=200 clash
docker compose logs -f --tail=200 yacd
```

## 如何验证

1) 容器状态

```bash
docker compose ps
```

2) 端口监听（任意一种）

```bash
ss -lnt | grep -E ":(${CLASH_MIXED_PORT:-30002}|${CLASH_CTRL_PORT:-30001}|${YACD_WEB_PORT:-30000})\\b"
```

3) 控制端口（不带 secret 的情况）

```bash
curl -fsS "http://127.0.0.1:${CLASH_CTRL_PORT:-30001}/version"
```

如果你的 `config.yaml` 设置了 `secret: <TOKEN>`，则：

```bash
curl -fsS -H "Authorization: Bearer <TOKEN>" "http://127.0.0.1:${CLASH_CTRL_PORT:-30001}/version"
```

4) 代理连通性（示例：HTTP 代理）

```bash
curl -I --proxy "http://127.0.0.1:${CLASH_MIXED_PORT:-30002}" https://www.example.com
```

5) 打开 YACD

- 浏览器访问：`http://127.0.0.1:${YACD_WEB_PORT:-30000}`

## 自动启动（可选）

这个 compose 已设置 `restart: unless-stopped`：只要 Docker 服务随开机启动，容器会在重启后自动拉起。

如果你更希望由 systemd 管理（用户服务），可以执行：

```bash
./scripts/install-systemd-user-service.sh
systemctl --user enable --now clash-compose.service
```

如果需要在未登录情况下也运行用户服务，可启用 linger：

```bash
loginctl enable-linger "$USER"
```

## 如何导出镜像（docker save）

```bash
./scripts/save-images.sh
```

导出的 tar 包会生成在项目根目录下。

## 如何加载镜像（docker load，离线环境）

如果你已经把镜像导出到 `images/`（例如 `images/mihomo_latest.tar`、`images/yacd_latest.tar`），可以执行：

```bash
./scripts/load-images.sh
```

也支持指定单个 tar：

```bash
./scripts/load-images.sh images/mihomo_latest.tar
```

也可以用 Makefile：

```bash
make load-images
```
