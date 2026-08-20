# Issue ledger — improve-openspec-task-guidance

规划阶段问题账本。实施问题写 `../implementation/issues.md`。`tasks.md` 只勾完成。

## Status model

`Observed` | `Confirmed` | `Designing` | `Implementing` | `Verified` | `Deferred`

## OSPEC-TASK-001: feature/fix 的 tasks 经常短到无法执行

- Status: Confirmed
- Scope: `.agents/skills/openspec-work/SKILL.md`；官方 `spec-driven` tasks instruction；无 `openspec/config.yaml`
- Evidence: `chore-as-remove-ue-plusplus-markers/tasks.md` 口号式四条；`feature-as-cross-host-language-service/tasks.md` 才有路径和 TDD。skill 写明 record-and-implement **start lean**。官方 tasks 模板不要求路径/追溯/验证命令。
- Decision: 不迁 Spec Kit。偷其硬规则；feature/fix/refactor/improve/test 默认写满；chore/docs 可瘦但必须有路径。注入口是 `config.yaml` + 改 skill，两处不能互相拆台。
- Implementation: 合同在 `specs/openspec-task-guidance/spec.md`。skill / config 未改（tasks 组 2）。
- Verification: not run
- Next: apply 组 2

## OSPEC-TASK-002: 官方 explore 被并进同一入口后失去“只读对话”约束

- Status: Confirmed
- Scope: `openspec-work`；官方 `/opsx:explore`
- Evidence: 官方 explore 不建 change、不写制品。本仓库同一 skill 允许边记边做。详见 `explore.md`。
- Decision: 需求不清的行为变更，默认先 explore 再 propose；不要和 start-lean 混成一条路。
- Implementation: 仅附件。skill 未改。
- Verification: not run
- Next: 改 skill 时把 explore 从 start-lean 里拆出来

## OSPEC-TASK-003: 把 Spec Kit 说明写进 README/AGENTS

- Status: Verified
- Scope: `Reference/README.md`、`AGENTS.md`、`AGENTS_ZH.md`（已还原）
- Evidence: 用户只要求克隆到 `Reference/`。agent 额外改了三份索引。用户明确：相关说明只进本 OpenSpec。三份文件已 `git checkout --` 还原。
- Decision: Spec Kit 目录、SHA、读哪些文件只记 `speckit-local-copy.md`。`Reference/` 在 gitignore，克隆不进提交。
- Implementation: 还原完成。克隆仍在 `Reference\spec-kit` @ `7eee05d0ed95d2984947b30a1fc25f0e23627880`。
- Verification: `git status` 上上述三文件无改动
- Next: 不要再为这个克隆改仓库级索引

## OSPEC-TASK-004: 本仓库没有 `openspec/config.yaml`

- Status: Confirmed
- Scope: `openspec/`
- Evidence: 2026-08-19 检查无此文件。测试约定和 start-lean 只活在 skill / AGENTS。
- Decision: 组 2 再加。本轮不落盘。
- Implementation: not started
- Verification: not run
- Next: tasks 2.1

## TOOL-001: 在错误工作目录跑 `openspec list`

- Status: Verified
- Scope: agent 会话，不在产品代码
- Evidence: 第一次 `openspec list --json` 在 `C:\Users\scottmei`，报 No OpenSpec changes directory。仓库在 `D:\Workspace\AngelscriptProject`。
- Decision: 以后先 `Set-Location` 到项目根。
- Implementation: 后续命令已在正确根目录执行。
- Verification: `openspec new change improve-openspec-task-guidance` 成功
- Next: 无

## OSPEC-TASK-005: task 挤成一行，缺 Files / Impact / Tests

- Status: Confirmed
- Scope: 本仓库多数 `tasks.md`；本 change 组 1 也曾一行写完
- Evidence: 用户要求每条 task 多行：改哪些文件、影响面、做完要不要测。OpenSpec 仍只解析 `- [ ]`，正文必须缩进在 checkbox 下。
- Decision: 模板见 `../implementation/task-body-template.md`。组 2 起按此写。
- Implementation: spec `Executable task line` 已改；`tasks.md` 组 2+ 已改成多行
- Verification: not run
- Next: skill/config 落地后按模板生成新 change
