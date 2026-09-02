# 便携 OpenSpec 与 spec 体系重基线（2026-08-27）

> 本文是 `improve-openspec-task-guidance` 讨论附件。稳定的项目级架构边界见 `Documents/Guides/OpenSpecSystemRefactor.md`；若两者冲突，以该指南及后续专项 change 为准。

## 当前项目状态

AngelscriptProject 正处于全面重构阶段。现有 `openspec/specs/` 和活动 change 的内容来自不同阶段，存在粒度不一致、能力边界重叠、历史目标与当前实现混杂、以及“计划中的目标”看起来像“已经成立的事实”等问题。

因此，当前 spec 集合不能整体视为权威现状，也不应被 CLI、Web 或 Skill 无差别呈现为当前事实。后续工作必须先建立 spec 重基线和可信度分类，再扩展体系。

## 已确认的便携版方向

- `Tools/openspec` 是随项目分发的 Rust 便携版本；`Reference/OpenSpec-rs` 和 `Reference/openspec` 只作为移植与行为对照源。
- Rust 便携版有两个主要交付面：确定性的 change/spec 生命周期与验证内核，以及复用同一解析和校验模型的本地 Web 预览工具。
- Web V1 应优先只读、离线，提供 specs/changes 浏览、artifact graph、状态、校验诊断和 requirements/scenarios/tasks trace，不建立第二套数据模型或事实来源。
- OpenSpec Skill 不由 Rust CLI 生成、更新或覆盖。项目和用户独立维护、版本化并下发各自 Skill；AngelscriptProject 的本地 Skill 负责 AS 插件边界、测试层、验证入口、OpenSpec 记录习惯和重构期 spec 可信度规则。
- 如果保留 `init`，它只创建最小 `openspec/` 数据结构，不检测 Agent 工具，不写 `.agents/`、`.claude/` 或 `.cursor/`，也不接管用户提示词。
- 计划逐步移除对全局 Superpowers 安装的依赖；仍然有价值的方法（探索、TDD、系统化调试、完成前验证、计划质量等）应经过筛选后内化为项目 `.agents/skills/` 下的本地规则，而不是依赖缺失时会失效的外部 Skill 名称。
- spec 体系扩展应选择性吸收社区实践，例如项目 context/rules、可替换 schema、research/review/test-plan/retrospective 等扩展 artifact，以及 requirements-to-tasks trace；不整包复制社区 schema，也不让流程仪式取代工程判断。

## 当前实现与目标的已知断点

- `Tools/openspec/src/cli/init.rs` 的 `run_init` 接收 `_profile` 但当前不使用。
- `generate_skills_for_tools` 调用 `get_skill_templates(None)`，会为每个选中工具生成全部 workflow Skill；整个生成路径已经不属于新的默认产品职责。
- `init` 与 `update` 的生成路径和落盘形态尚未统一，也不符合“只管理 OpenSpec 数据、不覆盖用户 Skill”的目标边界。
- Rust 内核尚未提供供 Web 稳定消费的版本化查询/诊断契约，Web 预览本身也尚未实现。
- `.agents/skills/openspec-work/SKILL.md` 已包含大量 AngelscriptProject 专用约束，但方法层仍显式依赖全局 `superpowers:*`。
- 现有 `improve-openspec-task-guidance` 仍以“官方 config 注入 + 外部 Superpowers + 当前 spec 基线基本可用”为前提。实施其第 2–4 组之前，必须结合本记录重新审视范围；不得直接把旧设计固化到便携版。

## 重基线原则

1. **先分类，再迁移。** 为现有 specs/changes 区分当前权威、部分有效、未来目标、重叠冲突和纯历史记录。
2. **不把混乱写进展示或提示词。** Skill 只携带稳定的项目规则和检索方法；Web 必须明确区分生命周期与可信度；具体能力事实仍从经过重基线的 spec、代码和测试读取。
3. **Rust、Web 与项目内容分层。** Rust 负责解析、验证、生命周期和稳定数据契约；Web 只消费同一模型；项目/用户独立维护 Skill、提示词、schema 选择和工程规则。
4. **默认路径要小。** 日常用户只需要最小 change lifecycle、validate/archive 和预览能力；多工具、多 workflow、workspace/initiative/context-store 等能力不应挤进默认体验。
5. **扩展必须可追溯。** 每项社区扩展都要记录来源、吸收的具体机制、拒绝的部分和本项目中的验证方式。
6. **保留历史，不伪装权威。** 重基线通过标记、迁移或归档澄清状态，不直接删除仍有研究价值的历史。

## 本轮不做

- 不卸载全局 Superpowers。
- 不修改 Rust CLI、`init`、parser、validator 或 schema。
- 不实现 Web 前端、本地服务或静态导出。
- 不修改或重新发布项目 Skill。
- 不批量重写、归档或删除现有 specs/changes。
- 不把 `improve-openspec-task-guidance` 标成已完成或直接继续 apply。

## 下一组架构决策

1. Rust 最小命令集和旧生成命令的兼容/删除策略；
2. Web V1 采用 `openspec web` 本地服务还是 `openspec preview --export` 静态导出；
3. CLI 与 Web 之间采用共享 Rust 类型还是版本化 JSON schema；
4. artifact、requirement、scenario 和 task 的稳定标识与 trace 规则；
5. 现有 specs/changes 的重基线和冲突归档流程。

这些决策需要各自形成范围明确的 change，并以 Rust 测试、CLI 契约测试和 Web 数据夹具验证，不能仅靠本文直接进入实现。
