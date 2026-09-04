# Daslang / AngelScript 架构持续对比记录

> **所属前缀**：Diff_（外部参考实现差异分析）
>
> **维护方式**：本文件是 Daslang（仓库名仍为 daScript）与 AngelscriptProject 的持续讨论总档。每轮讨论先保留日期、问题、证据与当时判断；经源码核实后，再把稳定结论整理进对应主题章节。后续相关讨论继续更新本文件，不另建零散报告。
>
> **结论边界**：本文区分源码事实、架构推断与尚未实测的性能判断。除非明确列出基准结果，否则“更快”“更省”等表述只代表实现结构上的倾向，不代表同机横向性能结论。
>
> **初始分析日期**：2026-08-21
>
> **参考版本**：
>
> - `Reference/daScript`：`ae21253fea2b8184f81c00013f2684c98c31174d`
> - `Plugins/Angelscript`：`ed22fbdf0fc1a3793b006bb703aeb62a7500b25a`

---

## 一、当前稳定结论摘要

### 1.1 Semantic Hash 与 Cache V2

1. daScript 的 **Semantic Hash 并不等价于整套 Cache V2**。它主要是完整编译和 `simulate` 之后的函数执行图指纹，用于把当前函数匹配到预编译 C++/LLVM AOT 入口。
2. daScript 真正用于跳过部分前端编译的是 **AstSerializer**；它与 Semantic/AOT Hash 是相邻但独立的机制。
3. daScript `Function::hash` 大致对应我们的函数 Execution Content；`Function::aotHash` 横跨了我们的函数内容、内容敏感依赖和直接调用工件集合概念；`AotLibrary` 最接近 StaticJIT Provider Matcher。
4. Cache V2 的职责更广：稳定身份、源码与环境验证、typed dependencies、函数级恢复、零前端 Exact Startup、内容寻址记录、不可变 generation 和事务发布。
5. 不应以一个 64 位 Semantic Hash 替代 Cache V2。值得借鉴的是“编译后执行语义指纹”和“Hash Recipe 可解释诊断”。

### 1.2 词法分析

1. AngelScript 内核是 **手写单 Token 扫描器 + 手写递归下降 Parser**；daScript 是 **Flex Lexer + Bison Parser**。
2. daScript 当前不是只有一条 Lexer：默认走 Gen2 的 `ds2_lexer` / `ds2_parser`，但文件可通过 `options gen2 = false` 切回 Gen1，因此 `ds_lexer` / `ds_parser` 仍是有效兼容路径。
3. AngelScript 的核心 Tokenizer 很轻，只识别 Token 边界和类别；数值转换、溢出和字符串转义主要后移到 Compiler。daScript Lexer 更“重”，会直接构造数值、检测范围、维护括号状态、自动插入分号/逗号、处理 include、字符串插值和 reader macro。
4. daScript 的词法能力更丰富，但 Lexer 同时承担布局规则、部分预处理、宏重写、语义值构造和错误检查，耦合明显更高。
5. UE AngelScript 在核心 Tokenizer 之前还有 `FAngelscriptPreprocessor`。它用另一套手写字符状态识别注释、字符串、指令、UCLASS/UFUNCTION、namespace、import 和 f-string，造成“宿主扫描器 + 核心扫描器”重复。
6. 两边当前都没有一个适合作为统一前端真相的、可复用的完整 TokenBuffer：AS Parser 按 byte offset 反复调用 Tokenizer；daScript Flex 流也是边扫边喂给 Bison，并依赖 `unput`、buffer stack 和合成 Token。
7. 当前 `refactor-as-source-aware-lexical-pipeline` OpenSpec 的方向仍然成立。应借鉴 daScript 的可重入扫描状态、显式字符串/注释状态和直接位置携带，但不应照搬 Flex/Bison、Lexer 内 include/macro 重写、数值语义转换或换行补 Token 规则。

---

## 二、Semantic Hash、AOT Hash 与 Cache V2

### 2.1 正确的职责映射

| daScript 机制 | 实际职责 | AngelscriptProject 中最接近的机制 |
|---|---|---|
| `TypeDecl::getSemanticHash()` | 类型语义指纹 | Stable Type Key、TypeSchema、布局/ABI Hash |
| `Function::hash` | 当前函数降级后 SimNode 执行树的 64 位指纹 | `FunctionContentHash.Execution`，但表示层不同 |
| `Function::aotHash` | 函数自身加传递函数依赖的 AOT 路由键 | `FunctionInputDigest`、ExecutionHash、StaticJIT `ArtifactSetDigest` 的混合概念 |
| `AotLibrary[aotHash]` | 从当前函数指纹找到原生入口 | `FAngelscriptJITProviderMatcher` |
| `AstSerializer` | 保存和恢复编译后的 Program/AST 对象图 | Cache V2 Store、Manifest、ModuleSnapshot、Exact Startup，但粒度更粗 |
| 文件名、mtime、Serializer Version | 编译快照的快速有效性检查 | SourceSnapshot、Compatibility、Context、Artifact Profile |
| AOT 缺失后解释执行或报错 | AOT fallback | 单函数 VM fallback / authoritative source compile |

没有任何一个 daScript 字段能一对一替代 Cache V2。daScript 把 AOT 的许多匹配条件压进一个 64 位值；我们把身份、输入、内容、环境、入口 ABI 和直接调用集合拆开验证。

### 2.2 daScript Function Semantic Hash

`SimFnHashVisitor` 遍历已经生成的 `SimNode` 执行树，使用 64 位 FNV-1a，写入：

- 节点操作名、节点大小和类型描述；
- 栈位置；
- 函数、整数、浮点数、字符串等节点参数；
- 子节点数量、顺序和结构；
- 函数返回类型和每个参数类型的 Semantic Hash；
- 对 `aotHashDeppendsOnArguments` 函数额外写入参数名和默认值表达式文本。

证据：

- `Reference/daScript/src/simulate/simulate_fn_hash.cpp:22`：`SimFnHashVisitor` 与 64 位 FNV-1a；
- 同文件 `:110`：单个 `SimNode` 的 Semantic Hash；
- 同文件 `:118`：函数签名类型与执行树组合。

因此，这里的 “semantic” 更准确地说是 **post-lowering execution graph fingerprint**。它不是源码 Hash，也不是严格的语言语义等价证明。两个源码写法产生相同 SimNode 时可能复用同一 AOT 指纹；但栈位置、节点形状或优化形式不同，即使行为等价也可能产生不同 Hash。

该实现直接 Hash 本机整数、浮点等字节表示，更适合同一目标环境中的 AOT 路由，不应当作跨平台永久身份。

### 2.3 类型 Semantic Hash

函数 Hash 前会加入返回类型和参数类型的 Semantic Hash。类型 Hash 会考虑基础类型、结构体、枚举、注解、嵌套类型、参数名称、定长数组、宏表达式和类型标志。

证据：

- `Reference/daScript/src/ast/ast_typedecl.cpp:529`：`TypeDecl::getSemanticHash()`；
- `Reference/daScript/src/ast/ast.cpp:214`：结构体字段、类型和 alias 的 own semantic hash。

这一原则和 Cache V2 一致：函数有效性不能只由函数源码决定，类型和布局也必须参与。但 daScript 最终多把这些信息折叠进函数 Hash；Cache V2 保留独立 TypeSchema、Interface ABI、Property/Layout 和 typed dependency edges。

### 2.4 AOT Hash 与依赖闭包

`getFunctionAotHash()` 会：

1. 从当前函数遍历 `useFunctions`；
2. 遍历 `useGlobalVariables`，继续发现全局引用链里的函数依赖；
3. 按 mangled name 对函数依赖排序；
4. 收集当前函数和非 builtin、非 `noAot` 依赖函数的 `Function::hash`；
5. 使用 `hash_block64`/wyhash 生成最终 64 位 AOT Hash。

证据：`Reference/daScript/src/simulate/simulate_fn_hash.cpp:148` 和 `:229`。

结果是低层 callee 内容变化会级联改变传递调用者的 AOT Hash。这对可能包含静态直接调用的 C++ AOT 是安全的，但也比较保守，因为它没有区分签名依赖、布局依赖、全局值依赖和函数内容依赖。

daScript 还提供 `getAotHashComment()`，输出当前函数和每个依赖函数的 Hash，见同文件 `:252`。这类可解释 Hash Recipe 是可直接借鉴的设计。

### 2.5 AOT Hash 的使用时机

daScript 在完整前端编译和 `simulate` 之后才获得实际 SimNode，随后 `Program::linkCppAot()` 计算 AOT Hash，在 `AotLibrary` 中查找原生函数并替换解释执行节点。

证据：

- `Reference/daScript/src/ast/ast_simulate.cpp:4074`：为模拟后的函数计算 Hash；
- 同文件 `:4145`：`Program::linkCppAot()`；
- `Reference/daScript/daslib/aot_cpp.das:4285`：生成 AOT Hash 到原生入口的注册表。

Semantic Hash 本身不能跳过读取源码、Parse、类型推导、优化和 SimNode 构造。它更接近 StaticJIT 工件匹配，而不是 Cache V2 Exact Startup。

### 2.6 AstSerializer 才是编译快照

AstSerializer 可以保存 Program/AST 对象图，包括 Module、Structure、Function、Variable、Expression、类型关系、Function Hash 和 AOT Hash。当前 serializer version 是 `109`。

证据：

- `Reference/daScript/include/daScript/ast/ast_serializer.h:223`：版本；
- `Reference/daScript/src/builtin/module_builtin_ast_serialize.cpp:1410`：结构与函数记录；
- 同文件 `:2824`：module-cache 版本门；
- `Reference/daScript/src/ast/ast_parse.cpp:584`：filename/mtime 驱动的读取路径。

一旦遇到第一个新模块或不匹配，会设置 `seenNewModule`，后续模块不再继续尝试旧 reader 复用。它更像顺序化的内部编译快照，而不是随机访问的内容寻址记录仓库。

AstSerializer 还使用指针位模式加 epoch 作为同一序列化流内的 node identity。恢复时不会把旧地址当可反引用指针，但这种内部对象图协议仍不同于 Cache V2 的稳定、无指针 DTO。

### 2.7 Cache V2 的分层身份

Cache V2 分别维护：

- Stable Module/Type/Function Key；
- Function Source Digest；
- Function Input Digest；
- Execution/Debug Content Hash；
- Interface/Type/Layout ABI；
- Compatibility、Context 和 Artifact Profile；
- SourceSnapshot、RecordId 和 Generation Manifest。

所有 canonical hash 最终使用 256 位 BLAKE3，并通过 domain tag 区分用途。

证据：

- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/Artifacts/AngelscriptArtifactIdentity.cpp:148`：BLAKE3 canonical writer；
- 同文件 `:238`：稳定 Module/Type/Function Key；
- 同文件 `:298`：SourceDigest 与 InputDigest；
- 同文件 `:321`：Execution 与 Debug 内容 Hash；
- 同文件 `:338`：Compatibility、Context 和 Profile。

### 2.8 Typed dependency 与函数级恢复

Cache V2 依赖边保留 dependency kind、stable target key、expected ABI 和可选 expected content/value。依赖类型包括 Import、Declaration、Signature、Inheritance、ValueLayout、PropertyLayout、GlobalStorage、HardValue、Initializer、CompileOption、EnvironmentAbi 和 FunctionContent。

恢复函数时，系统先要求当前 SourceDigest 与候选相同，再向当前 symbol authority 逐条解析依赖并重算 InputDigest。源码变化会直接 miss，从而让编译器重新发现依赖，避免沿用不完整的旧依赖集合。

证据：`Plugins/Angelscript/Source/AngelscriptRuntime/Cache/AngelscriptCacheCompilerBridge.cpp:428`、`:586` 和 `:672`。

### 2.9 Exact Startup、内容寻址与 StaticJIT 匹配

Exact Startup 会验证当前 Profile、SourceIndex、预处理观察、SourceSnapshot、模块集合和可恢复图，然后原子恢复整个 generation；该路径不调用前端编译器。

证据：

- `Plugins/Angelscript/Source/AngelscriptRuntime/Cache/AngelscriptCacheExactStartup.cpp:234`；
- `Plugins/Angelscript/Source/AngelscriptRuntime/Cache/AngelscriptCacheSourcePlanner.cpp:388` 和 `:547`；
- `Plugins/Angelscript/Source/AngelscriptRuntime/Cache/AngelscriptCacheArchive.cpp:137`：内容寻址 RecordId。

函数由源码编译或 Cache V2 恢复成为 authoritative current function 后，StaticJIT Matcher 还显式验证 ModuleKey、FunctionKey、Execution/Debug Hash、Profile、Native Environment、Entry ABI、所需入口、直接调用 ArtifactSet 和 stable references，并拒绝重复或歧义的 exact provider。

证据：`Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/AngelscriptJITProviderMatcher.cpp:150` 和 `:260`。

### 2.10 失效场景对照

| 场景 | daScript | Cache V2 / StaticJIT |
|---|---|---|
| 源码变化但最终执行树相同 | 完整编译后 Semantic Hash 可能相同，可继续匹配 AOT | Exact Startup 因源码快照变化而 miss；函数级复用取决于 canonical source |
| callee 只改函数体 | 传递调用者 AOT Hash 一般全部变化 | 只有内容敏感依赖传播；ABI-only 调用者可以复用 |
| 函数签名变化 | 参数/返回类型 Semantic Hash 改变 | FunctionKey、Signature ABI 和 InputDigest 精确变化 |
| 类型布局变化 | 类型 Semantic Hash 折入函数 Hash | 独立 TypeSchema/Layout ABI 沿 typed edge 传播 |
| 全局初始化变化 | 单独的 init/global AOT Hash 路径 | ModuleState、HardValue、Initializer、InitAction 显式建模 |
| 编译器或 Codec 变化 | Serializer Version；函数 Hash 是否变化取决于 SimNode | Compatibility/Profile 显式包含 schema、codec、产品/fork、UE 和目标环境 |
| 平台或架构变化 | Semantic Hash 本身没有独立平台域 | Profile 显式包含 platform、arch、pointer bits 和 endianness |
| 单函数不匹配 | 根据策略报 AOT link 错误或保留解释执行 | 当前函数单独 VM/编译 fallback |

### 2.11 当前建议

应当借鉴：

- 为 Function Artifact 提供统一、可读的 Hash Recipe 和 first-divergence 诊断；
- 如 TypedASTJIT/LLVM 后端确有跨编码语义复用需求，可研究 backend-private post-lowering semantic digest；
- Direct-call 后端可使用紧凑闭包摘要做候选预筛，但必须保留 typed dependency graph。

不应照搬：

- 单一 64 位 Hash 作为全部有效性依据；
- filename + mtime 代替内容和预处理依赖；
- 无类型的传递函数 Hash 取代 typed dependencies；
- 指针位模式或运行时 FunctionId 作为持久身份；
- 首个模块 miss 后放弃后续独立记录复用；
- 将环境、输入、执行内容和 Debug 内容混入同一个值。

---

## 三、AngelScript 与 daScript 词法分析实现对比

### 3.1 对比范围

这里区分三层：

1. **AngelScript 内核 Lexer/Tokenizer**：`asCTokenizer`；
2. **UE 宿主源码准备**：`FAngelscriptPreprocessor`；
3. **daScript 语言前端**：Gen1/Gen2 Flex Lexer 与对应 Bison Parser。

如果只把 `as_tokenizer.cpp` 与 `ds2_lexer.lpp` 横向比较，会漏掉 UE 宿主在核心 Tokenizer 之前做的大量扫描和重写，也会误以为 daScript 只存在一条 Lexer。

### 3.2 总体流水线

AngelScript 当前实际链路：

```text
.as authored source
    ↓
FAngelscriptPreprocessor
    - 手写字符状态扫描
    - #if/#else/#endif
    - UCLASS/UFUNCTION/UPROPERTY
    - import / namespace / comments
    - f-string、name literal、defaults 等重写
    - 产生 processed source 与 provenance
    ↓
asCParser::GetToken
    ↓ 每次传入 code + byte offset
asCTokenizer::GetToken
    - 返回一个 eTokenType + length
    ↓
手写递归下降 Parser
    ↓
Compiler/Sema 再解析数值和字符串语义
```

daScript 当前实际链路：

```text
.das source
    ↓
detectGen2Syntax 手写预扫描
    ↓
version_2_syntax ?
    ├─ true  → ds2_lexer(Flex) → ds2_parser(Bison)
    └─ false → ds_lexer(Flex)  → ds_parser(Bison)

Flex Lexer 内部还会：
    - 处理 include buffer stack
    - 处理注释和 CommentReader
    - 解析数值并检查范围
    - 分解字符串与插值
    - 执行 reader macro 文本回灌
    - 维护括号/布局状态
    - Gen1 合成缩进花括号
    - Gen2 在换行或 '}' 前合成分号/逗号
```

### 3.3 生成方式与 Parser 模型

| 维度 | AngelScript | daScript |
|---|---|---|
| Lexer | 手写 C++，`as_tokenizer.cpp` 约 466 行 | Flex `.lpp` 生成；Gen1 约 1297 行、Gen2 约 1047 行，Gen2 生成 C++ 约 4966 行 |
| Parser | 手写递归下降，`as_parser.cpp` | Bison grammar，pure/reentrant parser |
| 输入模型 | Parser 按 byte offset 请求一个 Token | Flex 连续扫描，Bison 持有 lookahead |
| 回退 | `RewindTo` 恢复 byte offset；只缓存最后一个 Token | Bison recovery 加 Flex `unput` 和 scanner state |
| Token 缓冲 | 没有完整 TokenBuffer | 同样没有完整持久 TokenBuffer |
| 并发状态 | Tokenizer 挂在 Engine；Parser 自有位置 | `%option reentrant`，每次解析有 `DasParserState` |

AngelScript Parser 中约有 300 处 `GetToken` 调用和 174 处 `RewindTo` 调用。`RewindTo` 的源码 TODO 已明确指出：除最后一个 Token 外，回退会导致同一文本再次 Tokenize。

证据：

- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_parser.cpp:962`；
- 同文件 `:1007`；
- `Reference/daScript/src/parser/ds2_lexer.lpp:64`：reentrant Flex 配置；
- `Reference/daScript/src/parser/ds2_parser.ypp:102`：pure Bison parser；同文件 `:107`：location 支持。

#### 3.3.1 Flex 与 Bison 是什么

Flex 和 Bison 都是**分析器代码生成工具**，不是 daScript 运行时临时加载的两套解析库，也不是完整编译器：

- **Flex**（Fast Lexical Analyzer Generator）读取词法规则，生成 C/C++ Lexer；Lexer 把字符流切分为 Token；
- **Bison**（GNU Parser Generator，兼容 Yacc 风格 grammar）读取语法产生式，生成 C/C++ Parser；Parser 把 Token 归约为语法结构，通常同时创建 AST；
- 名称解析、类型检查、常量求值、优化和代码生成仍由语言实现自己的后续阶段负责。

需要区分两个时间点：

```text
构建 daScript 编译器时：

ds2_lexer.lpp  ── Flex  ──→ 生成的 Lexer C/C++
ds2_parser.ypp ── Bison ──→ 生成的 Parser C/C++/Header
                                  ↓
                             C++ 编译与链接

运行 daScript 编译器时：

.das 字符流 ──→ 生成的 Lexer ── Token + value + location ──→ 生成的 Parser ──→ AST
```

因此，“Flex 生成 Lexer”中的“生成”发生在 daScript 编译器的构建阶段，而不是每次编译 `.das` 文件时重新生成 Lexer。

Flex 输入主要由正则式与动作组成。以下只是概念上的简化示意，不是 daScript 原文：

```lex
[0-9]+                  { return TOK_INTEGER; }
[a-zA-Z_][a-zA-Z0-9_]*  { return TOK_IDENTIFIER; }
"if"                    { return TOK_IF; }
"+"                     { return '+'; }
[ \t\r\n]+              { /* skip whitespace */ }
```

Lexer 对输入 `if value + 123` 的输出可以抽象为：

```text
TOK_IF
TOK_IDENTIFIER("value")
'+'
TOK_INTEGER(123)
```

Flex 通常选择当前位置能够匹配的最长规则；匹配长度相同时，规则顺序参与决定结果。规则动作仍然是语言实现编写的 C/C++，因此它可以远超“识别 spelling”：设置 semantic value、维护源码位置、切换字符串/注释状态、报告错误，甚至根据上下文合成 Token。

Bison 输入主要由 grammar 产生式和 semantic action 组成，例如：

```bison
expression:
      TOK_INTEGER
    | TOK_IDENTIFIER
    | expression '+' expression
    | expression '*' expression
    | '(' expression ')'
    ;
```

Parser 按需调用 Lexer 获取下一个 Token，并依据 grammar、lookahead 与分析栈完成移进/归约。产生式可以附加 C/C++ action，例如用 `$1`、`$3` 取得右侧成员的 semantic value，用 `$$` 设置当前产生式的结果，从而创建 AST 节点。Bison 常用 LALR(1) 作为默认 parser 类型，也支持其他 LR 表构造方式；所以不宜把“Bison”简单等同为唯一固定的 Parser 算法。

Flex/Bison 的经典接口常写成 `yylex` 与 `yyparse`。概念上的控制关系是：

```text
Bison Parser：需要下一个 Token
       ↓ 调用 yylex
Flex Lexer：返回 Token 类型，并携带 semantic value 和 source location
       ↓
Bison Parser：继续移进/归约，最终构造 AST 或报告语法错误
```

daScript Gen2 对这条桥接做了明确配置：

- `ds2_lexer.lpp` 通过 `%option reentrant` 生成可重入 scanner；
- `%option bison-bridge` 让 Lexer 接口接收 Bison 的 semantic value；
- `YY_DECL` 同时接收 `DAS2_YYSTYPE`、`DAS2_YYLTYPE` 和 `yyscan_t`；
- `ds2_parser.ypp` 使用 `%define api.pure full` 与 `%locations`，使 Parser 状态实例化，并在 grammar 中携带位置；
- `parseDaScript()` 创建 scanner，调用 `das2_yyparse(scanner)`，最后销毁 scanner。

对应到 AngelScript，功能角色相同但实现方式不同：

| 角色 | daScript | AngelScript |
|---|---|---|
| “识字” | Flex 规则生成 Lexer 状态机 | 手写 `asCTokenizer::ParseToken()` |
| “读句子” | Bison grammar 生成 LR 系 Parser | 手写递归下降 Parser |
| 语法表达 | `expression: expression '+' expression` | `ParseExpression()` 等 C++ 调用层级 |
| Token 读取 | Parser 调用 reentrant `yylex` | Parser 调用 `GetToken()` |
| AST 构造 | grammar semantic action | Parser C++ 逻辑直接创建节点 |

生成式与手写式各有代价：Flex/Bison 能集中展示 pattern 和 grammar，并自动生成大量状态机与分析表；生成代码本身却较难阅读，自定义诊断、上下文语法和恢复逻辑仍可能引入复杂状态。手写前端的控制流与诊断更直接，但 lookahead、rewind、优先级、恢复和扫描一致性都需要项目自己维护。

最重要的判断不是“生成一定比手写先进”，而是各阶段边界是否稳定。daScript 虽使用 Flex/Bison，Lexer 仍承担数值转换、字符串插值、include、reader macro、布局和合成 Token，因此“使用生成器”不等于“Lexer 天然轻量或纯粹”。对于 AS 当前重构，目标仍应是统一 lexical truth、稳定 Token/SourceRange、可重入状态和 `TokenBuffer`，而不是把迁移到 Flex/Bison 本身当成架构目标。

补充证据：

- `Reference/daScript/src/parser/ds2_lexer.lpp:53`：`yylex` 同时接收 value、location 与 scanner；
- 同文件 `:64`：`%option reentrant`；
- 同文件 `:65`：`%option bison-bridge`；
- `Reference/daScript/src/parser/ds2_parser.ypp:102`：`%define api.pure full`；
- 同文件 `:107`：`%locations`；
- `Reference/daScript/src/ast/ast_parse.cpp:931`：创建 Gen2 scanner；
- 同文件 `:966`：调用 `das2_yyparse(scanner)`；同文件 `:967`：销毁 scanner。

### 3.4 daScript Gen1 与 Gen2 都是有效路径

`CodeOfPolicies::version_2_syntax` 当前默认是 `true`，但 `detectGen2Syntax()` 会在源码中寻找 `options gen2`，允许单文件选择 Gen1 或 Gen2。`parseDaScript()` 根据结果初始化和执行不同的 scanner/parser。

证据：

- `Reference/daScript/include/daScript/ast/ast.h:1610`：Gen2 默认值；
- `Reference/daScript/src/ast/ast_parse.cpp:656`：语法版本预扫描；
- 同文件 `:927`：选择 `das2_yylex` 或 `das_yylex`；
- 同文件 `:965`：选择对应 Bison Parser。

Gen1 是缩进敏感语法。`ds_lexer.lpp` 维护 `indent` 状态和缩进深度，根据缩进合成 `OPEN_BRACE`、`CLOSE_BRACE` 和行末分号。

Gen2 使用显式 `{}`，但仍不是“换行只是空白”：Lexer 根据 Parser 通过 `DasParserState` 设置的 `das_indent_char`，在换行、EOF 或某些 `}` 前合成分号或逗号。

这说明 daScript Lexer 不只是 spelling scanner，而是语法布局处理器。

### 3.5 Token 识别策略

AngelScript `ParseToken()` 按固定顺序尝试：

1. whitespace；
2. comment；
3. constant；
4. identifier；
5. keyword/operator；
6. 最后返回单字节 `ttUnrecognizedToken`。

证据：`Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_tokenizer.cpp:148`。

关键字和操作符集中在 `as_tokendef.h` 的 `tokenWords` 表。Tokenizer 初始化时按首字节构造 jump table，并把候选按长度从长到短排列，保证 longest-match。

证据：

- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_tokenizer.cpp:50`；
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_tokendef.h:46`。

daScript 则由 Flex 正则规则和规则顺序实现 longest-match。固定关键字直接写成大量 `<normal>"keyword" return TOKEN` 规则，操作符与边界常通过 trailing context、`unput` 和 scanner state 消歧。

证据：`Reference/daScript/src/parser/ds2_lexer.lpp:267` 和 `:749`。

### 3.6 Token 表示

AngelScript Parser 的 `sToken` 只有：

```cpp
eTokenType type;
size_t pos;
size_t length;
```

它不拥有 spelling、行列、文件身份、literal value 或 trivia 关联。Parser/Compiler 需要时再从 `script->code[pos]` 取文本。

证据：`Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptnode.h:100`。

daScript 通过 Bison `YYSTYPE` 让 Token 直接携带 `int32`、`uint64`、`double`、`string*`、AST 指针等语义值；通过 `YYLTYPE` 携带首尾行列，再转换成包含当前 `FileInfo` 的 `LineInfo`。

证据：

- `Reference/daScript/src/parser/ds2_parser.ypp:107`；
- 同文件 `:114`；
- 同文件 `:4414`。

daScript Token 对 Parser 更方便，但 Lexer 与 AST/内存管理的耦合也更强；例如普通 NAME 会在 Lexer 中直接 `new string(yytext)`。

### 3.7 标识符与关键字

AngelScript 标识符默认是 ASCII 字母/下划线开头，后续允许数字。开启 `allowUnicodeIdentifiers` 时，任何最高位为 1 的字节都会被当作标识符组成部分；这里没有在 Lexer 内做完整 UTF-8 解码、Unicode category 判断或 normalization。

证据：`Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_tokenizer.cpp:387`。

AngelScript 还有一批 contextual words，例如 `this`、`super`、`override`、`property`、`mixin` 等不全部作为固定 Lexer keyword，而是在特定 Parser/Sema 位置按 identifier spelling 判断。

证据：`Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_tokendef.h:315`。

daScript Gen2 的名称规则是 `[_[:alpha:]][_[:alnum:]\`]*`。它显式允许反引号出现在名称中，但没有看到 UTF-8 codepoint 解码或 normalization。固定语言关键字由 Flex 规则识别。

证据：`Reference/daScript/src/parser/ds2_lexer.lpp:405`。

Gen1 还会查询模块动态注入的 `das_keywords`，把普通名字分类为 `KEYWORD` 或 `TYPE_FUNCTION`；Gen2 grammar 当前只声明 NAME 路径，不再使用这两个 Token。这是两代语法兼容面的一处真实差异，而不是简单的同一 Lexer 换括号风格。

### 3.8 数值字面量

AngelScript Lexer 只决定 spelling 边界和大类：

- 十进制整数；
- `0b`、`0o`、`0d`、`0x` based integer；
- 带小数点或 exponent 的 float/double；
- `f/F` 后缀。

实际整数转换、64 位宽度判断、溢出错误和 float/double 转换在 Compiler 中完成。

证据：

- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_tokenizer.cpp:245`；
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_compiler.cpp:15429`。

daScript Lexer 则直接：

- 接受数字分隔符 `_`；
- 识别 `u8/U8`、`u/U`、`l/L`、`f/F`、`lf/d`、`h/H` 等后缀；
- 使用 `fast_float::from_chars` 将 spelling 转换为目标数值；
- 在 Lexer 阶段报告 int、uint、uint8、float16、float、double 越界；
- 针对 `1..2` 等情况通过匹配后 `unput('.')` 与列位置修正消歧。

证据：`Reference/daScript/src/parser/ds2_lexer.lpp:443` 到 `:679`。

结论：daScript 字面量表面能力更丰富，但它把 literal semantic conversion 放进 Lexer。对于当前 AS Source-Aware Lexical Pipeline，不应照搬这一层次；RawLexer 应保留 spelling/range，由独立 literal decoder 或 Sema 完成值构造和类型决策。

### 3.9 字符串与插值

AngelScript 核心 Tokenizer 把普通单/双引号字符串或 `"""..."""` heredoc 作为一个整体 Token。它只寻找终止引号、处理反斜线奇偶和标记 multiline/non-terminated；真正的 escape decoding、字符字面量判断、heredoc trim 和字符串常量构造在 Compiler。

证据：

- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_tokenizer.cpp:328`；
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_compiler.cpp:15507` 和 `:15693`。

UE 的 f-string 不是核心 AngelScript Lexer 能力。`FAngelscriptPreprocessor` 识别 `f"..."`，在 authored source 上寻找边界，调用 `GenerateFormatString()` 产生普通 AngelScript 代码替换。

证据：`Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.cpp:4408` 和 `:4546`。

daScript Lexer 使用独立的 `strb`、`strfmt` 和 `reader` start condition：

- 开引号返回 `BEGIN_STRING`；
- 内容按 `STRING_CHARACTER` 或 `STRING_CHARACTER_ESC` 分段；
- `{` 切回 normal state，让 Parser 读取嵌入表达式；
- `}` 返回字符串状态；
- 格式段由 `strfmt` 处理；
- EOF 和嵌套字符串在 Lexer 阶段报错。

证据：`Reference/daScript/src/parser/ds2_lexer.lpp:162` 到 `:240`。

daScript 的字符串插值是 Lexer/Parser 原生协作；AS 当前是宿主源码重写。前者表达力强，后者保持核心语言较简单，但必须解决生成代码的 source provenance。

### 3.10 注释

AngelScript 核心 Tokenizer会返回 whitespace、single-line comment 和 multiline comment Token，Parser 再主动跳过。块注释遇到第一个 `*/` 即结束，不支持嵌套。

证据：

- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_tokenizer.cpp:165`；
- 同文件 `:196`；
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_parser.cpp:962`。

daScript Flex Lexer 通常不把注释交给 grammar，而是切换 `cpp_comment` / `c_comment` 状态并跳过内容。它支持嵌套 `/* ... */`，通过 `das_c_style_depth` 计数；同时把注释字符通过 `CommentReader` side channel 交给注册模块。

证据：`Reference/daScript/src/parser/ds2_lexer.lpp:102` 到 `:160`。

UE `FAngelscriptPreprocessor` 又实现了一套 `bInLineComment`、`bInBlockComment` 和 `bInString` 状态，用于文档注释、指令、chunk 和宏识别；`FindScopeCloseBracket()` 等 helper 还重复实现类似边界扫描。

证据：

- `Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.cpp:3510`；
- 同文件 `:4479`；
- 同文件 `:5049`。

这正是当前 Source-Aware Lexical Pipeline 想消除的“低层边界识别重复”，但宿主指令、反射描述符和源码重写本身仍应留在宿主层。

### 3.11 include、预处理与宏

AngelScript 内核 Tokenizer 不做 include 或宏展开。UE 宿主预处理器先处理：

- `#if/#ifdef/#ifndef/#elif/#else/#endif`；
- 禁止 `#include`，要求 `import` 或 automatic import；
- UCLASS/USTRUCT/UENUM/UFUNCTION/UPROPERTY/UMETA；
- namespace、defaults、delegate/event；
- f-string、name literal 和其他宿主重写；
- processed source provenance。

证据：`Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.cpp:3811`、`:3927` 和 `:4125`。

daScript 把部分源码准备直接放进 Lexer：

- `include` 规则通过 `FileAccess` 找文件，并 push Flex buffer；
- `#row,column,"file"#` line directive 直接切换当前 FileInfo 和行列；
- reader macro 可消费任意字符流，产生替换字符串，再 push 回 scanner；
- inline `%name! ... %%` reader macro 在 Lexer 规则里完成查询、执行和回灌；
- required module 能影响 Gen1 动态 keyword 集合。

证据：

- `Reference/daScript/src/parser/ds2_lexer.lpp:81`；
- 同文件 `:242`；
- 同文件 `:776`；
- 同文件 `:948`。

daScript 这种设计允许模块扩展编译期语法，但让 Lexer 的结果依赖当前 module library、FileAccess、ReaderMacro 和 ParserState。它不是可独立缓存或复用的纯 RawLexer。

值得注意的是，daScript 即使使用 Flex，也仍有 `detectGen2Syntax()`、`detectOptionLogRequire()` 等手写预扫描器，再次实现 comment/string 状态。因此“换成生成式 Lexer”本身并不会自动消除重复扫描。

### 3.12 Source Location 与生成来源

AngelScript `sToken` 只存 byte offset/length。错误时通过 `asCScriptCode::ConvertPosToRowCol()` 在 line position 表中二分查找行列。当前 maintained fork 还可以给 typed semantic span 应用 processed-to-authored/generated provenance，但这不是 Token 自身的统一 location authority。

证据：

- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptcode.cpp:128`；
- 同文件 `:153`。

daScript Flex 的 `YY_USER_ACTION` 在扫描时维护 first/last line/column，Bison `%locations` 将其传给 grammar；`tokAt()` 再把当前 `FileInfo` 与首尾行列组合成 `LineInfo`。include 和 reader rewrite 通过 buffer stack 保存/恢复文件、行和列。

证据：

- `Reference/daScript/src/parser/ds2_lexer.lpp:33`；
- `Reference/daScript/src/parser/ds2_parser.ypp:107`；
- 同文件 `:4414`。

daScript 的 Token location 比当前 AS `sToken` 更直接，但合成分号、`unput`、多行 reader macro 和 buffer rewrite 需要手工修正行列，已经出现专门的 phantom-column 回归测试。它说明“Token 自带行列”不是完整的 authored/processed/generated 映射替代品。

### 3.13 词法错误的归属

AngelScript Tokenizer 更接近纯分类器：

- 不认识的字节返回 `ttUnrecognizedToken`；
- 未终止字符串返回 `ttNonTerminatedStringConstant`；
- Parser 或 Compiler 再决定错误文案和上下文；
- 数值溢出与字符串 escape 错误主要由 Compiler 报告。

daScript Lexer 直接报告：

- 非法或越界数值；
- 未终止块注释、字符串、reader constant；
- 不匹配的 `()`、`[]`、`{}`；
- 非法缩进；
- reader macro 查找/歧义/输出错误；
- include/file lookup 错误。

这使 daScript 能在 Lexer 层给出很具体的错误，但也让 Lexer 依赖 AST、Program、Module、CompilationError 和宏系统。对 AS 重构而言，更合适的边界是：RawLexer 报稳定的 spelling/encoding/termination/range 类错误；语法、数值类型和宿主宏错误留给上层。

### 3.14 性能与内存：只能做结构判断

AngelScript 当前的有利点：

- Tokenizer 短小、手写、单 Token、无 spelling allocation；
- `sToken` 只有 type/offset/length；
- 固定关键字首字节 jump table 简单直接。

AngelScript 当前的成本：

- Parser 回退可能重复 Tokenize；
- UE Preprocessor 在 authored source 上先做一轮大型手写扫描；
- 多个 helper 再扫描 comment/string/delimiter；
- Parser 与 Tokenizer 没有共享 TokenBuffer。

daScript 当前的有利点：

- Flex DFA 通常线性前进；
- reentrant scanner 使每次编译状态隔离；
- 行列、括号状态和 lexer start condition 在扫描过程中持续维护；
- Bison 管理 lookahead，不需要 AS 式的大量 byte rewind。

daScript 当前的成本：

- NAME 在 Lexer 中分配 `std::string`；
- 字符串按字符/片段产生 Token；
- include、macro rewrite、`unput` 和合成 Token 增加状态复杂度；
- Gen1/Gen2 两套 Lexer/Parser 长期并存；
- Flex/Bison 生成文件大，源码调试经常需要在 `.lpp/.ypp` 与生成 C++ 间来回映射；
- Gen2 之前仍有手写语法探测扫描。

没有同机、同语义 workload 的 frontend benchmark，不能据此宣布哪边 Lexer 更快。当前能确认的是：AS 的主要优化机会不是“把手写 Lexer 换成 Flex”，而是避免同一 source generation 被重复扫描并减少 Parser rewind retokenization。

### 3.15 可维护性判断

AngelScript 的优点是核心 Tokenizer 容易读、Token vocabulary 集中、语言行为相对容易做精确单元测试。缺点是 Parser 直接依赖 byte offset 与 tokenizer，UE 宿主又复制了低层边界识别。

daScript 的优点是复杂词法模式写成声明式规则，字符串/注释/include/reader 状态明确，Parser 与 scanner 可重入。缺点是 Lexer 已演变成“词法 + layout + 预处理 + 宏执行 + 部分语义转换”的联合层，规则之间大量依赖 `unput`、嵌套计数和 ParserState；Gen1/Gen2 还存在行为分叉。

因此，两边的成熟方向不同：

```text
AngelScript 当前问题：层次太薄，宿主被迫复制扫描。
daScript 当前问题：词法层太厚，语言扩展和语法状态进入 Lexer。
```

理想的 AS 目标不在两者任一当前端点，而是：

```text
Immutable Source Buffers
    ↓
RawLexer（只识别 spelling/trivia/literal 边界）
    ↓
TokenBuffer + TokenCursor
    ↓
Parser / literal decoder / diagnostics

UE host source preparation
    ↑ 复用同一个 raw lexical truth
    └ 保留 directives、descriptors、rewrites、provenance
```

---

## 四、与 Source-Aware Lexical Pipeline OpenSpec 的关系

当前 OpenSpec：

- `openspec/changes/refactor-as-source-aware-lexical-pipeline/proposal.md`
- `openspec/changes/refactor-as-source-aware-lexical-pipeline/design.md`
- `openspec/changes/refactor-as-source-aware-lexical-pipeline/attachments/current-state-and-clang-reference.md`

### 4.1 daScript 对现有方向的验证

daScript 证明这些能力确实有价值：

- scanner state 必须是 compilation-local / reentrant；
- 注释、字符串、插值和 reader 模式需要显式状态；
- Token 应携带稳定 source range，而不是所有消费者自行数行；
- include/generated input 需要明确的 buffer/file stack；
- Parser 不应通过任意 byte offset 重扫源码完成普通 lookahead。

### 4.2 daScript 同时展示了需要规避的耦合

不能因为 daScript 使用 Flex/Bison，就把它当作 AS 重构的直接模板。以下做法不适合当前 OpenSpec 的边界：

- Lexer 内执行 include 文件发现和 buffer push；
- Lexer 内调用模块 reader macro 并把生成文本回灌；
- Lexer 内解析数值到最终值并决定目标宽度；
- Parser 通过共享 ParserState 指挥 Lexer 在换行生成不同 Token；
- 用 `unput` 和人工列修正维护复杂边界；
- 同时维护两套生产 Lexer/Parser 作为长期架构；
- 将 live scanner state 或 Token stream 直接持久化到 Cache V2。

### 4.3 对 OpenSpec 的具体建议

1. 保持 `SourceManager + RawLexer + TokenBuffer/Cursor + Host Adapter` 的既定分层，不改成 Flex/Bison 迁移。
2. 第一阶段优先统一 comment/string/delimiter 边界，让 UE Preprocessor 消费 shared lexical truth；不要先迁移 UCLASS 等宿主语义。
3. TokenBuffer 必须真正做到同一 source generation 单次扫描，并用 index/checkpoint 支持 Parser 回退；daScript 流式 scanner 本身没有解决这个目标。
4. Literal 先保存 spelling/range/lexical category；数值转换与目标类型选择留给 decoder/Sema。
5. 为 generated source、f-string 和 host rewrite 提供 authored/processed/generated mapping；不要把生成文本伪装为原文件位置。
6. 保留当前 AngelScript contextual keyword 语义；不要因为 daScript 固定关键字更多而扩大 Lexer keyword 集。
7. nested block comment、Unicode identifier normalization、数字分隔符等属于语言行为变化，必须另开兼容性提案，不能混入等价词法重构。
8. 将 lexical contract revision 纳入 Cache V2 Compatibility/Profile 的安全 miss 条件，但不要持久化 live TokenBuffer。

### 4.4 已验证的宿主扫描漂移风险

`FAngelscriptPreprocessor::ParseIntoChunks()` 的 `IsStartOfIdentifier()` 当前只把前置数字 `0` 和 `1` 判为 identifier continuation：

```cpp
if (PrevChar >= '0' && PrevChar <= '1')
    return false;
```

证据：`Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.cpp:3608`。

这应被视为重复手写扫描器容易漂移的直接证据。当前对比只记录该事实，不在本文中修复；实现变更前应先用 focused regression test 固定现状和预期，再决定是否作为兼容性修正。

---

## 五、当前可借鉴项与不可照搬项

### 5.1 值得借鉴

- daScript scanner 的 reentrant、per-compilation state；
- 对 comment/string/interpolation/reader 等模式使用显式状态，而不是散落布尔组合；
- Source range 在 Token 产生时形成，并能关联当前 source buffer；
- include/generated sequence 使用显式 source stack 的思想；
- nested delimiter 的边界错误能尽早分类；
- CommentReader 说明 trivia 可以通过受控 side channel 服务工具，而无需进入普通 AST；
- Semantic/AOT Hash 的 `getAotHashComment()` 式可解释配方。

### 5.2 不应照搬

- Flex/Bison 作为 AS 前端重构的目标本身；
- Gen1/Gen2 两套生产 Lexer/Parser 长期共存；
- Lexer 内数值转换和目标类型决策；
- Lexer 内 include、macro lookup、macro execution 和 rewrite 回灌；
- Parser 状态决定 Lexer 在换行生成哪种语法 Token；
- 以 `unput` 加人工行列补偿作为主要回退模型；
- 将一个 64 位 Hash 作为缓存、AOT 和环境身份的统一真相；
- filename/mtime 作为持久化有效性的主要依据。

---

## 六、讨论记录

### 2026-08-21：Cache V2 与 daScript Semantic Hash

**问题**：daScript 是否也实现了一套类似 AngelscriptProject Cache V2 的 Semantic Hash 缓存？

**结论**：只说 Semantic Hash 时，不是。daScript 实际由 Semantic/AOT Hash 与 AstSerializer 两套邻接机制覆盖部分相似职责。Semantic Hash 是编译后 AOT 路由键；AstSerializer 才能跳过部分前端。两者组合仍没有覆盖 Cache V2 的 typed dependency、内容寻址、Exact Startup、transactional generation 和 StaticJIT 多条件精确匹配。

**决策**：不以 Semantic Hash 重构 Cache V2；后续优先考虑 Hash Recipe 诊断和 backend-private semantic digest 的可行性。

### 2026-08-21：AngelScript 与 daScript 词法分析

**问题**：双方 Lexer/Tokenizer、Parser 输入、宿主预处理和宏系统有什么本质差异？

**结论**：AS 内核更轻、更手写、更按需，但宿主重复扫描且 Parser rewind 会重做词法；daScript 更生成式、更状态化、能力更强，但 Lexer 吞入了布局、include、宏执行和 literal conversion。daScript 默认 Gen2、保留 Gen1，且没有我们计划中的统一 TokenBuffer/SourceManager。

**决策**：继续现有 Source-Aware Lexical Pipeline 分层；借鉴 reentrant state 和 location 思想，不迁移到 Flex/Bison，也不把 daScript 的宏/layout 语义带入 RawLexer。

### 2026-08-21：Flex 与 Bison 概念补充

**问题**：所谓“Flex 生成 Lexer、Bison Parser”具体是什么，它们之间怎样配合？

**结论**：Flex 与 Bison 是构建期代码生成器。Flex 把正则式与词法动作生成 C/C++ Lexer，Bison 把 grammar 与 semantic action 生成 C/C++ LR 系 Parser；运行时由 Parser 按需调用 Lexer，接收 Token、semantic value 和 source location，再归约并创建 AST。生成器只替代状态机和分析表的手写工作，不替代语言的语义分析，也不自动保证 Lexer/Parser 职责纯净。

**决策**：继续把 daScript 的 Flex/Bison 方案作为实现对照，而不是 AS Source-Aware Lexical Pipeline 的迁移目标；优先吸收 reentrant state、稳定 location 与集中词法规则的思想。

**待验证**：

- 当前 Cache V2 Profile 是否已经完整覆盖 lexical contract revision；
- AS Parser rewind 在真实 Script corpus 中造成的重复 tokenization 比例；
- UE Preprocessor 各 helper 对同一 source generation 的重复扫描次数与时间；
- TokenBuffer 后的峰值内存与 frontend compile-time 变化；
- f-string、name literal、generated defaults 的 authored/processed/generated mapping 完整性。

---

## 七、关键源码索引

### AngelScript / UE

- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_tokenizer.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_tokenizer.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_tokendef.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_parser.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptnode.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptcode.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_compiler.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/Artifacts/AngelscriptArtifactIdentity.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Cache/AngelscriptCacheCompilerBridge.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Cache/AngelscriptCacheExactStartup.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/AngelscriptJITProviderMatcher.cpp`

### daScript

- `Reference/daScript/src/parser/ds_lexer.lpp`
- `Reference/daScript/src/parser/ds2_lexer.lpp`
- `Reference/daScript/src/parser/ds_parser.ypp`
- `Reference/daScript/src/parser/ds2_parser.ypp`
- `Reference/daScript/src/parser/parser_state.h`
- `Reference/daScript/src/parser/parser_impl.cpp`
- `Reference/daScript/src/ast/ast_parse.cpp`
- `Reference/daScript/src/simulate/simulate_fn_hash.cpp`
- `Reference/daScript/src/ast/ast_simulate.cpp`
- `Reference/daScript/src/builtin/module_builtin_ast_serialize.cpp`
- `Reference/daScript/include/daScript/ast/ast_serializer.h`
- `Reference/daScript/daslib/aot_cpp.das`
