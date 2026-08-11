# dotfiles

目标：把个人配置统一放到仓库的 `.config/`（尽量遵循 XDG），通过软链实现“一键迁移环境”。

## 快速开始

```bash
git clone git@github.com:Priest2wyw/dotfiles.git ~/github/dotfiles
cd ~/github/dotfiles
./install.sh
```

## 当前包含

- Clash (Mihomo) + YACD：`.config/clash/`
- systemd 用户服务：`.config/systemd/user/`
- 常用脚本：`.config/scripts/`（统一入口，便于迁移）

## Clash 自动启动

1) 准备配置：`~/.config/clash/config.yaml`（仓库默认忽略该文件）
2) 手动启动：`cd ~/.config/clash && docker compose up -d`
3) systemd 自动启动：`~/.config/clash/scripts/install-systemd-user-service.sh`

更多见：`.config/clash/README.md`

## 常用脚本（统一入口）

设计目标：`.bashrc` 只有一个入口，后续新增脚本无需改 `.bashrc`。

1) `install.sh` 会把 `.config/scripts` 软链到 `~/.config/scripts`
2) 在 `~/.bashrc` 增加一行：

```bash
source ~/.config/scripts/bootstrap.sh
```

3) 新脚本放在 `~/.config/scripts/bin/`，赋予可执行权限即可

当前内置命令：

- `cxd`：运行 `codex --yolo`
- `ccd`：运行 `claude --dangerously-skip-permissions`
- `pip_canel`：交互选择 pip 软件源（也可使用兼容入口 `pip_channel`）
- `uv_init`：通过 pip 在用户级别安装或升级 uv，并可交互设置缓存路径
- `init_uv`：兼容入口，效果与 `uv_init` 相同

`cxd` 和 `ccd` 会关闭对应 CLI 的常规安全检查，仅应在可信目录中使用。

更多见：`.config/scripts/README.md`
