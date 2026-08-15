# dotfiles

目标：把个人配置统一放到仓库的 `.config/`（尽量遵循 XDG），通过软链实现“一键迁移环境”。

## 快速开始

```bash
git clone --recurse-submodules git@github.com:Priest2wyw/dotfiles.git ~/github/dotfiles
cd ~/github/dotfiles
./install.sh
```

若克隆时遗漏了 submodule，`./install.sh` 会自动初始化 tmux 配置；也可手动执行：

```bash
git submodule update --init --recursive
```

## 一键重建

这套仓库能一键恢复的是“配置层”，不是系统软件层。典型流程是：

1. 先安装系统包：`git`、`bash`、`tmux`、`neovim`、`lazygit`、`python/pip`
2. 如需代理，再准备 `clash` 相关的 `docker compose` 和 `systemd --user`
3. 克隆仓库并执行 `./install.sh`
4. 补齐本机私密配置：`~/.config/clash/config.yaml`、`~/.bashrc` 入口、各类凭据
5. 首次启动 `nvim`，让 LazyVim 下载插件

如果你已经有一套老环境，`install.sh` 会先给冲突目标留 `.bak-时间戳` 备份，再重新建立软链。

## 框架

仓库只保存可复用的用户配置，`install.sh` 将它们软链到
`${XDG_CONFIG_HOME:-~/.config}`。已有目标会先被备份为带时间戳的
`.bak-*` 文件，再建立新链接。

```text
dotfiles/.config/
  clash/       Mihomo + YACD 的 Docker Compose 配置
  lazygit/     LazyGit 个人覆盖配置
  nvim/        Neovim + LazyVim 配置和插件锁文件
  scripts/     Bash 环境、别名、补全和个人命令
  systemd/     用户级 Clash 服务
  tmux/        Oh my tmux! submodule 和个人覆盖配置
  uv/          uv 全局配置
```

安装器不安装系统软件，也不保存凭据、订阅或机器专属路径。新机器至少需要
Git、Bash、tmux、Neovim、LazyGit、Python/pip，以及使用 Clash 时需要的
Docker Compose 和 systemd 用户服务。

这套配置里最适合“换机即复用”的是：

- `scripts/`：入口统一，个人命令和 shell 行为集中管理
- `tmux/`：主配置来自 oh-my-tmux，本地只保留覆盖层
- `nvim/`：LazyVim 作为框架，插件版本用 `lazy-lock.json` 锁住
- `lazygit/`：默认值尽量少，避免把机器专属偏好写死

## 自动化边界

可以自动化的部分：

- `./install.sh` 统一建立软链，并在目标已存在时先备份
- tmux 的上游 submodule 缺失时可自动初始化
- `nvim` 首次启动时会自动拉取 LazyVim 和插件
- Clash 现有本地配置可在首次安装时迁移到仓库忽略目录

仍需要人工处理的部分：

- 系统软件安装，例如 Git、tmux、Neovim、LazyGit、Python/pip、Docker Compose
- Clash 的订阅、节点和 `config.yaml`
- `~/.bashrc` 中的脚本入口接入
- `scripts/env.d/*.local.sh` 里的机器专属变量
- SSH、Git、AI CLI、镜像源等凭据或账号配置

这套仓库的设计目标不是把所有东西做成黑盒，而是把“可复用的默认值”收进仓库，把“机器相关、凭据相关、容易变化的内容”留在本机。

## 当前包含

- Clash (Mihomo) + YACD：`.config/clash/`
- systemd 用户服务：`.config/systemd/user/`
- 常用脚本：`.config/scripts/`（统一入口，便于迁移）
- tmux：Oh my tmux!（`.config/tmux/oh-my-tmux`）及个人覆盖文件 `.config/tmux/tmux.conf.local`
- Neovim + LazyVim：`.config/nvim/`（包含 `lazy-lock.json` 插件版本锁）
- LazyGit：`.config/lazygit/config.yml`

## tmux

安装脚本会将 Oh my tmux! 的主配置和仓库内的本地覆盖文件分别软链到：

```text
~/.config/tmux/tmux.conf
~/.config/tmux/tmux.conf.local
```

不要修改 `oh-my-tmux/.tmux.conf`；个人配置请写在 `.config/tmux/tmux.conf.local`。首次安装后直接运行 `tmux` 即可生效；已有 tmux server 时，执行 `tmux source-file ~/.config/tmux/tmux.conf` 重载。

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

- 通用 Shell：彩色 `ls/grep`、`l`、`..`、`...`、`....`、`cls`、`mkcd`、`croot`
- Git 快捷入口：`g`、`gs`、`gd`、`gl`
- `cxd`：运行 `codex --yolo`
- `ccd`：运行 `claude --dangerously-skip-permissions`
- `pip_canel`：交互选择 pip 软件源（也可使用兼容入口 `pip_channel`）
- `uv_init`：通过 pip 在用户级别安装或升级 uv，并可交互设置用户级拉取源和缓存路径
- `init_uv`：兼容入口，效果与 `uv_init` 相同

`cxd` 和 `ccd` 会关闭对应 CLI 的常规安全检查，仅应在可信目录中使用。

更多见：`.config/scripts/README.md`

## Neovim、LazyVim 和 LazyGit

安装器会将以下目录分别软链到 `~/.config/nvim` 和 `~/.config/lazygit`：

```text
.config/nvim/     LazyVim 配置、语言 extras 和 lazy-lock.json
.config/lazygit/  LazyGit 的个人覆盖配置
```

首次执行 `nvim` 时，LazyVim 会下载 `lazy.nvim` 和由 `lazy-lock.json`
锁定的插件版本；这些运行时数据不进入仓库。当前 LazyVim 启用了 Git、JSON、
Markdown、Python 和 TOML 的 extras，并通过配置中的 GitHub 加速地址下载插件。

`lazygit` 本身需要由系统包管理器或发行版安装；`config.yml` 是一个最小入口，
可按需加入个人快捷键、主题或 Git 行为覆盖。

## 本地与私密配置

- Clash 的 `config.yaml` 被 Git 忽略；请在本机提供订阅和节点配置。
- `scripts/env.d/*.local.sh` 用于机器专属环境变量，例如 uv cache 路径，不进入 Git。
- Neovim 的插件、Mason 工具、日志和状态目录由 `.config/nvim/.gitignore` 排除。
- Git、SSH、AI CLI 和镜像仓库凭据不在本仓库管理范围内。
