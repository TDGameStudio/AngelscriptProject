# OpenSpec 系统重构说明

> 状态：2026-08-27 架构方向记录。本文描述重构目标和责任边界，不表示 Rust CLI、Web 预览或现有 spec 重基线已经实现完成。

## 为什么需要重构

AngelscriptProject 当前处于全面重构期。现有 `openspec/specs/` 与活动 change 来自不同阶段，混合了不同粒度的能力定义、已经落地的事实、尚未实现的目标、相互重叠的边界和历史研究记录。因此，整个 spec 集合目前不能无差别视为权威现状。

在完成重基线前，工程判断必须交叉核对：

- 当前代码与公开接口；
- 当前测试及实际验证结果；
- 最新且仍适用的 change；
- 对应指南、报告与历史记录。

后续整理时，应把记录分类为“当前权威”“部分有效”“未来目标”“重叠/冲突”或“纯历史记录”，优先通过标记、迁移和归档澄清状态，不在没有专项 change 的情况下批量删除或改写。

## 已确定的产品边界

便携 OpenSpec 的产品方向收敛为两个主要交付面：

1. **Rust 生命周期与验证内核**：提供可移植、确定性、无 Node/npm 运行时依赖的 change/spec 生命周期、解析、校验和机器可读查询能力。
2. **Web 预览工具**：复用同一套 Rust 解析与验证语义，为本地仓库提供更直观的 spec/change 浏览、状态、关系和诊断预览。

OpenSpec Skill 不再是 Rust 工具生成或刷新的产物。项目 Skill、提示词和工程方法应作为独立交付物，由项目或用户自行版本化、下发和维护。Rust 工具不得把 `.agents/`、`.claude/`、`.cursor/` 等 Agent 配置目录当作自己的写入目标。

## 责任分层

| 层 | 负责 | 不负责 |
| --- | --- | --- |
| Rust 内核 | 解析 schema、读取 artifact、计算生命周期状态、校验、归档、输出稳定的机器可读结果 | 生成项目提示词、安装 Agent Skill、维护用户的工作方法 |
| Web 预览 | 使用与 CLI 一致的数据模型展示 specs、changes、关系、状态和诊断 | 在 V1 中编辑或自动改写 spec、替代 Git 审阅、创建隐式项目状态 |
| 项目 Skill | 解释项目边界、工作流、测试选择、验证入口和重构期可信度规则 | 重新实现 Rust parser/validator，或把自身生命周期绑定到 CLI 更新 |
| 项目/用户 | 维护专属提示词、Skill、schema 选择、社区扩展和发布策略 | 依赖 Rust `init` 覆盖本地 Agent 配置 |

这层划分允许 Rust 二进制、Web 前端和项目 Skill 独立升级。三者通过版本化的数据契约和仓库文件协作，而不是互相生成源文件。

## Rust 内核方向

Rust 版本应保留一个小而稳定的命令面。候选核心能力包括：

- 创建 change；
- 列出、查看和查询 change/spec；
- 计算 artifact graph 与完成状态；
- 输出下一步 instructions；
- 校验 change、spec、requirements、scenarios 和 tasks；
- 归档已完成 change；
- 查询或检查 schema；
- 为 Web 和其它调用方输出稳定、版本化的 JSON。

最终命令名称仍需单独设计和验证；本文记录的是能力边界，不把候选命令直接声明为既定兼容契约。

以下官方兼容行为应删除、隐藏到兼容层，或至少退出默认路径：

- 检测大量 AI 工具并分别生成 workflow Skill；
- 向不同 Agent 目录写入 Skill、command 或 prompt；
- `update` 覆盖用户维护的提示词；
- 仅用于提示词选择、但没有形成稳定产品语义的 profile；
- 默认暴露 workspace、initiative、context-store 等高级流程。

### `init` 的定位

如果保留 `init`，它只负责创建最小 OpenSpec 数据结构，例如：

```text
openspec/
├── config.yaml
├── specs/
├── changes/
│   └── archive/
└── schemas/        # 仅在显式需要项目 schema 时创建
```

`init` 不检测 Agent 工具，不安装 Skill，不写入提示词，也不接管 `.agents/`。重复执行必须可预测，并且不能覆盖用户维护的内容。

## Web 预览工具方向

Web 工具的价值在于把同一份 OpenSpec 数据从“文件目录”提升为可导航的工程视图，而不是建立第二套解析器或第二种事实来源。

V1 建议保持本地、离线、只读，至少覆盖：

- 浏览和搜索 specs、活动 changes 与 archive；
- 渲染 proposal、spec、design、tasks 及自定义 artifact；
- 展示 artifact graph、缺失依赖、完成状态和下一步入口；
- 展示校验错误、警告、文件位置与关联 requirement/scenario；
- 展示 requirements → scenarios → tasks 的可追溯关系；
- 对比活动 change、基线 spec 与归档结果；
- 对重构期记录显示可信度或生命周期标记，而不是把未来目标渲染成当前事实。

V1 不直接编辑、生成、归档或批量修复仓库内容。写操作需要单独的安全模型、Git diff/确认机制和专项 change，不能因 Web 界面存在就默认开放。

Web 的交付形态仍需决策：

- `openspec web` 启动本地 localhost 服务；或
- `openspec preview --export` 导出静态站点。

两种入口可以共享前端和版本化 JSON 模型，但第一版应选定一个主要路径，避免同时维护两套行为。无论选择哪种方式，解析和验证结论都必须来自 Rust 内核。

## Skill 的独立分发

AngelscriptProject 的 OpenSpec Skill 继续放在项目跟踪的 `.agents/skills/` 中，承载本项目独有的内容，例如：

- `Plugins/Angelscript` 为核心交付物的仓库边界；
- 父仓库与插件/Rust 工具子模块的双仓提交规则；
- UE、Standalone、自动化测试和文档验证入口；
- record-only、implement、archive 等项目工作约定；
- 全面重构期的 spec 可信度与检索规则。

需要下发给外部用户时，应使用独立的 Skill、插件或安装包版本，由接收方维护其项目约束。Rust CLI 只保证数据格式、校验语义和机器接口，不拥有也不覆盖这些提示词。

项目计划逐步移除对全局 Superpowers 安装的依赖。有价值的探索、TDD、系统化调试、完成前验证和计划质量方法，需要经过筛选后内化到项目本地 Skill；当前迁移尚未完成，因此现在不能把全局卸载视为已安全完成。

## 社区扩展原则

社区实现可用于扩展 schema、artifact、trace、review、test-plan、retrospective、hook/check 和可视化方式，但每项吸收都必须记录：

- 来源、版本与许可证；
- 采用的具体机制；
- 明确拒绝或延期的部分；
- 与现有 Rust 数据模型、项目 Skill 和 Web 展示层的归属关系；
- 本项目中的验证方法。

不整包复制社区 schema，不让流程仪式替代工程判断，也不允许 Web 或 Skill 私自引入 Rust 内核无法验证的隐藏状态。

## 当前仓库状态

- `Tools/openspec` 是 `TDGameStudio/openspec` 子模块，当前检出本地 `angelscript` 分支，提交为 `1ecbc7fccae1366ec12457c89c5d75fdf17ab254`，且没有 upstream。
- 该分支相对本地 `main` 多两个互相抵消的文档提交，当前最终 tree 与本地 `main` 相同；父仓库 HEAD/index 仍记录 `8de9d94`，因此父仓库会把子模块显示为已修改。
- 当前 Rust `init` 仍继承官方的多工具、多 workflow 生成逻辑，并未体现本文的新边界。
- 当前仓库尚未实现本文描述的 Web 预览工具。
- `.agents/skills/openspec-work/` 仍是项目本地工作流入口，但目前仍有对 `superpowers:*` 的方法依赖，尚未完成解耦。

这些是迁移起点，不是稳定产品契约。

## 本轮明确不做

- 不实现 Web 前端或本地服务；
- 不修改 Rust 命令、`init`、parser 或 validator；
- 不删除旧的工具检测和 Skill 生成代码；
- 不改写或重新发布项目 OpenSpec Skill；
- 不全局卸载 Superpowers；
- 不批量重写、归档或删除现有 specs/changes；
- 不把现有 `improve-openspec-task-guidance` 直接视为可原样 apply 的设计。

## 后续需要形成专项 change 的决策

1. Rust 最小命令集和兼容策略；
2. Web V1 采用 localhost 服务还是静态导出；
3. CLI/Web 共用的数据契约是直接共享 Rust 类型，还是稳定的版本化 JSON schema；
4. requirement、scenario、task 和 artifact 的稳定标识与 trace 规则；
5. 旧工具检测、Skill 生成和 prompt profile 是删除、隐藏还是保留显式兼容入口；
6. 现有 specs/changes 的重基线、冲突处理和归档流程。

在这些决策形成 change 并通过验证前，本文只作为架构方向和范围守卫。
