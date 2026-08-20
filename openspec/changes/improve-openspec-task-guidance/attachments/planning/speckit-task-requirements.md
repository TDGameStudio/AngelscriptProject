# Spec Kit 对 tasks.md 的官方要求

摘自已拉到本仓库的离线副本 `Reference\spec-kit`（2026-08-19 浅克隆，`main` @ `7eee05d0ed95d2984947b30a1fc25f0e23627880`，上游 tag 说明为 0.16.5）。原始远程：`git@github.com:github/spec-kit.git`。

本地对照入口：

- `Reference\spec-kit\templates\tasks-template.md`
- `Reference\spec-kit\templates\commands\tasks.md`（`/speckit.tasks` 生成指令）
- `Reference\spec-kit\templates\commands\implement.md`（`/speckit.implement` 如何消费 tasks）

这是生成器必须遵守的合同，不是博客建议。本仓库准备规范化 task 时，优先偷这些硬规则，而不是偷 Spec Kit 的目录模型和阶段门。

## 1. 生成前必须读什么

`/speckit.tasks` 规定：

| 输入 | 是否必须 | 用来干什么 |
|---|---|---|
| `plan.md` | 必须 | 技术栈、库、目录结构 |
| `spec.md` | 必须（有用户故事时） | 用户故事和优先级 P1/P2/P3 |
| `data-model.md` | 可选 | 实体映射到故事 |
| `contracts/` | 可选 | 接口合同映射到故事；若要求测试则先写合同测试 |
| `research.md` | 可选 | 决策落到 Setup 任务 |
| `quickstart.md` | 可选 | 测试/验收场景 |
| `constitution.md` | 若存在则读 | 项目不可违反的原则 |

生成后的完成报告必须包含：总任务数、每个用户故事的任务数、可并行点、每个故事的独立测试标准、建议的 MVP 范围、以及“全部任务都符合 checklist 格式”的确认。

官方原句：

> The tasks.md should be immediately executable — each task must be specific enough that an LLM can complete it without additional context.

## 2. 每条任务的强制格式

每条必须严格是：

```text
- [ ] [TaskID] [P?] [Story?] Description with file path
```

字段：

1. **Checkbox**：永远 `- [ ]`
2. **Task ID**：执行顺序的 `T001`, `T002`, …（不是 1.1）
3. **`[P]`**：仅当可并行时出现——不同文件、且不依赖尚未完成的任务
4. **`[Story]`**：只在用户故事阶段必填，写成 `[US1]` / `[US2]`。Setup、Foundational、Polish **禁止**故事标签
5. **Description**：清楚的动作 + **精确文件路径**

对错对照（官方原文）：

| 对 | 错 |
|---|---|
| `- [ ] T001 Create project structure per implementation plan` | `- [ ] Create User model`（缺 ID 和 Story） |
| `- [ ] T005 [P] Implement authentication middleware in src/middleware/auth.py` | `T001 [US1] Create model`（缺 checkbox） |
| `- [ ] T012 [P] [US1] Create User model in src/models/user.py` | `- [ ] [US1] Create User model`（缺 Task ID） |
| `- [ ] T014 [US1] Implement UserService in src/services/user_service.py` | `- [ ] T001 [US1] Create model`（缺文件路径） |

## 3. 组织原则：按用户故事，不按技术层一锅炖

**CRITICAL**：任务必须按用户故事组织，使每个故事能独立实现、独立测试、作为 MVP 增量交付。

从 `spec.md` 的每个故事（P1, P2, P3…）开一个 phase，把该故事需要的 model / service / UI / 测试映射进去。故事之间默认独立；跨故事依赖要显式标出，且不能破坏独立性。

来源映射：

- 合同 → 它所服务的故事；若要求测试，该故事 phase 里先写合同测试，标 `[P]`
- 实体 → 需要它的故事；多故事共用则放最早的故事或 Setup
- 共享基建 → Phase 1 Setup
- 阻塞所有故事的基础 → Phase 2 Foundational
- 只属于某故事的 setup → 放进该故事 phase

## 4. 固定 phase 结构

1. **Phase 1 Setup**：项目初始化，无依赖
2. **Phase 2 Foundational**：所有用户故事的阻塞前置。**任何故事工作开始前必须完成**。完成后有 checkpoint
3. **Phase 3+**：按 P1 → P2 → P3 每个故事一个 phase。每个 phase 包含：
   - Goal（这个故事交付什么）
   - Independent Test（单独怎么验）
   - Tests（仅当 spec 明确要求测试或用户要求 TDD）
   - Implementation
   - Checkpoint（做到这里该故事应可独立工作）
4. **Final Phase Polish**：跨故事的文档、清理、性能、安全、`quickstart.md` 验证

故事内部顺序：

> Tests (if requested) → Models → Services → Endpoints → Integration

以及：

- 测试若纳入，必须先写且先失败，再实现
- Model 先于 Service，Service 先于 Endpoint
- 核心实现先于集成
- 当前优先级故事完成后再进入下一优先级（并行团队除外）

## 5. 测试任务是可选的

官方写得很死：

> Tests are OPTIONAL — only include them if explicitly requested in the feature specification.

只有 spec 要求测试，或用户明确要求 TDD，才生成测试任务。模板里仍写：若生成测试，**先写、先失败再实现**。

对本仓库的含义：不要照抄“默认不写测试”。本仓库 Superpowers + 测试约定是默认要测行为变化。偷的是“测试任务必须是一等 checkbox，且排在实现前”，不是“可以不测”。

## 6. 每个故事必须能单独验收

每个用户故事 phase 都要有：

- **Goal**：一句话交付物
- **Independent Test**：不依赖尚未做的后续故事，怎么证明这个故事已经能用

实施策略写在 `tasks.md` 正文里：

- **MVP First**：Setup + Foundational + US1，然后 **STOP and VALIDATE**
- **增量交付**：每加一个故事就独立测、可演示，且不破坏已有故事
- **并行团队**：共同做完 Foundational 后，不同人做不同 US

## 7. 依赖与并行规则

Phase 依赖：

- Setup：无依赖
- Foundational：依赖 Setup，**阻塞全部用户故事**
- 用户故事：都依赖 Foundational；之后可按优先级串行，或在人手够时并行
- Polish：依赖打算交付的故事都完成

`[P]` 的精确定义：**不同文件，且不依赖未完成任务**。禁止对同一文件标并行。

可并行的典型情况：Setup 里标了 `[P]` 的项；Foundational 内部标了 `[P]` 的项；Foundational 完成后不同用户故事；同一故事里标了 `[P]` 的测试；同一故事里标了 `[P]` 的多个 model。

官方明确要避免：

- vague tasks
- same file conflicts
- cross-story dependencies that break independence

## 8. `/speckit.implement` 怎么消费这些任务

生成规则要和执行规则对齐，否则格式是空的。Implement 要求：

- 先读 `tasks.md` 和 `plan.md`（必须），再读 data-model / contracts / research / constitution / quickstart（若有）
- 若 `checklists/` 里还有未勾项，**停下来问人**是否继续；checklist 的 `[x]` 表示需求质量过关，**不表示实现完成**
- 按 phase 执行，先完成一个 phase 再进入下一个
- 尊重依赖；`[P]` 可一起做；碰同一文件的必须串行
- 走 TDD：测试任务先于对应实现任务
- 非并行任务失败则停；并行任务可继续成功的、汇报失败的
- 做完一条必须把 checkbox 改成 `[X]`
- 若 tasks 不完整或缺失，先让人跑 `/speckit.tasks`，不要猜着实现

## 9. 社区在官方格式之上又加的（非官方，仅作对照）

[Discussion #1123](https://github.com/github/spec-kit/discussions/1123) 有人给每个 task 另写一份 playbook（工具/MCP/skill 强制列表、BEFORE/DURING/AFTER、带牙齿的验收）。这比官方 `tasks.md` 一行一条更厚，作者自己也承认更耗 token。本仓库若采用，应放在 change 目录独立文件，不要把 checkbox 行撑成小说。

## 10. 建议偷什么、不建议照搬什么

建议偷进本仓库 task 合同：

1. 每条必须带精确路径，缺路径算格式失败
2. 按可独立交付/可独立验收的增量分组，并写 Independent Test
3. 阻塞性基础工作单独成组，做完才开始功能组
4. 可并行要显式标记，且定义是“不同文件、无未完成依赖”
5. 任务必须能追溯到 requirement / story
6. 生成结束时自检：数量、分组、并行点、MVP 范围、格式
7. 一条任务要具体到“换一个会话的 LLM 不看聊天记录也能做”
8. Apply 按组执行，组边界停下来验证；失败则停

不建议照搬：

- `T001` 编号（本仓库已用 `1.1`，保留即可）
- `[US1]` 标签原文（本仓库应对应 OpenSpec requirement / capability，而不是 Spec Kit 用户故事）
- “测试默认不生成”（与本仓库 TDD 默认冲突）
- 整个 Phase 1/2/3 的 Web 应用 Setup/Foundational 样例（本仓库是 UE/AngelScript 棕地，Setup 通常不是“初始化项目”）
- Spec Kit 的 `specs/00N-feature/` 目录和 constitution 文件模型
