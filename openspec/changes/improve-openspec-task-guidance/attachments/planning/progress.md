# Implementation progress — improve-openspec-task-guidance

按日期追加。勾选仍只在 `tasks.md`。

## 2026-08-19 — 记录轮（组 1）

- 创建 change `improve-openspec-task-guidance`（`openspec new change`，schema `spec-driven`）。
- 写入 proposal / design / specs / tasks，以及讨论、Spec Kit 规则、缺口、自定义、explore、提示词附件。
- 按用户要求浅克隆 Spec Kit 到 `Reference\spec-kit`（`7eee05d` / 0.16.5）。`Reference/` gitignore。
- 误改 `Reference/README.md`、`AGENTS.md`、`AGENTS_ZH.md`；用户制止后已还原。说明在 `speckit-local-copy.md`。见 `issues.md` OSPEC-TASK-003、TOOL-001。
- 附录拆成 `planning/`（讨论，实现默认不读）和 `implementation/`（apply 工作集）。实施中途改 OpenSpec 记 `../implementation/openspec-refactors.md`。
- 用户要求每条 task 多行：Files / Impact / Tests。组 2 起按 `../implementation/task-body-template.md`。
- 2026-08-20：补 `speckit-rules.md`，按 constitution → specify → clarify → plan → tasks → analyze → implement 梳理官方规则。
- **未做：** 不改 `openspec-work`，不加 `config.yaml`，不迁 Spec Kit。
