# AngelScript 增量脚本 Cache 研究记录

## 记录范围与当前结论

本记录是 `refactor-as-incremental-function-cache` 的渐进研究主档，专门处理预编译脚本 Cache；兄弟 change `refactor-as-static-jit-external-module` 处理外置 Native Provider、生成模块工具、Editor/PIE Native 路由和 Live Coding。两者只共享稳定函数工件身份，不共享磁盘存储、generation、失效状态或回退策略。

最终方向不是“每函数一个 cache 文件”，也不是“继续保存一个完整 `.cache`”：

- 逻辑上按 source/module/type/global/function/debug 切片。
- 物理上把大量小记录聚合到少量 immutable pack。
- 对活动 AngelScript engine 仍按完整 module transaction 装配和激活。
- 所有目标第一次启动都可从 loose `.as` 生成 Saved Cache；以后按依赖增量更新。
- 当前 V2 尚未实现；本轮只把研究、规格和可执行计划记录到 OpenSpec。

## 1. 当前 Cache 到底怎么配对

### 1.1 当前文件不是函数级分散存储

当前脚本预编译数据主要集中在 `Script/PrecompiledScript.Cache`。`StaticJIT/PrecompiledData.h/.cpp` 在同一个 archive 中混合保存：

- module：函数、class、enum、delegate、global、import、code hash、post-init、文件信息；
- class/type：继承、property、method table、constructor/factory/behavior、反射 metadata；
- function：声明、traits、bytecode、stack/locals、line/debug、UFUNCTION metadata、numeric ID；
- global：global property、initializer function、初始化顺序；
- archive-global relocation：TypeReferences、FunctionReferences、Global/Property references、StaticNames、旧指针 token；
- 顶层环境：随机 `DataGuid` 和 `BuildIdentifier`。

因此当前实现虽然内部存在 `FAngelscriptPrecompiledFunction`，但物理和引用模型仍是一个全局混合快照，不能把单个函数当作独立、可验证、可跨 generation 复用的记录。`Binds.Cache` 是另一个独立缓存，不属于这个 archive，也不在本 change 中重构。

### 1.2 当前 FunctionId 不是稳定身份

`FAngelscriptPrecompiledData::CreateFunctionId()` 会受到 module `CombinedDependencyHash`、当前处理顺序、32 位碰撞递增和 synthetic function 随机 ID 影响。生成的 StaticJIT 注册代码也使用这个 numeric ID，再通过全局 `FJITDatabase` 和 whole-cache `DataGuid` 配对。

结果是：

- 其他函数或依赖变化可能改变目标函数 ID；
- hot reload 新建的 `asCScriptFunction` 可以得到不同 ID；
- 两个 engine 可以复用相同 numeric ID 表示不同函数；
- whole-cache GUID 不匹配只能整体清空，不能逐函数路由。

结论：numeric FunctionId 只能保留为当前 engine 的临时索引。持久化和 StaticJIT 路由必须使用完整 256 位稳定函数键；显示 GUID 只能用于日志/UI。

## 2. 当前源码、module 与依赖粒度

### 2.1 一个 `.as` 通常对应一个 module，但 module 可能包含多 section

预处理器默认从规范化文件名派生 `FAngelscriptModuleDesc::ModuleName`；显式 module 名、include 和 processed sections 可以让一个 module 关联多个 source section。`FAngelscriptModuleDesc` 当前包含：

- `Code[]`：VirtualPath、RelativeFilename、AbsoluteFilename、processed Code 和 section CodeHash；
- module `CodeHash` 与 `CombinedDependencyHash`；
- Classes、Enums、Delegates、ImportedModules、PostInitFunctions；
- 编译后的 `asCModule*` 和旧 precompiled 状态。

所以“源文件”适合作为扫描/变化发现单位，“module”适合作为声明图和活动提交单位，但函数体仍可以作为 module 内部的复用单位。

### 2.2 已有依赖图可作为语义失效基础

`asCModule::FModuleDependencyInfo` 已记录：

- 首次依赖位置；
- `bIsHardValueDependency`；
- `bIsStructuralDependency`。

`DiffForReferenceUpdate` 及 `FAngelscriptEngine::CompileModules()` 已经用这些边区分代码级变化、hard value 变化和 structural 变化，并扩展热更新依赖闭包。Cache V2 应持久化并复用这套语义，而不是仅凭 whole-module content hash 猜测失效范围。

## 3. 编译与恢复接入点

### 3.1 当前 Engine transaction

`FAngelscriptEngine::CompileModules()` 的主要顺序是：

1. preprocess/source descriptor 已准备；
2. 各 module `BuildParallelParseScripts()` 可并行 parse；
3. `CompileModule_Types_Stage1` 创建 type；
4. `CompileModule_Functions_Stage2` 创建 declaration/layout；
5. `CompileModule_Code_Stage3` 调用 `BuildCompileCode()`；
6. `CompileModule_Globals_Stage4` 完成 globals；
7. dependency diff、module swap、ClassGenerator/reflection/reinstancing；
8. transaction 成功后对外发布活动 module。

旧预编译恢复也按 module 分阶段注册 type、layout/property/import/global/function，再处理函数体、global 和 JIT。这证明新的 cache 可以复用现有“先声明、后引用解析、最后激活”边界，但不能在活动 engine 中随意附加孤立函数。

### 3.2 函数级跳过编译需要维护的 AS C++ fork hook

`asCBuilder` 内已有：

- `sFunctionDescription`：script/node/name/objType/paramNames/funcId/shared 状态；
- `sFactoryDescription`；
- `sGlobalVariableDescription`；
- `CompileFunctions()`、`CompileFactory()`、`CompileGlobalVariables()`；
- generated constructor/destructor、factory 和 `__InitDefaults` 的集中编译路径。

进一步逐入口核查后，不能把 `CompileFunctions()` 当成唯一入口：`BuildCompileCode()` 还有独立 factory loop，public `CompileFunction()` 也直接完成单函数编译。`sFunctionDescription` 不能完整描述 factory 和全部 synthetic/generated callable，因此实现必须引入 fork-owned、kind-tagged invocation descriptor，至少区分 regular、factory、default constructor、default destructor、`__InitDefaults` 和 public single-function，并携带 owner/module/namespace、source/token/node、declaration 和 generated traits/context。

在每个实际 `asCCompiler` 调用之前，可以从规范化 token/AST slice 与语义依赖计算 `FunctionInputDigest`；命中时不能只拷贝 bytecode 数组，而要通过 VM-private adapter 重建 instruction operand relocation、`scriptData`、stack/local object、line/debug metadata 及所有 function/type/global/property/string 引用。未命中才进入 compiler，成功后再 capture。这个 hook 修改的是插件维护的 AngelScript C++ 内部实现，不改变业务 `.as` 语法，也不要求脚本作者增加 UUID/annotation。

### 3.3 global initializer 不能伪装成普通独立函数

`CompileGlobalVariables()` 使用依赖求解循环和 hard-value 语义决定 primitive/complex global 初始化顺序。一个 initializer 的值、顺序或依赖可以影响同 module 的其他 globals。因此 V1 把 globals、constants、enum values、global initializer bytecode/order 和 post-init 组合成 `ModuleState`，整体命中或重编译；不承诺逐 global initializer 复用。

## 4. 为什么必须同时分类型、全局和函数

只存函数 blob 无法回答以下问题：

- class/property/继承布局是否仍可恢复；
- enum/delegate/interface/reflection metadata 是否变化；
- function declaration table、method slot、factory/behavior 顺序是否稳定；
- global storage 与 initializer order 是否匹配；
- ClassGenerator 应执行 soft reload、full reload 还是拒绝 PIE 中结构替换。

因此最终记录分为：

| 记录 | 主要内容 | 典型失效 |
|---|---|---|
| `SourceIndex` | 虚拟路径、raw hash、include/preprocessor 影响、source→module | 文件增删改、include/define |
| `ModuleInterface` | namespace、imports、declaration table、function order、依赖边 | 签名、owner、add/delete/import |
| `TypeSchema` | class/struct/interface/enum/delegate 布局与 reflection | property、继承、metadata、enum |
| `ModuleState` | globals/constants/initializer/order/post-init | global/value/hard dependency |
| `FunctionBody` | input digest、content hash、bytecode、locals/stack、稳定引用 | 单函数 body 或实际依赖 |
| `DebugSidecar` | source map、line cues、debug symbol | 格式/行号/debug profile |

`ModuleSnapshot` 引用这些记录。磁盘上不是一记录一文件；manifest 将记录定位到 pack offset。这样既能按函数/类型失效，也能让完整 module warm load 顺序读取。

## 5. TypeDatabase 与环境 ABI

当前 `FAngelscriptTypeDatabase` 是运行中的 UE/AS 类型适配注册表，不只是 cache relocation table。序列化或替换它会扩大耦合，并可能让 cache 读取改变 engine 全局状态。

Cache V2 新增只读 `EnvironmentSymbolCatalog`：

- 在 binds 完成后观察当前可见的 bound C++/AS type/function/property/global；
- 为每个实际 symbol 生成稳定 key 和 ABI fingerprint；
- Cache record 只保存自己真正使用的 symbol 依赖；
- unrelated bind 变化不会让所有脚本进入新 profile 或全部 miss。

`CompatibilityKey` 只包含格式、编译器/bytecode ABI、平台架构等根兼容项；Editor/Game、配置、preprocessor/source mount 等组成 `ContextKey`；二者组合成 StaticJIT 也能消费的 `ArtifactProfileKey`。具体 binding 变化走 per-symbol dependency，不混入一个全局 binding-surface hash。

## 6. Editor、PIE、Development 与 Shipping

### 6.1 当前行为

- Editor/development mode 通常不读取 `PrecompiledScript.Cache`，普通成功编译也不回写。
- `-as-generate-precompiled-data` 保存单体文件后请求进程退出。
- Runtime 编译器仍在 Development/Shipping 模块中；没有 cache 时从源码编译已有基础。
- Editor `DirectoryWatcher` 和 `ClassReloadHelper` 已支持脚本热更新和结构 reinstancing。
- `ECompileType::SoftReloadOnly`、`ECompileResult::PartiallyHandled` 和 `ErrorNeedFullReload` 已表达 PIE 中的结构限制。
- `UAngelscriptSubsystem::Deinitialize()` 最终调用 engine shutdown，是 flush 的明确生命周期入口。

### 6.2 已确认目标

- Editor：每次成功 compile/hot reload 后异步发布；关闭 Editor 时最多 flush 5 秒，不在 shutdown 临时编译新源码。
- PIE：body change 可以立即 soft reload；结构变化保留活动实例安全，待 PIE 结束后 full reload。尚未激活但已成功编译的结构工件只能进入 `PendingColdStart`，不能让 `Current` 与活动 engine 状态分叉。
- Development/Shipping 冷启动：loose source 可包含结构变化；cache miss 正常编译并发布。
- packaged live reload：默认 `Disabled`；`Manual`/`Automatic` 只接受 code-only，结构变化返回 `RequiresRestart` 并保留旧活动 module。
- 当前 source 在 fresh startup 编译失败：source 权威，不能静默执行旧 cache。包体以非零状态失败；Editor 进入明确的脚本初始化失败状态，不激活旧脚本。
- hot reload 编译失败：保留当前活动 last-good module，`Current` 不前移。

## 7. 打包与真实测试

### 7.1 当前打包链

`Config/DefaultGame.ini` 目前用 `DirectoriesToAlwaysStageAsUFS=(Path="../Script")` staging Script；`Tools/RunPackage.ps1` 默认先执行 `-as-generate-precompiled-data -as-skip-static-jit-codegen`，检查 `Script/PrecompiledScript.Cache`，再运行 `BuildCookRun -pak`。脚本 cache 生成和包体启动是两件事，现有脚本没有真正启动归档 executable，也没有多启动 cache smoke。

### 7.2 新打包链

- `Script/` 改为 loose NonUFS；UE cooked content 仍可使用 Pak。
- `RunPackage.ps1` 删除旧 cache pre-step。
- 包体第一次运行生成 `Saved/Angelscript/CacheV2`。
- 新的重型 `CachePackage` suite 分别构建 Development 和 Shipping，并在归档副本中创建/修改专用 loose `.as` fixture。
- 每个配置执行 cold、unchanged warm、one-body edit、invalid source、restore-last-good、structural cold-start 多次启动。
- runner 只修改 package archive 与隔离 cache root，不修改工作区业务 `.as`。

现有 `AngelscriptHotReloadPIESessionTests.cpp` 与 `AngelscriptPIETestUtils` 已提供真实 PIE start/world/end/cleanup，可直接作为最后一阶段 Cache PIE 验收基础。

## 8. StaticJIT 与 Live Coding 边界

Cache change 交付：

- `StableFunctionKey`；
- `FunctionContentHash`；
- `ArtifactProfileKey`；
- 当前 engine 稳定 key→临时 FunctionId/function pointer 的路由基础；
- 可供生成工具读取的稳定制品描述。

StaticJIT change 独立交付 provider ABI、生成模块、fixed buckets、Native entry、Editor refresh 和 Live Coding。Provider 缺失、移除、ABI/content mismatch 只让相关函数回 VM，不删除 Cache V2。UE Live Coding 的 patch-complete 可以触发 provider catalog/environment symbol refresh，但 Cache V2 正确性不能依赖 Live Coding 成功。

## 9. 已否决方案

- **一个 `.cache` 全量覆盖**：无法局部复用，崩溃写入风险高。
- **一函数一个文件**：大型项目造成文件数量、句柄、目录扫描和杀毒软件开销。
- **只按 module cache**：实现简单，但单函数 body 修改仍重编整个 module，不能满足目标。
- **只按 function cache**：忽略 type/global/interface/ClassGenerator 语义，不正确。
- **Shipping 只读 packaged baseline**：与用户确认的首启生成、外部可编辑 source 冲突。
- **打包前强制生成 Cache V2**：继续保留旧发布痛点，也不能验证 end-user 首启。
- **整个 binding surface 进入 profile**：一个无关 bind 变化会使所有脚本失效；改用 per-symbol ABI dependency。
- **用 source line/GUID annotation 稳定函数**：要求改业务源码且在移动代码后不稳定。
- **让 UE Live Coding 负责 AS Cache 更新**：Live Coding 只处理 C++ module patch，不是 AS source/cache correctness 机制。

## 10. 当前实现程度与后续记录规则

### 10.1 计划阶段结论

截至初始 OpenSpec 整理：

- 已完成：代码路径、现有数据模型、依赖图、compiler seam、Editor/PIE 生命周期、打包链和测试基础研究。
- 已完成：产品决策收敛和 decision-complete OpenSpec 设计。
- 未开始：任何 Runtime/Editor/ThirdParty/Tools/Config/test 源码实现。
- 当前 host `.uproject` 与 `AgentConfig.ini` 指向 UE 5.8；cache 的 `CompatibilityKey` 必须隔离 UE/bytecode ABI，不能假定不同 engine minor 可复用。

实施过程中新增证据继续追加到本文件；性能原始数据放 `benchmarks/`，验证日志/命令放 `verification.md`，`tasks.md` 只保留可勾选任务，不写过程性评论。

### 10.2 2026-08-08 实施启动接缝审计

在隔离 worktree 逐段复核 Runtime、维护的 AS fork、StaticJIT 和测试入口后，新增以下必须约束：

- 旧 `PrecompiledData` 不是普通 DTO archive；它重建 AS 私有对象图，并在 `Process()` 中逐指令重定位 bytecode operand。新 FunctionBody restore 必须保留同等级 VM 语义，不能把 `CompileFunctions()` 简化为 blob attach。
- `BuildCompileCode()` 的 factory loop 与 public single-function `CompileFunction()` 不在普通 `CompileFunctions()` 覆盖范围内。测试矩阵与 hook 必须覆盖全部 compile family。
- environment catalog 的可信采样点是 normal `Initialize` 和 `InitializeWithoutInitialCompile` 各自在 `Binds.Cache`/bind 与 `BindScriptTypes` 完成之后；`FAngelscriptTypeDatabase` 内含 live pointer，只能观察，不能序列化，也不能使用 process-global fallback 作为多 engine identity 来源。
- 完整 SourceIndex 必须包含 mounts/root descriptors、provider version、include graph、generated source、defines/conditional symbols、完整 logical inventory 和 case-collision 证据；现有 module `CodeHash` 不足以证明 exact snapshot。
- `CompileModules()` 只有在 swap、dependency publication、ClassGenerator/reflection/reinstancing 全部成功后，才能构造不可变 publication DTO。后台 worker 只消费 DTO，不允许回读 mutable module descriptor 或调用 AS engine API。
- 当前 `CompilationLock` 是诊断/状态用途，不是缓存正确性的串行化边界。每个 `FAngelscriptEngine` 需要独立 mutation transaction gate；并行只用于既有 parse-only 区域和纯数据 prepare/validate/pack。
- current-function route 只能从成功激活的 global/class/method/generated/factory 函数重建，排除 `_NEW_`/`_OLD_` 等临时 module；numeric FunctionId 始终只属于当前 engine。
- Cache V2 切换前要先建立明确的 StaticJIT compatibility bridge。遗留扫描范围不只 `PrecompiledData.*`，还包括 `AngelscriptStaticJIT.*`、`StaticJITDiagnostics.*`、`StaticJITHeader.*`、AOT/Precompiled archive tests、`Tools/Diagnostics/ParseAngelscriptCache.py`、state dump 和 config。

因此第一个 TDD vertical slice 收窄为“纯 value identity + canonical writer + golden vectors”，第二个 slice 是最小 canonical record/archive roundtrip。live engine catalog、current route 和 VM restore 都后移到具备 record contract 与声明/事务边界之后。

### 10.3 独立计划复审后的契约闭合

独立只读复审继续发现并修正了以下原计划矛盾：

- “编译前实际依赖”不能从 `sFunctionDescription` 凭空获得。固定算法改为：冷编译/未命中时 instrumentation 收集实际稳定依赖；warm lookup 先比 `FunctionSourceDigest`，相等后用持久依赖在当前 engine 的 ABI fingerprint 计算 `FunctionInputDigest`。源码摘要变化直接 miss，不增加第二个语义编译 pass。
- public single-function 可能是临时 snippet/debug expression，并会继续生成 lambda。invocation kind 增加 lambda，lookup result 增加 `NotCacheable`；没有稳定 module 坐标的调用正常编译但绝不持久化/capture。
- `RecordId` 与 `PackId` 语义不同：前者 hash canonical uncompressed record，后者 hash 最终 byte-exact pack（含 index/codec/size/stored bytes）。否则不同 Zlib 输出会产生同名异内容不可变文件冲突。
- generation manifest 明确且只能引用一个 SourceIndex；ModuleSnapshot 只装配 module-level records；FunctionBody 是 optional DebugSidecar 的唯一链接权威，避免双重集合漂移。
- 完整 SourceIndex 还包括 `Game`/`Plugin`/`Memory`、provider identity/version/config、development/editor filter、memory/generated bytes、preprocess hook fingerprint。无法稳定 fingerprint 的 provider/hook 禁用其作用域的 exact zero-preprocess fast path。
- `PartiallyHandled` PIE 可能需要“当前活动态 DTO”和“cold-start candidate DTO”两个不同对象；`CompileEnd` 只能诊断，不能异步回读已移动/释放的 VM 状态。
- Cache change 只移除 `PrecompiledScript.Cache` 生产路径与 DataGuid 的 Cache 正确性地位；在 sibling external provider 完成前，保留并清单化 `FJITDatabase`/numeric generated registration 等 StaticJIT transport，通过稳定 key bridge 使用，避免两份 OpenSpec 形成循环前置。
- packaged 非 Editor 首启增加明确的 typed initialization result；unattended invalid-source 默认非零退出，不能依赖旧的可选 `-as-exit-on-error`。

### 10.4 Task 2 semantic record schema 审计

在最小 Cache V2 record envelope 完成首轮 RED/GREEN 后，对完整 Task 2
schema 再次逐字段核查。结论是：旧 `PrecompiledData` 只能作为“需要恢复哪些
语义”的字段盘点，不能作为新 archive 的 wire model。

旧实现会把 pointer、type ID、FunctionId、property offset 等旧进程坐标保留为
`int64`/bytecode operand，再依靠顶层引用表在新 engine 中修补；函数 `Id` 还会
受到 32 位碰撞递增和 unnamed initializer 随机数影响。它同时混合使用
`FArchive <<`、map iteration、随机 `DataGuid` 和 coarse
`BuildIdentifier`。这些都与 full stable key、canonical bytes 和跨 generation
复用冲突。

更重要的是，旧 `FAngelscriptPrecompiledFunction` 已经落后于当前 maintained
fork 的完整 `ScriptFunctionData`。旧 cache 保存 bytecode、variable space、
object-variable types/positions、`objVariableInfo`、heap count、stack need、
`declaredAt` 和 line numbers，但当前 fork 还包含：

- `tryCatchInfo`；
- `temporaryVariables`；
- 完整 local `variables`（type、stack offset、on-heap、declaration position）；
- 多 source section 的 `sectionIdxs`；
- function-level `dontCleanUpOnException` 等执行/清理状态。

因此完整 FunctionBody/ModuleState restore 必须以当前 fork 的 compiler、opcode
table 和 VM state 为权威，并建立三层边界：

1. common Cache archive 显式编码 canonical type、declaration、property、slot、
   global、metadata、typed dependency、keyed record graph 与 budgets；
2. VM-private codec 只负责 versioned execution/initializer/debug payload、
   instruction relocation、stack/local/try-catch/cleanup/section state；
3. per-engine mutation transaction 在全部记录和引用验证后串行 attach，并按
   module transaction 原子激活。

本审计还发现原 Task 2 草案的 bare RecordId arrays 无法按 TypeKey/FunctionKey
排序或验证 cross-owner，`StableKey + hashes` 无法支持 promised zero-parse
restore，单一 `TargetModule` 无法表达 type/property/global/environment
dependency，单个布尔 fast-path eligibility 也无法隔离 unfingerprinted provider
的作用域。正式 schema 因此改为 keyed links、reconstructible descriptors、typed
targets、stable mount/provider/hook/source-file/include keys 和 per-scope
eligibility。

V1 ownership 同时固定为：global/module initializer execution unit 嵌入
ModuleState，不作为可独立激活的 FunctionBody；TypeSchema 是 enum enumerator
shape/value/reflection 权威，ModuleState 仅持有并校验 derived hard-value
fingerprint；普通 ScriptFunction reference 的 ExpectedAbi 只表示
declaration/call ABI，真正被 fold/inline 的 content/value 使用单独 typed
dependency；无 DebugSidecar 使用 shared canonical writer 的
`function-debug-absent` domain，并且只写完整 ProfileKey。

正式字段、排序/序列规则、RecordId graph、预算/错误分类和 2B-1/2B-2/2B-3
切片记录在 `record-schema.md`。这次修订是实现前的 schema correction，不表示
完整 records、store 或 VM codec 已实现。

### 10.5 Task 2B-1 可执行接口审计与 V1 wire 收口

Task 2A 完成并通过独立复审后，下一轮只读接口审计发现 2B-1 的总体边界已经
正确，但 byte golden 仍会迫使实现者自行决定十四类细节：全局与 per-scope
eligibility 冲突、source 子键 hash 输入、SourceIndex 子记录、重复
source-to-module mapping、declaration tagged union、Import/Delegate/Funcdef
分类、multi-slot、派生 hash 输入、default expression、content presence matrix、
Unicode/case policy、raw bytes/provider state、global namespace 和 validation
class。

这些决定现已一次性冻结在 `record-wire-v1.md`：

- SourceIndex 删除全局 eligibility bool；`IneligibleScopes` 是唯一权威，并按
  目标 module/file 的 mount/provider/hook/source/module scope 查询，未受影响
  scope 仍可 exact-hit。
- 六种 source key 使用既有 Task 1 canonical writer 的固定 prefix/schema 和
  `cache-source-mount`、`cache-source-provider`、`cache-preprocess-hook`、
  `cache-source-file`、`cache-preprocessor-input`、`cache-source-edge` domain；
  version/config/content 只进入 SourceSnapshot。
- SourceIndex 显式保存 discovery filters/options、provider/hook capability、
  typed input target、raw BLAKE3-256、edges 和 ineligible scopes；
  `SourceFile.ModuleKey` 是唯一 mapping wire authority。当前 64-bit source state
  hash 不可代替内容 hash，真实 producer 能力留给 Task 4。
- Declaration 固定为 Type/Function/Global/Property tagged union，Import
  只有独立 table；Delegate/Typedef/Funcdef 都是 Type，新增不重编号的 Task 1
  EntityKind 6/7，delegate/funcdef signature 是由 TypeKey 拥有的 Function；identity
  traits 排序去重，stable key 通过现有 builder 重算，slot 按 kind 在整个
  ModuleInterface 内独立连续。
- default expression 进入 SignatureHash/InterfaceAbi；compiler 嵌入 resolved
  value 时仍产生独立 HardValue dependency。ExpectedContent 的 required/absent
  matrix 不再允许 optional 双义。
- V1 wire 使用 explicit enum numbers、u8/u32/u64 little-endian、strict UTF-8、
  禁止 NUL、不做 Unicode normalization；`FTextChar::GetCodepoint` 遍历 Unicode
  scalar value、逐 code point 调一次 `FTextChar::ToLower`，只检查路径碰撞且不做
  multi-code-point full fold、不改变 identity bytes。namespace table 只含非空实际值。
- declaration/reflection/parameter 三套 cache-specific flags 现在就冻结
  `0x1ff`/`0x3fff`/`0x7` KnownMask，不再保留未定义 call mask；无法表达的
  producer feature 必须 NotCacheable/schema bump，reader 对 unknown bits 拒绝。
- SourceSnapshot、SignatureHash、TraitsHash、InterfaceAbi 都排除自身后重算，
  payload/RecordId 仍覆盖存储的派生值。一个 exhaustive `Classify(Error)` 保留
  Task 2A envelope error 数值并成为 ValidationClass 唯一权威。

这是 RED 前规范修正，不是 semantic record 实现完成证据，也没有修改插件
源码、测试、provider 或 task checkbox。

### 10.6 2B-2 预审反向补齐 ModuleInterface coverage

在 2B-1 RED 尚未开始时，2B-2 的纯内存图验证预审发现：如果
ModuleInterface 不明确说明哪些 declaration 必须/禁止拥有 TypeSchema 和
FunctionBody，后续 validator 只能从名字、flags 或实际 record presence 猜测，
无法证明 exact coverage，也无法区分 abstract/delegate/initializer 与漏失 body。

因此该跨切片字段在首个 golden 前前移到 `record-wire-v1.md`：

- `SchemaCoverage` 和 `BodyCoverage` 都固定 `Forbidden=1 / Required=2`；
- V1 没有 Optional 或 inferred 状态；
- Type 要求 TypeSchema，其他 declaration 禁止 TypeSchema；
- 普通持久化可执行 Function 要求 FunctionBody；type/global/property、
  abstract、delegate signature、ModuleState-owned initializer 禁止 FunctionBody；
- producer 无法捕获一个 Required body 时，整个 snapshot 是 NotCacheable，不能
  通过把 coverage 改成 Forbidden/Optional 发布部分缓存；
- coverage 进入 SignatureHash 和 InterfaceAbi，ModuleSnapshot validator 后续对
  Required entity set 与 keyed links 做 exact equality，并拒绝 Forbidden link。

这仍是 RED 前 wire correction，不是 2B-1 或 2B-2 实现完成声明。

### 10.7 Typedef/Funcdef stable type identity correction

同一次 2B-2 type-union 预审还发现，早期草图把 Funcdef 作为 declaration kind
并复用 `DelegateSignature` FunctionKey，但后续 TypeSchema 需要以 TypeKey 对
Delegate、Typedef、Funcdef 做同一种 keyed coverage。这会造成 Funcdef 在
ModuleInterface 和 ModuleSnapshot 中拥有两套不同实体身份。

因为 2B-1 尚未写 RED/golden，V1 在此时修正为唯一表示：

- `EAngelscriptArtifactEntityKind` 在保留 1..5 现有值的前提下增加
  `Typedef=6`、`Funcdef=7`；
- DeclarationKind 只保留 Type/Function/Global/Property；
- Delegate/Typedef/Funcdef 都是 module-owned Type declaration 和 TypeKey；
- delegate/funcdef 的签名是由该 TypeKey 拥有的独立
  `Function + DelegateSignature=37` declaration；
- TypeSchema kind payload 后续链接这个 signature FunctionKey；
- Cache 与兄弟 StaticJIT 的 shared identity contract 同步记录新增 enum，但现有
  identity 算法、既有数值和 golden bytes 不变。

Task 2B-1 必须先用失败测试证明新 enum/identity declaration 组合，再宣称该扩展
已实现。

### 10.8 Task 2B-2 remaining-wire 接口收口

2B-2 编码前的只读审计列出了 20 个会让 serializer 与 graph validator 各自
猜测的缺口。它们现已在 `record-wire-v1-remaining.md` 一次性冻结，并且不修改
`record-wire-v1.md` 的 2B-1 byte layout：

1. TypeSchema、ModuleState、FunctionBody、DebugSidecar、ModuleSnapshot 各自从
   PayloadSchemaVersion 1 开始独立升级，unsupported result 带 record kind/stage。
2. property/type/enum/global-storage/hard-value/initializer/state 的 canonical
   domain 和完整输入流固定；execution/present-debug 继续使用 Task 1 payload-only
   domain，profile/codec 单独存储。
3. debug absence 是 shared identity API：`function-debug-absent` 只写完整
   ProfileKey，并由 Cache/StaticJIT 共用 golden，不使用 zero/empty sentinel。
4. ModuleState 与 DebugSidecar 都显式携带 ProfileKey。
5. debug logical section 使用 typed key，hash exact UTF-8 bytes，不允许 numeric
   section index 或隐式 normalization。
6. TypeKind 1..7 和 kind payload 固定；ModuleInterface 是唯一 type identity
   authority，TypeSchema 不再运行第二套 key 算法。
7. enum value 固定 signed int32 little-endian；name 唯一、numeric alias 允许、
   ordinal 连续，metadata 进入 authority hash。
8. reflection kind、type/property/class flags、replication condition 和 presence
   matrix 固定；relations/metadata 不重复，defaults 只走 InitDefaults body。
9. 删除 opaque ModuleLifetime；global 生命周期固定 allocate-all、ordered init、
   post-init、active 和 reverse cleanup，每个 global 使用 typed cleanup policy，
   不落盘 initialized bit。
10. CanonicalValue 按声明类型固定宽度保存 compiler-evaluated bits，包括 NaN
    payload；string/object/handle/UObject/mutable value 不得冒充 PureConstant。
11. ModuleInterface 的 Required/Forbidden coverage 继续作为 exact set authority。
12. constructor/factory 顺序只存在于按 kind 分组且 ordinal 连续的 behavior
    slots；relations 是 canonical set，不再有重复 ordered arrays。
13. common graph 只消费 injectable opaque validator 发布的 validated hash、
    relocation、debug source 和 owned name/string bytes；2B-2 fixture codec 与后续
    real VM codec 使用同一 seam。
14. relocation subset 按 dependency/ref kind/full key/ExpectedAbi/content
    presence+hash 全坐标匹配；name/string bytes 由 codec 拥有并重算 domain key。
15. 每个 VmInitializer global 恰一个 initializer、module initializer 0/1、
    OwnerGlobal presence 与 kind 对应，post-init 只能引用同 module declaration。
16. 每个 local enum 无论是否当前被引用，都在 ModuleState 中有且仅有一个
    EnumAuthority expectation。
17. precedence 固定 local/integrity -> immutable graph contradiction -> current
    source/profile/ABI/content/symbol Ineligible；内部矛盾不得伪装 normal miss。
18. 2B-2 只公开 per-module `ValidateModuleSnapshotGraph`；manifest exact
    reachability 和 unrelated extra record 留在 2B-3。
19. child decode、graph index/resident DTO、opaque summaries 共用一个 caller-owned
    budget，任何 child 不得 reset。
20. current resolver 对 module/type/function/global/property/import/environment
    返回 ABI 与 optional content；missing、ABI mismatch、content mismatch 是三个
    distinct Ineligible 结果，name/string bypass resolver。

独立复核又找出两处草图歧义并一并闭合。第一，ClassDesc 没有 Config flag，
不能写“ConfigName presence agrees with flags”：ordinary UClass 的 ConfigName
optional 且 absence 表示继承 superclass config，StaticClassGlobalName required；
synthetic StaticsClass UClass 两者都 forbidden；None/UEnum/UDelegate/UStruct 也都
forbidden，并对 StaticsClass bit 做双向约束。第二，Task 1 没有
GeneratedDefaultDestructor EntityKind；V1 不增值/不重编号，而是把该 InvocationKind
映射到既有 `Destructor=35 + Generated trait`，完整 invocation matrix 由 graph
验证。

这轮仍是 record-only 设计收口：没有修改插件/测试，没有运行 build，也没有把
任何 2B-2 checkbox 标为完成。

### 10.9 Task 2B-1 实现反馈补齐 source graph 与 query

2B-1 RED/GREEN 实现过程持续暴露原 wire 只写了单向/局部规则的含糊点，已在
`record-wire-v1.md` 补成可执行合同：

- 同 `{FromSourceFileKey, EdgeKind}` 的 SourceEdge SemanticOrdinal 必须全
  absent，或全 present 且为唯一连续 `0..N-1` 集；mixed presence 是
  InvalidPresence，不能从 canonical edge array 顺序猜 semantic order。
- Provider 的四项 capability 分别与自身 Provider scope/key 的
  MissingStableIdentity、MissingVersionFingerprint、
  MissingConfigurationFingerprint、UnstableGeneratedSource 双向对应；Hook
  对应前三项相同，ContentFingerprint 对应 UnknownHookBehavior。unset 要求该
  reason，set 禁止该 reason；其他独立 reason 不得替代。
- SourceIndex 在 publish 前解析完整 typed local graph：Mount→Provider、
  File→Mount 且 source/provider authority 一致、scope/input/edge/generated key
  按 tag 解析、ModuleKey 集只从 Files 派生。wrong typed set 优先
  WrongReferenceKind，全 set 缺失是 MissingGraphTarget，已解析 authority 冲突
  是 ConflictingKey；不存在 dangling source ref。
- 每个 present GeneratedSourceKey 只能由一个 File 拥有；不同 Files 共享该
  key 是 ConflictingKey，target/edge 不再解析到模糊 set。
- 六个 source key 各有唯一 public fail-closed typed builder，只接收 hash stream
  的 identity inputs、复用 ArtifactCanonicalWriter、失败清零；encoder/Task4/tests
  不得复制 domain/hash 实现，RED 逐个冻结 full hash。
- ImportKey 同样使用 public `TryBuildImportKey`，identity input 排除 route
  ExpectedAbi/ReferenceKind/Slots；full Import preparation 独立验证这些非 key
  字段，ABI/slot 变化不得改变 key builder 结果。
- ModuleInterface local owner graph 固定 callable matrix：Type-owned Function/
  Property→本 module Type，GlobalInitializer→本 module Global，Module-owned→
  ModuleKey；其中 Method 只允许 Class/Struct/Interface，Property 只允许
  Class/Struct，DelegateSignature 只允许 Delegate/Funcdef。CrossModuleOwner、
  WrongReferenceKind、MissingOwner 的 precedence 明确并进入 RED。
- CanonicalTypeSpelling 与 DeclaredType 在 2B-1 只做 presence/shape/hash；producer
  必须从同一 compiler type 产生，2B-2/current type authority 再做可验证 equality。
  pure reader 不从 StableKey 猜名字，也不解析 spelling 冒充 semantic equality。

同时冻结 pure `QueryExactFastPathEligibility(validated index, ModuleKey)`：从
目标 module files 推导 mounts/providers，对 Hook.AffectedScope 做 fixed-point
closure，返回 canonical matching IneligibleScopes/reasons 和 bool；missing module
返回 MissingGraphTarget 且清空输出。两个 module 的测试必须证明一个坏 scope
只污染它自己的 closure，仍不增加全局 eligibility bool。

### 10.10 Task 2B-3 manifest/pack wire 收口

在 disk store 实现之前，原计划对 manifest、pack、压缩和物理 ID 仍然只有结构
草图，无法稳定写 byte-golden，也容易把 record envelope、semantic payload 和
pack blob 混在一起。`manifest-pack-wire-v1.md` 现已冻结：

- manifest 是 `UEASCV2M` schema 1，pack 是 `UEASCV2P` schema 1；RecordId 在
  两者中固定 33 bytes，manifest root 65 bytes、location 122 bytes，pack header
  32 bytes、index entry 96 bytes，所有字段无 native padding/trailing data；
- pack 保存 canonical semantic payload，不嵌套 Task 2A 的 56-byte envelope；
  RecordId 仍是 kind+uncompressed semantic bytes 的 domain-separated identity；
- RawChecksum 是 raw semantic payload 的 direct BLAKE3；PackId 是完整 final
  pack bytes 的 direct BLAKE3；GenerationId 是完整 final manifest bytes 的
  direct BLAKE3，后两者都不在自身文件中存储，消除 self-hash 歧义；
- `None` 始终是有效表示；production Auto 的 Zlib 固定为 Unreal
  `NAME_Zlib + COMPRESS_BiasMemory + window 15`，仅在严格更小时使用，reader
  通过 fixed encoder recompress byte equality 拒绝 alternate/trailing stream；
- manifest 的 record index 必须恰好等于 SourceIndex + keyed ModuleSnapshot
  roots 的 transitive reachable set；pack 可以包含旧 generation 的 extra entry，
  但 manifest 不能把 unreachable extra 当成本 generation 成员；
- 默认 `MaxGenerationPacks=4096` 统计 distinct PackId，writer 必须拒绝超过上限
  的输出，decoder 必须在任何 pack lookup/open 前以 BudgetExceeded 拒绝；
- 只追加 archive stage `PackDecode=7`、`ManifestDecode=8`、
  `ManifestGraph=9` 和 format/integrity errors `65..71`，不把文件系统错误塞入
  archive error enum。

这一层仍是纯 memory format：不选 root、不打开 filesystem、不处理 pointer/
lock/recovery。Task 2B-3 的 RED/GREEN 要先证明完整 bytes/IDs、serial/random
determinism 和所有 malformed/budget precedence，再交给 disk store。

### 10.11 Task Group 3 store/publication 收口

`store-publication-v1.md` 把过去分散在 design/tasks 中的 Saved 路径、原子提交、
多进程和 compaction 约束收成一个可做 fault injection 的状态机：

- default base 是 `<ProjectSavedDir>/Angelscript/CacheV2`；
  `-as-cache-root` 替换完整 base，而不是在 override 下再次追加同名目录；
  compatibility/context/final object 都使用完整小写 64-hex，并做 canonical root
  containment；
- Current/Previous/Pending 是固定 80-byte `UEASCV2C` schema-1 binary pointer，
  包含 kind、nonzero GenerationId 和前 48 bytes 的 BLAKE3 checksum；pointer schema
  是 CompatibilityKey 输入；
- temp 固定在目标同目录并携带 pid+128-bit nonce。immutable object 必须完整
  write/full-flush/close/reopen validate，再 no-replace rename、directory sync、
  reopen final；pointer 必须走平台 old-or-new atomic replace/remove seam，UE generic
  delete-then-move 不能冒充原子操作；
- system-wide lock 由 canonical absolute namespace 派生，100 ms 以内轮询 deadline/
  cancellation；锁内重读 Current/Previous/Pending 并 rebase。same-source/same-
  semantic 是 AlreadyCurrent，same-source/different-semantic 是
  RebaseSemanticConflict，source epoch 变化要求 NeedsSourceRevalidation；
- Current replace success 是不可回滚 commit point。commit 后 cancellation 或
  directory sync error 必须保留 committed 状态，不能删 immutable object 回滚；
- reader 在 namespace lock 内验证 pointer/manifest、先执行 MaxGenerationPacks，
  再 pin manifest 和所有 distinct pack handles；读 session 不重新跟随 Current，
  也不按 path 重新打开已选 pack；
- fresh/cold fallback 次序固定 Current → Previous → eligible Pending，每个候选都
  独立通过 physical graph/profile/source 验证，不允许 corrupt Current 触发
  different-source stale generation；
- physical retention 把所有当前存在且 valid 的 Current/Previous/Pending pointer
  都当 root，与 selection eligibility 分离；compaction 只显式运行，Phase A 重写
  reachable union 并切换 slot pointers，Phase B 重新加锁/重新 mark 后 sweep，
  pinned reader 导致的删除失败只记 DeleteDeferred；startup 不做 compaction。

Store 自己使用独立 `EAngelscriptCacheStoreError 0..21`、stage 和 commit state。
只有 ContentValidationFailed 嵌套既有 archive validation result；path/lock/I/O/
flush/rename/cancel 不新增假 archive errors。这样 format/integrity 与 control-plane
失败的诊断和恢复语义不会互相污染。

### 10.12 HookKey 固定点歧义修正

这里不能把“eligibility 对 Hook closure 求 fixed point”误写成“HookKey 对循环图
求 hash fixed point”。HookKey 本身包含 AffectedScopeStableKey；当 scope 是 Hook
时，它引用的就是已生成 HookKey。因此：

- 合法 producer 从 Module/File/Mount/Provider base Hook 向 dependent Hook 逐层
  构造，validated authority graph 实际是 DAG；
- 一个同时满足所有 derived HookKey 的 self-cycle 或 multi-node cycle 要求构造
  BLAKE3-256 fixed point，不是 V1 producer 可构造输入；
- 手工伪造 cycle 会在 eligibility 之前的 derived-key recomputation 以现有
  `DerivedHashMismatch` 失败；不增加 cycle-specific error，也不实现 iterative
  HookKey solver；
- eligibility 仍对已经 validated 的合法 chain 求 transitive set closure。RED
  必须分别证明 base→dependent chain 传播、detached chain/另一个 module 不污染，
  以及 forged self/multi-node cycle 在 query 前被拒绝。

本轮只同步 OpenSpec/研究记录，没有修改 plugin source/tests，没有运行 build，
也没有勾选 2B-3 或 Task Group 3 实现任务。

### 10.13 Task 2B-1 code-freeze、golden 固化与独立复审 RED

Task 2B-1 的实现快照已经进入一次 code-freeze 与独立复审循环，但当前仍是
“修复 review RED 中”，不能据此勾选 2.2/2.3。阶段证据需要按时间顺序解释，
否则早期生成 golden 的开发工具和后续 RED 很容易被误写成最终 GREEN：

- code-freeze 的 Editor Development build 已通过，证据在
  `Saved/Build/as-cache-code-freeze-compile/20260808_062252_470_c35def74/Build.log`。
  同期 focused run 位于
  `Saved/Tests/as-cache-code-freeze-focused/20260808_062327_016_eec9c1c7/`；
  它是会报告未固化 golden 并最终在 SourceEdge fixture assertion 崩溃的开发
  快照，`RunMetadata.json` 记录 `ProcessExitCode=3`、`ExitCode=1`，不是 GREEN
  或回归基线。
- 为读取完整 payload/hash 常量，曾临时加入
  `EmitPendingGoldensForDevelopment`。对应 build 与单测分别在
  `Saved/Build/as-cache-golden-emitter-build/20260808_062912_841_89669d02/Build.log`
  和
  `Saved/Tests/as-cache-golden-emitter/20260808_062925_404_0bdd9a47/Report/index.json`，
  结果为 build success、emitter 1/1 success。它只负责产生开发证据；常量被
  逐项复制到独立命名断言后，该 emitter 已删除，不能成为 Runtime 架构、公开
  API 或最终测试面。
- golden/enum 固化后的 build 在
  `Saved/Build/as-cache-enum-golden-build/20260808_063428_373_157a4e47/Build.log`
  通过。Primitives 最终 focused 结果是 5/5 GREEN，见
  `Saved/Tests/as-cache-primitives-golden-final/20260808_063439_093_44f51391/Report/index.json`；
  它冻结 common primitive bytes/round-trip、malformed/budget、reference rules，
  以及 wire enums/flags/validation classes。
- SourceInterface golden 快照是 15 total / 14 success / 1 fail，见
  `Saved/Tests/as-cache-source-interface-golden-final/20260808_063510_819_e02041ea/Report/index.json`。
  唯一 RED 是 `SourcePathsCaseAndFingerprintPresenceFailClosed` 的非 ASCII
  simple-fold case-collision 合同；wire/graph precedence 的新增 RED 随后才进入
  review-red 集。因此这份 14/15 证据不能被描述为 SourceInterface 完成。

独立只读复审的完整报告保存在
`.superpowers/sdd/task-2b1-review-report.md`。结论为 0 Critical、7 Important、
1 Minor，且不批准当时快照。七项 Important 摘要如下：

1. decode 后的 semantic validation 丢失正确 `RecordKind` 与 enclosing-field
   `ByteOffset`；
2. string decode 没有在 allocation 前消费 resident budget，派生 hash 验证又
   产生未计费的整记录/数组/字符串深拷贝；
3. SourceIndex local/wire 和 graph phase 没有遵守固定的字段与错误 precedence；
4. ModuleInterface owner validation 早于 tagged shape/hash/order/duplicate 等
   local checks；
5. Mount/File authority 的 exact duplicate/conflict 内容比较不完整，generated
   exact duplicate 的判断顺序也错误；
6. source typed lookup、duplicate 检查和 owner resolution 反复线性扫描，核心
   路径退化为 O(n^2)，没有实现规范要求的 typed indexes；
7. preserving-order test writer 错误使用 `WITH_DEV_AUTOMATION_TESTS`，而不是
   `WITH_ANGELSCRIPT_UNITTESTS` 产品边界。

Minor 是 forged self-cycle 与真正 detached Hook-to-Hook chain 的回归证据缺口。
review 后新增的 RED 已补入这两类 fixture，因此该测试覆盖缺口本身已有针对性
证据；原 review 报告仍保留为当时快照，不能因此自动变成批准。另两类问题——
allocation-before-check/临时深拷贝预算和 O(n^2) typed lookup——普通结果断言不易
可靠观测，修复必须附结构复核，必要时增加 allocation/lookup instrumentation
seam，而不能只依赖 focused test 转绿。

review RED build 已通过，见
`Saved/Build/as-cache-review-red-build/20260808_064317_562_596623cc/Build.log`；
其 SourceInterface run 位于
`Saved/Tests/as-cache-review-red/20260808_064338_788_393f888a/Report/index.json`，
当前为 18 total / 14 success / 4 expected fail。四个 RED 分别是：

- `DecodedSemanticFailuresRetainRecordKindAndEnclosingFieldOffset`；
- `ModuleOwnerValidationRunsAfterLocalShapeHashOrderAndDuplicates`；
- `SourcePathsCaseAndFingerprintPresenceFailClosed`；
- `SourceWirePhasePrecedenceAndAuthorityContentAreFrozen`。

这些失败是修复中的 review obligations，不是可接受的最终状态。Task 2B-1 只有在
七项 Important 完成修复、四个行为 RED 获得 fresh GREEN、预算/复杂度获得可审计
证据，并由新的独立 re-review 明确批准后，才可讨论勾选 2.2/2.3。本次只记录
OpenSpec 进度，没有修改插件源码或测试源码，也没有改变 task checkbox。

### 10.14 Task 2B-2 第二轮预检：解码信任边界、一次性 codec 与 RED 阻塞项

在 2B-1 review RED 尚未获得独立批准时，对 2B-2 brief 做了第二轮只读预检。
结果不是“可以直接实现”，而是发现了三类会把局部 decoder、opaque codec 和
graph validator 重新耦合的合同漏洞，并据此修订
`record-wire-v1-remaining.md` 与实现 brief：

1. 五个 remaining-record `Deserialize` 现在统一限定为 wire/local/hash；它们都
   接收同一 `Limits + Budget`，但不接收、不调用 opaque validator。Initializer、
   FunctionBody、DebugSidecar 的 exact bytes hash 仍在局部重算，codec 结构只在
   graph step 1 针对实际 reachable owner 校验。
2. graph step 1 从 immutable token 建 full-key index，先沿目标 snapshot 做结构
   reachability，再对每个 reachable ModuleState initializer、FunctionBody 和
   body-owned DebugSidecar 恰好调用一次 validator；unrelated pool record 调用零次。
   后续 global/body/debug phase 只消费 candidate graph 持有的 validated summary，
   不能二次调用 codec。Debug opaque V1 冻结为零 relocation。
3. 原草图中的 public writable `{RecordId, canonical bytes, typed DTO}` 存在 TOCTOU
   信任洞：调用者可以在局部验证后修改 DTO 或 bytes。现在
   `FAngelscriptDecodedCacheRecord` 是受限构造的 immutable token；唯一 factory
   从 declared RecordId + canonical payload 重算 RecordId、按 kind dispatch 所有
   七类 decoder、同步捕获 nested field offsets，再一次性发布。SourceIndex 也必须
   通过这个 token 进入 graph，不能传可写 DTO pointer。
4. opaque `Validate` 与 `ValidateModuleSnapshotGraph` 都显式接收
   `const FAngelscriptCacheReadLimits&`；同一 caller budget 从新增 envelope budget
   overload 单调流经 token/decode/codec/graph。旧 envelope overload 保留为单次
   convenience wrapper。任何失败不 rollback/reset budget。
5. ValidationStage 继续 append-only；旧三参数 result constructor 的第三参数仍是
   ByteOffset、Stage 为 None。2B-2 使用 named staged factory。Envelope offset 以
   完整 envelope 为基准，其余 stage 以 canonical payload 为基准，并使用 decoder
   捕获的 enclosing field offset，禁止事后搜索 bytes 猜 offset。
6. fixture grammar 补上此前 error matrix 已引用、byte grammar 却遗漏的八字节 magic
   `UEASOPQ1`；complete envelope golden 改为“固定 56-byte header + 完整 payload”，
   不再误称整个 envelope 只有 56 bytes。Owned-byte canonical key/comparator 冻结为
   `{numeric ReferenceKind, full StableKey}`，bytes 只参与 exact duplicate/conflict。
7. Context 的 null services、wrong-kind SourceIndex token、zero selected profile/source/
   root 在 codec/resolver 前统一 fail closed；current eligibility 固定 source、profile、
   canonical dependency 顺序，并对每个 dependency 依次检查 missing、ABI、content。
   Record/declaration/owner/source/debug/dependency/relocation/owned-byte 都用 full-key
   index 或 canonical sort + adjacent comparison，counter fixture 证明不出现 O(n²)
   whole-pool rescan。

这轮同时明确两个 RED 硬门槛，避免实现者把未写出的矩阵当作“自由选择”：

- 2B-1 的七项 Important、focused GREEN、预算/复杂度证据和 fresh independent
  approval 没有全部关闭前，2B-2 Slice 0 不开始；批准后 Slice 0 也只能机械抽取
  private canonical codec，旧 Primitives/SourceInterface goldens 前后必须不变。
- TypeSchema 的完整 kind/payload/relation/property/method/behavior/reflection/flag/
  Config/Statics presence 矩阵，以及 ModuleState 的完整 init/value-width/cleanup/
  hard-value/initializer-owner/module-init/post-init 矩阵，仍需形成 exhaustive table 并
  独立批准；在此之前 Task 2B-2 RED 不开始，本文不猜未列行的语义。

2B-1 Unicode case-collision wording也在本轮同步为当前可审计实现边界：strict UTF-8
先解码到 TCHAR，再用 `FTextChar::GetCodepoint` 按 Unicode scalar value 遍历，逐
code point 调 `FTextChar::ToLower`；不做 multi-code-point full case fold，不修改
identity bytes。Unicode/lowercase 实现由 CompatibilityKey 隔离，并要求 BMP 与
supplementary-plane traversal vectors。原先“逐 TCHAR `FChar::ToLower`”会在 UTF-16
平台把 surrogate half 当字符，必须修正文档，不能留到 2B-2 猜测。

另记录 UBT gate 的当前边界：Runtime `PublicDefinitions` 已审计为单一 owner 结构，
但还没有 fresh dynamic verification。live `Documents/UnitTest/UnitTest.md`、
`Documents/Guides/Build.md`、shared compile-settings spec 与 Test Validation 诊断由
root 同步，本 change 不覆盖这些 change-dir 外文件。E1/E0 definitions-header 检查
仍待执行；Shipping compile/package 保留为最后阶段。本轮没有修改 plugin source/
tests，没有运行 UE build/test，也没有勾选 2.2/2.3/2.4/2.5。

### 10.15 Task 2B-1 最终独立复审：仍未批准，冻结剩余修复合同

2026-08-08 对修复后的 Task 2B-1 做了最终独立、只读复审。结论是
**NOT APPROVED：0 Critical / 4 Important / 3 Minor**。已有 focused 结果说明旧
RED 的若干行为问题已关闭，但测试通过不能替代 API、预算和 wire precedence 的
结构复核。当前证据为：

- SourceInterface `18/18 PASS`：
  `Saved/Tests/as-cache-review-focused-green/20260808_071830_154_50dae7e3/Report/index.json`；
- Primitives `5/5 PASS`：
  `Saved/Tests/as-cache-review-primitives-green/20260808_072015_620_01b97bcc/Report/index.json`；
- Identity `10/10 PASS`：
  `Saved/Tests/as-cache-review-identity-green/20260808_072055_145_c8f59b96/Report/index.json`；
- Editor Development build process/runner exit `0`：
  `Saved/Build/as-cache-review-focused-fix-build/20260808_071557_631_d182990c/RunMetadata.json`。

这组证据没有 fresh `WITH_ANGELSCRIPT_UNITTESTS=0` build，也没有关闭以下四项
Important：

1. SourceIndex graph-reference phase 的实现顺序仍不是规范 wire 顺序。V1 必须先建
   typed indexes，再严格按 Mount -> Hook -> File -> Input -> Edge -> Ineligible
   遍历；每个引用先判 kind，再判 missing target；全部引用解析完成后才允许执行
   resolved-authority `ConflictingKey`。
2. semantic validation、typed index 与 eligibility closure 的临时数组/映射/队列
   仍没有统一受 resident budget 约束。冻结同一 caller-owned `Limits + Budget`：
   stored/decompressed/decoded/retained/reference 等 persistent consumed counters
   单调；temporary scratch 使用 live-resident、move-only RAII reservation；任何
   `Reserve`/`SetNum*`/index/queue allocation 必须先 checked reserve；guard 在所有
   success/failure exit 释放临时 reservation，但不退还 persistent counters；失败
   reservation 不改 counter，也不发生 allocation；retained decoded + active scratch
   始终不超过 `MaxResidentDecodedBytes`。
3. serializer 的 semantic failure 仍可能带 `RecordKind=Invalid`。进入
   SourceIndex/ModuleInterface serializer 或 decoder 时就必须建立 record kind；
   serializer semantic failure 的 payload offset 固定为 `0`，decoder 使用已捕获的
   enclosing-field offset；record boundary 只补真正 nested 且 zero-kind 的结果。
4. eligibility 仍接受 raw DTO 并深拷贝/重复 prepare。冻结 factory-only immutable
   `FAngelscriptValidatedSourceIndex`：decoder/factory 只在局部持有 mutable DTO、
   offsets 与 indexes，全部校验成功后 move-publish；失败不发布 token。Query 只接收
   token，并显式接收 `const FAngelscriptCacheReadLimits&` 与同一个
   `FAngelscriptCacheReadBudget&`；不得复制整个 record、不得重新 validate/prepare。

三个 Minor 同步转为不可遗漏的补充证据，而不是当前完成声明：

1. source path case-collision 需要真正 supplementary-plane code-point traversal
   vector，不能只用 ASCII/BMP 或 surrogate-half 行为代替；
2. 当前只有 generic `CompatibilityDescriptor.CanonicalInputs` primitive，没有
   authoritative production CompatibilityKey assembly。第一个 production assembler
   必须纳入版本化 Unicode/lowercase policy 并补 isolation regression；Task 2B-1
   不拥有该 assembler，本轮不得把 CompatibilityKey assembly 冒充已经实现；
3. 需要构造两个各自覆盖完整 256-bit key、彼此竞争的 duplicate groups，直接证明
   报告的是最小 second wire occurrence，而不是 sorted/index 遍历顺序。

因此 `record-wire-v1.md`、`implementation-plan.md`、`design.md`、`tasks.md`、
`traceability.md` 与 `verification.md` 统一记录上述合同及 RED。2B-1 只有在四项
Important 完成、三个 supplementary regression 到位、focused + build 证据刷新并
获得新的独立批准后，才可勾选 2.2/2.3；2B-2 继续被该批准门槛阻塞。本记录只改
OpenSpec 与独立复审 scratch，不修改 Runtime/Test 源码。

## 2026-08-08 Task 2B-1 批准与 2B-2 矩阵晋升

上述 2B-1 复审项后来已全部完成并重新验证。最终独立只读复审结论为
`APPROVED — 0 Critical / 0 Important / 0 Minor`，因此 tasks 2.2/2.3 已勾选。
最终证据包括 SourceInterface `22/22`、Primitives + Identity `15/15`、合并聚焦
套件 `37/37`，以及 unit tests disabled/enabled 两种 Editor Development 完整构建。
详细产物路径与逐项批准理由保留在 `verification.md`。

随后把两份研究草案晋升为 OpenSpec 的共规范权威：

- `type-schema-matrix-v1.md`：完整冻结七类 TypeKind、11 个合法反射形式、关系、
  本地属性与精确字节偏移、单一全局 MethodSlot ordinal、17 类 behavior、依赖和
  错误优先级。关键修正包括 Delegate 为 `Final|Generated|ValueType`、新增
  `Copy/CopyConstruct/CopyFactory=15/16/17`、Behavior target 可为脚本函数或环境
  符号，以及 Compose/Interface live capture 的 fail-closed 边界。
- `module-state-matrix-v1.md`：完整冻结模块原子的 globals/state schema、三种初始化
  分类、精确宽度 scalar bits、cleanup ownership、HardValue authority/comparator、
  initializer declaration/依赖/ordinal、0/1 module initializer、post-init、StateInputHash、
  opaque summary 和错误优先级。函数体仍能独立失效，但 global schema/initializer/
  cleanup 作为一个 ModuleState 原子恢复，避免发布半初始化模块。

`record-wire-v1-remaining.md` 已将这两份矩阵按引用纳入权威集合，并同步修正所有
冲突的紧凑摘要字段。两份矩阵的晋升并不等于实现授权；Task 2B-2 的首个 RED
仍等待对冻结矩阵的 fresh independent approval。此门槛关闭后，先机械抽取私有
canonical codec 并证明 Task 2B-1 byte/hash/error goldens 不变，再进入其余记录的
RED/GREEN。

## 2026-08-08 TypeSchema 最终预审：数值布局权威重新打开

后续 common-contract 修复、allocator-authoritative 2B-1 批准和 ModuleState 独立
批准均已完成；私有 canonical codec 也已在旧 goldens 不变的条件下抽取。对当时
TypeSchema 候选的独立只读预审仍返回：

```text
NOT APPROVED — 1 Critical / 2 Important / 0 Minor
```

Critical 不是措辞问题：旧 TypeSchema 要求在 current resolver 前重算 exact property
offset、Base/code-root/UStruct boundary、aggregate alignment 和 terminal size，却只持久化
最终数字与不可反演的 ExpectedAbi/hash；合法 cross-module/environment target 又不是当前
ModuleSnapshot 的 child record。实现既没有 second immutable numeric authority，也不能
提前调用 live resolver 而把 stored contradiction 错分成 CurrentAbiMismatch。

两个 Important 分别是：

1. TypeSchema 没有像已批准 ModuleState 那样冻结每个真实 allocation family 的 exact
   allocator capacity、one-byte-short、no-allocation、RAII release、monotonic charge 和
   scratch-to-retained promotion；Task 2B-1 已经证明 `Num*sizeof(T)` 会低估 Unreal
   `TArray` slack capacity。
2. TypeSchema 把 derived-hash 检查放在 trailing exhaustion 前，和 shared remaining-wire/
   已批准 decoder precedence 冲突。同一 payload 可能不稳定地返回 TrailingData 或
   DerivedHashMismatch。

因此 2.4/2.5 继续保持未勾选；没有以一个 generic budget test 或把 size/alignment 临时
塞进 CurrentSymbols 来规避问题。

### 真实 maintained producer 的布局证据

只读核对维护分支后，以下来源冻结为 V1 设计依据：

- `ThirdParty/angelscript/source/as_builder.cpp:3484-3588` 的 `LayoutClass`
  先选 Base 或 `basePropertyOffset` cursor，按 property `GetAlignment()` checked AlignUp，
  value object 使用 `GetSizeInMemoryBytes()`，non-value object 使用
  `GetSizeOnStackDWords()*4`，最后按 aggregate alignment tail-align。
- `ThirdParty/angelscript/source/as_builder.cpp:2266-2275` 在 `LayoutClass` 前应用
  PreClassData，并立即把 `shadowType->alignment` max 进当前 object。因此 ordinary
  UClass 即使有 Script Base，也仍消费自己的 code-root/shadow alignment；Base 只替换
  cursor boundary，不取消这个更早的 alignment 输入。
- `Core/AngelscriptEngine.cpp:5169-5177` 的 UClass boundary 来自
  `CodeSuperClass->GetPropertiesSize()`，shadow type 来自该 code root 的已注册 AS 类型。
  post-generation UClass `PropertiesSize` 可能包含 editor hot-reload `+128` slack，不能
  反向成为 semantic AS size。
- `Core/AngelscriptEngine.cpp:5163-5166` 与 `ClassGenerator/ASStruct.h:16-31`
  证明 UStruct 只把 `UASStruct::ScriptValueOffset` 写成 PropertyOffset，未安装 ShadowType；
  因而 header 只贡献 boundary，不贡献额外 alignment。
- `ThirdParty/angelscript/source/as_datatype.cpp:680-768` 证明 reference/object handle
  alignment 固定为 `8`，primitive 使用自身 alignment，其余使用 fully registered/
  instantiated live TypeInfo layout。ExpectedAbi 或 canonical spelling 不能反演这些值。
- `ThirdParty/angelscript/source/as_builder.cpp:4520-4554` 与 typedef 使用点证明独立
  Typedef descriptor 是 `{primitive alias byte size, alignment 4}`，但属性使用时展开成
  primitive `aliasForType`；例如 typedef-int8 属性实际是 `{size=1, alignment=1}`。
- `ThirdParty/angelscript/source/as_typeinfo.cpp:456-470` 证明 Funcdef live descriptor 是
  `{size=0, alignment=4}`。legacy restore 对 Funcdef property 的 pointer-size 特判和正常
  `LayoutClass` 不一致，所以 V1 对 Funcdef property fail closed 为 NotCacheable。

### 选定的布局权威与失效分类

新增共规范 `type-layout-authority-v1.md`，选择“persisted pointer-free witness + separate
current layout resolver”：

- PropertySchema 在 Type 后追加 StorageKind、SemanticStorageSize、
  SemanticStorageAlignment、StorageLayoutHash；
- TypeSchema 在 Relations 后追加 canonical LayoutInputs，角色为 BaseType、CodeRoot、
  StructHeader，并分别带 optional boundary/alignment contribution 与 LayoutInputHash；
- optional presence 是语义，不能用零 sentinel；但 present boundary 允许为零，以覆盖空
  Script Base，storage size 和所有 alignment 仍必须非零；
- local decoder 完全从 persisted witness replay offset/alignment/terminal size；同 module
  linked Base/inline-value layout disagreement 是 GraphAbiMismatch；合法 cross-module/
  environment single witness 在 graph self-consistency 后由独立 CurrentLayouts 比较；
- CurrentLayouts 与 CurrentSymbols 共同由 sealed per-engine catalog 支持，不允许
  process-global type database fallback，也不向 stored hash 提供输入；
- physical payload exhaustion 先于 semantic/hash；trailing byte 与任一 derived-hash
  mismatch 组合时，TrailingData/PayloadDecode 固定获胜；
- `TS-SCR-01..22` 穷举 decoded ownership、local scratch、graph indexes、layout memo、
  candidate output 和最大同时存活组合，按真实 allocator capacity 做 exact-limit 与
  one-byte-short 证明。

截至本记录，这些修正已经合并到 remaining wire、TypeSchema matrix、semantic schema、
design、implementation plan、tasks、traceability 和 delta spec；仍需 strict mechanical
checks 与一次 fresh independent combined TypeSchema/layout approval，之后才能开始
Task 2B-2 RED。

### CurrentLayouts 的 raw coordinate 与 consumer mask 修正

第一次提交复审后，root 自审发现原 resolver 文案会造成稳定的假 miss：同一个
CodeRoot stable key 在 current catalog 中始终同时具有 properties boundary 与 shadow
alignment；root UClass 消费两者，而有 Script Base 的派生 UClass 只消费 alignment。
若 resolver 仅按 `{InputKind,ReferenceKind,StableKey}` 查值，却要求 returned optional
presence 和每个 stored witness 完全相等，则派生 UClass 的 stored boundary absent 永远
会与 current raw boundary present 冲突。

因此最终合同把两层含义分开：resolver 按稳定身份返回 raw role coordinates，并只
memo 一次；local validation 已证明每个 TypeSchema 的 stored presence matrix，current
comparison 用该 consumption mask 选择 raw 值并重算 masked LayoutInputHash。未消费的
raw CodeRoot boundary 不参与派生类比较。BaseType raw 返回 boundary+alignment，
CodeRoot raw 返回 boundary+alignment，StructHeader raw 只返回 boundary。缺整个 resolver
result 是 CurrentSymbolMissing；raw role shape 非法、stored-present 所需值缺失或 masked
值不等是 CurrentAbiMismatch。对应 root/derived 同 key 复用和 at-most-once RED 已加入
TypeSchema matrix、layout authority、remaining wire、delta spec、tasks 与 traceability。

### 冷启动 Exact Hit 的 resolver 循环依赖修正

对上述候选做完整独立复审后，原 `1 Critical / 2 Important` 已确认关闭，但复审又
返回 `NOT APPROVED — 1 Critical / 1 Important / 0 Minor`。新的 Critical 是冷启动
可实现性问题：旧 step 10 会把每个 TypeSchema 的同 module ScriptType/Base 都交给
`CurrentLayouts`。Exact Hit 冷启动时这些 live script types 尚不存在，而 cache restore
本身才负责创建它们，于是“恢复前必须查询已恢复类型”形成循环依赖并稳定退化成
`CurrentSymbolMissing`。

修正后的唯一资格划分以已验证 owner/StableKey 为依据，而不以 lookup 成败为依据：

- selected-module ScriptModule/Type/Function/Global/Property/Import 的本地权威由完整
  immutable graph 闭合，`CurrentSymbols` 零调用；import 的外部 target 仍是独立 eligible
  dependency；
- 同 module BaseType 与 InlineValue ScriptType 由 TypeSchema DAG 闭合；Primitive 与
  ObjectHandle slot 由版本化 Compatibility/Profile 常量闭合，均不进入 `CurrentLayouts`；
- cross-module BaseType、CodeRoot、StructHeader、external InlineValue ScriptType 和
  InlineValue EnvironmentType 才是 current-layout eligible 集合；
- required 本地声明缺 TypeSchema 是 immutable coverage 错误，不能 fall through 成外部
  current lookup；
- `IAngelscriptCacheProspectiveTypeLayoutView` 是已验证 TypeKey index 的零分配只读
  façade。EnvironmentType template 嵌套本地 value subtype 时，pre-materialization recipe
  只通过该 view 读取 TypeKind/size/alignment，不查询 selected module live AS type。

维护分支 `as_datatype.cpp:680-768` 同时给出了 profile-constant 的真实公式：primitive
size/alignment 分别使用 `AS_SIZEOF_BOOL`、1/2/4/8 与 `alignof(asINT64/double)`；非 value
object property 的 builder 分支使用 `GetSizeOnStackDWords()*4 = 4*AS_PTR_SIZE`，handle
alignment 固定为 8。V1 因此冻结 engine-free build-layout table，并要求未来首个生产
CompatibilityKey assembler 显式加入 bool size、pointer bytes、int64/double alignment、
handle/object/type-info alignment。这样 zero resolver call 仍有当前 build ABI 权威，不是
“跳过验证”。

对应 RED 明确要求：fixture resolver 不含任何本地 Script* entry 时，完整冷 Exact Hit
仍成功且本地 current-symbol/layout call count 都是零；eligible external/environment 调用
保持规范顺序和 at-most-once；nested environment/local-value 只有 outer eligible call。

### TypeSchema 唯一 local error/hash 顺序

同一轮复审的 Important 指出原矩阵虽然声称 wire order，却提前检查物理上更晚的
KindPayload/Dependencies，并把 LayoutInputHash 放到 property fingerprint 后，无法为
多重损坏给出唯一 ByteOffset。修正后顺序固定为：

1. 完整 physical decode；
2. `Reader.IsAtEnd()`，trailing 永远先赢；
3. top-level wire order 的 field-local pass；LayoutInput 字段内立即校验
   LayoutInputHash，每个 property 依次校验 StorageLayoutHash 和
   PropertyLayoutFingerprint，Enum KindPayload 校验 EnumAuthorityHash；
4. 所有 field-local 成功后，依次做 relation/LayoutInput pairing、local derived dependency
   coverage、完整 layout replay；
5. TypeLayoutHash 最后校验，再 publish。

因此派生 hash 顺序唯一为 LayoutInputHash → 每属性 StorageLayoutHash/
PropertyLayoutFingerprint → EnumAuthorityHash → TypeLayoutHash。测试对 Metadata 与
KindPayload、LayoutInputHash 与 PropertyFingerprint、Property 与 Dependencies、
EnumAuthorityHash 与 TypeLayoutHash 的竞争同时断言 Error、Stage、RecordKind 和捕获的
enclosing-field ByteOffset。
