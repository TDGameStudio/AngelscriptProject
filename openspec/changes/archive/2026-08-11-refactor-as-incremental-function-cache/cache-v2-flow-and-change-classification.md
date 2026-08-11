# Cache V2 流程、缓存机制与变更分类

记录日期：2026-08-09。

本文汇总围绕 Cache V2 的近期讨论，集中说明以下问题：

- 新缓存从源码发现、命中规划、恢复/重编译到 generation 发布的完整流程；
- 为什么缓存不是简单按函数切文件，也不是继续维护一个单体 `.cache`；
- 修改一个 `.as` 文件后，如何区分类/类型结构、全局状态、函数逻辑和调试映射变化；
- Source Scan、Preprocess、Parse、Semantic/Layout、Compiler 和 Lifecycle 各自能够确定什么；
- Editor、PIE、Development、Shipping、StaticJIT 和 Live Coding 如何接入同一套缓存身份而不互相越权。

本文是解释性架构文章，不替代规范。当本文与 delta specs、wire、matrix、authority 或 golden vector 冲突时，以那些冻结规范为准，其次以 `design.md` 为准。`status.md` 是当前实现进度和阻塞的唯一权威；本文描述目标流程时不表示相应功能已经端到端实现完成。

## 1. 核心结论

Cache V2 的总体原则可以压缩为一句话：

> `.as` 源码始终是正确性权威；缓存按函数、类型和模块状态等语义记录细粒度复用，但模块恢复与激活保持原子性；磁盘上不原地修改一个巨大的 `.cache`，而是发布由不可变 Pack、Manifest 和原子 generation 指针组成的新一代缓存。

它同时坚持以下边界：

1. 文件变化只用于找到受影响范围，不直接等同于整个模块重新编译。
2. 变化模块通常需要重新预处理和解析，但只有真正失效的函数进入 Compiler。
3. FunctionBody、DebugSidecar 和 TypeSchema 可以细粒度复用；ModuleState 和活动 ModuleSnapshot 必须原子处理。
4. 磁盘物理布局是有界数量的聚合 Pack，不是一函数一文件。
5. 新 generation 引用未变化的旧内容和新内容；更新不在旧 Pack 内原地打补丁。
6. 第一次 Editor 或 packaged 启动可以从权威 loose `.as` 编译并生成 Cache V2，不要求打包前预生成基线。
7. 当前源码编译失败时，不能静默激活不同源码版本的旧 generation。
8. StaticJIT 只消费稳定函数身份、内容和 Profile；它不拥有 Cache 有效性。
9. Live Coding 可以刷新 Editor 中的外部 Native Provider，但不决定 `.as` 缓存是否新鲜。
10. 最终直接删除旧 `PrecompiledScript.Cache` 生产路径，不提供 reader、migration、dual-write 或 V2 失败回退；`Binds.Cache` 保持独立。

### 1.1 启动中心，但不是“只保存文件影响关系”

Cache V2 的最大收益发生在 Engine initial script load、Editor/PIE 模块装载和
packaged runtime 启动；运行期间成功的 initial compile、soft reload 或 structural
reload 也会产生下一代可复用记录。正常 Shutdown 只 bounded-flush 已经完成的事务，
不会在退出阶段重新 Preprocess、Parse 或 Compile。

只持久化文件 Hash 和反向依赖只能回答“哪些模块可能需要重新处理”，不能让未变化
模块实现零 Preprocess/Parse/Compile 的恢复。因此磁盘物理布局可以保持为少量简单
Pack/Manifest，但其逻辑内容必须包含 SourceIndex、ModuleInterface、TypeSchema、
ModuleState、FunctionBody、DebugSidecar 和完整 ModuleSnapshot。所有记录都无进程指针，
numeric FunctionId 每次启动从 StableFunctionKey 重建。

关闭期间的变化按输入域处理：

```text
.as/source/include/options 变化
    -> DirectSourceInputs / candidate miss
    -> 现有权威 frontend 重建受影响 Module
    -> 按语义 RecordId 和 typed dependencies 传播

Runtime/plugin/Engine 变化
    -> Cache wire/schema、VM ABI、compile profile 或 environment ABI fingerprint
    -> 匹配则保留相应记录；不匹配则 safe miss/新 namespace

StaticJIT Provider 变化
    -> StableFunctionKey + FunctionContentHash + Profile + ABI 重新路由
    -> 只影响 Native/VM 选择，不拥有 Cache generation 有效性
```

类型变化不会无条件让“所有引用过该文件的模块”全部失效。变化模块先由正常编译产生
新的权威 ModuleInterface/TypeSchema，再按 Declaration、Signature、Inheritance、
ValueLayout、EnvironmentAbi 等有限 typed dependencies 传播。不能证明安全时才保守
safe miss。函数体-only 变化通常保留模块结构和不相关 FunctionBody；签名、继承、
属性布局或反射变化则扩大到实际语义消费者。

## 2. 从旧单体 Cache 到不可变 Generation

旧方案把模块声明、类型和反射数据、Globals、函数 bytecode、调试数据、进程内 FunctionId、旧指针重定位以及随机 DataGuid 混在一个文件中：

```text
Script/PrecompiledScript.Cache
├── Module Declarations
├── Type / Reflection Data
├── Globals / Initializers
├── Function Bytecode
├── Debug Data
├── Numeric FunctionIds
├── Old Pointer Relocations
└── Random DataGuid
```

这导致一次很小的函数修改也很难安全保留其他内容，并把 Cache 和生成的 StaticJIT 代码绑定成一个整体配对。

Cache V2 改为：

```text
逻辑层：七类可验证语义记录
    SourceIndex
    ModuleInterface
    TypeSchema
    ModuleState
    FunctionBody
    DebugSidecar
    ModuleSnapshot

物理层：不可变聚合对象
    Record Payloads
        -> Pack
        -> Manifest
        -> Current / Previous / PendingColdStart
```

旧方案倾向于整体重建：

```text
PrecompiledScript.Cache
        |
        +-- 重新生成整个文件
        +-- 整体配对 DataGuid / StaticJIT 数据
        +-- 打包前特殊流程
```

新方案发布 generation：

```text
Generation N
├── Manifest N
└── Pack A / Pack B

Generation N+1
├── Manifest N+1
├── 继续引用不变内容
└── 新增或复用 Pack C

Current:  N   -------- 原子替换 --------> N+1
Previous: N-1 --------------------------> N
```

这里的“增量更新”主要是发布新的不可变 generation，而不是修改正在被 Reader 使用的旧 Pack。

## 3. 七类逻辑记录及其粒度

### 3.1 SourceIndex

SourceIndex 是 generation 的完整源码事实根，记录：

```text
SourceIndex
├── Game / Plugin / Memory 源码集合
├── 原始源码内容 Hash
├── Mount / Provider / Hook 稳定身份与版本
├── Include / Generated Source 关系
├── Defines / 条件编译 / 预处理选项
├── SourceFile -> Module 映射
├── 新增与删除的源码
└── 无法走精确快速路径的 Scope
```

它首先回答“当前发现的源码是否与某一 generation 完全一致”。精确 SourceIndex、Profile、环境依赖和 ModuleSnapshots 都匹配时，符合条件的模块可以做到零 Preprocess、零 Parse、零 Function Compile。

### 3.2 ModuleInterface

ModuleInterface 保存可重建的模块声明和对外 ABI：

```text
ModuleInterface
├── Stable Module Identity
├── Imports
├── 类型、函数、Global、Property 声明
├── Owner 和 Slot
├── Signature / Qualifier / Trait / Call ABI
├── Reflection Surface
└── Typed Semantic Dependencies
```

函数实现变化但签名和声明 ABI 不变时，ModuleInterface 可以继续命中。签名、Owner、Import Route 或声明语义变化时，ModuleInterface 失效并传播到实际依赖这些声明的调用方或模块。

### 3.3 TypeSchema

TypeSchema 是类型粒度的结构、布局和反射权威：

```text
TypeSchema
├── Class / Struct / Interface / Enum / Delegate / Typedef / Funcdef
├── Base Type / Direct Interfaces
├── Property 类型、顺序、存储和反射信息
├── Size / Alignment / Offset / Boundary
├── Method / VFT / Behavior
├── UClass / UStruct / Reflection / Metadata
├── Enum Authority
├── Layout Inputs
└── TypeLayoutHash
```

普通函数体修改不应使 TypeSchema 失效；Property、Inheritance、Interface、Method Declaration、Reflection、Enum Authority 或布局变化会使相应 TypeSchema 和结构依赖闭包失效。

### 3.4 ModuleState

ModuleState 将模块 Global 生命周期作为一个原子单元：

```text
ModuleState
├── Globals
├── Constants
├── Enum Hard Values
├── Global Storage
├── Initializer Functions
├── Initializer Dependencies / Order
├── Post-Init
└── Hard-Value Dependencies
```

普通 FunctionBody 修改且 ModuleState 输入不变时，ModuleState 可以继续命中。任一 Global、Constant、Initializer Body/Dependency/Order 或 Post-Init 变化时，完整 ModuleState 失效；V1 不独立激活某个旧 Initializer FunctionBody。

### 3.5 FunctionBody

FunctionBody 是主要的函数级执行复用单元：

```text
FunctionBody
├── StableFunctionKey
├── FunctionSourceDigest
├── FunctionInputDigest
├── FunctionContentHash
├── Canonical Bytecode
├── Operands / Literals
├── Stack / Locals
├── Cleanup / Exception State
├── Stable Symbol Relocations
└── Persisted Actual Dependencies
```

函数体变化通常保持 StableFunctionKey，但改变 Source/Input/Content。函数 Signature、Owner、Qualifier 或 Function Kind 变化时会形成新的 StableFunctionKey，并进入声明/结构变化路径。

### 3.6 DebugSidecar

DebugSidecar 将 source mapping、line cues 和 debug-only state 与执行内容分离：

```text
FunctionBody
    └── Optional DebugSidecar
        ├── Source Mapping
        ├── Line Cues
        ├── Debug Sections
        └── Profile-specific Debug State
```

Editor Debug Profile 可以同时要求执行和调试内容匹配；Shipping 可以省略 sidecar。无调试数据使用显式稳定身份，而不是零 Hash 或空 payload sentinel。

### 3.7 ModuleSnapshot

ModuleSnapshot 是模块组装和激活根：

```text
ModuleSnapshot
├── 一个 ModuleInterface
├── 有序 TypeSchema 列表
├── 一个 ModuleState
├── 有序 FunctionBody 列表
├── 每个 FunctionBody 的可选 DebugSidecar
└── Dependency Metadata
```

它体现 Cache V2 的关键取舍：

```text
持久化和复用：尽可能细粒度
模块组装和激活：必须原子
```

不能把新 TypeSchema、旧 ModuleState、部分新 FunctionBody、部分旧 FunctionBody 和旧反射 UClass 混成活动模块。

## 4. 七类记录、Manifest 和 Pack 的关系

一个 generation 的逻辑可达图为：

```text
                         Manifest
                            |
          +-----------------+------------------+
          |                                    |
          v                                    v
   一个 SourceIndex 根                 每个模块一个 ModuleSnapshot 根
                                               |
                    +--------------------------+--------------------------+
                    |             |             |             |          |
                    v             v             v             v          v
            ModuleInterface   TypeSchema*   ModuleState   FunctionBody*  ...
                                                               |
                                                               v
                                                       DebugSidecar?
```

逻辑 Record 不等于磁盘文件。多个语义 payload 聚合进入 Pack：

```text
逻辑记录：

Record A: TypeSchema_Player
Record B: FunctionBody_PlayerTick
Record C: FunctionBody_PlayerJump
Record D: DebugSidecar_PlayerTick
Record E: ModuleState_Gameplay
Record F: ModuleSnapshot_Gameplay

                    |
                    v

物理聚合：

Pack 01
├── Record A payload
├── Record B payload
├── Record C payload
└── Record D payload

Pack 02
├── Record E payload
└── Record F payload

Manifest
├── Record A -> Pack 01 / offset / length / codec
├── Record B -> Pack 01 / offset / length / codec
├── Record C -> Pack 01 / offset / length / codec
├── Record D -> Pack 01 / offset / length / codec
├── Record E -> Pack 02 / offset / length / codec
└── Record F -> Pack 02 / offset / length / codec
```

生产 Codec 支持 None 和规范化 Unreal Zlib。逻辑 RecordId 由语义内容决定，不把物理压缩方式混成实体身份；Pack 文件整体另有自己的 PackId。Manifest 只索引从 SourceIndex 和 ModuleSnapshot roots 精确可达的记录，旧 Pack 可以暂时保留历史内容，但新 Manifest 不能把不可达 extras 当作本 generation 的成员。

## 5. Generation Store

默认根目录为：

```text
<ProjectSavedDir>/Angelscript/CacheV2/
    <CompatibilityKey>/
        <ContextKey>/
            Immutable Packs
            Immutable Generation Manifests
            Current Pointer
            Previous Pointer
            PendingColdStart Pointer
            Recognized Writer Temps
```

三个 slot 的语义是：

```text
                       Store Slots
                           |
          +----------------+----------------+
          |                |                |
          v                v                v
       Current          Previous      PendingColdStart
          |                |                |
当前活动/首选 generation  上一有效提交一代    只适合后续冷启动的一代
```

任何 slot 只有在 Compatibility、Context、Profile、SourceIndex、Manifest、Pack 和 Module Graph 都合法时才可选择。

## 6. 端到端总体流程

```text
                           .as 源码
                    Game / Plugin / Memory
                              |
                              v
                 +------------------------------+
                 | DirectSourceInputs           |
                 | Raw Hash / Logical Path      |
                 | Provider / Hook / Options    |
                 | Source -> Module 映射        |
                 +------------------------------+
                              |
                              v
              Direct-Input Digest / Current Candidate
                              |
                +-------------+-------------+
                |                           |
                v                           v
      验证持久化的 Include /          当前没有可用 Candidate
      Generated / Preprocess 依赖             |
                |                             |
                v                             v
       精确时读取 Generation            权威 Preprocess / Parse
      Current / Previous / Pending       并重新捕获 Candidate
                |                             |
                +-------------+---------------+
                              |
                              v
                     命中与失效规划器
                              |
          +-------------------+--------------------+
          |                   |                    |
          v                   v                    v
       记录命中            记录失效             新增记录
       直接恢复          重新编译/生成         重新编译/生成
          |                   |                    |
          +-------------------+--------------------+
                              |
                              v
             唯一 Seven-Kind Decoder / Factory
                              |
                              v
                ValidateModuleSnapshotGraph
                              |
                              v
              模块声明、类型、函数、Global 组装
                              |
                              v
                  每 Engine 的 Mutation Gate
                              |
                              v
         Module Swap + ClassGenerator + Reflection
                              |
                    成功？  /      \ 失败？
                          /          \
                         v            v
              冻结无指针发布 DTO    不发布新 Cache
                         |           保持正确的活动状态
                         v
             Worker 并行构建 Pack / Manifest
                         |
                         v
               Store 原子发布新 Generation
                         |
                         v
              Current / Previous / Pending
```

磁盘命中并不代表信任磁盘字节。Loader 在分配和 Engine mutation 前验证 magic、schema、kind、整数运算、count、offset、stored/raw length、codec、checksum、canonical order、duplicate/conflicting key、依赖类型、逻辑 root、Budget、PackId、GenerationId 和 Manifest-to-Pack location。

## 7. 第一次启动

第一次启动不要求提前生成 Cache：

```text
                 第一次启动
                     |
                     v
     Saved/Angelscript/CacheV2 不存在
                     |
                     v
        发现完整权威 .as 源码集合
                     |
                     v
      Preprocess -> Parse -> Compiler
                     |
                     v
        生成七类逻辑 Cache 记录
                     |
                     v
       验证 ModuleSnapshotGraph
                     |
                     v
   Module Swap / ClassGenerator / Reflection
                     |
                   成功？
                /          \
              否            是
              |             |
              v             v
       返回类型化失败       冻结无指针 DTO
       不写错误 generation      |
                                v
                       构建 Pack + Manifest
                                |
                                v
                       原子发布 Current
```

第一次启动生成的是可恢复的 Cache V2 VM artifacts，不是在用户机器上生成或编译 StaticJIT C++ Provider 模块。

## 8. 完全未修改时的 Warm Startup

```text
                    后续启动
                        |
                        v
             发现当前 DirectSourceInputs
                        |
                        v
          计算 Direct-Input Digest 并读取 Current
                        |
                        v
          验证持久化 Candidate Dependencies
                        |
                        v
             Manifest / Pack 严格验证
                        |
                        v
       Compatibility / Context / Profile 匹配
                        |
                        v
        SourceIndex / Candidate 完全匹配
                        |
                        v
         ModuleSnapshotGraph 完整且合法
                        |
                        v
              恢复七类记录和模块
                        |
                        v
      Preprocess = 0 / Parse = 0 / Compile = 0
                        |
                        v
                  模块原子激活
```

恢复过程不反序列化旧进程指针、UObject、vtable、FName index 或 numeric FunctionId，而是在当前 Engine 中从稳定引用重建当前对象和 FunctionId 路由。

## 9. 修改一个 `.as` 文件后的识别原则

系统不通过文本行 diff 猜“这是类修改还是函数修改”。识别分两阶段：

1. Source Scan 先比较可直接发现的输入，并用上一代持久化的
   Include/Generated/Preprocess candidate 缩小受影响模块；candidate 不匹配才
   运行现有权威 Preprocessor 并重新捕获依赖。
2. 受影响模块重新 Parse、建立声明/类型权威，再按 StableFunctionKey、
   FunctionInputDigest 和语义 RecordId 选择 FunctionBody Hit 或正常 Compile。

因此精确粒度是：

```text
变化发现粒度
    = Source / File / Include

重新解析粒度
    = 受影响 Module

编译与 Cache 复用粒度
    = ModuleInterface / TypeSchema / ModuleState /
      FunctionBody / DebugSidecar

活动激活粒度
    = ModuleSnapshot 原子激活
```

一个 `.as` 文件通常是一个 Module，不意味着文件变化后 Module 中所有函数都重新 Compile。文件变化会使受影响 Module 重新 Parse；Parse 后未变化且依赖仍满足的函数直接复用。

## 10. 各处理阶段能够确定什么

```text
Stage 0：Direct Source Inventory / Candidate Lookup
    原始字节 Hash、Mount、Provider、Hook、Options、Source -> Module
    验证上一代持久化 Include/Generated/Preprocess dependency candidate

Stage 1：Preprocess
    仅在 candidate miss 时运行
    Include、Define、Condition、Generated Source、受影响 Module Closure
    重新捕获下一代 candidate

Stage 2：Parse / Declaration
    Class、Property、Function、Global、Import、Signature、Body AST

Stage 3：Semantic / Layout
    ModuleInterface、TypeSchema、ModuleState Descriptor
    ABI、Property Layout、Reflection、Inheritance

Stage 4：Pre-Compile Hit Planning
    StableFunctionKey、FunctionSourceDigest、Persisted Dependencies
    Current FunctionInputDigest

Stage 5：Compiler
    Bytecode、实际依赖、FunctionContentHash、DebugSidecar

Stage 6：Module Assembly / Lifecycle
    ModuleState、ModuleSnapshot、ClassGenerator、PIE/Shipping Policy
```

### 10.1 Source Scan、候选依赖和 Preprocess 能确定的内容

不运行 Preprocessor 就能直接确定：

- 哪些文件原始字节变化；
- Mount、Provider、Hook、显式 Options 和 Source -> Module 输入是否变化；
- 上一次候选中命名的依赖内容/版本是否仍匹配。

Candidate miss 后，权威预处理阶段可以确定：

- 哪些 Include 消费者受影响；
- Define 和条件编译结果是否变化；
- Generated Source 或 Preprocessor Hook 是否变化；
- 哪些 Module 必须重新 Parse。

它不能独立确定：

- Property 类型变化后的最终 Size、Alignment 和 Offset；
- Base 变化影响的完整 Derived Type 闭包；
- 哪些 Caller 因 Signature ABI 变化而失效；
- Enum 值是否被某个函数作为 hard value 嵌入；
- 某函数编译器最终实际使用了哪些 Script/Environment symbols；
- ClassGenerator 是否能替换当前 PIE 中已有实例。

候选依赖是有界、可丢弃的优化状态；丢失只导致重新预处理。预处理结果可以缩小
范围，但 loose/current source 和成功前端结果始终是 Cache 正确性权威。

### 10.2 Parse / Declaration 能确定的内容

Parse 后可以识别：

- 类型、Property、Function、Global 和 Import 的新增/删除；
- Function Name、Owner、Signature、Qualifier 和 Kind；
- Function Body 的 canonical token/AST slice；
- Base、Interface、Property 声明和 Metadata 的语法变化。

大部分“签名/声明变化还是函数体变化”在进入函数 Compiler 前已经可以分流。

### 10.3 Semantic / Layout 才能确定的内容

最终类型结构分类需要：

```text
Parse Property Declaration
            |
            v
解析 Declared Type
            |
            v
计算 StorageKind / Size / Alignment / Offset
            |
            v
计算 PropertyLayoutFingerprint
            |
            v
计算 TypeLayoutHash / Reflection Shape
            |
            v
与旧 TypeSchema 比较
```

不能因为两个类型 Size 相同就认为语义类型、反射类型或 ABI 相同。

### 10.4 Pre-Compile Dependency Resolution

函数源码没有变化也可能因为实际依赖的 ABI、Layout 或 HardValue 变化而失效。此时不需要先运行完整 Function Compiler，但需要新声明图、TypeSchema、ModuleInterface、Environment Catalog 和上一代实际依赖集合。

### 10.5 Compiler 才能首次捕获的内容

第一次编译没有 persisted actual dependency set。只有编译器完成名称/类型/Property/Global/Operator 解析、常量折叠和 bytecode 生成后，才能准确捕获实际依赖、relocations 和内容 Hash。之后的启动才可以用这些持久化依赖在编译前做命中判断。

### 10.6 Lifecycle 才能决定的内容

即使 Semantic 阶段已经确定是 Structural Change，也要结合当前 Editor/PIE/Shipping 状态、live instances、ClassGenerator、Reflection 和 Reinstancing 结果，才能决定是激活 Current、保留活动状态、发布 PendingColdStart 或返回 RequiresRestart。

## 11. Function Identity 与三个不同摘要

函数 Cache 不把 lookup identity、输入和编译结果混成一个 Hash：

```text
StableFunctionKey
    逻辑声明和 Owner 身份

FunctionSourceDigest
    canonical token/AST slice
    + invocation kind
    + compile/preprocessor options

FunctionInputDigest
    FunctionSourceDigest
    + 当前实际依赖 fingerprints

FunctionContentHash
    编译或验证恢复后的 execution/debug 内容
```

函数查找算法为：

```text
StableFunctionKey 相同？
       /              \
     否                是
     |                 |
旧声明删除/新声明新增   比较 FunctionSourceDigest
声明/结构变化                 |
                           相同？
                         /       \
                       否         是
                       |          |
                 Function Miss    解析 Persisted Actual Dependencies
                                  |
                                  v
                           计算 FunctionInputDigest
                                  |
                             相同？ / \ 不同？
                                   /   \
                                  v     v
                           Function Hit  Function Miss
```

函数 Signature、Owner、Qualifier 或 Function Kind 变化会形成新 StableFunctionKey；普通 Body 修改保持 Key，但改变 Source/Input/Content。

## 12. 持久化实际依赖

冷编译时记录函数真正使用过的语义实体：

```text
Tick()
├── Property: Health
├── Function: ApplyDamage
├── Type: FDamageInfo
├── Global: DamageScale
└── Environment Symbol: FVector::Size
```

下一次查找先比较 SourceDigest。若 SourceDigest 相同，则根据持久化 Key 在当前声明和环境中解析 fingerprints：

```text
FunctionInputDigest =
    H(
        FunctionSourceDigest,
        ordered current dependency fingerprints
    )
```

于是：

```text
函数源码没改，但 Health 类型/布局变了
    -> FunctionInputDigest 变化
    -> FunctionBody Miss

函数源码没改，但无关类型增加 Property
    -> 不在 Actual Dependencies
    -> FunctionInputDigest 不变
    -> FunctionBody Hit
```

普通 ScriptFunction 调用依赖的是 callee 的 declaration/call ABI，而不是 callee implementation content。因此只改被调函数 Body 时，Caller 默认继续复用；Inlining、Constant Folding 或真实内容/硬值嵌入必须记录显式 content/hard-value dependency。

## 13. 如何区分常见变化

### 13.1 纯函数逻辑变化

```text
StableFunctionKey      相同
FunctionSourceDigest   变化
ModuleInterface        相同
TypeSchema             相同
ModuleState            相同
```

结果是对应 FunctionBody Miss，其他函数根据各自 Source/Input Digest 决定命中。

### 13.2 Function Signature 变化

```text
Signature / Return / Parameter / Qualifier 变化
                 |
                 +-- StableFunctionKey 变化
                 +-- ModuleInterface 变化
                 +-- Owner TypeSchema Method Declaration 变化
                 +-- Caller ExpectedAbi 变化
                 +-- ModuleSnapshot 变化
```

它属于 Declaration + Structural Change，而不是 Body-Only Change。

### 13.3 Property 或类布局变化

```text
Property / Base / Interface / Reflection 变化
                  |
                  v
              TypeSchema Miss
                  |
                  v
        Structural Dependency Closure
                  |
                  v
        Owner ModuleSnapshot 重新组装
```

访问改变 Property 的函数可能因 InputDigest 变化而 Miss，即使其 AST 没有变化。

### 13.4 Property 默认初始化变化

如果 Property 类型、顺序、大小、对齐和 Reflection 都没变，只有默认初始化逻辑变化，通常表现为生成的 `__InitDefaults` FunctionBody 变化，而 TypeSchema 仍可命中。若默认值同时参与 Reflection Metadata、Schema 或 hard-value semantics，则相应 TypeSchema/依赖也必须失效。

### 13.5 Global 或 Initializer 变化

```text
Global / Constant / Initializer / Order 变化
                    |
                    v
             完整 ModuleState Miss
                    |
                    v
          Hard-Value Consumers 按依赖失效
```

一个 Initializer Body、Dependency 或求解顺序变化会使完整 ModuleState Miss，不能独立激活旧 Initializer FunctionBody。

### 13.6 Enum 变化

Enum name/order/value 改变会改变 EnumAuthorityHash 和 TypeSchema。若具体 Enum value 被函数或 Global 作为 hard value 使用，相应记录的 hard-value dependency 也会失效。

### 13.7 注释、空白或格式变化

原始源码 Hash 变化会使 SourceIndex 不再精确命中，因此需要重新 Preprocess/Parse 证明语义未变。若 canonical AST 不变，Execution FunctionBody 可以继续命中；如果 line mapping 改变，可能只更新 DebugSidecar。

```text
只增加注释/空行
       |
       v
SourceIndex 变化
       |
       v
重新 Preprocess / Parse
       |
       v
Canonical AST 相同
       |
       +-- FunctionBody Execution Hit
       +-- TypeSchema Hit
       +-- ModuleState Hit
       +-- DebugSidecar 视映射变化决定 Hit/Miss
```

### 13.8 Include、Define 和 Generated Source 变化

SourceIndex 的 include/generated graph 找出消费者。消费者文件本身可以没有字节变化，但其预处理结果和语义可能变化；因此这些 Module 重新 Parse 后仍按 Interface/Type/State/Function 分类。

### 13.9 外部 UE Binding ABI 变化

Cache 不使用整个 binding surface 的总 Hash。初始化 binds 后，per-engine `FAngelscriptEnvironmentSymbolCatalog` 为可见类型、函数、Global、Property 建立 stable key 和 ABI/layout fingerprint。记录只持久化实际使用的环境依赖，所以无关 binding 新增不会造成全 Cache Miss；被引用符号 ABI 变化只失效相应闭包。

## 14. 变化分类总图

```text
.as 文件或其输入发生变化
          |
          v
SourceIndex 找到受影响 Module Closure
          |
          v
重新 Preprocess / Parse
          |
          v
声明/签名/Owner/Qualifier 变化？
          |
          +-- 是 --> ModuleInterface / Declaration / Structural Change
          |
          v
Property/Base/Interface/Layout/Reflection 变化？
          |
          +-- 是 --> TypeSchema / Structural Change
          |
          v
Global/Constant/Initializer/Order 变化？
          |
          +-- 是 --> ModuleState Change
          |
          v
函数 StableKey 相同但 canonical AST 变化？
          |
          +-- 是 --> FunctionBody Change
          |
          v
函数源码没变，但实际依赖 ABI/Layout/Value 变化？
          |
          +-- 是 --> FunctionDependency Change
          |
          v
仅 Source Mapping / Debug State 变化？
          |
          +-- 是 --> DebugSidecar Change
          |
          v
取所有变化产生的 typed invalidation closure 并集
```

分类不是互斥选择。一个文件可以同时包含 Property、FunctionBody 和 Global Initializer 变化，最终失效集合是所有分类闭包的并集。

## 15. 典型修改矩阵

| 修改 | 识别依据 | 主要失效记录 |
|---|---|---|
| 修改函数内计算或控制流 | StableFunctionKey 相同、SourceDigest 变化 | 对应 FunctionBody，可能 DebugSidecar |
| 修改局部变量 | Function AST/stack/local 内容变化 | 对应 FunctionBody，可能 DebugSidecar |
| 只改注释/格式 | Raw Source 变、canonical AST 不变 | SourceIndex；可能 DebugSidecar，Execution Body 可命中 |
| 修改参数、返回值或 Qualifier | StableFunctionKey/Declaration ABI 变化 | ModuleInterface、Owner TypeSchema、Caller 闭包 |
| 只改展示类 UFUNCTION metadata（Category/DisplayName 等） | StableFunctionKey 相同，Metadata/TraitsHash 变化 | ModuleInterface、Owner TypeSchema/Reflection、Blueprint impact；FunctionBody 可复用 |
| 修改 BlueprintCallable/Pure/Exec/AuthorityOnly | StableFunctionKey 相同，ReflectionFlags、SignatureHash/TraitsHash 变化 | ModuleInterface、Owner TypeSchema/UFunction reflection；签名相同的 AS FunctionBody 通常可复用 |
| 修改 BlueprintEvent/Override/CanOverrideEvent | StableFunctionKey 通常相同，Method/VFT/dispatch 角色变化 | ModuleInterface、TypeSchema Method/VFT/UFunction members、派生/调用闭包 |
| 修改 Server/Client/NetMulticast/Validation/Reliability | StableFunctionKey 通常相同，RPC call semantics 与 Entry ABI 变化 | Declaration ABI、FunctionInput/Body、RPC thunk、StaticJIT route、调用闭包 |
| 重命名函数、修改 owner 或函数种类 | StableFunctionKey 变化 | 旧声明退出当前快照，新声明/FunctionBody/TypeSchema/调用闭包重新建立 |
| 新增/删除 Property | Property set/layout 变化 | TypeSchema、ModuleSnapshot、结构依赖闭包 |
| 修改 Property 类型 | DeclaredType/storage/layout/ABI 变化 | TypeSchema、实际访问者 FunctionBody |
| 只改 Property 默认逻辑 | Generated Init AST 变化 | 通常 `__InitDefaults` FunctionBody；必要时 TypeSchema |
| 修改 Base Class | Base/layout 变化 | 当前和派生 TypeSchema、结构依赖闭包 |
| 增删 Interface | Interface declaration/TypeSchema 变化 | TypeSchema、ModuleInterface、实现/调用闭包 |
| 修改 UPROPERTY/UFUNCTION Metadata | Reflection schema 变化 | TypeSchema、ClassGenerator/反射闭包 |
| 修改 Enum 值 | EnumAuthorityHash 变化 | Enum TypeSchema、hard-value consumers |
| 修改 Global Constant | ModuleState/hard-value 变化 | 完整 ModuleState、实际消费者 |
| 修改 Global Initializer | Initializer body/dependency/order 变化 | 完整 ModuleState |
| 修改 Include/Define | SourceIndex graph/options 变化 | 重新解析消费者，然后按语义分类 |
| 外部 Binding ABI 变化 | Environment symbol fingerprint 变化 | 实际依赖该绑定的记录 |

### 15.1 UFUNCTION 标记为什么不都改变 StableFunctionKey

`StableFunctionKey` 回答“这个逻辑函数是谁”，而不是把函数的所有可变反射状态
都塞进身份。函数名、owner、函数种类、参数/返回值和身份 qualifier 改变时形成
新 Key；仅反射暴露方式或展示 metadata 改变时保留 Key，通过独立摘要表达变化：

```text
StableFunctionKey  -> logical declaration identity and owner
SignatureHash      -> call shape plus declaration/reflection call semantics
TraitsHash         -> identity traits, declaration/reflection flags, metadata
FunctionContentHash-> executable semantics
EntryAbiHash       -> StaticJIT native entry compatibility
```

因此 `BlueprintCallable` 变化不能继续使用旧 UFunction/TypeSchema 反射快照，但
不应凭这一点把相同 AS 实现误判为全新逻辑函数。RPC/override 类标记更强：它们
改变调用路由、虚分派或 Native entry 契约，即使 StableFunctionKey 保持相同，
相关执行切片和 StaticJIT route 也必须失效。V1 的 `ReflectionFlags` 已进入
`SignatureHash` 与 `TraitsHash`；V4/V5 增量选择器必须据此区分“反射重建但函数体
可复用”和“调用语义变化导致函数体/Native route 失效”，不得只比较源码正文。

## 16. 单函数修改的增量结果

假设只修改 `APlayerCharacter::Tick` 的实现：

```text
源码扫描发现一个文件变化
          |
          v
SourceIndex 定位受影响 Module
          |
          v
只 Preprocess / Parse 受影响闭包
          |
          v
Tick StableFunctionKey 相同
          |
          v
Tick FunctionSourceDigest 变化
          |
          +------------------------------+
          |                              |
          v                              v
Tick FunctionBody Miss            其他函数 Source/Input 相同
          |                              |
          v                              v
只编译 Tick                      继续复用 FunctionBody
          |
          v
TypeSchema Hit / ModuleState Hit
          |
          v
重新组装 ModuleSnapshot
          |
          v
安全激活并发布新 generation
```

期望诊断为：

```text
ModuleInterface: Hit
TypeSchema:      Hit
ModuleState:     Hit

FunctionBody:
    Tick:        Miss -> Compile
    Jump:        Hit
    BeginPlay:   Hit
    TakeDamage:  Hit

ModuleSnapshot:
    Miss -> Reassemble

CompilerCalls:
    1
```

## 17. 类结构变化的生命周期

### 17.1 Editor 非 PIE

```text
结构修改
   |
   v
完整编译与 TypeSchema 验证
   |
   v
Module Swap / ClassGenerator / Reflection / Reinstancing
   |
成功？
 /   \
否    是
|     |
保留旧活动状态
      |
      v
原子更新 active module
      |
      v
发布新 Current
```

### 17.2 PIE 中的结构修改

```text
结构修改对全新 Engine 合法
             |
             v
当前 PIE 中已有旧布局实例，不能安全替换
             |
      +------+----------------------+
      |                             |
      v                             v
active Current 保持旧状态       生成 Cold Candidate
与当前 live module 对齐              |
                                    v
                            PendingColdStart
                                    |
                                    v
                      PIE 结束后的完整冷/全量事务
                                    |
                                    v
                           成功后提升为 Current
```

### 17.3 Packaged Runtime

Runtime reload 默认 Disabled。显式启用 Manual 或 Automatic 时，所有请求通过 game-thread safe point：

```text
变化
 |
 v
Game-Thread Safe Point
 |
 +-- Code-Only
 |      -> AppliedCodeOnly
 |      -> 可发布 Current
 |
 +-- Signature / Property / Inheritance / Class or Global Layout /
     Interface / Delegate / Enum / Structural Dependency
        -> RequiresRestart
        -> 不替换 live structure
        -> 不发布为活动 Current
```

全新进程没有旧 live instances，新源码若合法，可以在冷启动事务中建立新结构。

## 18. 唯一 Decoder、Factory 和 Module Graph

Cache V2 限制为一条生产所有权路径：

```text
Pack Record Payload
          |
          v
Envelope / Declared RecordId Validation
          |
          v
唯一 Seven-Kind Factory
          |
          v
本地 Candidate
├── Physical Decode
├── Local Semantics
├── Derived Hashes
├── Budget
├── Captured Offsets
├── Opaque Validation
└── RecordId Recompute
          |
       全部成功？
      /          \
    否            是
    |             |
输出为空          一次性 Promotion
释放 Scratch          |
                     v
          Shared Const Validated Handle
                     |
                     v
        唯一 ValidateModuleSnapshotGraph
                     |
                     v
               Module Assembly
```

测试可以观察或注入同一路径的 checkpoint，但不能建立第二套 semantic decoder、record owner、graph traversal 或直接 publisher。Manifest generation reachability 必须消费同一 Factory 和 Module Graph，而不是再实现一套解释器。

## 19. Budget 和不可信输入

缓存字节在 Engine mutation 前经过 fail-closed 验证：

```text
输入字节
   |
   v
Magic / Schema / Kind
   |
   v
Overflow / Count / Offset / Length
   |
   v
Codec / Checksum / Canonical Order
   |
   v
Duplicate / Conflicting Keys
   |
   v
Dependencies / Roots / Reachability
   |
   v
预算预测
   |
Budget 足够？
 /           \
否            是
|             |
分配前拒绝     Reserve / Allocate
               |
               v
        predicted == actual allocator bytes？
             /              \
           否                是
           |                 |
        Fail Closed        继续验证
```

Controller、Payload、nested strings/arrays、captured offsets、scratch 和 retained output 进入同一 chronology 和 combined-live peak。失败释放 live ownership，但不回退已经消费的单调计数。

## 20. 并行与串行边界

允许 Worker 并行执行纯准备工作：

```text
Source Scan / Hash
Manifest / Pack I/O
Validation
Decompression
Hit Planning
Digest Preparation
Compression
Pack Construction
Immutable DTO Preparation
```

以下工作必须由每 Engine 的 Mutation Gate 串行化：

```text
Declaration Creation
Type / Layout Materialization
Stable Reference Attachment
Globals / Initializers
Module Swap
ClassGenerator / Reflection
Stable Route Rebuild
Current / Pending Selection
StaticJIT Route Refresh
Shutdown / Cancellation
```

总体线程边界为：

```text
Bounded Parallel Workers
          |
          v
   Immutable DTO Queue
          |
          v
Per-Engine Mutation Gate
          |
          v
 Freeze Successful DTO
          |
          v
Store Namespace Lock
          |
          v
Reread / Rebase / Atomic Publish
```

Worker 不调用 AngelScript Engine API，也不重新读取可变 descriptors。

## 21. 原子发布和恢复

发布顺序为：

```text
1. 构建不可变 Pack
2. Write / Flush / Close
3. Reopen / Validate
4. no-replace 安装最终 Pack
5. 构建 Manifest
6. Write / Flush / Close
7. Reopen / Validate
8. 在 namespace lock 下重新读取并 rebase slots
9. Previous <- old Current
10. 原子替换 Current <- new Generation
11. Directory Sync / Final Reopen Validation
```

故障语义：

```text
Current 替换前崩溃
    -> 旧 Current 完全保留

Current 已原子替换，随后 Cancel/Sync 结果不确定
    -> 重新读取指针
    -> 已提交则记录 CurrentCommitted
    -> 不伪造回滚

Current 或所需 Pack 损坏
    -> 仅可考虑 SourceIndex/Profile 匹配的 Previous/Pending
    -> 不可执行不同源码版本的 stale fallback

新源码 Fresh Startup 编译失败
    -> 返回类型化失败
    -> 不激活不同源码的旧 generation

Hot Reload 失败且已有有效 active module
    -> 保持 last-good active state
    -> 不推进 Current 到失败源码
```

## 22. Compaction

正常启动和增量发布不为删除不可达记录而重写所有 Pack。Current、Previous、PendingColdStart 当前有效指针都是物理 retention roots。

显式 `as.Cache.Compact` 采用两阶段：

```text
重新验证 Source / Profile / Roots
          |
          v
Phase A：构建可达并集的新不可变对象
          |
          v
原子切换重写后的 slot pointers
          |
          v
Phase B：重新获取锁并重新标记最新 roots
          |
          v
只删除严格命名且仍不可达的 final objects
```

Reader 正在 pin 旧 Pack 时，删除失败延后处理，不破坏已提交指针。Startup 不自动运行 compaction。

## 23. StaticJIT 与 Live Coding

Cache V2 和 StaticJIT 是兄弟系统：

```text
                    Cache V2
                       |
     StableFunctionKey + FunctionContentHash + Profile
                       |
                       v
             StaticJIT Provider 查询
                       |
             +---------+---------+
             |                   |
             v                   v
     Provider 精确匹配       Provider 不存在/不匹配
             |                   |
             v                   v
        Native Entry          VM Entry
```

Provider 缺失、移除、Content/Profile/ABI 不匹配只改变 Native/VM 路由，不使合法 Cache generation 失效。

Live Coding 的作用限定为：

```text
Editor Live Coding
       |
       v
重新构建或加载外部 StaticJIT Provider Module
       |
       v
刷新 StableFunctionKey -> Native Entry Route
```

它不负责 SourceIndex、Cache generation、Current pointer 或 `.as` 正确性。

## 24. Shutdown

Editor/Runtime Shutdown 只做 bounded flush：

```text
Flush 已完成或已准备的 Cache 工作
默认最多等待 5 秒
不在 Shutdown 新发现源码
不在 Shutdown 新 Preprocess
不在 Shutdown 新 Parse
不在 Shutdown 新 Compile
```

Editor 成功的 initial compile、soft reload 或 structural reload 应在正常事务完成后持续维护 Cache V2，不依赖关闭 Editor 才生成缓存。

## 25. 旧 Cache 的最终边界

V2 parity 后直接移除：

```text
PrecompiledScript.Cache Reader / Writer
DataGuid Cache Correctness
Old Pointer Relocations
Persisted Numeric FunctionIds
Old FunctionId Relocation Maps
Forced-Exit Cache Generation
Package Pre-Generation Step
```

不提供：

```text
V1 Reader
V1 -> V2 Migration
V1/V2 Dual Write
V2 Failure -> V1 Fallback
```

Sibling StaticJIT 尚需的 numeric generated-registration transport 单独清点，它不拥有 Cache 正确性。`Binds.Cache` 继续独立支持。

## 26. 当前实施顺序

旧计划把 Records、Pack、Store、Compiler、Lifecycle 做成完整水平阶段，导致真正
Cold/Warm Cache 长期不在关键路径。当前按纵向检查点推进，同时不绕过所选模块的
完整 decoder/graph/VM validation：

```text
V0 Stable Identity / Wire Foundation       已保留
                |
                v
V1 Real Module In-Memory Transaction       当前实现路径
                |
                +------> V2 Pack / Manifest / Store / Cold Publish
                                  |
                                  v
                        V3 Exact Warm Restore
                                  |
                                  v
                        V4 Changed-Module Clean Oracle
                                  |
                                  v
                        V5 Per-Function Compiler Hit
                                  |
                                  v
                        V6 Editor / PIE / Runtime / StaticJIT Routes
                                  |
                                  v
                        V7 Cutover / Package / Real Acceptance
```

纯 Pack/Manifest 和 Store 数据面可以在其冻结 byte/publication contract 下尽早
实现，不再等待每一个无关的 TypeSchema negative matrix。真实 activation 仍必须
通过唯一 Factory、唯一 ModuleSnapshotGraph、private VM codec 和累计 Budget。
Changed-module clean compile 先建立语义 Record 比较 oracle，随后 V5 在相同
artifact model 上证明真正逐 invocation 跳过 `asCCompiler`。真实 PIE 和
Development/Shipping multi-launch 验收仍最后进行。

## 27. 当前实现状态声明

截至 2026-08-12，本文的核心流程已经落到生产路径；本节取代早期
“V1 partial / V2 design only”的历史快照。当前事实为：

```text
V0 Stable Identity / Common Archive
    Complete GREEN

V1 In-Memory Module Transaction
    Complete GREEN
    ModuleInterface / TypeSchema / ModuleState / FunctionBody /
    DebugSidecar / ModuleSnapshot 均有 canonical codec 和 graph validation

V2 Generation / Store / Cold Publish
    Complete GREEN
    Immutable Pack / Manifest / Current / Previous / PendingColdStart /
    atomic publication / recovery / compaction / multi-process lock

V3 Exact Warm Restore
    Complete GREEN
    direct-input candidate、fresh Engine exact restore、zero-compile fast path

V4 Changed-Module Clean Oracle
    Complete GREEN
    mutation classification、typed invalidation、incremental generation、
    dependent recompile wave、forced-clean equivalence

V5 Per-Function Compiler Reuse
    Complete GREEN
    maintained-AS builder hook、actual dependency capture、production hybrid
    compiler reuse、class graph/property/inheritance current authority

V6 Lifecycle / StaticJIT Isolation
    Complete GREEN
    Editor / PIE / packaged reload policy、per-Engine stable route、
    StaticJIT compatibility isolation、schema-4 diagnostics、Python dump

V7 Cutover / Package / Real Acceptance
    V7.1..V7.6 Complete GREEN
    legacy production cache removed；Development / Shipping seven-launch
    matrices、real PIE、HotReload、generated-AOT StaticJIT 已通过

V7.7 Benchmark / Writer Policy / Final Regression
    Complete GREEN
    production bounded-parallel immutable Pack preparation 与 4/16/64 MiB
    tests、真实 56-row benchmark、最后 Shipping、536/536 Cache 与
    37-shard 2971/2971 parallel-All 已通过
```

V0–V7.7 已全部完成，`tasks.md` 为 `54/54`。最终证据来自本轮最新代码：完整
benchmark、fresh Shipping、完整 Cache/Standalone 和四槽并行 All。旧 Slice/
ready packet 保留为历史审计附件，不再指导实现顺序；权威完成状态以
`tasks.md`、`status.md`、`implementation-issues.md` 和 `verification.md` 为准。

## 28. 最终简图

```text
Source Changed?
     |
     +-- Direct Inputs + Candidate Exact ----------------------+
     |                                                         |
     |                                                   Exact Warm Restore
     |                                                0 Preprocess/Parse/Compile
     |
     +-- Miss / Changed
           |
           v
Authoritative Preprocess / Affected Module Closure
           |
           v
Parse -> Declaration -> Semantic/Layout
           |
           +-- Declaration/Signature ----> ModuleInterface Change
           +-- Type/Layout/Reflection ----> TypeSchema Change
           +-- Global/Initializer --------> ModuleState Change
           +-- Function AST --------------> FunctionBody Change
           +-- Actual Dependency ---------> FunctionInput Change
           +-- Debug Mapping -------------> DebugSidecar Change
           |
           v
Per StableFunctionKey Compile Selection
     exact FunctionInput -> attach validated FunctionBody
     miss/unsupported    -> authoritative compile
           |
           v
Typed Minimum Complete Invalidation Closure
           |
           v
Sole Seven-Kind Factory
           |
           v
Sole ModuleSnapshotGraph
           |
           v
Atomic Module Assembly / ClassGenerator / Reflection
           |
        Success?
       /        \
     No          Yes
     |            |
Keep Correct      v
Active State   Freeze Pointer-Free DTO
                  |
                  v
          Deterministic Pack / Manifest
                  |
                  v
             Immutable Store
                  |
                  +-- Editor/Code-Only ------> Current
                  +-- PIE Structural --------> PendingColdStart
                  +-- Packaged Structural ---> RequiresRestart
                  |
                  v
           Next Launch Incremental Reuse
```

## 29. 相关权威文档

- `proposal.md`：产品动机、破坏性边界和影响范围。
- `design.md`：架构和生命周期决策。
- `specs/as-incremental-script-cache/spec.md`：增量 Cache 行为规范。
- `specs/as-script-artifact-identity/spec.md`：稳定 artifact identity 规范。
- `specs/as-cooked-packaging-runtime/spec.md`：打包和运行时变化。
- `record-wire-v1.md`、`record-wire-v1-remaining.md`：七类 record wire 权威。
- `manifest-pack-wire-v1.md`：Manifest/Pack wire 权威。
- `store-publication-v1.md`：路径、指针和原子发布权威。
- `type-layout-authority-v1.md`、`type-schema-matrix-v1.md`：类型和布局权威。
- `status.md`：当前进度、阻塞和下一门槛。
- `implementation-plan.md`、`tasks.md`：当前执行计划和 backlog slices。
