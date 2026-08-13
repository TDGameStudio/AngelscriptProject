# Cache V2 测试审查 — 2026-08-13

> 范围：`Plugins/Angelscript/Source/AngelscriptTest/Cache/`（103 个 `.cpp`，0 个头文件）对照 `Plugins/Angelscript/Source/AngelscriptRuntime/Cache/` 与已归档 OpenSpec `refactor-as-incremental-function-cache`。
> 性质：只读审查。本文不改测试代码。
> 背景：Cache 单 shard 已是全量墙钟主因（约 17 分钟）。用户感觉“实现很乱”——乱主要在**测试树按 slice 堆出来**，Runtime Cache 本身按记录/Store/Service 拆得还算清楚。

## 0. 先看结论

Cache V2 的测试不是按“用户能看到的缓存契约”设计的，而是按 2026-08 那轮增量 OpenSpec 的 **RED 切片**长出来的：每个 approved slice 加一个 TU，几乎不回收 harness。

结果是：

1. **一张扁平目录、103 个文件、0 个测试 helper 头。** 计划里的 `FAngelscriptCacheTestEngineFixture` 从未落地。
2. **一张 15885 行的 TypeSchema 笛卡尔矩阵**压过所有行为测试；它重写了 `ASSERT_THAT`，前 5500 行还没有第一个 `TEST_METHOD`。
3. **同一套夹具被复制了几十遍**：`FPackSource` × 12，`FScopedProjectRoot` × 16，`MakeCaptureOptions` × 30+ 文件。
4. **前缀和文件名对不齐**，还有一对文件共用同一个 prefix。
5. **真正证明冷启动 / 增量 / PIE / 投毒回退的测试是少数**；大量行数锁的是 wire offset、captured coordinate、allocator chronology。

Runtime Cache（约 32 个 `.cpp` / 36 个 `.h` + Private codec）按记录种类拆文件，比测试侧干净。乱的是测试，不是生产模块边界本身。

---

## 1. 规模：为什么看起来像一团

| 口径 | 数字 |
|------|------|
| Cache 测试 `.cpp` | **103**，全在一层目录，无子目录、无 `*.h` |
| Runtime Cache 实现 | 32 `.cpp` / 36 `.h` + `Private/` codec |
| 测试 : 实现 TU | 大约 **3 : 1** |
| 最大文件 | `AngelscriptCacheTypeSchemaTests.cpp` **15885 行 / 67 个 `TEST_METHOD`** |
| 前 10 大文件合计 | 约 **3.5 万行**（几乎全是 Archive / TypeSchema / Pack / Store） |
| 2026-08-08 矩阵快照 | 94 TU / 518 `TEST_METHOD`（`unit-test-coverage-matrix.md`） |
| 今天 | 103 TU / 约 **544** 个 `TEST_METHOD`；矩阵文档已过期 |

超过 800 行的文件（按行数）：

| 行数 | 文件 | 实际在测什么 |
|------|------|----------------|
| 15885 | `TypeSchemaTests` | TypeSchema wire / producer 拒绝矩阵 / TS-SCR 分配探针 |
| 4017 | `SourceInterfaceTests` | SourceIndex / ModuleInterface 编解码 |
| 2874 | `ManifestPackTests` | Pack/Manifest golden |
| 2357 | `RemainingRecordCoordinateTests` | 剩余 record 坐标/DTO 形态 |
| 1694 | `SourceInterfaceCapturedOffsetTests` | 捕获 offset 0..N |
| 1649 | `ModuleSnapshotGraphTests` | 模块图可达性 |
| 1595 | `ArchivePrimitiveTests` | 基础 wire / alias / Budget |
| 1352 | `InvocationFamilyParityTests` | builder 调用族对照 |
| 1322 | `ModuleGraphLayoutTests` | 图布局 |
| 1294 | `StoreCompactionTests` | Store 压缩 |

这些大文件大多是 **codec / 坐标 / golden / 分配时间线**，不是“改一行 `.as` 后 cache 是否命中”。

---

## 2. 乱从哪来

### 2.1 测试树是 slice 化石，不是产品分层

归档变更里每一刀都对应一批 TU：B1 TypeSchema RED、B2 slice 1–5、v3.1 DirectSource、v3.4 FreshEngine、v4.5 CleanOracle、v5.6 ProductionCompilerReuse……

落地策略是“新 slice = 新文件”，关闭后没有把同类场景收成一个主题目录。所以现在平铺着：

- `ClassGraphDeclarationOrder` / `FunctionSignature` / `Inheritance` / `Property` / `Reflection` / `Rollback` / `InheritedClassRestore` / `RootClassRestore`
- `ProductionCompilerReuse` / `ProductionClassCompilerReuse` / `ProductionClassGraphCompilerReuse` / `ProductionClassPropertyCompilerReuse`
- `CleanOracleMutation` / `CleanOracleInputMutation` / `CleanCaptureInvocationFamilies` / `CleanCaptureOpaqueValidation`
- `Store` + `StoreDisk` + `StoreLock` + `StoreTransaction` + `StoreCompaction` + `StoreConcurrency` + `StoreFaultInjection` + `StorePointer` + `StorePointerPublication` + `StoreReadSession` + `StoreRebase` + `StoreTempCleanup` + `StoreGenerationRead`（13 个）

`unit-test-coverage-matrix.md` 要求按层拆 shard（Identity / Budget / TypeSchema / Graph / Store / Lifecycle…），并且要有独立的 `FAngelscriptCacheTestEngineFixture`。目录和夹具都没做。测试继续用通用 `FAngelscriptTestFixture`，再在每个文件里手写磁盘根、PackSource、CaptureOptions。

### 2.2 同一套夹具复制粘贴

**`FPackSource`（实现 `IAngelscriptCachePackSource`）出现 12 次**，正文几乎一样，只是包在不同的 class / namespace 里：

- 6 个 `ClassGraph*` restore
- `GlobalFunctionOnlyRestore`、`InheritedClassRestore`、`RootClassRestore`、`StaticNameRestore`
- `DependencyPropagation`、`MultiModuleGeneration`

**`FScopedProjectRoot` 出现 16 次。** 四个 Production*Reuse 文件里，差异基本只有 Saved 子目录名：

```24:48:Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptCacheProductionCompilerReuseTests.cpp
	class FScopedProjectRoot final
	{
	public:
		FScopedProjectRoot()
		{
			Root = FPaths::ConvertRelativePathToFull(FPaths::Combine(
				FPaths::ProjectSavedDir(),
				TEXT("Automation/AngelscriptCacheProductionCompilerReuse"),
				FGuid::NewGuid().ToString(EGuidFormats::Digits)));
```

`ProductionClassCompilerReuseTests.cpp` 同一段，只把路径换成 `...ProductionClassCompilerReuse`。`CreateEngine`（`bSkipThreadedInitialize` + `CacheV2RootOverride` + `GetProjectDir` lambda）也整段复制。

**`MakeCaptureOptions()` 在 30+ 文件里各写一份**，内容都是填 `Compatibility` / `Context` / `Profile` / `CanonicalCompileOptions`，只改一个 canonical 字符串标签。

Cache 测试目录里 **0 个头文件**。没有任何 `AngelscriptCacheTestHelpers.h` 把这三样收走。

### 2.3 前缀和文件名各说各话

大部分前缀是 `Angelscript.TestModule.Cache.<SliceName>`，但有几套并行分类：

| 文件 | 前缀 | 问题 |
|------|------|------|
| `AngelscriptArtifactIdentityTests.cpp` | `Cache.Identity` | 文件名没有 Cache 前缀 |
| `AngelscriptNeutralArtifactRouteTests.cpp` | `Cache.NeutralArtifacts` | 文件名和前缀对不上 |
| `AngelscriptCacheManifestPackTests.cpp` | `Cache.PackFormat` | 文件说 Manifest，前缀说 PackFormat |
| `AngelscriptCacheValidationTests.cpp` | `Cache.Validation.Result` | 多了一层 Result |
| TypeSchema / SourceInterface / ModuleGraph* / RemainingRecord | `Cache.Archive.*` | 只有编解码族用了 Archive 分层 |
| `FreshEngineRestoreTests.cpp` | `Cache.FreshEngineRestore` | 正常 |
| **`FreshEngineRollbackTests.cpp`** | **`Cache.FreshEngineRestore`** | **和上一行撞前缀** |

FreshEngine 这一对是实打实的碰撞：rollback 文件注册的是 restore 前缀。按前缀跑 `FreshEngineRestore` 会把 rollback 也带上；按文件名则看不出来。

其余 ClassGraph / Production / Store 全部扁平挂在 `Cache.` 下，没有 `Cache.Restore.` / `Cache.Production.` / `Cache.Store.` 这种稳定分层。All suite 只能整包跑 `Angelscript.TestModule.Cache`。

### 2.4 TypeSchema 测试不是普通 CQTest

`AngelscriptCacheTypeSchemaTests.cpp` 自己重写了 CQTest 的 `ASSERT_THAT`，以支持两参数“带 authority 上下文”的断言：

```16:28:Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptCacheTypeSchemaTests.cpp
// CQTest's stock ASSERT_THAT accepts one argument. This declaration-first TU also
// carries source-authority context on selected assertions; keep that information
// and the identical early-return behavior without weakening the matcher.
#pragma push_macro("ASSERT_THAT")
#undef ASSERT_THAT
#define UEAS_TYPESchema_ASSERT_THAT_1(_assertion) \
	do { if (!this->Assert._assertion) { return; } } while (false)
```

文件前半是 `IsExpectedTsScrReferenceCaseForTests`、畸形 ordinal 重算 hash、TS-SCR probe view 这类**测试权威基础设施**。第一个 `TEST_METHOD` 在 5515 行，还是 `static_assert` 锁 wire 枚举数值。

67 个方法里大量是笛卡尔拒绝矩阵：

- `RelationKindsFormsCardinalitiesAndReferenceKindsAreCartesian`
- `LayoutInputRolePresenceAndTargetMatrixIsComplete`
- `PropertyStorageKindDataTypeAndQualifierMatrixIsExhaustive`
- `AllSeventeenBehaviorKindsUseRepresentedNonemptyRowsAndElevenEmptyForms`
- `TypeSchemaCapturedCoordinateMatrixZeroThroughFortyThreeIsExactAndFree`

这些对冻结 pack 格式有价值，但它们：

- 和用户可见的 cache 命中/失效不是一层
- 和 ColdGeneration / Incremental / PIE 挤在同一个 Heavy prefix 里
- 任何一个 TypeSchema 字段重编号都会炸一大片 golden

这就是“实现很乱”的体感来源：打开 Cache 测试目录，先撞上 1.6 万行坐标权威，而不是“改函数体应命中、改签名应失效”。

### 2.5 ClassGraph / Production 是同一 harness 的切片分身

六个 `ClassGraph*` restore 文件结构相同：

1. 内部 `FPackSource`
2. `MakeCaptureOptions()`
3. IsolatedFull 生产引擎 → `CleanCapture` → 编码 pack
4. 第二个 IsolatedFull 消费引擎 → `Restore`
5. **一个** `TEST_METHOD` 断言各自切片（声明序、继承链、互指属性、反射 flag、签名跨类、晚失败回滚）

按 `UnitTest.md`，这应该是一个 CQTest 类里的六个 `TEST_METHOD`，共享 private helper。现在是六个 200–800 行文件，只为了对应六个 OpenSpec task 勾选。`InheritedClassRestore` 和 `ClassGraphInheritanceRestore` 连夹具都几乎一样，只差 compatibility 字符串和场景脚本。

四个 `Production*CompilerReuse` 同理：同一套磁盘工程根 + 生产引擎启动，只换脚本形状（全局函数 / 单类 / 类图 / 属性）。

单方法文件一共大约 **25 个**。极端例子是 `InvocationFamilyParityTests.cpp`：约 1400 行 private producer，`TEST_METHOD` 只有一条 `ForcedCleanAndCachedArtifactsMatchAcrossTwoEngines`。

---

## 3. 测了什么、没测扎实什么

### 3.1 真正有产品语义的一组（值得留，但应收成主题）

这些是 Cache V2 指南里的主路径，测试也在，只是被矩阵文件淹没：

| 主题 | 代表文件 | 证明什么 |
|------|----------|----------|
| 冷生成 | `ColdGeneration` | 正常编译发布 generation，新 session 能 reopen |
| 精确热启动 | `ExactWarmStartup`、`ProductionWarmStartup` | 源未变则 restore |
| 增量 | `IncrementalGeneration`、`CleanOracleMutation` | body-only / 改签名 / 改属性 / 改全局 的记录级异同 |
| 依赖传播 | `DependencyPropagation` | 调用方是否随 provider 失效 |
| 新引擎 restore | `FreshEngineRestore`、`RootClassRestore`、`InheritedClassRestore` | 第二个引擎能执行恢复出来的函数 |
| 回滚 | `FreshEngineRollback`、`ClassGraphRollback` | 晚失败不留下半套模块 |
| 编辑器/PIE | `EditorLifecycle`、`PIE` | 失败热更保 Current；PIE 结构变更走 PendingColdStart |
| Store | `Store*` 族 | 锁/事务/压缩多半是编辑器进程里的伪造时钟/内存 FS；磁盘/并发/故障注入才是真文件。矩阵要求 Store stress 单独成组，没拆 |
| StaticJIT 隔离 | `StaticJITIsolation` | JIT 丢了不能让 Cache generation 变合法 |
| 诊断 | `Diagnostics`、`Explain`、`DebugApi`、`DecisionTrace` | JSON / console |

`CleanOracleMutation` 是行为层写得比较清楚的一个：八个方法分别锁 body / signature / property / global / constant / debug-only。这一组比 TypeSchema 笛卡尔矩阵更接近产品说明。

### 3.2 过薄、只能算烟测

| 文件 | 行数 | 实际断言 |
|------|------|----------|
| `RuntimeReloadApiTests` | 34 | `RequestRuntimeReload` 是 `BlueprintCallable`，`as.ReloadScripts` 控制台对象存在。**没有执行一次 reload** |
| `PackageSmokeExitPolicyTests` | 22 | `ShouldRequestAngelscriptCachePackageSmokeExit` 三个布尔组合 |
| `StartupCompileFailurePolicyTests` | 64 | 启动失败策略枚举/分支 |
| `DecodedRecordDeclarationTests` | 42 | C++ 可见性 / friend codec 是空的 |
| `WriterPolicyTests` | 59 | 写策略枚举 |
| `Validation.Result` | 141 | 分类器基础 |

`CachePackage` suite（真 Development/Shipping 进程）和这些 in-editor 布尔测试不是一回事。`PackagedRuntimeReloadTests` 是编辑器里模拟的打包策略，不是真包；七次启动循环也不覆盖 Disabled/Manual/Automatic 热更。

Runtime 里还有几个**没有专属 TU、只被别的文件间接碰到**的实现：

- `AngelscriptCacheCurrentModuleAuthority.*`（约 2800 行 producer）只从 CleanCapture / CompileReuse 走进去
- `AngelscriptCacheAtomicFileOps.cpp` 只被 Store 磁盘路径带着跑
- C++ Cache 前缀**没有**放一个 `PrecompiledScript.Cache` 再断言忽略；这条只在 `CachePackage` 工具自测里

矩阵里仍标着、后来也没单独补上的契约洞：注释/CRLF-only 是否仍能命中、interface/delegate/`TArray` 的 live restore 准入、shutdown flush 超时取消、layout-only ObjectHandle 复用。

### 3.3 锁内部实现、对产品契约贡献小

OpenSpec 明确允许“特殊测试 seam 观察内部不变量”，但要求每个 seam 有完整性用例，并且**不要变成第二套 decoder**。现状是 seam 测试的体量已经大于契约测试：

- captured offset 0..43 精确矩阵
- TS-SCR 分配点、one-byte-short、caller-owned probe
- Remaining record 坐标/one-hot/pointer-free
- Manifest/Pack 字节 golden + exact SHA 审核流程
- TypeSchema 里 `Family`/`Variant` 手写 switch 决定哪些 reference case 合法

这些保护的是 **pack 兼容性**，改 codec 时必须跑。它们不应该和“改一行脚本后能否热启动”挤在同一个 17 分钟 prefix 里。

### 3.4 和 Runtime 文件的对应

Runtime 一侧一个关注点一个文件（`Store` / `Restore` / `CleanCapture` / `ExactStartup` / `Service` / `TypeSchema`…）。测试一侧没有镜像这个结构：

- `AngelscriptCacheModuleGraph.cpp` 对应至少 4 个测试 TU（Layout / Dependency / SnapshotGraph / HardValue），前缀还混用 `Cache.Archive.*` 和扁平名
- `AngelscriptCacheStore.cpp` 对应 13 个测试 TU
- `AngelscriptCacheRestore.cpp` 对应 8+ 个 ClassGraph/Root/Inherited/GlobalFunction restore TU
- `AngelscriptCacheService.cpp` 对应 Service + ServiceStoreFlush + Maintenance + Flush + Debug + Explain，切得随意

不是“缺测试”，是 **同一实现被按历史 task 切成很多近重复入口**。

---

## 4. 风格和规范冲突

相对 `Documents/UnitTest/UnitTest.md` / 测试指南：

- 大量文件用 **文件级 / 匿名 namespace 的 `RunXxx` / `CaptureAndPrepare…`**，`TEST_METHOD` 只做转发。FreshEngine 两个文件尤其明显。
- 目录里 **0** 次 `BEFORE_ALL` / `ASTEST_CREATE_ENGINE`。引擎生命周期是每个方法里 `FAngelscriptTestFixture(..., IsolatedFull)` 或自建 `CreateEngine`。对双引擎 producer/consumer 这往往是对的，不要为了迎合指南硬改成共享引擎；缺的是共享 **pack/options/工程根**，不是共享 Full 引擎。
- 大约 65 个文件用 `AngelscriptCacheXxxTests_Private` 命名空间绕开“禁止匿名 namespace”，再把 100–1200 行流程塞进去。这和 `UnitTest.md` §1 禁止的类外 `RunXxx` 是同一件事。
- TypeSchema 重定义 `ASSERT_THAT`，和“不要文件级断言别名”直接冲突。
- ClassGraph 六个文件各只有 1 个 `TEST_METHOD`，却各自复制 200–800 行 private helper。
- 断言风格本身不乱：没有 `TestRunner->TestTrue`，也没有 Disabled / `#if 0`。`AddInfo` 是 IC/V 工单面包屑，不是 skip。
- `ETestEngineMode::SharedClone` 名字仍是 clone，实际是 Full（全仓库老问题，Cache 测试大量 IsolatedFull，反而还好）。
- `FAngelscriptFunctionRouteSnapshotTests` 类名掉了 `Cache`；`AngelscriptArtifactIdentityTests.cpp` 文件名也掉了。

---

## 5. 建议（只排序，不在本文件开工）

### P0 — 先让 Cache 测试可读、可分开跑

1. **抽出 `Cache/AngelscriptCacheTestSupport.h`（或 `Cache/Support/`）**
   只收三样：`FScopedCacheProjectRoot`、`FInMemoryCachePackSource`、`MakeTestCaptureOptions(Tag)`。16+12+30 份复制立刻能删。
2. **拆 suite**
   - `Cache.Archive`：TypeSchema / SourceInterface / RemainingRecord / ManifestPack / ModuleGraph codec
   - `Cache`：Cold / Warm / Incremental / Restore / PIE / Store 磁盘契约 / Diagnostics
   现在 All 的一个 Heavy prefix 把 1.6 万行矩阵和 200 行冷启动绑在一起。
3. **修 `FreshEngineRollback` 的前缀**，改成 `Cache.FreshEngineRollback`。

### P1 — 按主题合并切片分身

1. 六个 `ClassGraph*` + `RootClassRestore` + `InheritedClassRestore` → 一个 `Cache.Restore.ClassGraph` 类，多个 `TEST_METHOD`。
2. 四个 `Production*CompilerReuse` → 一个 `Cache.Production.CompilerReuse` 类。
3. Store 不必合成一个 8000 行文件，但应放到 `Cache/Store/`，前缀统一 `Cache.Store.*`。
4. TypeSchema 留着当 **格式权威**，搬到 `Cache/Archive/`，不要再假装它是普通行为回归。

### P2 — 补真正缺的契约，而不是再加坐标矩阵

1. `RuntimeReloadApi` 至少跑一次成功 reload + 一次 `RequiresRestart`，不要只查 UFunction 存在。
2. 不要再造一个第二套 cache 实现当 `FAngelscriptCacheTestEngineFixture`。归档文档已经禁止测试复刻 validation/restore。抽出 pack source、CaptureOptions、工程根就够。
3. 更新 `unit-test-coverage-matrix.md` 的 94/518 数字，或标明已退役，避免再当 live inventory。归档里写“第二个文件需要同一套 pack reopen 再抽 helper”——第二个文件早就来了十几次，helper 还是没有。

### 不要做的事

- 不要在没抽 helper 之前继续为新 slice 加第 104 个平铺文件。
- 不要把 TypeSchema 笛卡尔矩阵删掉当“清理”——它是 pack 兼容的权威，只是不该占行为 suite。
- 不要把 `CachePackage` 真进程烟测并进这个 in-editor prefix。

---

## 6. 和 Runtime 实现的关系

Runtime Cache 按职责拆文件（Archive、TypeSchema、Store、Restore、Service、ExactStartup、IncrementalGeneration…），和指南里的七种 record + Store 布局是对齐的。

测试乱，是因为 **测试的组织轴是 OpenSpec task id，不是 Runtime 文件或用户契约**。所以会出现：

- 实现一个 `Restore.cpp`，测试八个 `*RestoreTests.cpp`
- 实现一个 `Store.cpp`，测试十三个 `Store*Tests.cpp`
- 实现一个 `TypeSchema.cpp`，测试一个 15885 行 TU 外加 `TypeSchemaDependencyTests`

若要动 Cache 实现，先把测试收到和 Runtime 相同的轴上，否则每次改 Restore/Store 都要在十几个近重复文件里找该改哪份 `FPackSource`。

---

## 7. 修订

- 2026-08-13：基于当前 103 个 Cache 测试 TU、Runtime Cache 目录和已归档 incremental-function-cache 权威文档写成。未重跑 Cache suite。
