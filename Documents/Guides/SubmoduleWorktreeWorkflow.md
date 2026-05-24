# 子模块 Worktree 工作流

> 本文档覆盖 AngelscriptProject 中"父仓库 + 多子模块 + worktree + OpenSpec"组合场景的标准流程。

## 背景

本仓库的插件目录是子模块，不是普通目录：

| 子模块路径 | 远端仓库 | 说明 |
|-----------|---------|------|
| `Plugins/Angelscript` | `TDGameStudio/UnrealAngelscriptPlugin` | 核心插件，绝大多数代码改动在此 |
| `Plugins/AngelscriptGAS` | `TDGameStudio/AngelscriptGAS` | GAS 扩展插件 |
| `Plugins/UnrealEvent` | `TDGameStudio/UnrealEventPlugin` | GMP 衍生事件插件 |

`git worktree add` 只处理父仓库的工作树，**不会自动初始化或检出子模块**。新 worktree 中子模块目录只有 gitlink 占位，没有源码。直接构建或访问源码会失败。

## 核心约束

1. **父仓库记录的子模块 commit 远端不一定可取** — 本地开发分支的子模块 commit 可能还没 push 到远端，`git submodule update --init` 会失败。
2. **每个子模块是独立 git 仓库** — 子模块需要自己的 branch/worktree，不能假设 `git submodule update` 一步到位。
3. **OpenSpec 在父仓库，源码改动可能在子模块** — 天然是"双仓库变更"，合并/提交需要分别处理。
4. **新 worktree 没有 `AgentConfig.ini`** — 构建前必须 bootstrap，且新 worktree 无法自动解析主 workspace 的本机配置，需要显式传 `EngineRoot`。

## 一键流程（推荐）

绝大多数情况下，下面这一行就能完成"父 worktree + 子模块 init/fallback + AgentConfig.ini + OpenSpec change 骨架"：

```powershell
# 在主 workspace 根目录执行
powershell.exe -NoProfile -ExecutionPolicy Bypass `
    -File Tools\Bootstrap\NewWorktree.ps1 -Name <change-name>
```

`<change-name>` 同时作为：

- 父 worktree 目录：`.worktrees/<change-name>`
- 父分支名：`<change-name>`（从当前 HEAD 开分）
- OpenSpec change 目录：`openspec/changes/<change-name>/`（含空的 `proposal.md` / `tasks.md` / `design.md` / `specs/.gitkeep`）

常用开关：

| 参数 | 用途 |
|------|------|
| `-DryRun` | 仅打印将执行的命令，不改文件系统/git |
| `-NoOpenSpec` | 跳过 OpenSpec 骨架（小改动不需要 OpenSpec 时使用） |
| `-NoPrewarm` | 跳过 `TargetInfo.json` 预热（首次执行仍建议保留预热） |
| `-EngineRoot <path>` | 显式指定 EngineRoot（默认从主 workspace 的 `AgentConfig.ini` 读取） |
| `-Verify` | bootstrap 完成后跑一次 `RunBuild.ps1` 验证构建链路 |
| `-Force` | 透传给 BootstrapWorktree，强制重写 `AgentConfig.ini` / 覆盖已有 OpenSpec 目录 |

执行成功后，按提示 `cd .worktrees/<change-name>` 即可继续 OpenSpec 流程或构建/测试。

如果一键流程在某个子模块上失败（典型场景：父仓库记录的子模块 commit 远端不可取且本地对象库也没有），脚本**不会回滚** worktree，让你按下面的标准流程接手手工处理。

---

## 标准流程（手工版本，用于排查或脚本无法覆盖的场景）

### Phase 1：创建父仓库 worktree

```powershell
# 从主 workspace 根目录执行
git worktree add .worktrees/<change-name> -b <branch-name>
```

此时 `.worktrees/<change-name>/Plugins/Angelscript` 等子模块目录只有 gitlink，没有源码。

### Phase 2：初始化子模块

进入新 worktree 后，**按优先级尝试以下策略**：

#### 策略 A：标准 init + update（优先尝试）

```powershell
cd .worktrees/<change-name>
git submodule init
git submodule update
```

如果父仓库记录的子模块 commit 在远端可取，这一步就够了。验证：

```powershell
git submodule status
# 所有条目应显示 commit hash，无 '-' 前缀（表示未初始化）
```

#### 策略 B：从本地子模块对象库创建 worktree（远端不可取时）

当 `git submodule update` 失败（通常报 `fatal: reference is not a tree`），说明父仓库记录的子模块 commit 远端没有。此时从主 workspace 已有的子模块对象库创建 worktree：

```powershell
# 以 Plugins/Angelscript 为例
# 从主 workspace 的子模块 git 目录创建 worktree 到新父 worktree 中
git -C Plugins/Angelscript worktree add `
    "D:/Workspace/AngelscriptProject/.worktrees/<change-name>/Plugins/Angelscript" `
    -b <change-name>-plugin

# 以 Plugins/UnrealEvent 为例
git -C Plugins/UnrealEvent worktree add `
    "D:/Workspace/AngelscriptProject/.worktrees/<change-name>/Plugins/UnrealEvent" `
    -b <change-name>
```

**命名约定**：子模块 worktree 分支名用 `<父branch>-plugin` 后缀，或与父分支同名（取决于子模块是否有独立分支策略）。

#### 策略 C：用本地 HEAD 临时补齐构建环境

如果只是为了验证构建通过（不需要精确匹配父仓库记录的 commit），可以用本地子模块的 HEAD：

```powershell
git -C Plugins/Angelscript worktree add `
    "D:/Workspace/AngelscriptProject/.worktrees/<change-name>/Plugins/Angelscript" `
    HEAD --detach
```

**必须记录**：在 commit message 或 tasks.md 中注明"用了本地 HEAD 作为 build env，非提交内容"。此方式会导致 `git status` 中出现 `M Plugins/Angelscript` 噪音，不是本次代码改动。

### Phase 3：Bootstrap AgentConfig

新 worktree 没有 `AgentConfig.ini`，bootstrap 需要显式传 `EngineRoot`：

```powershell
# 从新 worktree 根目录执行
powershell.exe -NoProfile -ExecutionPolicy Bypass `
    -File Tools\Bootstrap\powershell\BootstrapWorktree.ps1 `
    -EngineRoot "<EngineRoot>" -NoPrewarm
```

`EngineRoot` 从主 workspace 的 `AgentConfig.ini` 读取。如果主 workspace 也没有，需要用户提供。

### Phase 4：验证构建环境

```powershell
# 确认所有子模块目录有源码
Test-Path .worktrees/<change-name>/Plugins/Angelscript/Source
Test-Path .worktrees/<change-name>/Plugins/AngelscriptGAS/Source
Test-Path .worktrees/<change-name>/Plugins/UnrealEvent/Source

# 确认 AgentConfig.ini 存在且 ProjectFile 指向当前 worktree
Get-Content .worktrees/<change-name>/AgentConfig.ini

# 尝试构建
powershell.exe -NoProfile -ExecutionPolicy Bypass `
    -File Tools\RunBuild.ps1 -Label worktree-verify -TimeoutMs 180000
```

### Phase 5：处理 git status 噪音

使用策略 B/C 补齐的子模块会导致 `git status` 出现 `D Plugins/Angelscript` 或 `M Plugins/Angelscript` 等条目。这不是本次代码改动：

- 提交时只 `git add` 实际改动的文件，不要 `git add .` 全量暂存
- 在 PR 描述中注明哪些子模块是临时 build env

## OpenSpec 双仓库变更

当 OpenSpec change 的实际代码改动在子模块中时：

| 内容 | 存放位置 |
|------|---------|
| OpenSpec artifacts（design.md, tasks.md, spec/） | 父仓库 `openspec/changes/<change>/` |
| 源码实现（.cpp, .h, .as） | 子模块对应的分支 |
| 构建/测试验证 | 在父 worktree 中执行，消费子模块源码 |

**提交顺序**：
1. 先在子模块中提交源码改动
2. 在父仓库中 `git add Plugins/<submodule>` 更新 gitlink
3. 在父仓库中提交 OpenSpec artifacts + gitlink 更新

## Scope Guard

在子模块中做实现时，必须明确 scope boundary：

- **UnrealEvent runtime migration**：只允许 `Source/UnrealEvent/**`、`Source/UnrealEventEditor/**`、`Source/UnrealEventTest/**`。不要扫或修改 `Source/GMPEditor/**`，除非用户明确要求。
- **Angelscript plugin**：按 `AngelscriptRuntime` / `AngelscriptEditor` / `AngelscriptTest` 模块边界工作。

批量操作（rg 扫描、include 替换等）时用明确的路径参数，不要扫整个 `Plugins/<submodule>/Source/`。

## PowerShell 注意事项

- `rg` 正则在 PowerShell 中**必须用单引号**，双引号中的 `|`、`"`、`$` 会被 shell 解析
- 大型文件移动优先用 `git mv`，保留 rename detection 可读性
- 路径分隔符用 `/` 或转义 `\\`，裸 `\` 在正则中是转义符

## 故障排查

### `git submodule update` 报 `fatal: reference is not a tree`

父仓库记录的子模块 commit 远端没有。使用策略 B（从本地对象库创建 worktree）或策略 C（用本地 HEAD）。

### 子模块目录存在但为空

`git worktree add` 创建了父 worktree 但没初始化子模块。执行 Phase 2。

### `git submodule status` 报 `fatal: no submodule mapping found`

git index 中有 160000（submodule）条目但 `.gitmodules` 没有对应映射。清理残留：

```powershell
git rm --cached <stale-path>
```

### 新 worktree 构建失败 `AgentConfig.ini not found`

执行 Phase 3，从主 workspace 读取 `EngineRoot` 后 bootstrap。

### `git status` 显示 `D` 或 `M` 的子模块条目

策略 B/C 的预期行为。提交时只暂存实际改动文件，不要全量 `git add .`。

## 检查清单

创建新 worktree 时按顺序验证：

- [ ] 父 worktree 创建成功（`git worktree add`）
- [ ] 所有必要子模块已初始化（`git submodule status` 无 `-` 前缀，或已通过策略 B/C 补齐）
- [ ] 每个子模块的 `Source/` 目录有实际文件
- [ ] `AgentConfig.ini` 存在且 `ProjectFile` 指向当前 worktree
- [ ] 构建通过（`Tools\RunBuild.ps1`）
- [ ] 明确记录哪些子模块用了非标准初始化方式
