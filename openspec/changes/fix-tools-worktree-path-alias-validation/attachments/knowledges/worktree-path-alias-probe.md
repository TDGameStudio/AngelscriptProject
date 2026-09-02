---
topic: Worktree 路径别名与 AgentConfig 校验
source: 源码阅读 + 实验验证
verified_at: 2026-08-24
against: 本机 9 个 worktree；PowerShell 7.6.0；UE_5.8
confidence: verified
---

# Worktree 路径别名实测

## 别名清单

`git worktree list` 有 9 个 worktree，其中 5 个通过短路径别名访问。

| 别名 | 类型 | 目标 |
|---|---|---|
| `D:\as-cta` | junction（`Directory, ReparsePoint`） | `.worktrees\refactor-as-canonical-typed-ast-compiler` |
| `D:\as-lns` | junction（`Directory, ReparsePoint`） | `.worktrees\improve-as-library-namespace-canonicalization` |
| `R:` | subst | `.worktrees\feature-as-angelsea-runtime-jit-plugin` |
| `T:` | subst | `.worktrees\refactor-as-subsystem-typeinfo-bind-cache` |
| `V:` | subst | `.worktree\feature-as-typed-semantic-aot` |

注意 `.worktree` 和 `.worktrees` 两个父目录都在用（`as-assets-singletons`、`ueevent`、`feature-as-typed-semantic-aot` 在 `.worktree`；其余在 `.worktrees`）。

各 worktree 的 `Paths.ProjectFile` 现状：3 个指向自己的长路径，5 个指向别名，1 个（`feature-as-angelsea-llvm-jit-plugin`）指向**另一个** worktree 的长路径（`.worktrees\llvmjit\...`）—— 后者是独立问题，本次不处理，但值得记一笔。

## 词法归一化不解析别名

```
A = D:\as-cta\AngelscriptProject.uproject
B = D:\Workspace\AngelscriptProject\.worktrees\refactor-as-canonical-typed-ast-compiler\AngelscriptProject.uproject
[System.IO.Path]::GetFullPath 后字符串相等: False
内容哈希相同（同一文件）:            True
```

## 复现

```powershell
$wt = 'D:\Workspace\AngelscriptProject\.worktrees\refactor-as-canonical-typed-ast-compiler'
. "$wt\Tools\Shared\UnrealCommandUtils.ps1"
Resolve-AgentConfiguration -ProjectRoot $wt
Resolve-AgentConfiguration -ProjectRoot 'D:\as-cta'
```

```
从 .worktrees 长路径进入 → FAIL: AgentConfig.ini [Paths] ProjectFile does not belong to
                                 project root 'D:\Workspace\...\refactor-as-canonical-typed-ast-compiler'.
                                 Run Tools\Bootstrap\BootstrapWorktree.bat for this worktree.
从 D:\as-cta 进入        → OK   ProjectFile=D:\as-cta\AngelscriptProject.uproject
```

## 两种规范化手段对比

| 手段 | junction | subst | 结论 |
|---|---|---|---|
| `(Get-Item -Force).ResolveLinkTarget($true)` | 解析 | **返回 `$null`**；对裸根 `V:\` 抛 "Could not find a part of the path" | 只覆盖 5 个里的 2 个 |
| `GetFinalPathNameByHandle`（kernel32） | 解析 | 解析 | 全覆盖，且对已规范路径幂等 |

Win32 实测输出：

```
D:\as-cta                             -> D:\Workspace\AngelscriptProject\.worktrees\refactor-as-canonical-typed-ast-compiler
V:\                                   -> D:\Workspace\AngelscriptProject\.worktree\feature-as-typed-semantic-aot
V:\AngelscriptProject.uproject        -> D:\Workspace\...\.worktree\feature-as-typed-semantic-aot\AngelscriptProject.uproject
D:\as-cta\AngelscriptProject.uproject -> D:\Workspace\...\refactor-as-canonical-typed-ast-compiler\AngelscriptProject.uproject
<长路径>\AngelscriptProject.uproject   -> 原样返回
```

`subst` 是 DOS 设备映射而非 reparse point，这就是 `ResolveLinkTarget` 解不了它的原因。

## 为什么短路径是必须的

`refactor-as-canonical-typed-ast-compiler` 的 `attachments/worktree-max-path-build-failure.md` 记录了 2026-08-21：`ProjectFile` 用长路径时 UBT `Failed (OtherCompilationError)`，ProcessExitCode 6 / FinalExitCode 1，15.08 s，无任何 `cl.exe` / `error Cxxxx`。纯 MAX_PATH(260) 环境失败。

所以规范化只能用于相等判断，不能用于执行路径。

## 代码位置

| 位置 | 行 | 事实 |
|---|---|---|
| `Tools\Shared\UnrealCommandUtils.ps1` | 8 | `Normalize-PathValue` = `GetFullPath` + 分隔符/尾斜杠清理，纯词法 |
| 同上 | 932 | 候选来自 `Get-ChildItem $resolvedProjectRoot -Filter *.uproject` |
| 同上 | 940-941 | `-notcontains` 字符串比较后抛错 |
| 同上 | 1019-1024 | `-Project=` 取配置值 —— 所以执行路径本来就是短的 |
| `Tools\Bootstrap\powershell\BootstrapWorktree.ps1` | 102-114 | `Resolve-ProjectFileForBootstrap` 无条件从 `WorktreeRoot` 重算 |
| 同上 | 143 | `ProjectFile = $resolvedProjectFile` 直接赋值，**不**走 `Get-PreferredConfigValue`（而 `EngineRoot` 和所有 `Build` 键都走） |
| `Tools\Bootstrap\NewWorktree.ps1` | — | 无任何 junction / subst / 别名逻辑 |

最后一条是复发根因：`NewWorktree.ps1` 只造长路径，MAX_PATH 迫使手工建别名，工具链不知道别名存在，于是配置和入口永久错位。
