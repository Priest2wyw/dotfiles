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

## Clash 自动启动

1) 准备配置：`~/.config/clash/config.yaml`（仓库默认忽略该文件）
2) 手动启动：`cd ~/.config/clash && docker compose up -d`
3) systemd 自动启动：`~/.config/clash/scripts/install-systemd-user-service.sh`

更多见：`.config/clash/README.md`
