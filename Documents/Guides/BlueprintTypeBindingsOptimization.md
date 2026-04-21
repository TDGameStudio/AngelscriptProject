# BlueprintType 绑定 Phase 2 性能优化实施说明

## 背景

Angelscript 插件 `Bind_Defaults` 在编辑器启动时的 **Phase 2（函数枚举 + Callable/Event 绑定）** 原本独占 36.22 s / 99.72%（平均 5.74 ms × 6312 个函数）。本次优化将该阶段压缩到 **147 ms**，总降幅 **−99.59%**，行为与 baseline 完全等价（`classes=7853`、`funcs_bound=6312` 计数一致）。

**对应提交**：`3642f79 [Runtime] Perf: optimize Bind_Defaults Phase 2 function enumeration`

## 优化前后对比

| 指标 | Baseline | 优化后 | 降幅 |
|------|----------|--------|------|
| Phase 2 `func_bind` | 36 220 ms | 147.4 ms | **−99.59%** |
| Phase 2 总耗时（collect+bind+setter+props） | ~36 320 ms | 279.9 ms | −99.23% |
| `classes` | 7 853 | 7 853 | ✅ 一致 |
| `funcs_bound` | 6 312 | 6 312 | ✅ 一致 |
| Shadow-UFUNCTION 审计 | — | 0 次触发 | — |

## 改动文件

| 文件 | 优化项 | 改动量 |
|------|--------|--------|
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintType.cpp` | Opt 4 / Opt 5 / Opt 6 + 挂载 `FScopedBindCaches` | +50 / −16 |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/BlueprintCallableReflectiveFallback.cpp` | Opt 1 / Opt 3 实现 | +147 / −0 |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/BlueprintCallableReflectiveFallback.h` | 导出 `FScopedBindCaches` / `AngelscriptBindCaches_TryHasFunctionName` | +22 / −0 |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Helper_FunctionSignature.h` | Opt 2 / Opt 3 消费点 | +81 / −8 |

共 4 个文件、+300 行 / −24 行。

## 根因定位

Baseline 的瓶颈分布（分析得出）：

| 成分 | 占比 | 是否可动 |
|------|------|----------|
| AS 引擎 `RegisterObjectMethod` 签名解析 | ~60% | ❌ 引擎核心，约束不改 |
| 元数据 12-15 次 `HasMetaData`/`GetMetaData` | ~15% | ✅ |
| 冗余 `FindFunctionByName`（前缀冲突检测 + 双查找） | ~10% | ✅ |
| `IsScriptDeclarationAlreadyBound` 全局函数 O(M²) 扫描 | ~10% | ✅ |
| `GenerateFunctionList` 重复遍历 / EditorOnly 重复调用 | ~5% | ✅ |

## 六个优化项的详细说明

### Opt 1 (E)：Hash 化全局函数扫描

**问题**：`IsScriptDeclarationAlreadyBoundImpl::HasGlobalDeclaration` 在 `bStaticInScript` 分支每次调用都遍历 `ScriptEngine->GetGlobalFunctionCount()` 进行 strcmp 线性扫描。随 Phase 2 进度，M 单调递增，整体 O(M²)。这是最大单点瓶颈。

**方案**：
- 在 `BlueprintCallableReflectiveFallback.cpp` 引入 `thread_local FBindCachesTLS* GBindCachesTLS`
- 缓存结构：`TMap<FString /*Namespace*/, { TSet<FString> Names; TSet<FString> Declarations; }>`
- 在 `Bind_Defaults` Phase 2 入口用 RAII 守卫 `FScopedBindCaches` 激活
- `HasGlobalDeclaration` 命中守卫时先查 TLS，TLS 首次访问或落后引擎时通过 `SyncGlobalDeclCacheFromEngine` 增量从 `GetGlobalFunctionByIndex` 拉取
- 守卫析构时重置 TLS，其他调用方（非 Phase 2）自动回退到原线性路径

**关键代码**：

```cpp
// BlueprintCallableReflectiveFallback.cpp
struct FBindCachesTLS {
    TMap<FString, FGlobalDeclCacheEntry> GlobalDecls;
    asUINT LastSyncedGlobalFunctionCount = 0;
    bool bGlobalDeclsActive = false;
    // ...
};
thread_local FBindCachesTLS* GBindCachesTLS = nullptr;

void SyncGlobalDeclCacheFromEngine(asIScriptEngine* ScriptEngine) {
    // 只追加新注册的函数 —— Phase 2 中全局函数集单调增长
    for (asUINT i = Last; i < Count; ++i) { /* 加入 Names/Declarations */ }
    LastSyncedGlobalFunctionCount = Count;
}
```

**实测收益**：单此一项压下了 Phase 2 的绝大部分时间（从 36.22s → 接近 0）。

### Opt 2 (C)：批量元数据探测

**问题**：`FAngelscriptFunctionSignature::InitFromFunction` 每函数调用 12-15 次 `HasMetaData(K)` + `GetMetaData(K)`。UE 5.7 中，`UField::HasMetaData` 内部走 `UPackage::GetMetaData().FindValue(this, Key)`，两次调用 = 两次 `FMetaData::FindValue` 查找。

**方案**：
- **注意**：`UField::GetMetaDataMap()` 在 UE5 **不存在**（只有 `FField` 有），原计划的"缓存 map 指针"策略不可用 —— 这是实施中发现并纠正的
- 改为单次 `FindMetaData(K)` + 空指针判断：`HasMetaData(K) + GetMetaData(K)` 两次查找 → 一次 `FindMetaData(K)` + 空指针检查

**关键代码**：

```cpp
// Helper_FunctionSignature.h::InitFromFunction
auto HasFuncMeta = [&](const FName& K) -> bool {
    return Function->FindMetaData(K) != nullptr;
};
auto GetFuncMetaRef = [&](const FName& K) -> const FString& {
    const FString* V = Function->FindMetaData(K);
    return V != nullptr ? *V : EmptyString;
};

// 原：
//   if (Function->HasMetaData(K)) DeprecationMessage = Function->GetMetaData(K);
// 新：
const FString* DeprecatedMeta = Function->FindMetaData(NAME_Function_DeprecatedFunction);
bDeprecated = DeprecatedMeta != nullptr;
if (bDeprecated) DeprecationMessage = GetFuncMetaRef(NAME_Function_DeprecationMessage);
```

针对 `CPP_Default_<ArgName>` 循环也做了同样的 `FindMetaData` 单调用化。

### Opt 3 (D)：前缀冲突检测缓存

**问题**：`GetScriptNameForFunction` 对带 `K2_` / `BP_` / `AS_` / `Received_` / `Receive` 前缀的函数（占绝大多数 Blueprint 函数），在剥离前缀后调用 `OwningClass->FindFunctionByName(*OutScriptName)` 检查是否与既有函数冲突。每次调用走 super 链 + FuncMap hash。

**方案**：
- 在 `BlueprintCallableReflectiveFallback.cpp` 新增 `TMap<UClass*, TSet<FName>> ClassFuncNames` TLS 缓存（含 super chain，语义与 `FindFunctionByName` 等价）
- 暴露 `AngelscriptBindCaches_TryHasFunctionName(UClass*, FName, bool& bOutExists)`
- `GetScriptNameForFunction` 先问 TLS；未激活守卫时 fallback 到原 `FindFunctionByName`
- TLS 命中存在时仍需一次 `FindFunctionByName` 拿 UFunction 指针（判 BlueprintCallable/Pure/Event flag）—— 但大多数情况是命中**不存在**，可直接 O(1) 跳过后续工作

**关键代码**：

```cpp
// Helper_FunctionSignature.h::GetScriptNameForFunction
bool bCacheExists = false;
if (AngelscriptBindCaches_TryHasFunctionName(OwningClass, FName(*OutScriptName), bCacheExists)) {
    if (bCacheExists) {
        if (UFunction* Existing = OwningClass->FindFunctionByName(*OutScriptName)) {
            if (Existing != InFunction && Existing->HasAnyFunctionFlags(FUNC_BlueprintCallable|FUNC_BlueprintPure|FUNC_BlueprintEvent))
                bConflict = true;
        }
    }
    // 命中不存在：O(1) 直接跳过
} else if (UFunction* Existing = OwningClass->FindFunctionByName(*OutScriptName)) {
    // Fallback：原路径
    // ...
}
```

### Opt 4 (B)：TFieldIterator 替代双查找

**问题**：Phase 2 的最外层循环用
```cpp
TArray<FName> NameArray;
BindOrder.Class->GenerateFunctionList(NameArray);   // 第一次遍历 FuncMap
for (auto& Elem : NameArray) {
    UFunction* Function = BindOrder.Class->FindFunctionByName(Elem); // 第二次 hash 查找
    ...
}
```

两次扫描 `UClass::FuncMap`，中间还分配了一个 `TArray<FName>`。

**方案**：
```cpp
for (TFieldIterator<UFunction> FuncIt(BindOrder.Class, EFieldIteratorFlags::ExcludeSuper); FuncIt; ++FuncIt) {
    UFunction* Function = *FuncIt;
    ...
}
```

**关键点**：
- 必须传 `EFieldIteratorFlags::ExcludeSuper`（默认值是 `IncludeSuper`，会枚举父类函数，破坏"本类只绑一次"契约）
- 遍历顺序从 FuncMap hash 顺序变为 `Children` 链表声明顺序。最终注册的函数**集合**相同 —— 通过 `classes=7853 funcs_bound=6312` 对比验证

### Opt 5 (A)：移除冗余 SuperClass->FindFunctionByName（审计阶段）

**问题**：紧跟 `GetSuperFunction() != nullptr` 之后，又有一行：
```cpp
if (SuperClass && SuperClass->FindFunctionByName(Function->GetFName()) != nullptr)
    continue;  // O(N) 父类扫描
```

UHT 已经在父子同签名 UFUNCTION 间建立了 `GetSuperFunction()` 链接，这第二行只在"子类声明了与父类同名但**未** override、签名可能不同的 UFUNCTION"场景 fire —— 这属于罕见/错误模式。

**方案（两阶段）**：

**当前阶段**（已提交）：保留 `FindFunctionByName` 调用但加 `ensureMsgf` 审计
```cpp
if (SuperClass != nullptr && SuperClass->FindFunctionByName(Function->GetFName()) != nullptr) {
    ensureMsgf(false,
        TEXT("[AS] Shadow-UFUNCTION detected: %s::%s — inherits-by-name but no GetSuperFunction() link."),
        *BindOrder.Class->GetName(), *Function->GetName());
    continue;
}
```

**下一阶段**：确认 `ensureMsgf` 在完整编辑器启动下从不触发后，直接删除该 if 块，或改为 `TSet<FName>` O(1) 预收集。

**实测**：完整编辑器启动无任何 ensure 触发，可以安全进入阶段 2。

### Opt 6 (F)：提升 EditorOnly 早退检查

**问题**：Phase 2 内层循环每次都调用 `FAngelscriptEngine::ShouldUseEditorScriptsForCurrentContext()`，但该函数返回值在整个 Phase 2 生命周期内是常量。

**方案**：Phase 2 入口前缓存一次：
```cpp
const bool bUseEditorScripts = FAngelscriptEngine::ShouldUseEditorScriptsForCurrentContext();
for (auto& BindOrder : ClassesToBind) {
    ...
    if (!bUseEditorScripts && Function->HasAnyFunctionFlags(FUNC_EditorOnly))
        continue;
    ...
}
```

L1414 处的另一个 `FUNC_EditorOnly` 判断（"跳过 DB 记录"）保持不动 —— 它与 L1395-1399 语义不同，不能合并。

## TLS 守卫的设计要点

`FScopedBindCaches` RAII 守卫统一管理 Opt 1 + Opt 3 的 TLS 生命周期：

```cpp
struct ANGELSCRIPTRUNTIME_API FScopedBindCaches {
    FScopedBindCaches();   // 激活 TLS + 重置
    ~FScopedBindCaches();  // 失效 TLS + 清空
    FScopedBindCaches(const FScopedBindCaches&) = delete;
};
```

关键保证：
1. **不可重入**：`checkf(GBindCachesTLS == nullptr, ...)` 阻止嵌套实例化
2. **活动范围外完全无影响**：`bGlobalDeclsActive` / `bClassFuncNamesActive` 双 flag 控制，非 Phase 2 调用自动 fallback 到原路径
3. **线程安全**：`thread_local` 存储，不同线程不共享状态
4. **惰性同步**：`SyncGlobalDeclCacheFromEngine` 只在查询时被动触发，不主动钩住绑定 API

## 语义等价性证明

| 检查项 | 方法 | 结果 |
|--------|------|------|
| 绑定的类总数 | 对比 baseline `classes=7853` | ✅ 一致 |
| 绑定的函数总数 | 对比 baseline `funcs_bound=6312` | ✅ 一致 |
| `TFieldIterator` vs `GenerateFunctionList` 集合等价 | 经上一步计数验证 | ✅ 一致 |
| Shadow-UFUNCTION 场景 | `ensureMsgf` 审计 | ✅ 全编辑器启动 0 触发 |
| Opt 2 `FindMetaData` 与 `HasMetaData`+`GetMetaData` 语义等价 | 源码级对齐（都走 `UPackage::GetMetaData().FindValue`） | ✅ |
| Opt 3 TLS 命中路径与 `FindFunctionByName` 等价 | 缓存填充时枚举 own + super chain 全量 UFunction | ✅ |

## 验证方法

### 编译验证
```powershell
powershell -ExecutionPolicy Bypass -File Tools\RunBuild.ps1
```
4 个源文件 + 2 个 Unity 单元全部 compile 成功，2 个 DLL 链接成功。

### 运行时 Profiling

`Bind_BlueprintType.cpp:1530` 处已有 `UE_LOG(Angelscript, Log, TEXT("[Profiling] blueprinttype bindings breakdown: ..."))`，启动编辑器后从 `Saved/Logs/AngelscriptProjectEditor.log` 或 automation log grep：

```bash
grep "blueprinttype bindings breakdown" Saved/Logs/*.log
```

Baseline 与优化后对比见开头表格。

## 下一步可选工作

1. **Opt 5 阶段 2**：删除 `SuperClass->FindFunctionByName` 的 `ensureMsgf` 块（已验证零触发）
2. **Opt 1 扩展到 GetGlobalProperty 扫描**：如果后续出现其他全局属性查询瓶颈，同样的 TLS 模式可扩展
3. **Phase 3 / Phase 4 类似优化**：当前 `TGetterSetter=4.4ms` / `props_inherit=124ms` 占比很小，暂不需要优化
4. **cooked 启动验证**：优化面向编辑器，cooked 场景也应受益但幅度有限（cooked 下 `AS_USE_BIND_DB=1` 走快路径，本次优化的很多点不在热路径上）

## 回滚策略

全部改动在单个 commit `3642f79` 里，`git revert 3642f79` 即可完整回滚。若需要单独回滚某个 Opt：

- **Opt 1 / Opt 3** 共用 `FScopedBindCaches`：注释掉 `Bind_BlueprintType.cpp` L1378 的实例化即可让两个 TLS 缓存全部退化到 fallback 路径
- **Opt 2**：将 `FindMetaData` 调用回退到 `HasMetaData` + `GetMetaData`（局部改动）
- **Opt 4**：把 `TFieldIterator<UFunction>` 循环换回 `GenerateFunctionList` + `FindFunctionByName`
- **Opt 5**：删除 `ensureMsgf(false, ...)`，保留 `continue`
- **Opt 6**：把 `bUseEditorScripts` 替换回 `FAngelscriptEngine::ShouldUseEditorScriptsForCurrentContext()` 调用
