# Spec Kit 本地副本

用户要求把 GitHub Spec Kit 拉进 AngelscriptProject 的 `Reference/`，作为离线对照。**目录说明只记在本 change，不改 `Reference/README.md` / `AGENTS.md` / `AGENTS_ZH.md`。**

`Reference/` 被 `.gitignore` 忽略，克隆不会进 git。

## 位置与来源

| 项 | 值 |
|---|---|
| 本地路径 | `D:\Workspace\AngelscriptProject\Reference\spec-kit` |
| SSH | `git@github.com:github/spec-kit.git` |
| HTTPS | `https://github.com/github/spec-kit.git` |
| 克隆方式 | `git clone --depth 1 --recurse-submodules git@github.com:github/spec-kit.git Reference\spec-kit` |
| 分支 | `main` 浅克隆 |
| 拉取日期 | 2026-08-19 |
| SHA | `7eee05d0ed95d2984947b30a1fc25f0e23627880` |
| 上游说明 | `chore: release 0.16.5, begin 0.16.6.dev0 development (#4206)` |
| 许可证 | MIT |

更新（需要时，在该目录执行）：

```powershell
git -C D:\Workspace\AngelscriptProject\Reference\spec-kit fetch --depth 1 origin main
git -C D:\Workspace\AngelscriptProject\Reference\spec-kit reset --hard origin/main
```

更新后把新 SHA 写回本文件。

## 规范化 task 时要读的文件

| 本地文件 | 用途 |
|---|---|
| `Reference\spec-kit\templates\tasks-template.md` | `tasks.md` 骨架、phase、Independent Test |
| `Reference\spec-kit\templates\commands\tasks.md` | `/speckit.tasks` 强制格式 |
| `Reference\spec-kit\templates\commands\implement.md` | 怎么按 phase 执行、失败即停 |
| `Reference\spec-kit\templates\spec-template.md` | 需求模板对照 |
| `Reference\spec-kit\templates\plan-template.md` | 计划模板对照 |
| `Reference\spec-kit\templates\constitution-template.md` | 项目原则；本仓库对应物是将来的 `openspec/config.yaml` context |
| `Reference\spec-kit\README.md` | 总览 |
| `Reference\spec-kit\README.zh-CN.md` | 中文总览 |
| `Reference\spec-kit\spec-driven.md` | 方法论 |

规则摘录见同目录 `speckit-task-requirements.md`。

## 对本仓库的边界

- 只当研究副本。不是运行时、构建或发布依赖。
- 不引入 `.specify/`，不把 Spec Kit 和 OpenSpec 两套命令并行塞进 agent。
- 偷 task 硬规则（路径、分组、独立验收、并行定义、生成后自检）；不偷 `T001` 编号、不偷“测试默认不生成”、不迁 `specs/00N-feature/` 目录模型。
