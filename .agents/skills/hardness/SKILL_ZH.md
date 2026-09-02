# Hardness（Harness 挂具）

版本: 0.2.0 (2026-09-02)

本 skill 是串联全项目 skill 的唯一总入口，做三件事：

1. **路由** —— 一张"任务类型 → 该读哪个 skill 文件"的分发表。
2. **循环协议** —— `Tools/RalphLoop` 无人值守循环每轮迭代的固定契约。
3. **反馈闭环** —— 使用过程中发现的 harness 问题记录到 `feedback/` 下；之后由开发者与 AI 在交互式会话中共同评估并更新 harness。Agent 永远不自行修改 harness。

其他 skill 或 prompt 引用本 skill 的标准写法："Read and follow `.agents/skills/hardness/SKILL.md`"。

## 路由表

做对应类型的工作前，先按路径读目标 SKILL.md。状态列反映当前 skill 重构进度；`待激活` 的 skill 在激活前不作为权威依据。

| 任务类型 | Skill 路径 | 状态 |
|---|---|---|
| OpenSpec CLI 原语 + 共享操作规则（Start/Update/Verify） | `.agents/skills/openspec/SKILL.md` —— CLI 调用统一走下方 `scripts/openspec.ps1` 包装 | 已激活 |
| 书写 / 组织 `openspec/` 下任何文件（change 树与 specs 树 schema） | `.agents/skills/openspec-schema/SKILL.md` | 已激活 |
| 为 change 创建下一个计划产物 | `.agents/skills/openspec-continue-change/SKILL.md` | 已激活 |
| 实施 change 的任务清单（实施纪律） | `.agents/skills/openspec-apply-change/SKILL.md` | 已激活 |
| 把 delta 规格并入当前规格 | `.agents/skills/openspec-sync-specs/SKILL.md` | 已激活 |
| 收尾并归档 change（收尾政策） | `.agents/skills/openspec-archive-change/SKILL.md` | 已激活 |
| 决策前的探索 / 调研 | `.agents/skills/openspec-explore/SKILL.md` | 已激活 |
| 接收代码评审反馈 | `.agents/skills/code-review/receiving-code-review/SKILL.md` | 已激活 |
| 完成前请求代码评审 | `.agents/skills/code-review/requesting-code-review/SKILL.md` | 已激活 |
| C++ 自动化测试（CQTest、内联 AS fixture） | `.agents/skills/angelscript-test-guide/SKILL.md` | 已激活 |
| 任何功能/修复的 TDD 纪律 | `.agents/skills/test-driven-development/SKILL.md` | 已激活 |
| Git worktree、分支、提交流程 | `.agents/skills/git-workflow/SKILL.md` | 已激活 |
| Hazelight 上游更新审计 | `.agents/skills/hazelight-update-audit/SKILL.md` | 已激活 |
| Unreal Engine 开发知识 | `.agents/skills/unreal-engine-develop/SKILL.md` | 已激活 |
| 讨论用可视化解释 / 图示 | `.agents/skills/visual-explain/SKILL.md` | 已激活 |
| 精致的独立图表（HTML/SVG） | `.agents/skills/external/archify/SKILL.md` | 已激活 |
| TiddlyWiki / WikiText 编辑 | `.agents/skills/external/tiddlywiki-wikitext/SKILL.md` | 已激活 |

已删除——若在历史记录或转录中出现，禁止遵循：`openspec-work`（由 openspec + 四个操作 skill + openspec-schema + openspec-explore 加本 harness 取代）、`openspec-Implementation` 与 `openspec-replan`（由 `openspec-apply-change` 取代）。

禁止直接使用 `npx @fission-ai/openspec`、全局安装的 openspec、或 `Tools/openspec` 的构建产物；所有 OpenSpec CLI 调用统一经 `scripts/openspec.ps1`。

## 循环迭代协议（无人值守）

RalphLoop 每轮迭代都是全新 agent、没有记忆。按顺序执行：

1. 完整读本 SKILL.md（路由表 + 下方规则）。
2. 定位循环 prompt 指定的任务源——通常是 `openspec/changes/<change>/tasks.md`，取第一个未勾选任务。
3. 查路由表，动代码前先读对应 skill 文件。
4. 只做该任务的最小完整步骤；涉及代码行为变化时应用 TDD。
5. 运行循环 prompt 给定的验证命令（或任务自带的 verify 说明）。没有通过的输出就不许声称成功。
6. 成功后在 `tasks.md` 勾选该任务，并以简洁的收尾消息结束：做了什么、验证了什么、下一步是什么。
7. 发现 harness 缺陷（路由错误、路径失效、协议不清、缺 skill）时，按 `feedback/README.md` 记录到 `feedback/open/`。先查重；有同类条目就追加佐证，不新开文件。
8. 收尾消息末行的停止信号：
   - `HARNESS_COMPLETE` —— 全部任务勾选且验证通过。
   - `HARNESS_BLOCKED: <原因>` —— 无人工输入无法继续（同时记录一条 feedback）。

## 保护文件（硬规则）

无人值守运行期间，agent 不得修改：

- `.agents/skills/hardness/SKILL.md`、`SKILL_ZH.md`
- `.agents/skills/hardness/feedback/README.md`
- `.agents/skills/hardness/scripts/`

本 skill 内唯一允许的写入是在 `feedback/open/` 下新增/追加条目。harness 的更新只发生在开发者在场的评审会话（见下）。包装层验证可以直接判定"改动触碰保护路径的迭代"为失败。

## 反馈评审（开发者 + AI，仅交互式）

1. 通读 `feedback/open/` 全部条目。
2. 逐条处理：采纳（更新路由表/协议/脚本，并递增顶部版本号）或拒绝（写明理由）。
3. 条目移入 `feedback/archived/` 并追加一行 `Verdict:` —— 被拒绝的也要归档，避免后续迭代重复提议。
4. 保持 `SKILL.md` 与 `SKILL_ZH.md` 同步。

## 脚本

**`scripts/openspec.ps1`** —— 项目本地 OpenSpec CLI（`.agents/skills/openspec/bin/openspec.exe`）的包装。任意工作目录可用；参数全量透传；保留退出码。

```powershell
# 打印解析出的 exe 绝对路径
.agents/skills/hardness/scripts/openspec.ps1 -GetPath
# 执行任意 openspec 命令
.agents/skills/hardness/scripts/openspec.ps1 validate "my-change" --strict
```
