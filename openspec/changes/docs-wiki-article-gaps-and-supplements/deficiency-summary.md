# Wiki 文章不足与补充交付总结（docs-wiki-article-gaps-and-supplements）

> 本文同时记录两件事：当前正式中文 Wiki 的内容基线，以及本 change 暂存的 200 篇候选文章如何回应这些缺口。统计日期为 2026-08-08。所有检查都是对 frontmatter、正文、链接、注册来源和仓库路径的只读审计；按用户要求，本轮没有创建或运行测试，也没有修改 `Wiki/` 子模块。

## 1. 范围与口径

当前基线只统计 `Wiki/wiki/tiddlers/docs/zh-Hans/` 中带文档状态的正式中文 `.tid`，共 96 篇；`docs/data`、`docs/navigation`、`docs/taxonomy` 等控制 tiddler 不计入文章数。96 篇中 29 篇位于 `generated-knowledge/`，67 篇为人工维护的正式专题页。

本 change 的候选稿位于 `supplements/`，是父仓库 OpenSpec 附件，不是 Wiki 子模块中的正式文章。采用前仍需在 `Wiki/` 仓库内完成中文人工审阅、逐主题迁移和独立提交。附件全部保持 `as-content-status: draft`，不会用数量或 frontmatter 合法性冒充已发布质量。

与 `docs-wiki-content-and-expression-overhaul` 的边界保持不变：umbrella change 负责全站状态/组件治理；本 change 负责“缺口解释 + 可采用的完整正文 + 逐篇证据目录”。

## 2. 当前正式 Wiki 基线

### 2.1 完成状态与深度

| 指标 | 当前值 | 含义 |
|---|---:|---|
|文章总数 |96 |67 篇人工页 + 29 篇 generated-knowledge |
|内容状态 |placeholder 30 / draft 53 / reviewed 13 / published 0 |30 个入口仍是占位页，尚无正式 published 中文文章 |
|深度 |L0 22 / L1 13 / L2 35 / L3 5 / L4 17 / L5 4 |深度标签不少，但部分旧 L4/L5 正文仍只有计划骨架，标签不能单独证明深度 |
|语言 |zh-Hans 96 / en-GB 0 |英文导航外壳没有对应正文语料 |

29 篇 generated-knowledge 全部是 draft。人工维护的 67 篇中，30 篇 placeholder、24 篇 draft、13 篇 reviewed；也就是说，人工专题页中 54/67 仍未进入 reviewed。

### 2.2 ReaderNav 分布

| nav-group | 文章数与状态 | 主要不足 |
|---|---|---|
|bindings-extensions |12：draft 8 / placeholder 4 |UHT 四页仍为占位，生成链与维护边界不足 |
|getting-started |5：reviewed 5 |已有起步闭环，但尚未覆盖源码插件安装、目录身份与首次分层排错 |
|internals-reference |24：draft 14 / placeholder 10 |占位最多；parser/VM/ClassGenerator/Hazelight 差异的符号证据和维护地图不足 |
|language-basics |10：draft 2 / reviewed 8 |基本语法较完整，但容器/所有权/转换等跨主题边界仍需更系统的诊断说明 |
|script-features |22：draft 20 / placeholder 2 |Unreal 方言条目多，但 reviewed 为 0，生成/反射/消费边界不够稳定 |
|unreal-development |12：draft 5 / placeholder 7 |全部集成专题仍是占位，已有示例没有形成任务工作流 |
|workflow-validation |11：draft 4 / placeholder 7 |热重载五页及 Editor/Showcase 入口为空，失败恢复与证据采集不足 |

现有机器可读 `as-doc-link` 在当前树中能够解析；主要问题已不是“链接字符串普遍断裂”，而是链接目的地仍可能只有占位正文、同一 topic 被拆到不同 ReaderNav，或者 landing 承诺的学习路线远大于实际内容。

### 2.3 表现组件与代码呈现

| 表达形式 | 使用文章数 |
|---|---:|
|`as-callout` |20 |
|`as-doc-cards` |10 |
|`<$angelscript-code>` |2 |
|Markdown 代码围栏 |51 |

组件使用集中在 landing 与少量入门页，leaf 文档尤其是 generated-knowledge 大量依赖纯正文和普通围栏。这里的缺口不是要求每页堆组件，而是让风险、前置条件、可运行路径、成功判据和失败分支在视觉与语义上可分辨。

## 3. 七类内容不足

### A. 完成度不足

30 篇 placeholder 并非随机分布，而是集中在高价值分支：`topics-integrations` 的 index 与六个集成专题、`hot-reload` 的五个子专题、`editor-ide-debugging/index`、`showcase-lab/index`、`architecture-maintenance/index`、多篇 UHT 与 Hazelight 差异页，以及 Unreal 方言的边界/维护页。它们多描述“以后要写什么”，尚不能帮助读者完成任务。

### B. 专题覆盖和正文深度不足

旧正式树中，ArchitectureMaintenance、EditorIdeDebugging、RuntimeJitVm、ShowcaseLab、TypeObjectReflection 等分支曾长期只有 landing 或依赖 generated-knowledge 作为唯一 leaf；CompileModulePreprocessor、TestingDiagnosticsRelease 等分支也只有极少正式子页。与此同时，一些文章标为 L4/L5，却没有符号级管线、状态不变量、失败原子性或维护影响图，形成“深度标签越级”。

正文深度不能用篇数或文件大小代替。L1 至少要让读者按步骤得到可观察结果并处理常见失败；L3 需要交代 Runtime/Editor/Commandlet/PIE 等所有权和生命周期；L4/L5 还必须落到真实符号、数据结构、old/new 状态、兼容性与回归证据层。

### C. 已有示例与读者工作流脱节

仓库已有可核实示例，但旧占位页没有把它们接入工作流：

- Networking：`Script/Examples/Extended/Example_NetworkReplication.as`；
- AI/Behavior Tree：`Script/Examples/Core/Example_BehaviorTreeNodes.as`；
- UI/UMG：`Script/Examples/Core/Example_Widget_UMG.as`；
- Enhanced Input：`Script/Examples/EnhancedInput/*.as` 与相关 Character Input 示例。

另一类风险是反方向的：旧 GAS 占位描述暗示存在 Extended GAS 示例，但仓库中没有对应脚本。高质量文章必须区分“已有可运行示例”“只有插件源码/验证资产”“尚无作者示例”，不能用猜测补齐叙述。

### D. 成功路径多，失败与恢复合同少

许多旧稿能展示一段语法，却没有说明：编译失败是否保留最后成功状态、热重载后应观察旧实例还是新实例、默认值属于脚本 CDO/Blueprint CDO/实例哪一层、公开签名变化如何影响 Blueprint，以及 Editor 成功是否等价于 cooked/commandlet 成功。缺少这些边界时，读者只能“照抄成功”，无法诊断真实项目。

### E. 源码证据链不足

旧 internals 页面常列出宏观阶段名，却没有把可观察行为连到真实文件、符号、数据结构和消费者。尤其是 parser/compiler、ClassGenerator、UHT 生成绑定、VM dispatch、StaticJIT、GC、global state、DebugServer 与 reload pipeline，一篇维护者文章至少要回答：谁创建、谁持有、谁发布、失败前后保留什么、哪一层证据能证明结论。

来源注册本身也不是事实核验。`as-sources` 只能声明证据域，正文仍需给出实际路径/符号，并区分当前 fork、Hazelight 对照材料、项目指南、示例和 OpenSpec 记录的证据优先级。

### F. 信息架构与导航认知负担

Wiki 同时存在 15-topic taxonomy 与 7 个 ReaderNav group。两者用途不同，但旧文档没有始终解释这种映射；UnrealLanguage 等逻辑专题分散在多个 nav group，部分页面的物理路径、topic tag、nav parent 与读者任务不完全一致。当前链接可解析不等于信息架构已经清晰，landing 仍需承担范围、读者、成熟度与下一步路由，而不是只列标题。

### G. 国际化与采用闭环缺失

当前没有 en-GB 正文，英文入口无法形成真实对照语料。更直接的交付缺口是：即使候选中文稿已经完成，也必须经过 Wiki 子模块的人工审阅、迁移、内容契约检查和提交，才能成为正式站点内容。本 change 刻意不越过这条仓库边界。

### 3.1 Placeholder / landing-only 覆盖清单

| 缺口族 | 当前 placeholder | 本附件的回应 |
|---|---:|---|
|ArchitectureMaintenance |1 |13 篇：模块所有权、依赖、全局状态、dump、打包、子模块交付等 |
|BindingsUhtExtensions / UHT |4 |22 篇完整覆盖手工绑定、生成后端、fallback、扩展与维护合同 |
|EditorIdeDebugging |1 |11 篇覆盖 VS Code、LSP/DAP、断点、导航、协议故障与发布边界 |
|HotReload |5 |11 篇覆盖日常循环、变化分类、reload pipeline、失败恢复和维护证据 |
|Hazelight / 差异维护 |7 |ReferenceDifferencesVersion 11 篇，区分当前 fork、上游证据与选择性回移 |
|ShowcaseLab |1 |6 篇把过度承诺的 42 项目录收敛为可维护的展示/实验合同 |
|TopicsIntegrations |7 |12 篇覆盖 optional-plugin 与 engine-domain 两类集成、真实示例和打包边界 |
|UnrealLanguage 维护/边界 |4 |21 篇覆盖作者功能、反射限制、实现原则和源码/维护证据 |

这 30 个 placeholder 是最显眼的缺口，但并不是本批只重写 30 页的理由。其余 draft 中同样存在深度标签越级、示例断链与生命周期不足，所以最终采用 30 rewrite + 170 new 的完整专题集合，而不是只替换空壳。

## 4. 本 change 的补充交付

### 4.1 数量、生命周期与 topic 配额

- 候选文章：200 篇；`as-doc-key` 200 个且唯一，title 200 个且唯一；
- 状态：200 篇全部为 `draft`；
- 生命周期：30 篇 `rewrite`，170 篇 `new`；
- 双向目录：`supplements/README.md` 200 行与 200 个 `.tid` 一一对应；
- 来源：每篇只使用 SourceRegistry 已登记的来源键，目录中的 grounding path 与来源逐项对应且在当前父仓库存在。

| Topic | 篇数 | Topic | 篇数 |
|---|---:|---|---:|
|Start |6 |Language |12 |
|UnrealLanguage |21 |TypeObjectReflection |10 |
|UnrealCore |14 |CompileModulePreprocessor |13 |
|HotReload |11 |EditorIdeDebugging |11 |
|TestingDiagnosticsRelease |18 |RuntimeJitVm |20 |
|BindingsUhtExtensions |22 |ArchitectureMaintenance |13 |
|TopicsIntegrations |12 |ReferenceDifferencesVersion |11 |
|ShowcaseLab |6 |**总计** |**200** |

### 4.2 最终深度与正文体量信号

| 深度 | 篇数 | 正文字符最小值 | 中位数 | 最大值 |
|---|---:|---:|---:|---:|
|L0 |6 |2329 |3475 |4257 |
|L1 |33 |2377 |3469 |6600 |
|L2 |47 |2390 |3828 |7609 |
|L3 |55 |2965 |5686 |14142 |
|L4 |45 |4010 |6639 |16581 |
|L5 |14 |6361 |7695 |12486 |

字符数是从 frontmatter 后正文统计的异常信号，不是验收门槛。短而完整的矩阵页不会因为没有凑字数被降级；长文若缺状态模型、失败边界或符号证据同样要返工。此次最终分布体现的是内容合同，而不是机械追求每一层同样长。

### 4.3 深度质量如何落到正文

本批采用 D9 分层合同：

- L0：说明专题范围、读者、适用边界、证据状态和阅读路由；
- L1：提供可执行步骤、预期结果、常见失败和下一步；
- L2：在 L1 上增加概念/生命周期模型、约束矩阵和诊断分支；
- L3：明确 Runtime、Editor、Commandlet、PIE 等所有权与真实文件/符号；
- L4：给出符号级管线、关键结构、不变量、失败原子性、old/new 状态和分层证据；
- L5：再覆盖完整维护地图、兼容/迁移影响、清理边界和证据层。

代表性落地包括：

- Start 六篇不再是短检查表：安装链、路径身份、保存/编译/发布状态机、诊断五元组、Blueprint 默认值所有权和首次接入决策树均有完成判据；
- TopicsIntegrations 不再把“引擎域”“可选插件”“有示例”“无示例”混为一类；GameplayTags 为 L3，Enhanced Input、Networking、UMG、Behavior Tree 为 L2，并指向真实示例或插件边界；
- `global-state-containment`、`static-jit-pipeline`、`garbage-collector`、`vm-call-lifecycle`、`compile-failure-atomicity` 等 L4 页补齐所有权、发布阶段、失败状态和诊断证据；
- `as-compiler-pipeline`、`as-parser-internals`、`as-bytecode-instruction-set`、`as-script-engine-core`、`execution-context`、`classgenerator-structure` 等 L5 页形成符号/结构/兼容性/维护闭环；
- Preprocessor 的 source provider、context、summary 和 virtual path 页面分别说明运行身份、阶段快照、值对象陈旧性与离线路径替换合同，避免把相邻职责混成一篇泛论；
- Unreal Language 的函数 specifier、默认语句、默认组件与 Construction Script 页面明确 parser/lowering/ClassGenerator/dispatch/Blueprint/RPC 边界，总入口按全部 20 个子专题重新路由。

### 4.4 WikiText 与元数据一致性

候选稿统一使用 TW5 字段和 WikiText 约定：PascalCase topic tag、`as-nav-*`、注册 `as-sources`、`as-doc-link`、TW5 粗体语法。只读审计未发现 Markdown `**bold**` 残留；代码中的幂运算、`void**`、glob 与 TW5 嵌套列表不被误判。所有链接目标在候选集或当前 Wiki 中可解析，所有 `as-nav-parent` 可解析。

## 5. 仍未由本 change 完成的工作

以下内容必须留给正式采用阶段，不能通过把附件标成 reviewed/published 来绕过：

1. 在 `Wiki/` 仓库中按 topic 进行中文人工审阅，确认术语、示例叙述和站点呈现；
2. 决定 30 篇 rewrite 如何替换现有页，以及 170 篇 new 如何进入正式目录；
3. 迁移时复核 Wiki 当前 SourceRegistry、导航、宏组件和全局模板影响；
4. 在正式 Wiki 改动发生后再运行其内容契约与浏览器验证；本轮按用户要求没有运行这些测试；
5. 为 en-GB 制定真实翻译计划，或收缩英文入口的承诺；
6. 在 Wiki 子模块先提交并推送，再由父仓库更新 gitlink。

## 6. 结论

当前 Wiki 的核心问题仍是“结构大于已审阅内容”：96 篇中 30 placeholder、53 draft、0 published，且高价值集成、热重载、维护者专题长期缺正文。这个 change 已把回应方式从早期 11 篇锚点扩展为 200 篇完整 draft，并用 15-topic 配额、D9 深度合同、源码 grounding、失败/恢复模型和双向采用目录形成可审阅交付。

它现在可以作为 Wiki 内容采用的来源包，但仍不是正式 Wiki 发布。质量结论限于文章内容与只读一致性审计；正式迁移、站点验证和发布状态仍属于后续 Wiki 子模块工作。
