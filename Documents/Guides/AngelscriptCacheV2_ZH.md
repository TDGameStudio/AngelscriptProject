# AngelScript Cache V2 使用与排障指南

本文面向插件使用者和维护者，说明增量 Cache V2 在 Editor、PIE、Development、Shipping 与 StaticJIT 路由中的实际职责、磁盘布局、配置、调试入口和验证方法。完整设计推导与变更分类见 `openspec/changes/refactor-as-incremental-function-cache/cache-v2-flow-and-change-classification.md`。

## 1. 它解决什么问题

Cache V2 把 AngelScript 启动时已经验证过的编译产物保存为内容寻址、可增量复用的记录。第一次启动没有合法缓存时，源码仍按正常流程编译；编译成功后生成缓存。后续启动优先尝试精确恢复，源码或环境变化时只复用仍然有效的记录并重新编译失效部分。

源码永远是正确性权威。缓存损坏、版本不兼容、源码身份不匹配或依赖验证失败都会转成类型化 miss 或启动失败，不会为了“尽量启动”而执行另一份旧源码对应的缓存。

它主要降低 Engine 初始化、Editor/PIE 脚本装载和 packaged process 启动时的工作量，但也由成功的 Editor hot reload、可选 packaged runtime reload 和正常 Engine shutdown 维护。Editor 关闭不是生成缓存的唯一时机；shutdown 只在默认 5 秒上限内 flush 已冻结的发布任务，不重新扫描、预处理、解析或编译源码。

## 2. 缓存粒度

Cache V2 不把一个 `.as` 文件简单保存成一个不可拆分的大对象，也不为每个函数创建一个物理文件。逻辑记录按语义拆分，磁盘再把不可变记录聚合为 Pack：

| 逻辑记录 | 保存的主要内容 | 常见失效原因 |
| --- | --- | --- |
| `SourceIndex` | mount、provider、文件、include/generated 输入及摘要 | 原始源码、include、define、provider 或预处理配置变化 |
| `ModuleInterface` | 模块声明、import、函数/类型/global/property 的公开契约 | 声明、签名、owner、trait 或 import route 变化 |
| `TypeSchema` | 继承、接口、property、layout、method/VFT、reflection/enum 权威 | 类结构、布局、反射标记、继承、接口或 enum 变化 |
| `ModuleState` | globals、constants、initializer、初始化顺序与依赖 | global/constant/initializer/order 变化 |
| `FunctionBody` | 稳定函数身份、输入摘要、VM 执行产物和实际依赖 | 函数逻辑、调用 ABI 或实际依赖 fingerprint 变化 |
| `DebugSidecar` | 行号、源码映射等调试信息 | 行映射或 debug profile 变化；Shipping 可省略 |
| `ModuleSnapshot` | 一个可恢复模块引用的完整记录集合 | 任一必需组成记录或模块装配关系变化 |

因此“模块是恢复和激活的原子单元”与“函数、类型、模块状态可以独立复用”可以同时成立。恢复不会把半个新模块和半个旧模块暴露给 Engine。

## 3. 修改如何分类

原始文件字节变化首先使精确 `SourceIndex` 快路径 miss；系统随后使用正常 preprocessor、parser、声明与 semantic/layout 权威判断实际影响，不靠文件名或正则表达式猜测。

典型结果如下：

- 只改函数体：`StableFunctionKey` 保持不变，对应 `FunctionBody` 的 source/input/content 摘要变化；无关函数、类型和模块状态仍可复用。
- 改函数参数、返回值、qualifier、owner 或函数种类：稳定函数 key 或声明 ABI 变化，`ModuleInterface`、owner `TypeSchema` 以及实际 caller 闭包失效。
- 改 property、基类、接口、method/VFT、reflection 或 enum：对应 `TypeSchema` 与结构依赖闭包失效；真正访问变化布局的函数也会因依赖摘要变化而 miss。
- 改 global、constant、initializer 或初始化顺序：完整 `ModuleState` 失效，使用 hard value 的消费者按实际依赖失效。
- 只加注释、空格或换行：原始 hash 会变化，所以需要重新 preprocess/parse；若 canonical 语义不变，执行 `FunctionBody`、`TypeSchema` 和 `ModuleState` 仍可命中，行号变化时通常只更新 `DebugSidecar`。
- 改 `UFUNCTION` 展示 metadata：通常保持逻辑函数 key，但重建声明/type reflection；RPC、event、virtual dispatch 等会改变调用语义的标记还会使执行路由和相关调用闭包失效。

第一次编译时，compiler 会捕获名称、类型、property、global、operator、hard value 和可选嵌入内容等实际依赖。以后即使 caller 源码没改，只要它实际依赖的 ABI/layout/value 变化，预编译选择器也能让它安全 miss。

## 4. StableFunctionKey 与 StaticJIT

Cache V2 不持久化进程内 numeric FunctionId。函数的逻辑身份使用 domain-separated BLAKE3-256 `StableFunctionKey`，由稳定 module/owner、namespace、function kind 和 canonical declaration/traits 构成。普通函数体修改保持 key，重命名、owner、签名、qualifier 或函数种类变化会得到新 key。

每个新 Engine 从已经恢复或编译的函数重建 `StableFunctionKey -> 当前 Engine FunctionId` 路由。StaticJIT provider 使用稳定函数 key、函数执行内容 hash、profile 和 ABI 选择 Native entry；缺失、过期或不匹配的 Native provider 只让该路由回退 VM，不会让一份不合法 Cache generation 变合法。

UE Live Coding 可用于刷新 Editor 中已经编译进外部模块的 Native provider 和函数入口，但它不负责判断 `.as` 源码新鲜度，也不拥有 Cache generation、`Current` 指针或 hot reload 正确性。

## 5. Editor、PIE 与 packaged runtime

### Editor 非 PIE

成功的 initial compile 或 hot reload 会冻结一份无指针 DTO，并异步准备 Pack/Manifest。代码或结构更新只有在正常 module swap、ClassGenerator、reflection 和 reinstancing 成功后才成为新的 `Current`；失败时保留旧活动模块与旧 `Current`。

### PIE

函数体-only 的安全更新可以跟随活动 Engine 更新 `Current`。如果结构变化对全新 Engine 合法、但当前 PIE 已有旧布局实例而不能安全替换，活动 `Current` 保持与当前 Engine 一致，新源码候选发布到 `PendingColdStart`。PIE 结束后的完整冷/全量事务成功后，才能把新结构提升为 `Current`。

### Development / Shipping

包内保留 loose `.as` 源码，不要求在打包前生成 cache baseline。第一次启动从权威源码编译并发布 `Current`；以后未修改启动可精确恢复。packaged runtime reload 默认 `Disabled`。显式配置 `Manual` 或 `Automatic` 时，请求在 game-thread safe point 执行：code-only 变化可应用并发布，新类结构、签名、layout 等变化返回 `RequiresRestart`，不会热替换 live structure。

## 6. 磁盘布局与原子发布

默认基目录是 `Saved/Angelscript/CacheV2`。每个 compatibility/context 组合使用独立 namespace：

```text
Saved/Angelscript/CacheV2/
  <CompatibilityHash>/
    <ContextHash>/
      Current.ascurrent
      Previous.ascurrent
      PendingColdStart.ascurrent
      Generations/
        <GenerationId>.asmanifest
      Packs/
        <PackId>.aspack
```

Pack 和 Manifest 是不可变、内容寻址文件；pointer 文件很小并原子替换。正常 `Current` 发布会把旧 `Current` 推到 `Previous`。崩溃发生在 pointer 替换前时旧 `Current` 完整保留；替换后状态不确定时通过重新读取 pointer 判定是否已经提交。`Current`、`Previous` 和 `PendingColdStart` 都是 compaction 的 retention roots。

## 7. 配置和命令行覆盖

Project Settings 中的 `AngelScript Incremental Cache` 对应 `UAngelscriptCacheSettings`：

| 设置 | 默认值 | 说明 |
| --- | ---: | --- |
| `bEnableCacheV2` | `true` | Editor 与 packaged runtime 生成/消费 Cache V2 |
| `ShutdownFlushTimeoutSeconds` | `5.0` | shutdown 等待已冻结发布的最长秒数 |
| `PackTargetMiB` | `64` | 每个不可变 Pack 的 canonical raw byte 目标，范围 1..256 MiB |
| `bEnableParallelPreparation` | `true` | 并行压缩不可变 records 并构建互相独立的 Packs |
| `MaxPreparationWorkerCount` | `4` | Cache 专用准备 worker 上限，范围 1..64 |
| `bEnableDecisionTrace` | `false` | 开启有界、无指针的决策事件环形缓冲 |
| `DecisionTraceCapacity` | `1024` | 最多保留的事件数，范围 1..65536 |
| `PackagedRuntimeReloadMode` | `Disabled` | packaged reload 的 Disabled/Manual/Automatic 策略 |

诊断或基准可以用以下 process 参数覆盖，不需要改项目配置：

```text
-as-cache-root=<absolute-directory>
-as-cache-report=<absolute-json-path>
-as-cache-trace
-as-cache-trace-capacity=<1..65536>
-as-cache-pack-target-mib=<1..256>
-as-cache-preparation-workers=<1..64>
-as-cache-force-serial-preparation
```

正常生产策略是 64 MiB、最多 4 个 worker 的 bounded parallel preparation。worker 只处理不可变 DTO、压缩和独立 Pack 构造，不调用 AngelScript Engine API，也不读取可变 descriptor。声明创建、类型/layout materialization、globals/initializers、module swap、ClassGenerator、stable route 和 generation 选择仍由每 Engine mutation gate 串行化。forced-serial 和并行模式必须产生 byte-identical Pack、Manifest、RecordId 和 GenerationId。

## 8. 运行时调试入口

Console 命令均使用当前 Engine，并返回类型化结果：

```text
as.Cache.Status
as.Cache.Status Json=Diagnostics/cache-status.json
as.Cache.Flush Timeout=5
as.Cache.Verify Generation=Current Deep=1
as.Cache.Verify Generation=Previous Deep=0
as.Cache.Compact Timeout=5
as.Cache.ForceClean
as.Cache.ForceClean Module=<canonical-name-or-stable-module-key>
as.Cache.Trace Enable Capacity=4096
as.Cache.Trace Dump Json=Diagnostics/cache-trace.json
as.Cache.Trace Clear
as.Cache.Trace Disable
as.Cache.Explain Transaction=<ordinal> Module=<64-hex-key>
```

`Json=` 路径必须位于 Project `Saved` 下。`Status` 和 `-as-cache-report` 生成相同的 pointer-free schema 4 session JSON，可与不同进程、Editor 或游戏启动的离线 dump 按 stable coordinates 关联。Blueprint 可调用 `Get AngelScript Cache Status JSON`。C++ 可使用 `CaptureAngelscriptCacheDiagnosticSnapshot`、`CaptureCurrentAngelscriptCacheDiagnosticJson`、`VerifyAngelscriptCacheStore`、`FlushCurrentAngelscriptCacheToStore`、`CompactAngelscriptCacheStoreForEngine`、`ForceCleanAngelscriptCache` 和 `ExplainAngelscriptCacheDecisions` 等 typed API。

## 9. Python 只读 dump

离线工具不启动 Unreal，也绝不修改 cache：

```powershell
python Plugins/Angelscript/Tools/CacheV2Dump/cache_v2_dump.py `
    Saved/Angelscript/CacheV2

python Plugins/Angelscript/Tools/CacheV2Dump/cache_v2_dump.py `
    Saved/Angelscript/CacheV2 --json --generation Current

python Plugins/Angelscript/Tools/CacheV2Dump/cache_v2_dump.py `
    Saved/Angelscript/CacheV2 --json `
    --session-report Saved/Diagnostics/cache-session.json

python Plugins/Angelscript/Tools/CacheV2Dump/cache_v2_dump.py `
    Saved/Angelscript/CacheV2 --json --diff Previous Current

python Plugins/Angelscript/Tools/CacheV2Dump/cache_v2_dump.py `
    Saved/Angelscript/CacheV2 --json --explain <stable-key>
```

它可以验证 pointer、Manifest、Pack、BLAKE3 identity、index、codec、checksum、record identity 和部分公共 payload schema，并显示 module/type/function/global/reuse 统计。它是物理完整性与观察工具，不代替 Runtime 对当前 ABI、依赖图、relocation、预算和 Engine materialization 的最终验证。

## 10. 验证与基准入口

常用入口均通过仓库 wrapper：

```powershell
# Python dump 自测
Tools\RunCacheV2DumpTests.ps1

# Cache C++/Engine 测试前缀
Tools\RunTests.ps1 -TestPrefix Angelscript.TestModule.Cache

# Development 或 Shipping 真实打包、多次启动矩阵
Tools\RunAngelscriptCachePackageSmoke.ps1 -Configuration Development
Tools\RunAngelscriptCachePackageSmoke.ps1 -Configuration Shipping

# 对一个已生成的 loose package archive 做真实多进程基准
Tools\RunAngelscriptCacheBenchmark.ps1 `
    -ArchiveRoot <archive-root> `
    -Configuration Development `
    -WarmupRuns 1 -MeasuredRuns 3

# 全量 UE Automation 并行分片
Tools\RunTestSuiteParallel.ps1 -Suite All -Strategy CoarseDynamic `
    -TestModuleWorkers 4 -MaxParallelLight 4 -MaxParallelHeavy 4
```

基准使用 disposable package fixture 和隔离 cache roots，覆盖 cold、exact warm、函数体、类型、模块状态、诊断开销与 4/16/64 MiB 串并行组合。计时只做观测，不设置未经真实基线证明的机器时间 pass threshold；semantic parity、process exit、report/dump 关联和确定性才是硬性断言。

2026-08-12 的 V7.7 Development 小型 fixture 基准包含 38 个 staged source、
一个 32.7 KiB Pack。其 cold median 为 11093 ms，unchanged warm 为
14055 ms；warm report 恢复 18 个函数，同时仍有 4 个 compiled miss 和 4 个
typed `NotCacheable`，因此这组数据**没有证明启动加速**，不能用来宣传性能收益。
4/16/64 MiB 在该 fixture 中都只有一个 Pack，并行相对串行 median 为
+0.40% / +1.45% / +0.60%，只证明结果一致，不能证明 worker 加速。更大的真实项目
语料和更细 stage timing 是后续性能调优的前提；当前 64 MiB/4 worker 是保守默认，
不是由这个小样本选出的最优值。Summary 与 Disabled 的 process median 差 0.07%，
Verbose 差 0.22%，同样只作为三次测量的观察值。

## 11. 排障顺序

1. 先保存 process log，并通过 `-as-cache-report=<absolute-json>` 或 `as.Cache.Status Json=...` 取得 session JSON。
2. 对所选 namespace 执行 `as.Cache.Verify Generation=Current Deep=1`。浅验证检查 Store/Manifest/Pack 边界，深验证继续解压和 decode reachable records。
3. 用 Python `--session-report` 关联 live profile/context/source/generation/function routes 与磁盘 Store；用 `--diff Previous Current` 判断实际改变的 records。
4. 需要知道“为什么 miss/回退”时，启动前显式加 `-as-cache-trace`，再用 `as.Cache.Trace Dump` 或 `as.Cache.Explain` 查询 bounded event journal。平时保持 trace 关闭以控制诊断开销。
5. 怀疑缓存路径影响行为时，用 `as.Cache.ForceClean` 走权威 clean compile，与 cached 结果比较；不要手工修改 `.asmanifest`、`.aspack` 或 pointer 文件。
6. 若 compatibility/context/profile、source snapshot、UUID/GenerationId 或 stable key 对不上，让本次启动正常 miss 并生成新 generation。开发期不提供旧 cache reader 或迁移工具；需要彻底重建时，关闭相关进程后删除该项目 `Saved/Angelscript/CacheV2` 的精确目录即可，源码不会受影响。
