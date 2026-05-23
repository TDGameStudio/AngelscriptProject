# 工作区 / Worktree / OpenSpec 盘点

> 最后更新：2026-05-24  
> 用途：主 workspace 与 worktree、OpenSpec 变更、子模块分支的一页式对照表。  
> 维护：每次新建/删除 worktree 或归档 OpenSpec 变更后同步更新。

---

## 1. 主 Workspace（`D:/Workspace/AngelscriptProject`）

| 项 | 状态 |
|----|------|
| 分支 | `main` @ `e784859` |
| 相对 origin | **ahead 51**（大量本地提交未 push） |
| 子模块 `Plugins/Angelscript` | `24d1572`（clone-removal 已完成，**未提交到 main gitlink**） |
| 子模块 `Plugins/AngelscriptGAS` | 指向 `improve-as-direct-bind-coverage-fix` 分支 |
| 子模块 `Plugins/UnrealEvent` | 指向 `improve-as-direct-bind-coverage-fix` 分支 |

### 主 workspace 未提交改动（⚠️ 与 test-coverage worktree 重叠）

| 文件 | 说明 |
|------|------|
| `Documents/Guides/Test*.md` | 测试目录文档更新 |
| `Tools/RunTestSuite.ps1` | 测试套件 runner 增强 |
| `Tools/Diagnostics/.../Test-AutomationEntryPoints.ps1` | 自动化入口诊断 |
| `Config/DefaultEngine.ini` | 引擎配置微调 |
| `Plugins/Angelscript` gitlink | 指向 clone-removal 子模块提交 |
| `openspec/changes/test-*`（3 个） | 新建、尚未 `git add` |

**建议**：主 workspace 应保持干净；上述 WIP 应归入 **`.worktrees/openspec-test-coverage-pack-v2`** 对应分支提交，避免 main 与 worktree 双份脏状态。

---

## 2. Git Worktree 一览

| Worktree 路径 | 分支 | OpenSpec 对应 | 状态 | 建议 |
|---------------|------|---------------|------|------|
| **（主目录）** | `main` | 多个已完成 + 在途 proposal | 脏 | 清理 WIP，只保留已合并内容 |
| `.worktrees/openspec-test-coverage-pack-v2` | `openspec-test-coverage-pack-v2-root` | `test-bindings-gap-closure` + `test-functional-runtime-coverage` + `test-editor-and-runtime-diagnostics-coverage` | **活跃**：子模块 `openspec-test-coverage-pack-v2-plugin` 有大量 Bind/Functional 测试改动 | **保留**（唯一 test-coverage 工作区） |
| `.worktrees/test-bindings-gap-closure` | `test-bindings-gap-closure` | `test-bindings-gap-closure` | 与 v2 重复，仅子模块 M | **删除**（合并到 v2 后） |
| `.worktrees/openspec-test-coverage-pack` | `openspec-test-coverage-pack-root` | 同上 v1 | 与 v2 重复 | **删除** |
| `.worktrees/openspec-test-coverage-pack-v3` | `openspec-test-coverage-pack-v3-root` | 同上 v3 | 与 v2 重复，无额外提交 | **删除** |
| `.worktrees/improve-as-direct-bind-coverage-fix` | `improve-as-direct-bind-coverage-fix` | `improve-as-direct-bind-coverage` | 仅子模块 M，无父仓库提交 | 继续用或删除（proposal-only） |
| `.worktrees/refactor-as-gameplaytags-optional-plugin` | `refactor-as-gameplaytags-optional-plugin-root` @ `545a3f9` | `refactor-as-gameplaytags-optional-plugin` | **损坏**：子模块 git 路径失效 | **删除并重建**（rebase 到 `main`） |
| `.worktrees/refactor-unrealevent-gmp-runtime-layout` | `refactor-unrealevent-gmp-runtime-layout` @ `d739b6c` | 已归档的 UnrealEvent 布局变更 | 过时，有本地 openspec 副本 | **删除**（工作已完成并归档） |

### 无 worktree 的本地分支

| 分支 | 说明 |
|------|------|
| `improve-static-jit-diagnostics-root` | 陈旧，指向旧提交 → **可删** |
| `refactor-unrealevent-remove-xconsole` | 已归档 → **可删** |
| `backup/*` | 备份分支，保留或按需清理 |

---

## 3. OpenSpec 活跃变更（`openspec/changes/`，不含 archive）

### 3.1 应归档（实现已在 main / 子模块，tasks 已勾选）

| 变更 | tasks | main 证据 | 动作 |
|------|-------|-----------|------|
| `improve-static-jit-diagnostics` | 7/7 ✓ | HEAD `e784859` | **已归档** |
| `refactor-as-engine-owned-hooks` | 15/15 ✓ | `7e6e8b5` | **已归档** |
| `refactor-as-engine-extension-hooks` | 4/4 ✓ | `e552315` | **已归档** |
| `refactor-as-engine-clone-removal` | 0/42（**文档 stale**） | 子模块 `24d1572`，`CreateCloneFrom` 已移除 | **核对 tasks → 勾选 → 归档** |

### 3.2 进行中

| 变更 | tasks | worktree | 说明 |
|------|-------|----------|------|
| `test-bindings-gap-closure` | 0/4 | v2（推荐） | Bindings 测试 + `Bind_FString` fix |
| `test-functional-runtime-coverage` | 0/5 | v2 | Functional 主题 placeholder → 可执行断言 |
| `test-editor-and-runtime-diagnostics-coverage` | 0/8 | v2 | Editor/Runtime 诊断覆盖 |
| `refactor-unrealevent-prune-gmp-editor-modules` | 2/10 | 无 | UnrealEvent editor 模块 prune |

### 3.3 Proposal-only（排队中，0% tasks）

按依赖/优先级建议顺序：

1. `refactor-as-gameplaytags-optional-plugin` — 引擎链下一环（clone/hooks/extension 已完成）
2. `refactor-as-audit-remove-with-angelscript-haze` — autoaccessor 已移除，可启动
3. `improve-as-direct-bind-coverage` — UHT/direct bind 覆盖
4. `refactor-as-bind-eliminate-previously-bound-function` — 绑定层清理
5. `refactor-debugger-protocol-v2` — 需复核：DebugServer V2 已落地，可能是 V1 移除/测试迁移
6. 其余：`refactor-code-coverage-data-export`、`refactor-angelscript-test-helper-api`、`refactor-as-library-full-namespaces`、`feature-commandflow-plugin`、`docs-wiki-repository-publishing-plan`

### 3.4 变更集群（避免并行改同一文件）

```
test-coverage-pack ─┬─ test-bindings-gap-closure
                    ├─ test-functional-runtime-coverage
                    └─ test-editor-and-runtime-diagnostics-coverage
                    → 单一 worktree（v2）执行

engine-architecture ─ refactor-as-engine-clone-removal ✓
                    → refactor-as-engine-owned-hooks ✓
                    → refactor-as-engine-extension-hooks ✓
                    → refactor-as-gameplaytags-optional-plugin（下一）

binding-layer ─ improve-as-direct-bind-coverage
              ↔ refactor-as-bind-eliminate-previously-bound-function
              ↔ test-bindings-gap-closure
              → 分阶段，不要并行改 Bind_*.cpp
```

---

## 4. 推荐清理命令（确认后执行）

```powershell
# 从主 workspace 根目录

# A. 删除重复/过时 worktree（先确认 v2 已保存所有 WIP）
git worktree remove .worktrees/openspec-test-coverage-pack --force
git worktree remove .worktrees/openspec-test-coverage-pack-v3 --force
git worktree remove .worktrees/test-bindings-gap-closure --force
git worktree remove .worktrees/refactor-unrealevent-gmp-runtime-layout --force
git worktree remove .worktrees/refactor-as-gameplaytags-optional-plugin --force

# B. 删除陈旧本地分支
git branch -D improve-static-jit-diagnostics-root
git branch -D openspec-test-coverage-pack-root
git branch -D openspec-test-coverage-pack-v3-root
git branch -D test-bindings-gap-closure

# C. 主 workspace 恢复干净（⚠️ 先 stash 或确认 WIP 已在 v2）
git stash push -m "main-wip-move-to-v2" -- Documents Tools Config .gitignore
git submodule update --init Plugins/Angelscript  # 恢复到 main 记录的 gitlink

# D. clone-removal 归档（tasks 核对后）
# openspec archive "refactor-as-engine-clone-removal" -y
```

---

## 5. 当前唯一推荐开发入口

**Test coverage 三连变更** → 使用：

```
.worktrees/openspec-test-coverage-pack-v2/
  父分支: openspec-test-coverage-pack-v2-root
  子模块: openspec-test-coverage-pack-v2-plugin
```

完成并合并后，删除 pack v1/v3 及 `test-bindings-gap-closure` 独立 worktree，归档三个 `test-*` OpenSpec 变更。
