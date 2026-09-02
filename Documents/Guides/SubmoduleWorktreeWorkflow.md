# 子模块 Worktree 工作流

本文说明 Hardness 如何在 AngelscriptProject 中管理父仓库、多个子模块、Goal worktree 与 Current workspace。Hardness 只是 Skill/PowerShell 路由，不维护 daemon 或隐藏状态库。

## 模式

| 模式 | 工作位置 | 成功终态 |
|---|---|---|
| Goal | canonical `.worktrees/<goal>`，分支 `goal/<goal>` | committed、verified、reviewed、ready-to-integrate |
| Current | 当前 checkout | 验证完成并保留已有工作区改动 |

两种模式都不会自动 merge、push、publish 或删除 worktree。普通直接任务使用 Current；原生 Goal 默认使用 Goal。OpenSpec change 只在目标明确要求时创建，不是 worktree 初始化副作用。

## 统一入口

```powershell
Import-Module .\.agents\skills\hardness\scripts\Hardness.psd1

$goal = New-HardnessContext -Mode Goal -GoalName refactor-example
Invoke-Hardness -Command workspace.new -Context $goal
Invoke-Hardness -Command workspace.verify -Context $goal

$current = New-HardnessContext -Mode Current
Invoke-Hardness -Command workspace.status -Context $current
```

需要修复已有 worktree 时使用 `workspace.bootstrap`；canonical Goal 准备 Git 收口时使用 `workspace.finish`。Current 留在当前 checkout，通过 `workspace.status` / `workspace.verify` 检查并保留已有改动，不调用 `workspace.finish`。`workspace.remove` 是独立、显式操作，并且拒绝 dirty parent/submodule。

## 子模块边界

以下目录是独立 Git 仓库：

| 路径 | 所有权 |
|---|---|
| `Plugins/Angelscript` | 核心插件 |
| `Plugins/AngelscriptGameplayTags` | GameplayTags 扩展 |
| `Plugins/AngelscriptGAS` | GAS 扩展 |
| `Tools/openspec` | 便携 OpenSpec Rust CLI |
| `Wiki` | 独立 Wiki 工作区 |

父 worktree 创建后必须初始化父提交记录的精确 gitlink OID。`git submodule update --init --recursive` 是首选；不能因为远端缺失对象就改用“最新 HEAD”。

## 远端缺失 gitlink 对象

当远端返回 `not our ref` 或 `reference is not a tree`：

1. 从父仓库 `git ls-tree HEAD -- <submodule>` 读取期望 OID。
2. 在主 checkout 的同一子模块中用 `git cat-file -e <oid>^{commit}` 验证本机确实拥有对象。
3. 只把该 OID fetch 到新 worktree 的独立子模块仓库，并 detached checkout 精确 OID。
4. 验证目标子模块 clean、HEAD 等于 gitlink；否则 workspace verification 失败。

不得清理、reset 或覆盖主 checkout 的 dirty 子模块。也不得用本机任意 HEAD 冒充父仓库记录的构建基线。

## 本机配置

`AgentConfig.ini` 是被忽略的机器配置。Goal 创建时仅在以下条件全部成立后复制：

- 来源位于已确认的项目根；
- 目标位于刚创建的 worktree 根；
- `git check-ignore AgentConfig.ini` 成功；
- 目标文件尚不存在，或调用者明确选择了可恢复的覆盖策略。

配置中的 `Paths.ProjectFile` 必须指向目标 worktree 的 `.uproject`。`workspace.bootstrap` 只在安全条件下复制缺失且已被忽略的 `AgentConfig.ini`，并初始化或恢复父仓库记录的精确 gitlink；它不重写配置、不执行 toolchain preflight，也不创建 OpenSpec change。

## 并行与资源

- 父 workspace 和每个子模块分别检查 dirty 状态。
- Task DAG 只有在 `task_graph.depends_on` 的直接前置任务完成，并且 Files、生成产物与 exclusive execution lease 不冲突时才可并行。
- 每个 run 使用独立目录与 run ID，禁止跨 worktree 共享日志文件。

## 提交与完成

涉及子模块的提交顺序固定：

```text
submodule tests
  -> submodule commit/tag
  -> parent gitlink update
  -> parent tests/review
  -> parent commit
```

`workspace.finish` 必须列出：

- `ProjectRoot` 与 Goal branch；
- parent commit；
- 每个已提交子模块的 commit；
- 最终 `GitStateComplete`。

测试证据、Review Gate 与 ready-to-integrate 判断由 Goal 工作流单独记录，不属于 `workspace.finish` 的返回契约。

它不执行 merge、push 或 remove。任何删除 worktree 前都要重新验证目标绝对路径位于预期 worktree 根，并拒绝 parent 或子模块的未提交内容。

`Tools/openspec` 的源码提交与 annotated tag 位于子模块。每个 release 在父仓库只提交一次最终 accepted package 更新：gitlink、release manifest/docs 与 bundled `openspec.exe`；候选 executable 不进入父仓库历史。

## 常见故障

- **目标目录未被忽略**：先修正并提交 `.gitignore`，不要创建 worktree。
- **目标分支/路径已存在**：使用 `workspace.status` 判断是否为可恢复的同一 Goal；不要覆盖未知目录。
- **子模块远端缺 OID且本机也没有**：这是外部对象缺失，记录精确 OID 后停止；不要替换为新版本。
- **主工作区很 dirty**：Goal 仍从明确 base commit 创建；只按批准的 pathspec 迁移本次 WIP，不 stash/reset/clean 或 blanket-copy。
- **worktree 初始化或结构状态错误**：先运行 `workspace.bootstrap`，再运行 `workspace.verify`；不要用任意本地 HEAD 替换父仓库记录的 gitlink。
