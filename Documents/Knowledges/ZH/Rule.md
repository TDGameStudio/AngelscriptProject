# Knowledges/ZH 写作规则

> 本文件是 `Documents/Knowledges/ZH/` 下所有文档的共同写作规范。
> 任何新文档动笔前应先读本文件 + 对应 prefix 的样板文章。
> 本文件随大批量补齐工作（2026-05）首版固化，后续如修订需在 `Index.md` 顶部记录。

---

## 一、Prefix 体系（与 Index.md 同步）

`Documents/Knowledges/ZH/` 下所有文档均采用 `<Prefix>_<Topic>.md` 扁平命名。前缀决定**这篇文章站在哪个视角看代码**，请勿越界混写。九个前缀的边界如下：

| 前缀 | 主题 | 不覆盖什么 | 样板文章 |
|------|------|------------|---------|
| `Arch_` | 插件总体架构、跨模块协作、生命周期编排 | 不深入单子系统实现细节（那是 RT_ / Type_ / AS_ 的活） | `Arch_RuntimeLifecycle.md`、`Arch_EditorTestDumpCollaboration.md`、`Arch_ErrorDiagnostics.md` |
| `AS_` | AngelScript 内核（`ThirdParty/angelscript/`）原貌与 UE Fork 差异 | 不写插件桥接层、不写 UE 类型生成 | `AS_ScriptEngine.md` |
| `Type_` | 脚本类型→ UE 反射对象的桥接、绑定数据库、`FProperty` 创建 | 不写脚本语法、不写运行时调度 | `Type_ClassGeneration.md` |
| `RT_` | 运行时子系统（HotReload / JIT / Debugger / StateDump / GlobalState 等）实现细节 | 不写架构编排（那是 Arch_）、不写绑定数据库 | `RT_StateDump.md`、`RT_HotReload.md` |
| `Test_` | 测试模块结构、Helper 分层、运行约定 | 不写具体某个测试用例、不写 Editor 扩展 | `Test_Layering.md`、`Test_Infrastructure.md` |
| `Syntax_` | 单一关键字 / 修饰符 / 容器类型的语法机制与实现原理 | 不写"怎么用"（那是 Guide_） | `Syntax_TArray.md`、`Syntax_UFUNCTION.md`、`Syntax_DefaultStatement.md` |
| `Diff_` | 当前插件与参考实现（Hazelight / Verse 等）的客观差异比对 | 不写如何补齐（那是 `Documents/Plans/` 的事） | `Diff_HazelightDefaultStatement.md` |
| `Guide_` | 用户向使用指南、案例驱动、入门到精通 | 不深入实现原理（那是 Syntax_ / RT_） | `Guide_QuickStart.md` |
| `Note_` | 零散笔记、外部框架使用心得、临时备忘 | 不要把架构性知识塞这里——拿不准就升到 Arch_/Type_/RT_ | `Note_CQTest.md` |

**命名约定**：
- 主题段落用 PascalCase（如 `Arch_RuntimeLifecycle`）
- 容器/修饰符直接写原名（如 `Syntax_TArray`、`Syntax_UFUNCTION`）
- 差异类用 `<参考方>+<主题>` 格式（如 `Diff_HazelightDefaultStatement`、`Diff_VerseArchitecture`）

新增文章前先翻 `Index.md`：若该前缀已为新文件预留位置，按位置补齐；若是全新主题，先在 Index.md 对应前缀块尾追加并补 `// <一行说明>`。

---

## 二、文档头部元数据块

每篇文章紧随 `# <文件名> — <一句话标题>` 之后，必须有一段统一格式的引用块作为元数据：

```markdown
# Arch_RuntimeLifecycle — Runtime 总控与生命周期

> **所属前缀**: Arch_（插件总体架构族）
> **关注层面**: 架构总控与生命周期编排（不深入单子系统实现细节）
> **关键源码**:
> `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp` (~3000+ 行)
> · `Core/AngelscriptEngineSubsystem.cpp` (~205 行)
> · `Plugins/Angelscript/Angelscript.uplugin`
> **关联文档**:
> `Documents/Knowledges/ZH/Arch_Overview.md` — 插件总体概览
> · `Documents/Knowledges/ZH/RT_HotReload.md` — Tick 中的热重载链路
> **外部参考**（可选）:
> [AngelScript 官网](https://www.angelcode.com/angelscript/)
```

四个**必填项** + 一个**可选项**：

| 字段 | 含义 | 写法 |
|------|------|------|
| `**所属前缀**` | 一句话说明本文站在哪个 prefix 的视角 | `Arch_（插件总体架构族）` 这种格式 |
| `**关注层面**` | 用一句话定边界，重点写**不覆盖什么** | `架构总控与生命周期编排（不深入单子系统实现细节）` |
| `**关键源码**` | 列出本文反复引用的 5–10 个源码文件 | 单行用 `·` 分隔；多文件每行一个，必要时跟 `(~XXX 行)` 容错备注 |
| `**关联文档**` | 列出 3–5 篇跨文章引用 | 用相对仓库根的路径 `Documents/Knowledges/ZH/<file>.md` + ` — <一行说明>` |
| `**外部参考**` | 仅当文章引用了官方文档或外部仓库时写 | 标准 markdown 链接 |

**强制规则**：
- 不要省略 `**关注层面**` 字段——它是本文与其他 prefix 的界碑。
- `**关键源码**` 用 `~XXX 行` / `~XX KB` 形式标注规模，**不要写绝对行号**（容易随源码变更失效）。
- `**关联文档**` 至少列 1 条，否则本文像孤岛。

**已知历史分歧**（旧文章中存在，新文章不要再这样写）：
- `AS_ScriptEngine.md` 用 `**所属模块**` 替代 `**所属前缀**` —— 新文章统一写 `**所属前缀**`。
- `Syntax_UFUNCTION.md` 缺少完整元数据块 —— 新文章必须补全。

---

## 三、正文章节组织

### 3.1 章节骨架

每篇文章按以下骨架推进：

```markdown
# <文件名> — <一句话标题>

> 元数据块（见 §二）

---

## 概览

[1–3 段 + 1 张总览 ASCII 图。开篇先用一句话点出本文聚焦的核心问题，
再用 ASCII 图给出"全景骨架"，最后预告后续章节的展开顺序。]

---

## 一、<第一节标题>

[展开]

## 二、<第二节标题>

...

## 七、<第 N 节标题>

---

## 附录 A：<速查表 / 模板骨架 / ...>

## 附录 B：<避坑清单 / 决策树 / ...>

---

## 小结

[3–5 个 bullet，把全文要点收口。]
```

### 3.2 硬规则

- **第一节固定为"概览"**：包含核心问题陈述 + 全景 ASCII 图。
- **后续节使用中文序号 `一、二、三`**，不要写 `## 1.` `## 2.`（已知 `Note_CQTest.md` 用了 `## 1.`，属于历史分歧，新文章不再这么写）。
- **每篇至少一张 ASCII 图**（box-drawing 或 `+--+` 风格），首选放在概览。
- **末尾固定收口章节**：`附录 A/B`（速查表 / 模板）+ `## 小结`（要点回收）。`Syntax_*` 与 `Note_*` 也可在末尾加 `## 修订记录` 表。
- **正文不要使用 emoji 与中英文标题混搭**——所有标题用纯中文 + 必要时英文符号名。

---

## 四、代码引用规范

### 4.1 三行注释标头（强制）

任何 ≥3 行的源码引用必须用以下标头开篇（不可省略，便于读者一眼定位）：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptEngineSubsystem.cpp
// 函数: UAngelscriptEngineSubsystem::Initialize
// ============================================================================
void UAngelscriptEngineSubsystem::Initialize(FSubsystemCollectionBase& Collection)
{
    Super::Initialize(Collection);
    EnsurePrimaryEngineInitialized();
}
```

可选第三行：除 `函数:` 外可换 `角色:` / `性质:` / `节选自:` 等更贴切的指代。

### 4.2 引用片段控制

- **5–15 行**为常态，超过 20 行就要质疑：是不是该用伪代码总结而非整段粘贴？
- **不复制整函数**——保留入口签名、关键 `if/else` 分支、`★` 标记的关键调用即可，其余用 `// ...` 省略。
- **不内联大段类定义**——超过 30 行的 struct/class 拆成节列字段表 + 局部代码块。
- 用 `// ★` 注释标注"本段最关键的一行"，便于读者扫读时聚焦。

### 4.3 文件路径

- 用 `/` 而非 `\\`（Markdown 跨平台一致性，Windows reader 也能正确显示）。
- **完整路径**用相对仓库根：`Plugins/Angelscript/Source/...`。
- **次要引用**可省略前缀（前文已交代上下文时）：直接 `Core/AngelscriptEngine.cpp`。
- **行号容错**：`~XXX 行` / `行 144-174` / `:1375` 三种均可，但避免精确到单行编号——源码漂移时不易维护。

### 4.4 语言标记

```` ```cpp ```` 用于 C++、`````` ```angelscript `````` 用于 .as、`````` ```text `````` 用于 ASCII 图与流程伪代码、`````` ```json `````` 用于 .uplugin 等 JSON。

---

## 五、图表与列表

### 5.1 ASCII 图

- **框线图**首选 box-drawing 字符：`┌ ┐ └ ┘ ─ │ ├ ┤ ┬ ┴ ┼`，等宽场景下视觉最齐。
- **粗略框图**或 IDE 不能正确渲染时退回 `+--+` `|` `-` 组合。
- **流程链路图**用 `->` / `▼` / `║` 等纯 ASCII 箭头串联，不依赖 Mermaid——部分 viewer / 知识库索引器不支持渲染。
- 每张图前后留一空行，图内不要超过 80 列宽度（控制台与 GitHub 视图都不会换行）。

### 5.2 表格

- 用 GitHub Flavored Markdown 标准三段式：`| 列 | 列 |` + `|---|---|` + 行。
- 列数控制在 6 以内，超过就拆成两个表或改用 bullet。
- 头一列尽量是"主语"（文件名 / 函数名 / 阶段名），便于左对齐扫读。

### 5.3 列表

- 一律用 `- ` 不用 `* `（视觉一致）。
- 嵌套缩进 4 个空格（不要 2 空格，会与正文混淆）。
- 序号列表保留给"严格有序的步骤"，常规说明用无序列表。

---

## 六、长度与深度

不同 prefix 的长度区间（基于现有样板统计，仅供参考、不作硬性约束）：

| 前缀 | 期望长度 | 现有样板 |
|------|---------|---------|
| `Arch_` | 400–800 行 | `Arch_RuntimeLifecycle.md` (~560)、`Arch_EditorTestDumpCollaboration.md` (~708)、`Arch_ErrorDiagnostics.md` (~612) |
| `AS_` | 500–1000 行 | `AS_ScriptEngine.md` |
| `Type_` | 500–800 行 | `Type_ClassGeneration.md` (~656) |
| `RT_` | 400–700 行 | 多见 |
| `Test_` | 300–600 行 | 多见 |
| `Syntax_` | 修饰符 400–800；容器 800–1200 | `Syntax_UFUNCTION.md`、`Syntax_TArray.md` (~1114) |
| `Diff_` | 200–500 行 | `Diff_HazelightDefaultStatement.md` |
| `Guide_` | 300–600 行 | `Guide_QuickStart.md` |
| `Note_` | 200–800 行 | `Note_CQTest.md` (~785) |

**深度原则**：本知识库面向**插件维护者**，不是用户文档：
- 可以深入到字节码 / GC schema / 模板特化级别，**鼓励写出"为什么这么设计"**。
- 拒绝套话与"使用说明手册"风格——那部分内容应去 Wiki/。
- 但也不要为了凑长度堆冗余表格，每个表格 / 图都应回答"读者为什么要看这一段"。

---

## 七、跨文档引用

### 7.1 路径规则

- **同目录引用**（`Knowledges/ZH/` 内部）：直接写文件名 `RT_HotReload.md` 或带相对前缀 `Documents/Knowledges/ZH/RT_HotReload.md`，两种都允许；首推后者，便于读者从仓库任意位置跳转。
- **跨目录引用**（引用 `AGENTS.md` / `Documents/Guides/` / `Documents/Plans/` 等）：用从仓库根开始的相对路径 `AGENTS.md` / `Documents/Guides/Build.md`。
- **不要**硬编码绝对路径（`D:\Workspace\...` / `/home/user/...`）。
- **跨仓库引用**（参考的 Hazelight 引擎、外部 GitHub 仓库等）：用完整 URL 或相对配置项（如 `AgentConfig.ini` 中的 `References.HazelightAngelscriptEngineRoot`），不要用本机绝对路径。

### 7.2 引用风格

- 行内引用用反引号包裹：`` `Type_ClassGeneration.md` ``。
- "详见某节"形式：写 `详见 Arch_RuntimeLifecycle.md §三` 或 `详见本文 §1.2`。
- "待写"占位：`Documents/Knowledges/ZH/Arch_Overview.md`（待写） —— 待写文章上线时统一去掉占位文字。

---

## 八、与其他文档系统的边界

`Documents/` 下并行存在多套文档体系，**Knowledges/ZH 与它们职责严格不重叠**：

| 体系 | 角色 | 受众 | 内容 |
|------|------|------|------|
| `Documents/Knowledges/ZH/` | 维护者内参 | 插件开发者 / 维护者 | 实现原理、架构编排、源码地图、决策动机 |
| `Wiki/`（待抽离） | 用户文档 | AS 脚本作者、游戏程序员 | 怎么用、API 速查、常见问题 |
| `Documents/Guides/` | 工程流程文档 | 工程师 | 构建、提交、子模块工作流等 SOP |
| `Documents/Reports/` | 自动产出归档 | CI / 评审 | 测试报告、覆盖率、技术债清单 |
| `Documents/Plans/` | 已弃用 | —— | 历史保留，不新增；新规划走 OpenSpec |
| `openspec/changes/` | 变更提案 | 开发者 | 单次变更的 proposal/spec/tasks |

**典型越界与处理**：
- "我想写一篇 AS 调用 C++ 函数的 cookbook" → 这是 Wiki/ 的内容，不写进 Knowledges。
- "我想记录某次重构的全过程" → 写进 OpenSpec proposal/tasks，不写进 Knowledges。
- "我想总结某个模块怎么测试" → 看主题：测试**架构**进 `Test_*`；具体测试用例编写**指引**进 `Guide_TestWriting.md`。
- **Diff_ 仅做客观差异比对**，不写"怎么补齐"——补齐计划进 `Documents/Plans/Plan_*.md` 或 OpenSpec。
- **Guide_ 仅做使用指南**，不写实现原理——原理进 `Syntax_*` / `RT_*` / `Type_*`。

越界容易让两套读者都看不懂，写之前先问"如果我把这段挪到对应的另一处，会不会更合适？"。

---

## 九、编辑流程

1. **新增 .md 必须同步登记 Index.md**：写完文章前先翻 `Index.md`，确认对应前缀块下已有占位行（按位补齐）或自行追加。Index 中每行格式：`├── <文件名>.md  // <一行说明>`。
2. **每个 Phase 完成后跑一致性校验**：用脚本或 PowerShell `Compare-Object` 对比 Index 列表与目录实际文件，确保没有未登记或登记后未落地的文件。
3. **代码引用自查**：提交前 grep 一遍引用的文件路径与符号名是否在源码中仍然存在；若源码已改动则同步更新引用。
4. **Git 提交格式**：遵循 `Documents/Rules/GitCommitRule.md`，常用形式：
   - `[Docs] Feat: Knowledges/ZH 新增 Arch_RuntimeLifecycle 等 N 篇`
   - `[Docs] Update: Knowledges/ZH 修订 Type_ClassGeneration 关联文档列表`
   - `[Docs] Fix: Knowledges/ZH 修正 Syntax_TArray 行号漂移`
5. **不要单独 commit 一篇未在 Index 登记的文章**——这会让读者从索引找不到入口。
6. **修订重大结构（如本规则）**：在 `Index.md` 顶部追加一行版本备注，便于回溯。

---

## 附录 A：模板骨架（可复制粘贴）

下面是一份可直接拷贝的空白文章骨架，按需替换 `<...>` 占位：

```markdown
# <Prefix>_<Topic> — <一句话标题>

> **所属前缀**: <Prefix>_（<族名>族）
> **关注层面**: <一句话定边界，重点写不覆盖什么>
> **关键源码**:
> `<Plugins/Angelscript/Source/.../FileA.cpp>` (~XXX 行)
> · `<.../FileB.h>`
> · `<ThirdParty/.../FileC.cpp>`
> **关联文档**:
> `Documents/Knowledges/ZH/<Sibling>.md` — <一行说明>
> · `Documents/Knowledges/ZH/<Other>.md` — <一行说明>
> **外部参考**（可选）:
> [<标题>](<URL>)

---

## 概览

本文聚焦一个核心问题：**<一句话核心问题陈述>**。

```text
<8–20 行总览 ASCII 图：核心矛盾 / 三层架构 / 流程骨架>
```

后续章节按 <X / Y / Z> 的顺序展开。

---

## 一、<第一节标题>

<正文展开。需要引用代码时用 §四的三行注释标头。>

```cpp
// ============================================================================
// 文件: <相对仓库根路径>
// 函数: <符号名>
// ============================================================================
<5–15 行核心代码>
```

---

## 二、<第二节标题>

<...>

---

## 三、<第三节标题>

<...>

---

## 附录 A：<速查表 / 决策树 / ...>

| <列> | <列> | <列> |
|------|------|------|
| ... | ... | ... |

---

## 附录 B：<避坑清单 / FAQ / ...>

1. <一行避坑总结>
2. <...>

---

## 小结

- <要点 1>
- <要点 2>
- <要点 3>
```

---

## 附录 B：常见错误与避坑

下列错误在历史 Review 中反复出现，新文章动笔前请自查：

1. **越界写法**：把 `Guide_` 写成对比分析、把 `Diff_` 写成使用教程、把 `Note_` 升级为架构论述。每篇下笔前先回答"我属于哪个 prefix 的视角"。
2. **代码引用漏标头**：贴了一段 cpp 但没有 `// ============================================================================ // 文件: ... // 函数: ...` 三行——读者无从定位。统一补全。
3. **行号硬编码漂移**：写死 `Line 1234`，半年后源码改动后这一行已经不对应。改用 `~XXX 行` / `行 144-174` / `:1375` 区间或锚点式标注。
4. **多个前缀抢同一主题**：例如"热重载"既写在 `Arch_RuntimeLifecycle` 又写在 `RT_HotReload`，两边都半深半浅。在 `Index.md` 中先划分清楚边界（`Arch_` 写 Tick 怎么调度、`RT_` 写文件链路与 SoftReload/FullReload 决策），再下笔。
5. **大段粘贴非主线源码**：把整个 200 行函数复制进文章。改用"入口签名 + 关键分支 + `// ...`" 概要式呈现。
6. **英文小节标题/序号**：`## 1. Background` `## Section A` 等破坏一致性。统一中文 `一、二、三` 序号。
7. **元数据块字段错位**：复制其他文章时把 `**所属前缀**` 改成了 `**所属模块**`、漏写 `**关注层面**`、`**关联文档**` 留空。一律按 §二 五字段（一可选）格式校齐。
8. **引用路径混用斜杠**：`Plugins\Angelscript\Source\...` 与 `Plugins/Angelscript/Source/...` 混用。统一用 `/`。
9. **未登记 Index.md**：新增文章只 commit 了 .md 自身、忘了在 `Index.md` 对应前缀块加一行——索引看不到入口。
10. **小结写成"参考资料堆"**：末尾 `## 小结` 应是 3–5 个收口性 bullet，不是关联文档清单（关联文档已在元数据块里）。
