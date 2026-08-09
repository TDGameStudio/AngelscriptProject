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

在 `CompileFunctions()` 调用 `asCCompiler` 之前，可以从规范化 token/AST slice 与语义依赖计算 `FunctionInputDigest`；命中时挂接已验证 bytecode，未命中才进入 compiler。这个 hook 修改的是插件维护的 AngelScript C++ 内部实现，不改变业务 `.as` 语法，也不要求脚本作者增加 UUID/annotation。

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

截至本次 OpenSpec 整理：

- 已完成：代码路径、现有数据模型、依赖图、compiler seam、Editor/PIE 生命周期、打包链和测试基础研究。
- 已完成：产品决策收敛和 decision-complete OpenSpec 设计。
- 未开始：任何 Runtime/Editor/ThirdParty/Tools/Config/test 源码实现。
- 当前 host `.uproject` 与 `AgentConfig.ini` 指向 UE 5.8；cache 的 `CompatibilityKey` 必须隔离 UE/bytecode ABI，不能假定不同 engine minor 可复用。

实施过程中新增证据继续追加到本文件；性能原始数据放 `benchmarks/`，验证日志/命令放 `verification.md`，`tasks.md` 只保留可勾选任务，不写过程性评论。
