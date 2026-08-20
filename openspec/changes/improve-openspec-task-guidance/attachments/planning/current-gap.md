# 本仓库当前 task 指引的缺口

对照 Spec Kit 官方规则和 2026-08-19 讨论。

## 官方 OpenSpec 默认对 tasks 要求极少

内置 `spec-driven` 的 tasks instruction 只要求：

- 用 `##` 分组
- checkbox 写成 `- [ ] X.Y ...`（apply 靠这个解析）
- 小到一次 session 能做完
- 按依赖排序
- 做完能判断完成

默认模板几乎是空骨架。**不要求**文件路径、对应哪条 requirement、验证命令、TDD 顺序、并行标记、独立验收标准。

## `openspec-work` 实际写了什么

会写的：

- `<!-- TDD -->` / `<!-- Non-TDD -->`
- plan-only 时要求达到 Superpowers `writing-plans` 质量（文件地图、咬一口的任务、精确验证命令）
- 测试层选择、`Angelscript` 前缀、只走 `Tools\RunBuild.ps1` / `RunTests.ps1` / `RunTestSuite.ps1`
- `tasks.md` 保持干净 checklist，笔记另存

同时又写：

- OpenSpec 是记录不是门禁
- record-and-implement **start lean**
- plan 可随时扔掉
- 没有阶段墙

结果：plan-only 理论很厚，日常“边记边做”走瘦路径，瘦路径赢。

## 和 Spec Kit 的差距表

| Spec Kit 硬规则 | 本仓库现在 | 差距 |
|---|---|---|
| 每条必须带精确路径 | 好的 change 有，默认不强制 | 生成器经常省略 |
| 按可独立交付的故事分组 + Independent Test | 按主题/层级分组，常无独立验收句 | 大 change 无法中途停 |
| Foundational 阻塞后续 | 无此阶段概念 | 实现和基建缠在一起 |
| `[P]` 并行有精确定义 | 无 | apply 一次吞整张清单 |
| 任务追溯到 US | 好的 change 能对上 spec，无强制 | 会出现对不上 requirement 的任务 |
| 测试任务先于实现（若纳入） | 有 TDD 标记，但不保证排序 | 常先写实现再补测试 |
| 生成后格式自检报告 | 无 | 短任务直接进入 apply |
| implement 按 phase，失败则停 | apply 无组边界 | #539 同类问题 |
| constitution 注入每次生成 | 无 `config.yaml` | 测试约定只活在 skill 里 |

## 仓库内正反例

厚、可执行：`openspec/changes/feature-as-cross-host-language-service/tasks.md`  
薄、只记账：`openspec/changes/chore-as-remove-ue-plusplus-markers/tasks.md`

规范化后不应消灭第二种（chore/docs 允许瘦），但 feature/fix/refactor 的默认值应接近第一种，并补上 Spec Kit 的路径 / 追溯 / 独立验收 / 组边界。
