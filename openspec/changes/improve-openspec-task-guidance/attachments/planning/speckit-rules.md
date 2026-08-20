# Spec Kit 规则梳理

来源：`Reference\spec-kit` @ `7eee05d`（0.16.5）。实现会话默认不读本文件。

```text
constitution  →  specify  →  clarify  →  plan  →  tasks  →  analyze  →  implement
     项目宪法        what          最多5问        how       清单        只读对账       按清单做
```

可选：`checklist`（给人审需求质量）、`converge`、`taskstoissues`。

---

## 横切（所有命令共用）

1. **Constitution 最高权威。** 和宪法冲突一律 CRITICAL，改 spec/plan/tasks，不准稀释原则。改原则只能另跑 constitution。
2. **阶段有前置。** specify 产出 spec；plan 要有 spec + constitution；tasks 要有 plan+spec；analyze/implement 要有完整 tasks。
3. **NEEDS CLARIFICATION 最多 3 条**（specify）。优先级：范围 > 安全/隐私 > UX > 技术细节。其余自己猜，写进 Assumptions。
4. **Clarify 最多 5 个高价值问题**，答案写回 spec，建议在 plan 之前跑完。
5. **Spec 禁止实现细节**（语言、框架、API）。Success Criteria 必须可测且技术无关。
6. **Analyze 只读**，不改文件。
7. **Checklist `[x]` ≠ 实现完成**，只表示需求质量过关。implement 见未勾项要停下来问人，且不得改勾选。
8. 各命令可有 `hooks.before_*` / `hooks.after_*`。

---

## Constitution

- 只改 `.specify/memory/constitution.md`，不改业务代码。
- 原则必须陈述清楚、可检验；少用模糊 should。
- Governance：怎么修订、怎么版本、怎么审查。
- 版本：MAJOR 删改原则；MINOR 加原则；PATCH 措辞。
- 日期 ISO `YYYY-MM-DD`。顶部 HTML 注释写 Sync Impact Report。

示例原则槽位：Library-First、CLI、Test-First（NON-NEGOTIABLE）、Integration Testing、Observability / Versioning / Simplicity。

---

## Specify（what）

一次命令只建一个功能目录：`specs/<NNN|-timestamp>-<short-name>/spec.md`。

**强制章节：** User Scenarios & Testing、Requirements、Success Criteria。

用户故事规则：

- P1 / P2 / P3，按重要性
- 每个故事独立可测、可当 MVP 切片
- 必须有 Why this priority、Independent Test、Given/When/Then
- 没有用户流 → ERROR

功能需求：`FR-001` 起，每条可测。数据实体不写实现。

成功标准：`SC-001` 起，可测、技术无关、可验证。

写完自检 `checklists/requirements.md`：无实现细节、无残留澄清标记、场景和边界在、范围有边界。失败最多改 3 轮。

---

## Clarify

plan 前用。按范围/数据/UX/非功能/集成/边界/术语/完成信号扫歧义。Clear / Partial / Missing。最多 5 问，答案写回 spec。

---

## Plan（how）

读 spec + constitution。未知标 `NEEDS CLARIFICATION`。Constitution Check 是门：过不去且无正当理由 → ERROR。

- Phase 0：`research.md` 消掉澄清项
- Phase 1：`data-model.md`、`contracts/`、`quickstart.md`
- 设计后再跑一遍 Constitution Check
- **不写** `tasks.md`（那是下一命令）

Technical Context 要填：语言、依赖、存储、测试、平台、项目类型、性能、约束、规模。

---

## Tasks（清单）

`tasks.md` 必须马上能执行：换一个没看过聊天的模型也能做。

格式：`- [ ] T001 [P?] [USn?] Description with file path`

- `[P]`：不同文件、无未完成依赖
- `[USn]`：只在用户故事阶段
- 缺路径 / 缺 ID / 缺 checkbox = 错

组织：Setup → Foundational（阻塞全部故事）→ US1/US2… → Polish。  
每个故事：Goal + Independent Test；内部 Tests（若有）→ Model → Service → Endpoint → Integration。  
测试默认可选；写入则先写先失败再实现。

生成结束报告：总数、每故事多少条、并行点、独立测试标准、MVP 范围、格式全过。

---

## Analyze（implement 前）

只读 spec / plan / tasks / constitution。最多 50 条发现。

查：重复、含糊形容词、缺对象/缺验收、任务对不上文件、违宪、需求无任务、任务无需求、术语漂移、顺序矛盾。

和 constitution 冲突 = CRITICAL。

---

## Implement

按 phase 做；同文件串行；`[P]` 可并行。  
非并行失败则停。  
TDD：测试任务先于对应实现。  
做完勾 `[X]`。  
`checklists/` 有未勾 → 停问人。  
tasks 不完整先回去跑 tasks，不要猜。

---

## Checklist（给人审）

`/speckit.checklist` 产出 reviewer 用的需求质量问题。`[x]` 不是代码做完。implement 只读勾选状态。
