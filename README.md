# SeaBlock 2 预览版

Factorio SeaBlock 2 模组包的安装管理仓库，通过 git submodule 管理各模组源码，并将其链接到 Factorio 的 mods 目录。

## 注意事项

> [!IMPORTANT]
> **本模组包要求你拥有正版 Factorio。** 游戏本体需自行在 [factorio.com](https://factorio.com) 或 Steam 购买。

> [!WARNING]
> **SeaBlock 与 Space Age 不兼容。** 请在游戏的模组管理界面中关闭以下内容：
> - **Space Age**（太空时代 DLC）
> - **Quality**（品质系统）
> - **Elevated Rails**（高架铁路）

## 版本要求

本模组包锁定 **Factorio 2.0.72**，请勿使用其他版本以免出现兼容性问题。

### Steam 版本锁定方法

1. 在 Steam 库中右键 Factorio → **属性**
2. 切换到 **测试版（Betas）** 标签页
3. 在下拉列表中选择 `2.0.72`
4. 等待 Steam 下载并切换到指定版本

### factorio.com 版本锁定方法

前往 [factorio.com/download](https://factorio.com/download) 下载 **2.0.72** 版本：

- Linux：下载 `factorio_linux_2.0.72.tar.xz`，放入仓库根目录，脚本会自动解压
- Windows：下载 `factorio_win_2.0.72.zip`，放入仓库根目录，脚本会自动解压

若压缩包不在仓库根目录，脚本则默认使用本地已安装的 Factorio。

## 前置要求

### Linux / macOS

- `git`
- `tar`（仅在使用仓库根目录压缩包安装 Factorio 时）

### Windows

- `git`
- PowerShell 5.1 或更高版本（Windows 10 内置）

## 安装

### 第一步：克隆本仓库

```bash
git clone <本仓库地址>
cd <仓库目录>
```

### 第二步：运行安装脚本

**Linux / macOS**

```bash
./setup.sh
```

**Windows（PowerShell）**

```powershell
# 如遇执行策略限制，先运行一次：
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned

.\setup.ps1
```

脚本会依次执行：

1. 拉取本仓库的最新变更
2. 将所有 submodule 更新到仓库记录的 commit
3. 若仓库根目录存在 Factorio 压缩包则自动解压，否则使用本地已安装的 Factorio
4. 为 `trunk/` 中的各模组目录在 Factorio mods 目录中创建符号链接（Linux/macOS）或 Junction（Windows）
5. 将 `trunk/` 中版本锁定的 `.zip` 模组复制到 mods 目录

## Factorio 安装路径

| 情况 | mods 目录 |
|------|----------|
| 仓库根目录存在压缩包 | `<仓库根目录>/factorio/mods` |
| 本地已安装 Factorio | Linux/macOS: `~/.factorio/mods` · Windows: `%APPDATA%\Factorio\mods` |

## 更新

重新运行安装脚本即可。脚本会自动拉取本仓库的最新 commit 并同步所有 submodule。

若需主动将 submodule 推进到上游最新版本并锁定：

```bash
git submodule update --remote --merge
git add trunk/
git commit -m "Update submodules"
```

## 仓库结构

```
.
├── trunk/                      # 模组源码
│   ├── SeaBlock/               # submodule
│   ├── Angelmods/              # submodule（Angel's Mods）
│   ├── bobsmods/               # submodule（Bob's Mods）
│   ├── CircuitProcessing/      # submodule
│   ├── LandfillPainting/       # submodule
│   ├── ScienceCostTweakerM/    # submodule
│   ├── SpaceMod/               # submodule
│   ├── reskins-angels/         # submodule
│   ├── reskins-bobs/           # submodule
│   ├── reskins-compatibility/  # submodule
│   └── *.zip                   # 版本锁定的 zip 模组
├── setup.sh                    # Linux / macOS 安装脚本
├── setup.ps1                   # Windows 安装脚本
└── .gitmodules
```
