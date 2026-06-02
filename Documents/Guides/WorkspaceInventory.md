# 工作区 / Worktree / OpenSpec 盘点

> 最后更新：2026-06-02（子模块清理后）
> 用途：主 workspace 与 OpenSpec 变更、子模块分支的一页式对照表。

---

## 1. 主 Workspace（`D:/Workspace/AngelscriptProject`）

| 项 | 状态 |
|----|------|
| 分支 | **仅 `main`** @ `6d0b187` |
| Worktree | **仅 main**（无额外 worktree） |
| Tag | **无** |
| 工作区 | **干净**（无未提交改动） |
| 相对 origin | ahead 55（未 push） |
| 子模块 `Plugins/Angelscript` | `679704f` @ `main` |
| 子模块 `Plugins/AngelscriptGAS` | `2120a8f` @ `main` |

### 2026-05-24 完全清理

- 删除 Superpowers 外部 worktree（`openspec-test-coverage-pack-v3`）及对应分支
- 删除父仓库 + Angelscript 子模块全部 `backup/*` tag（13 个）
- 四个仓库均仅保留 `main` + `remotes/origin/main`
- 无 `.worktrees/` 目录

### Deferred

- Angelscript main 可能缺 native SDK 扩展 + StaticJIT diagnostics（原在已删 backup tag 上）；需从 reflog 或重新实现恢复
- `refactor-as-engine-clone-removal` OpenSpec tasks 待核对归档
- 构建/测试验证待做

---

## 2. Git 结构

```
父仓库 main
├── Plugins/Angelscript  main @ 679704f
└── Plugins/AngelscriptGAS  main @ 2120a8f
```

---

## 3. OpenSpec 活跃变更

进行中：`test-bindings-gap-closure`、`test-functional-runtime-coverage`、`test-editor-and-runtime-diagnostics-coverage`

待核对：`refactor-as-engine-clone-removal`

Proposal-only：见 `openspec/changes/`（15 个活跃变更）

已归档（2026-05-23）：`improve-static-jit-diagnostics`、`refactor-as-engine-owned-hooks`、`refactor-as-engine-extension-hooks`

---

## 4. 开发入口

直接在 **main workspace** 开发。需要隔离时：

```powershell
git worktree add .worktrees/<change-name> -b <branch-name>
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\Bootstrap\powershell\BootstrapWorktree.ps1 -EngineRoot "<EngineRoot>" -NoPrewarm
```

详见 [`SubmoduleWorktreeWorkflow.md`](SubmoduleWorktreeWorkflow.md)。
