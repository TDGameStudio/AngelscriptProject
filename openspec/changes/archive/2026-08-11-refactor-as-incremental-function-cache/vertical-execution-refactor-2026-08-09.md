# Cache V2 纵向执行重构决定

日期：2026-08-09（Asia/Shanghai）

状态：当前执行方向说明。本文不取代 delta spec、wire、identity golden、
TypeSchema/ModuleState matrix、Store publication 或 StaticJIT 兄弟规范；它解释
这些既有契约如何按真实产品需求组成一条可交付路径。

## 1. 决定摘要

Cache V2 不降级为模块 Blob Cache。最终系统继续同时具备：

- 完整 256-bit `StableFunctionKey`；
- 函数级 `FunctionBody` / `DebugSidecar` 和 `FunctionContentHash`；
- changed module 内基于 `FunctionSourceDigest`、持久化实际依赖和
  `FunctionInputDigest` 的逐函数 Compiler Hit/Miss；
- StaticJIT 对 `{StableFunctionKey, FunctionContentHash, ArtifactProfileKey,
  ABI}` 的精确 Provider 匹配；
- 逐函数 Native/VM 路由和 HotReload 后的 Engine-owned route rebuild；
- 类型、全局和活动模块的 `ModuleSnapshot` 原子激活；
- 不可变 Record/Pack、完整 Generation Manifest 和 root-last publication。

本次重构改变的是执行顺序和若干流程表达：

1. 把“当前可直接发现的 Source 输入”和“上次预处理捕获的候选依赖”分开；
2. 把完整编译作为权威 fallback 和 clean-vs-cached 等价性 oracle；
3. 先跑通真实 Cold -> Publish -> Warm -> Edit 闭环，再扩张水平异常矩阵；
4. TypeSchema `Dependencies` 继续负责 Record 自洽和恢复安全，不充当源码
   变化分类器；
5. 只有 wire/identity/ownership/publication 等高风险边界需要额外冻结审查，
   普通实现使用直接 TDD、构建和 focused/integration evidence。

## 2. 实际产品需求

本变更必须同时覆盖以下使用方式：

```text
Editor / PIE
    .as HotReload 继续由现有前端和 ClassReloadHelper 掌权
    变化函数立即拥有正确 VM artifact
    未变化且 Provider 精确匹配的函数继续 Native
    变化函数在新 StaticJIT Provider 到达前逐函数回退 VM
    结构变化由 Current / PendingColdStart / reinstancing 规则处理

Development / Shipping
    第一次没有 Cache 时正常编译并发布 Saved generation
    后续未变化启动精确恢复，Preprocess/Parse/Compiler 计数为零
    Cache 缺失、损坏或 profile 不匹配时安全 miss/rebuild
    packaged end user 不运行 UBT、C++ compiler 或 Live Coding

StaticJIT external module
    StableFunctionKey 跨重启、HotReload、FunctionId 变化和 Cache repack 稳定
    FunctionContentHash 变化只使对应 Native Entry 失配
    fixed bucket 由 StableFunctionKey 决定
    Live Coding 只刷新 Provider/route，不拥有 Cache freshness
```

## 3. 必须分开的粒度

| 责任 | V1 粒度 | 说明 |
|---|---|---|
| 源码变化发现 | File / Module input | Raw bytes、logical path、provider/options/profile。 |
| 预处理、解析和声明 | 受影响 AS Module | 使用现有权威前端，不建立第二套启发式分类器。 |
| 持久化 Artifact | Type / Function / ModuleState Record | 允许 content-addressed 独立复用。 |
| 函数编译选择 | StableFunctionKey | `FunctionInputDigest` 命中才跳过该 invocation 的 `asCCompiler`。 |
| StaticJIT Provider | StableFunctionKey + content/profile/ABI | 逐 Entry 精确匹配。 |
| 运行时激活 | ModuleSnapshot | 类型、全局、函数和反射必须完整验证后原子切换。 |
| 物理存储 | Aggregate Pack + Manifest | 不产生一函数一文件。 |

模块级 fallback 与函数级最终能力不冲突：当函数坐标、依赖或 VM codec
暂时不支持时，模块仍可正常编译；成功编译结果提供稳定 Key、内容 Hash 和
下一次候选。Fallback 不是另一个 Cache 格式或身份体系。

## 4. 两条权威运行路径

### 4.1 Exact unchanged path

```text
发现 DirectSourceInputs
    raw bytes / logical path / mount-provider identity
    explicit options / profile / hook-provider version
        |
        v
计算 canonical direct-input digest 并读取 Current 的 single-current candidate
        |
        v
验证 candidate 中持久化的 include/generated/actual input fingerprints
        |
        +-- 任一缺失或不匹配 -> Changed path
        |
        +-- 全部匹配
                -> 验证 Manifest / Packs / Records / ModuleSnapshot
                -> 重建当前 Engine FunctionId 和 stable routes
                -> 原子激活模块
                -> Preprocess = Parse = FunctionCompiler = 0
```

Lookup 前不得为了重建 include graph 或 effective conditional 结果而运行
Preprocessor。那些是上一次成功预处理捕获的候选状态；它们可丢弃、可重建，
不是无限增长的依赖数据库。

### 4.2 Changed module path

```text
DirectSourceInputs 或 candidate dependency 变化
        |
        v
现有 Preprocessor / Parser 处理受影响模块闭包
        |
        v
声明、ModuleInterface、TypeSchema 和 Environment authority 就绪
        |
        v
按 StableFunctionKey 进入每个 builder invocation
        |
        +-- 坐标不稳定 ----------------------> NotCacheable -> 正常编译
        +-- FunctionSourceDigest 不同 --------> Miss         -> 正常编译
        +-- actual dependency 无法解析 -------> Miss         -> 正常编译
        +-- FunctionInputDigest 精确匹配 ------> 验证/附着 FunctionBody
        |
        v
ModuleState / graph / ClassGenerator / lifecycle 完整成功
        |
        v
比较并复用相同 RecordId，只写新 content
        |
        v
ModuleSnapshot -> Manifest -> root-last publication
```

实现早期允许所有函数走正常编译，以建立权威 artifact capture 和比较 oracle；
但变更完成条件仍包含逐函数 Hit/Miss，不能把 full-module compile fallback 当作
最终命中能力。

## 5. StableFunctionKey 与三个函数坐标

```text
StableFunctionKey
    逻辑函数声明和 owner；Body 改动不变，签名/owner/kind 改动产生新 Key。

FunctionSourceDigest
    当前 parsed invocation 的 canonical token/AST slice、kind 和相关 options。

FunctionInputDigest
    FunctionSourceDigest + 当前实际依赖 ABI/layout/hard-value fingerprints；
    仅用于 Cache 的编译前选择。

FunctionContentHash
    编译或验证恢复后的执行/debug artifact 身份；用于 Cache 验证和 StaticJIT
    精确匹配。
```

`StableFunctionKey` 不包含 Body、source line、absolute path、numeric FunctionId、
pointer、RecordId、GenerationId、PackId 或 ProviderGeneration。持久化和
StaticJIT equality 使用完整 256-bit 值；`FGuid` 仅用于显示。

## 6. 变化分类的唯一权威

系统不在文件扫描阶段猜测“类改动还是函数改动”。

| 问题 | 权威答案 |
|---|---|
| 哪个文件/模块输入变化？ | DirectSourceInputs 与 persisted candidate fingerprints。 |
| 声明、签名、Import 是否变化？ | 新旧 `ModuleInterface`。 |
| 类、Property、Inheritance、Reflection、Layout 是否变化？ | 新旧 `TypeSchema`。 |
| Global、Constant、Enum hard value、Initializer 是否变化？ | 新旧 `ModuleState`。 |
| 某个函数是否可跳过 Compiler？ | `StableFunctionKey`、`FunctionSourceDigest`、当前 actual dependencies 和 `FunctionInputDigest`。 |
| Native Entry 是否可运行？ | 当前 `FunctionContentHash`、profile、Entry ABI 和 native environment。 |

TypeSchema/Function dependencies 是恢复、复用和传播的语义输入；它们不是第二套
文件级预处理器。任何不能稳定证明的情况都安全 Miss，而不是近似命中。

## 7. Clean-vs-cached 等价性 Oracle

函数级 VM attachment 和依赖捕获是项目自定义能力。每个支持的 invocation family
都必须比较同一 fixture 的：

```text
authoritative clean compile
        vs
cached compile with selected FunctionBody restores
```

至少比较 ModuleInterface、TypeSchema、ModuleState、StableFunctionKey、
FunctionContentHash、canonical bytecode、relocations、stack/locals、cleanup、
debug sidecar 和可观察 VM 行为。两条路径不相等时，Cache 路径失败为 Miss；
不得调整 clean compile 结果或放宽 StaticJIT 匹配。

## 8. 执行顺序修正

旧计划把 Record、Pack、Store、Compiler、Lifecycle 分成完整水平阶段，导致 Store、
Compiler Hook 和 Service 长期不在关键路径。新计划按以下纵向检查点推进：

```text
V0  已接受身份和 wire 基础
V1  真实模块的完整 in-memory artifact transaction
V2  Generation + immutable Store 的 cold publish
V3  Direct inputs + candidate dependencies 的 exact warm restore
V4  Changed-module full-compile oracle 与增量 Record publication
V5  Per-function compiler Hit/Miss 与 clean-vs-cached equivalence
V6  Editor/PIE/runtime lifecycle 与 StaticJIT route isolation
V7  legacy cutover、真实 PIE、Development/Shipping 和 benchmark
```

V1/V2 可以交错实现纯 Pack/Store 和剩余 record codec；但任何真实 activation 都
必须等待所选 ModuleSnapshot 的完整 decoder/graph/VM validation。纵向执行不是绕过
不可信输入、Budget、ownership 或原子发布边界。

## 9. 研究证据边界

ccache/sccache 支持 direct input key、bounded historical dependency candidates、
miss 后重新预处理/捕获和 disposable optimization state。它们不直接证明 AS 模块内
逐函数 semantic dependency、VM artifact attachment 或 StaticJIT route。

ThinLTO 支持 global facts 先于 backend reuse、稳定内容 Key、模块原子结果和并行
Backend，但它同样不直接证明本项目的函数粒度。我们采用这些成熟模式，同时把
函数级 VM/Native 组合列为必须由本项目测试证明的能力。

## 10. 本次不做的事情

- 不修改 `.as` 语言语法或建立第二套 AS 前端；
- 不删除或降级 StableFunctionKey/FunctionInputDigest/FunctionContentHash；
- 不把 FunctionBody 合并为一个不可分割 Module Blob；
- 不让 StaticJIT 消费 Cache Pack/Manifest/Generation；
- 不兼容、迁移或双写旧 `PrecompiledScript.Cache`；
- 不在启动路径强制 compaction；
- 不把 64 MiB Pack target 当作未经 benchmark 的最佳事实；
- 不提前执行真实 PIE 或 Development/Shipping package acceptance。
