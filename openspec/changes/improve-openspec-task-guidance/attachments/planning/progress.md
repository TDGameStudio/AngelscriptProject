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

## 2026-08-27 — 便携版与重构期重基线标记

- 确认 `Tools/openspec` 是随项目分发的 Rust 便携版本，其最终重点是生成/刷新一个携带项目定制规则的 OpenSpec Skill，而不是复刻官方多工具、多 workflow 安装体验。
- 标记 AngelscriptProject 正处于全面重构期；当前 spec 集合存在年代、粒度、重叠和事实/目标混杂，不能整体视为权威基线。
- 记录后续方向：简化 `init`，以项目 `.agents/skills/` 承载稳定方法，逐步移除全局 Superpowers 依赖，并选择性吸收社区扩展机制。
- 新增 `portable-openspec-rebaseline-2026-08-27.md`。本轮仅记录，不修改 Rust、Skill、schema 或现有 spec 内容。

## 2026-08-27 — 后续架构收缩（取代 Skill 生成方向）

- 前一检查点中“Rust 生成/刷新单一项目 Skill”的方向已被后续决定取代，不再作为目标产品契约。
- 新方向包含两个主要交付面：Rust change/spec 生命周期与验证内核，以及复用同一 Rust 模型的本地 Web 预览。
- 项目或用户独立版本化、下发和维护 OpenSpec Skill；Rust 不生成或覆盖 Skill，也不写入 Agent 配置目录。
- 如果保留 `init`，它只创建最小 `openspec/` 数据结构；Web V1 优先只读、离线，具体采用 localhost 服务还是静态导出留待专项 change。
- 新增稳定指南 `Documents/Guides/OpenSpecSystemRefactor.md`，并同步修订本附件。本轮仍只记录，不修改 Rust、Web、Skill、schema 或现有 spec 内容。
