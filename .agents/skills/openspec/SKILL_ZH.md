---
name: openspec
description: 在本项目中执行任何 OpenSpec 操作时使用——开始、继续、修订、实现、核验、同步或归档变更,以及查看 domain、spec 和产物状态。定义如何定位并调用便携版 Rust openspec.exe(而不是官方 Node CLI),以及构建在其上的生命周期操作流程。
---

> 本文件是 [SKILL.md](./SKILL.md) 的中文同步版,仅供阅读参考。Agent 实际触发时读取的是 `SKILL.md`。两份文件冲突时以 `SKILL.md` 为准。

# OpenSpec 便携版 CLI(原语)

本 skill 是 **"该运行哪个 OpenSpec 二进制、怎么运行"** 的唯一权威来源。其他 skill(变更生命周期、探索等)应引用本 skill,而不是各自重复描述 CLI 调用方式。

## 二进制

便携版 exe 以**优化过的 Release 构建**随本 skill 目录分发。所有项目操作都直接使用这个固定位置:

```text
<repo-root>/.agents/skills/openspec/bin/openspec.exe
```

```powershell
$openspec = Join-Path (git rev-parse --show-toplevel) ".agents/skills/openspec/bin/openspec.exe"
& $openspec change list --json
```

**绝不要直接调用裸命令 `openspec`。** 本机 PATH 会把 `openspec` 解析到 npm/scoop 全局安装的官方 Node CLI。那是另一个产品,命令面不兼容(`new`、`list`、`set`、`context-store`、`--store` 等)。便携版只有 manifest 模型。始终用完整路径调用。

`.agents/skills/openspec/bin/openspec.exe` 是 skill 和日常操作的运行时入口;不要用 `cargo run`,也不要让 skill 直接依赖 `target/`。Rust 源码的唯一权威仍是 `Tools/openspec` 子模块。源码更新后重新构建并刷新随 skill 分发的 Release 副本(需 Rust 1.75+):

```powershell
# 在 Tools/openspec 内执行
cargo build --release
Copy-Item target/release/openspec.exe ../../.agents/skills/openspec/bin/openspec.exe -Force
& ../../.agents/skills/openspec/bin/openspec.exe --version
```

## 命令面(v0.6.0,manifest 模型)

支持 `--json` 的命令在供 Agent 消费时优先输出 JSON;命令的精确参数以随版本分发的 `--help` 和 `Tools/openspec/openspec/commands/` 为准。

| 命令 | 用途 |
|---|---|
| `init [path] [--project-id <id>] [--title <t>] [--workflow <w>]` | 只创建 `project.yaml`、`config.yaml` 和空的按类型分根目录 |
| `doctor [--json]` | 对仓库做一次确定性快照,汇总所有结构诊断 |
| `validate <id> [--type change\|spec]` | 按对象所选 workflow 的 validation profile 检查一个活跃 change 或当前 spec |
| `validate --all\|--changes\|--specs\|--archived [--strict] [--json]` | 批量检查活跃记录、当前规格或固定归档 `tasks.md` 契约 |
| `domain create <id>` | 创建 domain 并补齐缺失的父级 domain |
| `domain list` / `domain show <id>` | 发现 domain,或解析一个规范 ID/别名 |
| `domain move <id> --to <id>` | 级联移动 domain 及其下所有 spec 和 change |
| `spec create <domain>/<leaf> [--title] [--description]` | 在已注册 domain 下创建规格对象 |
| `spec list` / `spec show <id>` / `spec move <id> --to <id>` | 发现、解析或移动 spec(UID 保留,旧 ID 成为别名) |
| `change create <domain>/<leaf> [--title] [--goal] [--affected-area <a>]...` | 创建带 `change.yaml` 的活跃变更 |
| `change list` / `change show <id>` / `change move <id> --to <id>` | 发现、解析或移动活跃变更 |
| `change archive <id> [--date YYYY-MM-DD]` | 纯目录移动到带日期的归档并写 `archived_at`;不合并 spec |
| `status --change <id> [--workflow <w>]` | 单个变更的产物/操作就绪状态 |
| `instructions <artifact> --change <id>` | 返回模板、项目 context/rules、依赖、解析后的 `contextFiles`、输出路径 |
| `instructions apply\|archive --change <id>` | 返回操作就绪状态和可编辑的项目指引 |
| `workflow list` / `which <name>` / `validate [name]` | 查看已解析的 workflow 定义及来源 |
| `workflow fork <source> [name]` / `workflow init <name>` | 物化或脚手架一个项目本地 workflow 包 |
| `completion generate\|install\|uninstall` | 管理 shell 补全 |

标识规则:spec 和 change 的 ID 永远是完整的 `<domain>/<leaf>` 路径(如 `engine/runtime/compiler/rework-types`);domain 每一段都必须注册;叶子名为小写 kebab-case;移动保留 `uid` 并把旧规范 ID 存为别名;ID 解析大小写不敏感。

## 这个二进制不做什么

- 没有 `new` / `list` / `show` / `archive` 顶级旧路由,没有 `set`、`--store`、`context-store` / `initiative` / `workspace` 子系统——那些属于官方 Node CLI,面向本二进制的 prompt 和 skill 里不得出现。顶层 `validate` 是基于当前 manifest/workflow 模型恢复的正式命令,不是旧 Node 行为的兼容入口;它不支持 `.openspec.yaml`、`skip_specs` 或 merge archive。
- 归档不合并 spec:`change archive` 是内容保持不变的目录移动。
- 不探测 AI 工具、不生成 skill/斜杠命令、不编辑 `AGENTS.md`、不写入 `.agents/` / `.claude/` / `.cursor/`——本 skill 这类集成由项目自行维护,不由 CLI 生成。
- 无遥测、无 HTTP 客户端、无机器全局配置命令、无反馈上报。

## 目录模型速查

```text
openspec/
├── project.yaml            # 仓库 manifest
├── config.yaml             # 可编辑的 workflow 选择器、context、rules、operations
├── workflows/              # 可选的项目本地 workflow 包
├── domains/<...>/domain.yaml
├── specs/<domain>/<leaf>/spec.yaml      + 项目自有文档
├── changes/<domain>/<leaf>/change.yaml  + proposal/design/tasks 等
├── archive/changes/<domain>/<date>-<leaf>/
└── legacy-history/         # 可选,不参与检查
```

`openspec/config.yaml` 是常规定制点:`workflow` 选择工作流(内嵌兜底:`spec-driven`),`context` 承载项目背景,`rules` 和 `operations` 承载按产物、按操作的指引。未知键会被拒绝。内嵌的 `spec-driven` 工作流在 `proposal` / `specs` / `design` / `tasks` 之间没有硬依赖边。

## 当前项目状态(重要)

AngelscriptProject 根目录的 `openspec/` 已完成 manifest 模型初始化:

- `openspec/project.yaml` 标识项目 `angelscript-project`,默认 workflow 为 `angelscript`;
- `openspec/config.yaml` 是项目提示词、artifact rules 和 apply/archive guidance 的定制入口;
- `openspec/workflows/angelscript/` 是当前唯一的项目本地 workflow 和模板包;
- `openspec/domains/`、`specs/`、`changes/`、`archive/changes/` 是 CLI 管理的类型根;
- `openspec-old/` 是由根 `.gitignore` 忽略的旧历史,不属于当前 CLI 仓库,不得自动迁移、扫描或改写。

分组写命令现在可以针对根 `openspec/` 正常执行。进行结构性写操作前先运行 `doctor --json`;不要手工伪造或移动 `project.yaml`、`domain.yaml`、`spec.yaml`、`change.yaml`,应使用对应的 `domain/spec/change` 命令维护对象身份。

## 生命周期操作

作用于变更的操作流程。**内容规范在姊妹 skill `openspec-schema` 里**——变更在磁盘上长什么样、`tasks.md` 怎么写、附件怎么写。没有阶段墙:操作可以在任何时刻、以任何顺序执行;纯计划(记录后停下)是一等模式。

四个操作各有专属 skill 承载完整权威流程——本文件对它们只保留一行摘要:

| 操作 | Skill |
|---|---|
| Continue——创建下一个产物 | `.agents/skills/openspec-continue-change/SKILL.md` |
| Implement——执行任务清单 | `.agents/skills/openspec-apply-change/SKILL.md` |
| Sync specs——把 delta 并入当前规格 | `.agents/skills/openspec-sync-specs/SKILL.md` |
| Archive——收尾政策 + 归档原语 | `.agents/skills/openspec-archive-change/SKILL.md` |

**选择变更。** 用户点名就用它;恰好只有一个活跃变更(`change list --json`)就自动选中;否则列出最近修改的几个及其进度,请用户选。永远先宣布:"Using change: `<id>`"。

**消费 `instructions` 输出。** `template` 是要填充的结构。`context` 和 `rules` 是**给你的约束,绝不是文件内容**——不要抄进任何产物。`dependencies` 文件从磁盘重读,不要用对话记忆。写到返回的输出路径,写完验证文件存在。

### Start(开始)

先弄清用户要做什么——不清楚绝不推进。请求横跨多个独立子系统时,建议先拆成多个变更。然后:`change create <domain>/<leaf>` → `status --change <id> --json` → `instructions <第一个产物> --change <id> --json` → 展示模板,停下等指示。ID 已存在就建议继续那个变更。

### Continue(继续)

创建**下一个**产物,每次调用只写一个;`specs` 和 `design` 是条件产物。完整流程:`openspec-continue-change` skill。

### Update(修订)

修订已存在的计划产物并保持一致;这里绝不改代码。**任意方向**调和——改 `tasks.md` 可能反过来要求修订 `proposal.md`。只编辑已存在的文件。逐条展示修订提议和理由;用户确认后才写。请求改变的是变更的*意图*时,建议另起新变更。

### Implement(实现)

带验证纪律执行 `tasks.md`:先批判性审阅计划,验证通过才勾选,停下来问而不是猜。完整流程:`openspec-apply-change` skill。

### Verify(核验,建议性)

按完整性 / 正确性 / 一致性三维对照产物检查实现;按 CRITICAL / WARNING / SUGGESTION 分级并附文件行号建议。供用户参考;绝不作为归档闸门。

### Sync Specs(同步规格)

CLI **永不合并规格**——归档是纯移动——所以把 delta 规格并入当前规格永远由 agent 驱动:合并而非覆盖;幂等。完整流程与合并语义:`openspec-sync-specs` skill。

### Archive(归档)

`change archive` 这个 CLI 原语只负责写 `archived_at` 和移动目录;它本身不合并 spec、不清理附件、也不检查任务完成度。项目的严格收尾政策(doctor、strict 校验、任务完成度、附件收尾、规格同步)和归档流程在 `openspec-archive-change` skill 里——绝不把裸原语当作校验。

### 典型命令流程

```powershell
$openspec = Join-Path (git rev-parse --show-toplevel) ".agents/skills/openspec/bin/openspec.exe"

& $openspec doctor --json                                  # 先做健康检查
& $openspec change create engine/runtime/my-change --title "My change" --goal "..."
& $openspec status --change engine/runtime/my-change --json
& $openspec instructions proposal --change engine/runtime/my-change --json
# ... 把产物写到返回的输出路径,实现,更新 tasks ...
& $openspec validate engine/runtime/my-change --type change --strict --json
# ... 确认 tasks 全部完成、附件已裁剪、长期规格已同步或明确不适用 ...
& $openspec change archive engine/runtime/my-change
& $openspec validate --archived --json
```
