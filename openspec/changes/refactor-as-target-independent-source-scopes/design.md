# 研究状态

这不是实施设计，也不构成对现有 `#if`、Cache V2、StaticJIT 或打包行为的修改承诺。

当前主要研究问题：

1. daScript `static_if` 在 Parser、AST、类型推导、常量折叠和 AOT 中如何流转？
2. 它是否消除了平台/构建配置造成的多份 AOT，还是只把分支选择从文本预处理移动到语义阶段？
3. 在不要求 `Script/Editor`、`Script/Dev` 等目录承担编译语义的前提下，AngelScript 的局部/顶层 Target Conditional 应如何映射到模块、类型和函数变体？
4. 哪些 Profile Variant 的语义/AOT Body 实际相同并可去重，哪些 Profile、ABI、Native Environment 和最终二进制身份必须继续分开？
5. 如何把模块、类型结构、初始化、函数 Entry 和函数 Body 的 Profile 差异合并到一棵 Generated AOT Source Tree，同时冻结自定义宏配置并避免组合爆炸？

当前研究判断：

- daScript `static_if` 是“解析后、分支语义分析前”的静态裁剪；未选分支不会进入名称/类型解析和 AOT。
- 它与 AOT 完全兼容，但编译环境相关条件会被烘焙进 AOT，因此不会自动消除多目标产物。
- 对 AngelScript 而言，把 `#if EDITOR` 原样替换成语言级 `static_if(EDITOR)`，只能改善编译器结构，不能解决三种 Target 语义变体。
- `Reference/myas` 实证表明局部 `#if EDITOR` 广泛存在于普通 Gameplay Actor/Component 中；完全禁止 Target Conditional 或全部迁入 Editor 目录不可行。
- 不再建议用目录或 `Editor/Dev` Source Scope 作为新方案的核心语义。目录可以继续用于代码组织，但源码发现、Profile Presence 和 AOT Guard 应由 Preprocessor Context、Canonical AST Diff 与明确的 Target Matrix 决定。
- 局部和顶层 Target Conditional 都可以继续存在：顶层条件自然表现为 Module/Decl Presence，类内条件表现为 Type Shape，稳定函数签名下的条件表现为 Function Body Variant。
- AOT 的候选优化方向改为构建精确 Profile Variant 后按 Semantic/Execution Hash 合并实际相同的函数 Body，并保留薄 Profile Catalog；不再强求三个 Profile 只有一棵 materialized AST。
- 新 `refactor-as-canonical-typed-ast-compiler` worktree 的 sealed Canonical Typed AST 很适合作为三 Profile 的差异权威和 AOT 输入，但它目前仍是 LEGACY 默认下的迁移平台与有限 CANONICAL CodeGen 子集，不能把已有绿色测试误认为生产切换已经完成。
- 三个 Profile 的 sealed AST 不应被物理改写成一棵可变 AST；候选合并层应建立只读 `Profiled AST Overlay`，用稳定声明锚点把各 Snapshot 节点分组，并让生成器引用原 Snapshot 节点。
- 合并至少需要区分 `DeclAnchorKey`、`SemanticSubtreeHash` 和 `NativeAOTVariantKey`：前者负责跨 Snapshot 对齐，第二个判断语言语义是否相同，第三个再叠加类型布局、Entry ABI、Native Call Route、执行策略和 Backend Schema，证明最终 C++ Body 是否可以共享。
- 目标生成形态是 Stable Function Variant Group：三个 Profile Body 全同则生成一份，形成两组则生成两份，只有三个最终 Body/依赖 ABI 全不同时才生成三份；结构/布局差异按依赖闭包保守提升变体范围。
- “只生成一份 AOT”明确指一棵 Guarded Generated C++ Source Tree，不代表跨 UE Target 共用一个 DLL 或放松 Profile/ABI 精确匹配。候选生成仍允许 ED/GD/GS 各做一次隔离的 AS Source Compile，再合并冻结语义快照与 Backend Candidate。
- 合并层级不能只有“函数内/函数外”：至少需要 Module Presence/Surface、Type Shape、Initialization、Function Presence/Entry 和 Function Body 五类。文本缩进只用于诊断，最终 Frozen Semantic Snapshot Diff 才是归类与共享安全性的权威。
- 模块级先用 Presence Mask 包整 TU 或局部实体；类型级用 Type Shape/Layout 与 Semantic Dependency Closure 只提升受影响函数；函数级把存在性、Entry ABI 与最终 Native Body 分开分组。
- 当前 `Dev/` 只被 `EditorDevelopment` 包含、`GameDevelopment` 也会跳过，这是现有实现事实而不是新方案的推荐边界。新方案不赋予目录隐式 Profile 含义；一个完整模块是否存在也由同样的 AST Presence Diff 得出。
- 自定义 `PreprocessorFlags` 当前都是 Settings 注入的 true-only Build Inputs，并且已进入 Cache V2 Artifact Profile。单树方案默认把它们冻结为一个 Build Feature Set，配置变化必须重新生成；只有显式声明的 Profile-Mapped Flag 才进入有限 Target Matrix，不支持任意 `2^N` 组合。
- `WITH_SERVER_CODE`、`COOK_COMMANDLET` 等不在当前 ED/GD/GS 覆盖矩阵中的轴必须冻结、扩展为明确 Target Row 或拒绝；不能只生成一侧 AS 语义却在 C++ 中假装支持双方。

完整证据、限定条件和对比见 `attachments/ue-script-hosting-and-aot-research.md`。
