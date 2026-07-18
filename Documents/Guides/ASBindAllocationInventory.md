# Angelscript Bind 阶段分配点清单

> 2026-05-13 | 关联文档：`ASTestSuiteMemoryPeakRootCause.md`（实证数据 / 全量峰值根因）、`ASEngineMemoryAnalysis.md`（修复历史 / Arena 路径评估）
>
> 目的：把 `FAngelscriptEngine::BindScriptTypes()` 一次完整 bind 中**所有可识别的内存分配点**列在同一张表里，每条都落到具体的代码引用 + 触发条件 + 量级估算 + 持久性 + 可优化方向。
>
> 适用范围：当前主线代码（含 Phase 2A/2B 并行 Prepare/Commit 拆分、AS_USE_BIND_DB 开启路径）。BindDatabase 关闭路径（`!AS_USE_BIND_DB`）的差异在末尾单独说明。

## 一、bind 整体量级（实测，单次完整 bind）

来源：`Angelscript.TestModule.Engine.Isolation` run 中的 `[Profiling] blueprinttype bindings breakdown` 日志。

| 指标 | 数值 |
|------|------|
| 经过 `TObjectRange<UClass>` 收集到的 UClass 数（`classes=` 字段） | **5037** |
| 实际 bind 成功的 UFunction 数（`funcs_bound=` 字段） | **5623** |
| 自动注册的 C++ UInterface 方法 / 接口类型数 | **212 / 267** |
| UHT 生成 BlueprintCallable 入口总数（30 shard, 12 module） | **5683** |
| 单次 `Bind_Defaults` Late+100 总耗时 | **~880–950 ms** |
| 单次 bind 引起的进程 WS 瞬时增长（实测，运行中段） | **~1.2 GB**（详见 `ASTestSuiteMemoryPeakRootCause.md` 附 B.3） |

bind 主干入口（按调用顺序）：

```2318:2335:Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp
void FAngelscriptEngine::BindScriptTypes()
{
	AS_PERF_SCOPE_STARTUP_BIND_SCRIPT_TYPES();

	#if WITH_DEV_AUTOMATION_TESTS
	FAngelscriptBindExecutionObservation::BeginBindScriptTypesTiming();
	FAngelscriptEnumTableBaselineProbe::Reset();
	#endif

	FAngelscriptBinds::ResetGeneratedFunctionBindingTiming();
	FAngelscriptBinds::CallBinds(CollectDisabledBindNames());
	FAngelscriptBinds::LogGeneratedFunctionBindingTimingSummary();

	#if WITH_DEV_AUTOMATION_TESTS
	FAngelscriptBindExecutionObservation::EndBindScriptTypesTiming();
	FAngelscriptEnumTableBaselineProbe::MaybeAutoDump();
	#endif
}
```

`CallBinds` 顺序迭代所有 `FBindFunction` 并逐个执行：

```296:331:Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.cpp
void FAngelscriptBinds::CallBinds()
{
	CallBinds(TSet<FName>());
}

void FAngelscriptBinds::CallBinds(const TSet<FName>& DisabledBindNames)
{
	AS_PERF_SCOPE_BINDS_CALL_BINDS();
	// ... iterates GetSortedBindArray() and runs each Bind.Function() ...
}
```

## 二、分配点分类

### 类别 A：AngelScript SDK 内部对象（每次 bind 不可避免）

每次 `RegisterObjectType` / `RegisterObjectMethod` / `RegisterObjectBehaviour` / `RegisterObjectProperty` / `RegisterEnum` / `RegisterFuncdef` / `RegisterGlobalFunction` 都会让 AS SDK 内部分配 `asCObjectType` / `asCScriptFunction` / `asCDataType` / `asCEnumType` 等持久对象，**这些对象的生命周期跟 `asIScriptEngine` 一致**，引擎销毁时统一释放。

| # | 入口 | 代码引用 | 触发数量（单次完整 bind） | 单次开销估算 | 备注 |
|---|------|---------|---------------------------|--------------|------|
| A1 | `asCreateScriptEngine` | `AngelscriptEngine.cpp:1722` | 1 个 `asCScriptEngine` | ~2–5 MB（含初始 arrays/maps） | 引擎实例本身 |
| A2 | `RegisterObjectType` | `AngelscriptBinds.cpp:376` | 121 (Bind_*) + 5037 (BlueprintType) + delegate/struct 若干 | ~200–400 B / 类型（`asCObjectType`） | `ValueClass` / `ReferenceClass` 内部入口 |
| A3 | `RegisterObjectMethod` | `AngelscriptBinds.cpp:400, 564, 571` | 121 模块手动 method + 5623 BlueprintCallable + 212 interface auto + 各类 mixin | ~300–600 B / 方法（`asCScriptFunction` + 参数 list） | 每个 method 一个 `asCScriptFunction` |
| A4 | `RegisterObjectBehaviour` | `AngelscriptBinds.cpp:407, 550, 557` | 每个值类型的 ctor/dtor/op (~3–8 个) × 类型数 | ~300 B / behaviour | ctor/dtor/copy/assign/cast 等 |
| A5 | `RegisterFuncdef`（delegate 声明） | `Bind_Delegates.cpp:1331-1353` | 全部 `UDelegateFunction`（含 multicast/sparse） | ~300–500 B / funcdef | `TObjectRange<UDelegateFunction>()` |
| A6 | `RegisterGlobalFunction` / `RegisterGlobalProperty` | `AngelscriptBinds.cpp`（globals 群）+ `Bind_BlueprintType.cpp:737-740`（每类一个 `__StaticType_*`） | 5000+ static-class 全局变量 | ~150 B / global | 每个 `BindStaticClass()` 都贡献一个 |

> **A 类是 12GB 峰值的核心驱动**：A2+A3 单独就是 5037×400 + 5623×500 ≈ **5 MB（类型） + 2.8 MB（方法）= ~8 MB**。但这只是 SDK 直接持有的对象本身，**SDK 内部还会为每个方法 / 类型构建解析索引、签名 hash、参数 array** —— 实际折算到 working set 上接近 ~50–80 MB 的稳态结构。

### 类别 B：插件适配层 C++ 对象（每次 bind 完整重建）

这一类是 **AS SDK 之外**、由插件代码自己分配的 C++ 对象。它们大部分都被注册到 SDK 对象的 `userData` 槽里，跟着 SDK 引擎一起释放；少量被放到全局 TMap，需要在 shutdown 时显式清理（已修复，见 `ASEngineMemoryAnalysis.md` 第三章）。

| # | 类型 / 分配点 | 代码引用 | 触发数量 | 单次大小估算 | 持久性 |
|---|--------------|---------|----------|--------------|--------|
| B1 | `MakeShared<FUObjectType>` | `Bind_BlueprintType.cpp:699` | **每个 UClass 一次**（~5037） | ~120 B + shared-ptr ctrl block | 跟 TypeDatabase 一起释放 |
| B2 | `MakeShared<FSubclassOfType / FObjectPtrType / FWeakObjectPtrType>` | `Bind_BlueprintType.cpp:2773-2785` | 一次性全局 | ~80 B/个 | 跟 TypeDatabase |
| B3 | `MakeShared<FScriptDelegateType / FMulticastScriptDelegateType>` | `Bind_Delegates.cpp:1335-1341` | 一次性 + 每个 UDelegateFunction 一份 type | ~100 B/个 | 跟 TypeDatabase |
| B4 | 栈对象 `FAngelscriptFunctionSignature`（内部 heap） | `Helper_FunctionSignature.h:38-65` 结构定义；构造点见 `Bind_BlueprintCallable.cpp:167/171/310`、`Bind_BlueprintEvent.cpp:581/690` | **每个 UFunction 一次**（5623） | 栈 ~150 B + 堆 `~30 B × ArgCount × 3 TArray` + Declaration FString ~64–128 B | Phase 2A 构造，存到 `BindOrder.FunctionPreps`；Phase 2B commit 后 `BindOrder.FunctionPreps.Empty()`（`Bind_BlueprintType.cpp:1589`） |
| B5 | `new FBlueprintEventSignature` | `Bind_BlueprintEvent.cpp:590`（无 DB 路径）、`Bind_BlueprintEvent.cpp:724`（FromPrep 路径）、`Bind_BlueprintEvent.cpp:922`（Sparse 路径） | **每个 BlueprintEvent 一次**（estimated 300–800） | ~1.5 KB（含 8 个 `FAngelscriptTypeUsage Arguments[]` + ReturnType + MixinType + OutReferences[8] + 各种 flag） | **永久**（挂在 `asCScriptFunction::userData`，靠 AS 引擎生命周期释放） |
| B6 | `new TSubclassOf<UObject>(Class)` | `Bind_BlueprintType.cpp:738` | **每个 UClass 一次**（5037） | ~16 B | **永久**（绑定到 AS 全局变量 `__StaticType_*`） |
| B7 | `MakeUnique<FInterfaceMethodSignature>` | `AngelscriptEngine.cpp:1674-1677` | 每个 C++ UInterface 方法（212） | ~24 B（含 FName） | 永久，存 `InterfaceMethodSignatures` array，引擎 shutdown 时统一释放 |
| B8 | `new FDelegateOps` | `Bind_Delegates.cpp:610` | 每个 single-cast delegate event | ~40 B | 永久（绑给 AS userData） |

### 类别 C：全局 / 永久 TMap（跨 cycle 增长，是历史泄漏重灾区）

| # | 容器 | 代码引用 | 增长速率 | 已知治理状态 |
|---|------|---------|---------|--------------|
| C1 | `FAngelscriptBinds::GetRuntimeClassDB / GetEditorClassDB` | `AngelscriptBinds.cpp:39-49` | 全 UClass 收录，~5000 entry | 进程级 static，永久存活 |
| C2 | `FAngelscriptBinds::GetClassFunctionBindings` | `AngelscriptBinds.cpp:51-56` | 每 UClass 一个内嵌 TMap，含 ~10–30 `FAngelscriptFunctionBinding`/类 | 进程级 static |
| C3 | `FAngelscriptBinds::GetBindModuleNames / GetSkipBinds / GetSkipBindNames` | `AngelscriptBinds.cpp:56-71` | 启动期间填充 | 进程级 static |
| C4 | `GBlueprintEventsByScriptName` | `Bind_BlueprintEvent.cpp:68` | 每 BP event 一个 `(UClass*, ScriptName → UFunction*)` entry | 进程级 static，**已在 shutdown 中清理**（见 `ASEngineMemoryAnalysis.md`） |
| C5 | `GCachedEditorClasses` | `Bind_BlueprintType.cpp:939` | 每 UClass 一个 entry，记 IsEditorOnly bool | 进程级 static，**已在 shutdown 中 Empty**（line 943） |
| C6 | `GScriptNativeForms` | `StaticJITBinds.cpp:27` | 仅 `IsGeneratingPrecompiledData()` 模式下增长 | **已通过 `FScriptFunctionNativeForm::ReleaseAllNativeForms()` 清理**（line 62-69） |
| C7 | `FAngelscriptDocs::UnrealDocumentation / UnrealTypeDocumentation / GlobalVariableDocumentation / UnrealPropertyDocumentation` | `AngelscriptDocs.cpp:28-31` | `WITH_EDITOR` 模式下，每方法 / 类型 / 属性的 tooltip + category | 进程级 static，**已通过 `ResetAllDocumentation()` 清理**（line 120-126） |
| C8 | `FAngelscriptBindDatabase::Classes / Structs / BoundEnums / BoundDelegateFunctions / HeaderLinks` | `AngelscriptBindDatabase.h:132-137` | 完整 bind 元数据缓存 | 单例，`Clear()` 在 `AngelscriptEngine.cpp:1912`（`AS_USE_BIND_DB` 开启时 bind 后立即清空） |
| C9 | `FAngelscriptTypeDatabase`（per-engine）：`RegisteredTypes` / `TypesByAngelscriptName` / `TypesByClass` / `TypesByData` / `TypesImplementingProperties` | `AngelscriptType.cpp:35-100` | 每个 `FAngelscriptType::Register` 调用插入 1 entry，共 ~5000 type | 跟 `FAngelscriptEngine` 一起释放 |

### 类别 D：FAngelscriptBindDatabase 内的 FString / TArray（重型字段）

`FAngelscriptBindDatabase` 在 `AS_USE_BIND_DB` 开启时，会被 bind 后立即 `Clear()`，因此**这部分在生产编辑器 session 中只是 bind 期间的瞬时分配**；在 cook commandlet 中则会写盘后释放。

但在 bind 进行中，每个 entry 都会被填充：

| 字段 | 代码引用 | 单次大小 | 数量 |
|------|---------|---------|------|
| `FAngelscriptClassBind::TypeName / UnrealPath` | `AngelscriptBindDatabase.h:91-93` | 2 × FString（每个 ~32 B + heap） | 5037 |
| `FAngelscriptClassBind::Methods[]` | line 94 | `FAngelscriptMethodBind` ~120 B + 4 FString heap | 5623 entry across all classes |
| `FAngelscriptClassBind::Properties[]` | line 95 | `FAngelscriptPropertyBind` ~80 B + 3 FString | ~每类 5–20 |
| `FAngelscriptStructBind`（同上） | line 38-54 | 同 ClassBind 量级 | ~200–500 USTRUCT |

整体 bind 数据库**瞬时占用 ~30–60 MB**（5000 类 × 平均 6 KB metadata 量级），bind 完成后 `Clear()` 释放回 mimalloc cache。

### 类别 E：Phase 2A/2B 临时数组（最大瞬时尖峰）

Phase 2A 把每个 UClass 的 `FUFunctionBindPrep` 全量构造完后存到 `BindOrder.FunctionPreps`，Phase 2B 一条条 commit 完才 Empty：

```1386:1389:Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintType.cpp
		// Phase 2A (prepare) populates this; Phase 2B (commit) consumes it.
		// Empty until Phase 2A runs; cleared after Phase 2B finishes.
		TArray<FUFunctionBindPrep> FunctionPreps;
	};

	TArray<FBindOrder> ClassesToBind;
```

```1583:1591:Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintType.cpp
				BindOrder.DBBind.Methods.Add(DBMethod);
				++TotalFuncsBound;
			}
		}

		// Free transient prep storage now that commit is done.
		BindOrder.FunctionPreps.Empty();
	}
```

| # | 数组 / 容器 | 数量 | 单 entry 大小 | 瞬时峰值 | 清理时机 |
|---|------------|------|--------------|---------|----------|
| E1 | `ClassesToBind` | 5037 `FBindOrder` | ~256 B（含 Type 共享指针 + DBBind 占位） | ~1.3 MB | Bind_Defaults lambda 结束（栈对象） |
| E2 | `BindOrder.FunctionPreps`（所有 ClassIdx 累加） | 5623 `FUFunctionBindPrep` | 含一个 `FAngelscriptFunctionSignature` (~150 B 栈 + 多 TArray heap) | ~50–80 MB（**主要瞬时分配源**） | Phase 2B commit 每个 class 完后 `Empty()` |
| E3 | Phase 5 接口收集 `InterfacesToBind` | ~267 | ~80 B | ~21 KB | lambda 结束 |
| E4 | 每个接口方法的 `FAngelscriptTypeUsage` ArgumentTypes / ArgumentNames / ArgumentDefaults | 212 method × ~3–8 arg | TArray heap | 累计 ~100 KB | 方法注册后栈释放 |

### 类别 F：StaticJIT 永久绑定对象（仅 IsGeneratingPrecompiledData 模式）

`StaticJITBinds.cpp` 中 16 处 `new FScriptNative*` 分配，全部由 `BindNativeXxx()` 走 guard：

```121:126:Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/StaticJITBinds.cpp
void FScriptFunctionNativeForm::BindNativeConstructor(FAngelscriptBinds& Binds, const ANSICHAR* Name, bool bTrivial, const ANSICHAR* CustomForm)
{
	if (!FAngelscriptEngine::IsGeneratingPrecompiledData())
		return;
	GScriptNativeForms.Add(FAngelscriptBinds::GetPreviousBind(), new FScriptNativeConstructor(Name, bTrivial, CustomForm));
}
```

| # | 类型 | 代码引用 | 触发条件 |
|---|------|---------|----------|
| F1 | `FScriptNativeConstructor` | `StaticJITBinds.cpp:125` | 每个手动 ctor bind |
| F2 | `FScriptNativeDestructor` | `StaticJITBinds.cpp:169` | 每个手动 dtor bind |
| F3 | `FScriptNativeAssignment` | `StaticJITBinds.cpp:212` | 每个 opAssign bind |
| F4 | `FScriptNativeUObjectCast` | `StaticJITBinds.cpp:343` | 每个 UObject Cast bind |
| F5 | `FScriptNativeMethod / Function / FunctionHeader` | `StaticJITBinds.cpp:381 / 414 / 452` | 每个手动方法 / 全局函数 bind |
| F6 | **`FScriptNativeUFunction`** | `StaticJITBinds.cpp:543` | **每个 BlueprintCallable / Event bind** —— 量最大 |
| F7 | TArray iterator / index / template / push-arg 等 | `StaticJITBinds.cpp:605 / 716 / 790 / 873 / 914 / 944` | 容器和参数桥接 |
| F8 | Delegate / Multicast / Event execute | `StaticJITBinds.cpp:974 / 1004 / 1034` | 每个 delegate bind |

**普通 editor session（非 cooker）这一类不会分配**。但 `bGeneratePrecompiledData=true` 的 commandlet 中，量级跟 A3 / B5 同等（5000+ 对象）。

### 类别 G：BindProperty 临时 FProperty 对象

Bind 期间会在 AS engine 这一侧 `new` 一些 `FProperty` 子类，作为 reflect-fallback 模板挂到 SDK 对象上：

| # | 类型 | 代码引用 | 持久性 |
|---|------|---------|--------|
| G1 | `new FClassProperty` | `Bind_BlueprintType.cpp:165, 1942` | 与所在 `FAngelscriptType` 一起释放 |
| G2 | `new FObjectProperty` | `Bind_BlueprintType.cpp:171, 2204` | 同上 |
| G3 | `new FWeakObjectProperty` | `Bind_BlueprintType.cpp:2507` | 同上 |
| G4 | `new FDelegateProperty` | `Bind_Delegates.cpp:135` | 同上 |
| G5 | `new FMulticastInlineDelegateProperty` | `Bind_Delegates.cpp:711` | 同上 |

每个 ~80–120 B，数量 ~几百到一千，整体 ~100 KB 量级。

## 三、bind 阶段时间轴（典型 Late+100）

按 `[Profiling] blueprinttype bindings breakdown` 五段计时分解：

```
T0  ───┐ collect           (~3–5 ms)
       │   TObjectRange<UClass>() + FClassVisiter::Visit + Phase 1.5 NameArray prewarm
       │   → 分配 ClassesToBind / FBindOrder 数组（E1）
       │
       ├── func_bind        (~800–900 ms)  ★ 最重
       │     Phase 2A Prepare (ParallelFor):
       │       - 每 UClass 跑 TFieldIterator<UFunction>
       │       - 构造 FAngelscriptFunctionSignature → B4 + 内部 TArray/FString
       │       - 写 BindOrder.FunctionPreps[]
       │       → 这里是瞬时峰值的最大头（E2）
       │     Phase 2B Commit (GameThread):
       │       - 逐 FunctionPreps[]，调用 BindMethodDirect → AS SDK 分配 A3
       │       - new FBlueprintEventSignature → B5（永久）
       │       - 推送 GBlueprintEventsByScriptName → C4
       │       - SCRIPT_NATIVE_UFUNCTION → F6（cooker 模式才分配）
       │       - BindOrder.FunctionPreps.Empty() ← 单 class 完后立即释放
       │
       ├── getter_setter    (~3–10 ms, WITH_EDITOR only)
       │     Phase 3: BlueprintGetter / BlueprintSetter 重绑
       │
       ├── props_inherit    (~60–80 ms)
       │     Phase 4:
       │       - ScriptType->CopySystemType(InheritScriptType)
       │       - BindProperties() → G1–G3 临时 FProperty
       │       - BindStaticClass() → B6 + A6
       │       - FAngelscriptBindDatabase::Get().Classes.Add(DBBind) → C8
       │
       └── interface        (~1–5 ms)
             Phase 5: 212 个 UInterface 方法
               - FAngelscriptTypeUsage / FString 临时数组（E4）
               - RegisterInterfaceMethodSignature → B7（永久）
               - Binds.GenericMethod → A3
```

**总耗时 / 总瞬时 working-set 增长**：约 **880–950 ms** / **~1.0–1.2 GB**（实测，见 `ASTestSuiteMemoryPeakRootCause.md` 附 B.3）。

## 四、按"是否随 cycle 累积"重新切分

| 累积模式 | 包含 |
|---------|------|
| **进程级 static**（一次性，多 engine cycle 复用同一份） | C1–C3, C5（已 Empty in shutdown）, C7（已 Reset in shutdown） |
| **每 cycle 全量重建 + 释放** | A1–A6（跟 asCScriptEngine 一起），B1–B3、B7（跟 TypeDatabase），B4（栈），B8、G1–G5（跟 SDK 释放） |
| **每 cycle 全量重建 + 永久挂在 SDK userData** | **B5 ★**（FBlueprintEventSignature，每 cycle ~500 KB–1 MB 增量；如果 SDK 引擎也每 cycle 重建，跟着释放） |
| **仅 cooker 模式分配** | F1–F8（StaticJIT），bind 数据库 `Save()` 路径 |
| **AS_USE_BIND_DB 路径瞬时** | D 全部（bind 结束 `Clear()` 释放） |
| **AS_USE_BIND_DB 路径永久持有** | D 全部（cook commandlet 模式下，要写盘） |

## 五、可观测性 / 优化方向

### 5.1 已实施的优化

| 优化 | 入口 | 收益 |
|------|------|------|
| Phase 2A 并行 Prepare | `Bind_BlueprintType.cpp:1543-1547`（`CVarBindParallelPrepare`） | bind 耗时降 30–40%，瞬时峰值不变 |
| Phase 1.5 NameArray prewarm | `Bind_BlueprintType.cpp:1439-1453` | 让 Phase 2A 在 worker 线程上调 `FindFunctionByName` 不再 race |
| `FAngelscriptBindCaches` TLS | `Bind_BlueprintType.cpp:1559`（`FScopedBindCaches`） | 消除 Phase 2B 全局 scan `IsScriptDeclarationAlreadyBound` 的 O(N²) |
| 单次 `FindMetaData` 替代 `HasMetaData + GetMetaData` | `Helper_FunctionSignature.h:209` | `FAngelscriptFunctionSignature::InitFromFunction` 中 metadata lookup 减半 |
| `TFieldIterator<UFunction>(ExcludeSuper)` 替代 `GenerateFunctionList + FindFunctionByName` | `Bind_BlueprintType.cpp:1478` | bind 函数枚举单 pass |
| `AS_USE_BIND_DB` `Clear()` after bind | `AngelscriptEngine.cpp:1912` | 释放 ~30–60 MB 元数据 |

### 5.2 仍可考虑的优化（按"瞬时峰值收益"排序）

| 方向 | 目标分配点 | 预期收益 | 风险 |
|------|-----------|---------|------|
| 复用 `FunctionPreps` 全局池 + chunked commit | E2 | 把瞬时峰值 ~50–80 MB → ~5–10 MB | 需保证 Prep 不再含 std::move-only 字段；可能影响并行度 |
| `FAngelscriptFunctionSignature` 中 `Declaration` 用 inline-string（`TStringBuilderBase`）避免堆分配 | B4 内部 | 瞬时分配数 -O(N×3)（每函数省 3 个 FString heap） | 改动散布在 InitFromFunction 与 BuildFunctionDeclaration 中 |
| `FBlueprintEventSignature` 改成 SmallVector / 内联 Arguments | B5 | 单对象 1.5 KB → ~500 B；BlueprintEvent 多的项目永久持有可降 ~1 MB | 需要重写 InvokeReflectionFallbackFromGenericCall 的访问模式 |
| 让 `AS_USE_BIND_DB` 路径在 Phase 2B 直接消费 DB 而不构造 `FAngelscriptFunctionSignature` | B4 / E2 | 跳过 Phase 2A 大量瞬时构造 | 需要 DB 携带足够运行时元数据（已部分覆盖） |
| 按 `DisabledBindNames` 在 bind 选择阶段就裁掉，而不是注册后再不调用 | A2–A4 + B 一系列 | 减少不需要的类型 / 方法 SDK 内对象 | 现已支持，但裁剪覆盖率有限 |
| `WITH_EDITOR` 仅在 `ShouldUseEditorScriptsForCurrentContext()` 真值时填 `FAngelscriptDocs` | C7 | tooltip / category map 量级 ~5000 entry × ~100 B = ~500 KB | 已部分接入，不在 commandlet 模式填 |
| 把 `GScriptNativeForms` 拆为 per-engine map | C6 / F6 | 让多 engine 共存时不会跨 engine 冲突 | 需要重写 lookup path |

### 5.3 可观测性建议

如果要给 bind 阶段加更细的内存计量，下面这些点是**直接放 LLM tag / 自定义 stat** 的最佳位置：

| LLM tag 候选 | 包裹范围 | 代码引用 |
|--------------|----------|---------|
| `AS_Bind_TypeDatabase` | `FAngelscriptType::Register` | `AngelscriptType.cpp:54-100` |
| `AS_Bind_FunctionSignature` | `FAngelscriptFunctionSignature::InitFromFunction` | `Helper_FunctionSignature.h:157-375` |
| `AS_Bind_EventSignature` | `new FBlueprintEventSignature` | `Bind_BlueprintEvent.cpp:590, 724, 922` |
| `AS_Bind_PrepArray` | Phase 2A `FunctionPreps.Add(MoveTemp(Prep))` | `Bind_BlueprintType.cpp:1528` |
| `AS_Bind_Database` | `FAngelscriptBindDatabase::Get().Classes.Add(BindOrder.DBBind)` | `Bind_BlueprintType.cpp:1696` |
| `AS_Bind_Docs` | `FAngelscriptDocs::Add*` 入口 | `AngelscriptDocs.cpp:33-56` |
| `AS_Bind_StaticJIT` | `BindNative*` 系列 | `StaticJITBinds.cpp:121, 169, 212, ...` |

接入后可以用 `stat llm` / `memreport -log` 把 bind 阶段的瞬时峰值再拆细，把"~1.2 GB 单次 bind"分解到具体类别。

## 六、`!AS_USE_BIND_DB` 路径差异

默认主线开启 `AS_USE_BIND_DB`。若关闭：

| 改变 | 入口 |
|------|------|
| 不走 Phase 2A/2B Prepare/Commit 拆分，改成单 pass `Bind_Defaults` lambda | `Bind_BlueprintType.cpp:765-927` |
| 每次 bind 都重新 `WriteToDB(DBBind)`，bind 结束**不 `Clear()`**，可以走 `Save()` 写盘 | `AngelscriptEngine.cpp:1903-1909` |
| `FAngelscriptFunctionSignature` 构造点改为 `Bind_BlueprintCallable.cpp:171` / `Bind_BlueprintEvent.cpp:581` | （inline 路径）|
| 没有 Phase 5 自动接口 binding 缓存（接口 method 仍然 `RegisterInterfaceMethodSignature`） | `AngelscriptEngine.cpp:1672` |

整体瞬时分配量级类似，差别主要在执行模型而非分配量。

## 七、与全量测试套件内存峰值的关系

参考 `ASTestSuiteMemoryPeakRootCause.md` 第二章拆解：

- 单次 bind 瞬时活跃 ~1.0–1.2 GB（实测，附 B.3 第 22 秒处 +1248 MB）
- 测试套件 200+ engine cycle，每个 cycle 都完整重跑一次 bind
- 由于 mimalloc 默认 10 s reset_delay（实测附 B.4），cycle 间 free 的页被缓存，OS 看到的 working set 单调上升
- 12.9 GB 峰值 = `UE Editor 基线 (~1.5–2 GB) + AS bind 活跃 (~1 GB) + mimalloc 累积 cache (~7–9 GB) + FNamePool / persistent 残留`

本文档列出的"每 cycle 全量重建"分配点（类别 A + 大部分 B + E + D 瞬时）就是那"1 GB AS bind 活跃"的具体来源；要降低这部分，看 5.2 的优化方向。

---

**末更新**：2026-05-13。当代码主干变化（Phase 2A/2B 拆分调整、DB 路径切换、Bind_*.cpp 增减）时同步刷新表格。
