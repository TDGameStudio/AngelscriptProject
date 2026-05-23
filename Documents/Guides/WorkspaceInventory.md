# 工作区 / Worktree / OpenSpec 盘点

> 最后更新：2026-05-24（分支全量清理后）  
> 用途：主 workspace 与 OpenSpec 变更、子模块分支的一页式对照表。  
> 维护：每次新建/删除 worktree 或归档 OpenSpec 变更后同步更新。

---

## 1. 主 Workspace（`D:/Workspace/AngelscriptProject`）

| 项 | 状态 |
|----|------|
| 分支 | **仅 `main`** @ `ae0bed5` |
| Worktree | **仅 main**（无额外 worktree） |
| 相对 origin | ahead 54（未 push） |
| 子模块 `Plugins/Angelscript` | `679704f` @ `main` |
| 子模块 `Plugins/UnrealEvent` | `caf1e9a` @ `main` |
| 子模块 `Plugins/AngelscriptGAS` | `2120a8f` @ `main` |

### 2026-05-24 分支 purge 摘要

**已删除**（四个仓库合计 27 个本地非 main 分支）：

| 仓库 | 删除数 | 说明 |
|------|--------|------|
| 父仓库 | 3 | `backup/*` x2、`openspec-test-coverage-pack-final` |
| Angelscript | 10 | 含 `rebase/*`、`test-as-native-sdk-coverage-plugin` 等 |
| UnrealEvent | 12 | 全部 stale worktree 分支 |
| AngelscriptGAS | 5 | 全部 stale worktree 分支 |

**保留**：各仓库 `remotes/origin/main`（远程跟踪，用于 push/pull）。

**Angelscript orphan review 结论**（删除前 review）：

| 主题 | main 是否已有 | 备注 |
|------|--------------|------|
| engine-owned hooks | 是 | `GetHooks()` 已在 `Bind_FString.cpp` 等 |
| clone-removal | 是 | `CreateCloneFrom` 已移除 |
| autoaccessor 移除 | 是 | 测试/源码无 autoaccessor 残留 |
| native SDK 扩展（~18 文件） | **否** | main 仅 6 个 SDK 测试文件；扩展在 tag `backup/pre-branch-purge-20260524` |
| StaticJIT diagnostics | **否** | 扩展在 tag `backup/pre-branch-purge-static-jit` |

删除前已在 Angelscript 子模块打 backup tag：

- `backup/pre-branch-purge-20260524` → 原 `rebase/native-sdk-onto-autoaccessor` tip（`0fa6d02`）
- `backup/pre-branch-purge-native-sdk` → 原 `test-as-native-sdk-coverage-plugin` tip
- `backup/pre-branch-purge-static-jit` → 原 `improve-static-jit-diagnostics` tip

### 2026-05-24 worktree 清理摘要（早前）

| 来源 | 合入内容 |
|------|----------|
| `openspec-test-coverage-pack-v2` | Bindings/Functional 测试、`Bind_FString.cpp`、Memory/GC 测试、Test 文档 |
| `improve-as-direct-bind-coverage-fix` | Syntax/StaticJIT 测试增量 |
| `refactor-unrealevent-gmp-runtime-layout` | UnrealEvent GMP runtime 文件大规模 prune |

**Patch 备份**：`Saved/Patches/worktree-cleanup-20260524/`（本地，不提交）

### Deferred（可后续慢慢修）

- 从 backup tag 恢复 native SDK 扩展 + StaticJIT diagnostics 到 main（当前 main 子模块缺这两块）
- v2 WIP 基于 `0fa6d02` 合入到 `24d1572` 之上；构建/测试验证待做
- `refactor-as-engine-clone-removal` OpenSpec tasks 仍 0/42，但子模块 clone-removal 已实现 → 需核对 tasks 后归档

---

## 2. Git Worktree 与分支

| 项 | 状态 |
|----|------|
| Worktree | 仅 `D:/Workspace/AngelscriptProject` → `main` |
| 父仓库本地分支 | 仅 `main` |
| 子模块本地分支 | 各仅 `main` |
| `.worktrees/` | 不存在 |

---

## 3. OpenSpec 活跃变更（`openspec/changes/`，不含 archive）

### 3.1 进行中

| 变更 | tasks | 说明 |
|------|-------|------|
| `test-bindings-gap-closure` | 0/4 | Bindings 测试覆盖（WIP 已合入 main 子模块，tasks 待勾选） |
| `test-functional-runtime-coverage` | 0/5 | Functional 主题 placeholder → 可执行断言 |
| `test-editor-and-runtime-diagnostics-coverage` | 0/8 | Editor/Runtime 诊断覆盖 |
| `refactor-unrealevent-prune-gmp-editor-modules` | 2/10 | UnrealEvent editor 模块 prune |

### 3.2 待核对/归档

| 变更 | 说明 |
|------|------|
| `refactor-as-engine-clone-removal` | 子模块已实现，tasks 文档 stale |

### 3.3 Proposal-only（排队中）

1. `refactor-as-gameplaytags-optional-plugin`
2. `refactor-as-audit-remove-with-angelscript-haze`
3. `improve-as-direct-bind-coverage`
4. `refactor-as-bind-eliminate-previously-bound-function`
5. `refactor-debugger-protocol-v2`
6. 其余：`refactor-code-coverage-data-export`、`refactor-angelscript-test-helper-api`、`refactor-as-library-full-namespaces`、`feature-commandflow-plugin`、`docs-wiki-repository-publishing-plan`

### 3.4 近期已归档（2026-05-23）

- `improve-static-jit-diagnostics`
- `refactor-as-engine-owned-hooks`
- `refactor-as-engine-extension-hooks`

---

## 4. 推荐开发入口

直接在 **main workspace** 继续 OpenSpec 变更。需要隔离时：

```powershell
git worktree add .worktrees/<change-name> -b <branch-name>
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\Bootstrap\powershell\BootstrapWorktree.ps1 -EngineRoot "<EngineRoot>" -NoPrewarm
```

详见 [`SubmoduleWorktreeWorkflow.md`](SubmoduleWorktreeWorkflow.md)。
