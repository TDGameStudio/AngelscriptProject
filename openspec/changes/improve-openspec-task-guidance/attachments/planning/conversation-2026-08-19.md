# 2026-08-19 讨论记录

本附件记录用户在 Grok 会话中提出的问题和当时的结论。实现尚未开始；本 change 先记账。

## 用户提出的问题

1. 用 OpenSpec 时记录偏少、`tasks.md` 安排不合理。网上大家怎么安排？有没有改进或提示词？
2. 网上具体怎么说？
3. 官方 customization 里的社区 schema 是什么？怎么自定义规则？Spec Kit 怎么样？我们其实只用 OpenSpec 记账，写法和落实是自己规范，而且失败了。`/opsx:explore` 是干什么的，为什么有人评价很高？
4. 把上述讨论记进本仓库一个新的 OpenSpec change 附件。
5. 先看 Spec Kit 对 task 有什么要求，准备规范化自己的 task 规则。
6. 把 Spec Kit 拉到本仓库 `Reference/`。
7. 不要改 `Reference/README.md` / `AGENTS.md` / `AGENTS_ZH.md`；相关说明全部记进本 OpenSpec change。
8. 对照工作区里已完成和进行中的 OpenSpec，补齐附件种类。
9. 执行过程中碰到的问题要能渐进记录；已完成的 change 里已经有这种做法。
10. 每条 task 要多行：改哪些文件、影响面、做完要不要测。
11. 讨论过程要记，实现时默认不看讨论附录，卡住再看，省 token。
12. 实现过程中可能随时重构 OpenSpec，也要记。

## 当时对仓库现状的判断

- 仓库已有大量 `openspec/changes/` 和 `openspec/specs/`，也有自定义 skill `.agents/skills/openspec-work/SKILL.md`。
- **没有** `openspec/config.yaml`。官方最推荐的规则注入口没用上。
- `openspec-work` 把官方 explore / propose / apply / archive 合成一个入口，并写明：
  - OpenSpec = 轻量记录，不是门禁
  - record-and-implement 时 **start lean**（先只写 `proposal.md` + `tasks.md`）
  - 落实方法交给 Superpowers，但 Superpowers 只有 agent 主动去读才会生效
- 同一仓库里厚度两极：`feature-as-cross-host-language-service` 的 tasks 带路径、fixture、TDD 标记；`chore-as-remove-ue-plusplus-markers` 只有几条口号式任务。
- 因此“记录少、任务短”不只是官方默认模板薄，也是本仓库 skill **授权变瘦**。

## 社区对 OpenSpec 的态度（摘要）

- **薄是产品选择。** 相对 Spec Kit，OpenSpec 故意少写。Reddit / Hashrocket：OpenSpec 约 250 行 vs Spec Kit 约 800 行；资深小团队喜欢轻，要手把手选 Spec Kit。
- **薄的代价。** SINAPTIA（Rails，生产 4 个月）：直接 propose 模糊需求时，LLM 会按自己的品味填坑。必须先 explore、生成后必须读计划。他们同时认为 `tasks.md` **就该是 checkbox，不要塞实现细节**——这和“任务太短没法执行”是同一根绳的两端。
- **任务粒度两边都有人骂。** 官方红旗是一条巨型 `implement the feature`。火山引擎中文实战则嫌默认拆太碎（ThemeContext 拆成 1.1/1.2/1.3），主张合并。GitHub #539：大 change 一次 apply 会吞整张清单。#708 求 apply-one。#1478 认为 bug 不必走满四件套。
- **没有万能提示词。** 网上落地的是改 `config.yaml` / 自定义 schema / 先 explore / 用一两句把粒度拧回去。

## 社区 schema 与自定义（摘要）

官方三层：`config.yaml`（context + 按制品 rules + apply/archive guidance）→ 项目 `openspec/schemas/` → 用户级 schema。

官方 customization 收录的社区 schema：

| Schema | 要点 | 对本仓库 |
|---|---|---|
| intent-driven | Gherkin 行为 + 长期 ADR | 可能和已有 design/research 重复 |
| superpowers-bridge | OpenSpec 管记录，Superpowers 管执行；多 `plan.md` / verify / retrospective | 最接近本仓库意图，但比当前“合并 skill、放松仪式”硬得多 |
| nanopm | 产品审计 / PRD 上游 | 不太适用 |
| e2e-runbooks | 按 capability 记 e2e 跑法 | 验收模型对不上 |
| anvil | 对抗 review + test-plan 映射 scenario | 对 TDD 有用，全量会重 |

另有 minimalist（specs+tasks）、behaviour-driven、event-driven。

社区 schema **只改产出哪些文件和 instruction**，不自动保证写得好。`openspec validate` 不检查 task 是否带路径。

## Spec Kit 结论（当时）

- 不迁账本。本仓库已是 OpenSpec delta + archive 模型；Spec Kit 是 `specs/<编号功能>/` 阶段门，没有一等公民 delta。
- 失败点是“自己的写法/落实规范没接到注入口”，不是缺另一套工具。
- 值得偷的是 constitution ≈ `config.yaml`、clarify ≈ explore、analyze ≈ verify，以及 **`/speckit.tasks` 的硬格式**（见 `speckit-task-requirements.md`）。

## Explore 结论（当时）

官方 `/opsx:explore` 是 **thinking partner，不是生成器**：读代码、比方案、画图、磨范围；不建 change、不写制品、不改代码。有人评价高，是因为它卡在模型最爱“自信填坑”的点上，比各家 Plan Mode 更会先查再问，并且允许白探索。

本仓库把官方 explore 并进 `openspec-work`，改成五种用法之一，同一入口还可以“边记边做 / start lean”。网上吹的那个开关，和仓库里叫 explore 的东西不是同一个。

## 当时建议的最小改法（尚未实施）

1. 加 `openspec/config.yaml`，把测试入口、命名、以及 “task 必须带路径和验证命令” 写成 `rules.tasks`。
2. 改 `openspec-work`：只有 chore/docs 允许瘦；feature/fix/refactor 默认先 explore，再按 Superpowers `writing-plans` 厚度记。
3. 不要让所有 change 走同一套仪式。
4. 大 change 先拆或先 explore，不要一次 apply 整张清单。

## 本 change 本轮范围

只记录。不改 skill、不加 `config.yaml`、不迁移 Spec Kit、不重写既有 active change。不改 `Reference/README.md`、`AGENTS.md`、`AGENTS_ZH.md`。

Spec Kit 源码在 `Reference\spec-kit`（gitignore，见 `speckit-local-copy.md`）。讨论附录在 `attachments/planning/`；实现只读 `attachments/implementation/`。路由见 `../INDEX.md`。
