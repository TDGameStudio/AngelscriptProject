# BlueprintType Bindings 性能优化方向

## 性能基线

2026-04-17 在当前项目上采集的分段计时数据：

| 段 | 内容 | 耗时 | 占比 |
|---|---|---|---|
| 段 1 | 类收集（TObjectRange + 拓扑排序） | 6.0 ms | 0.02% |
| **段 2** | **函数枚举 + Callable/Event 绑定** | **36,220.0 ms** | **99.72%** |
| 段 3 | GetterSetter 绑定 | 4.1 ms | 0.01% |
| 段 4 | Inherit + BindProperties + DB 写入 | 92.7 ms | 0.26% |
| 合计 | | 36,322.7 ms | 100% |

关键统计量：

- 处理 7,853 个 UClass，实际绑定 6,312 个函数
- 每函数平均耗时 5.74 ms
- 与 `FAngelscriptScopeTimer` 的 36,323.6 ms 一致（误差 < 0.003%）

**结论：36.2 秒中 36.22 秒（99.72%）花在段 2。后续优化应 100% 聚焦段 2。**

## 段 2 的内部调用链

每个被绑定的函数都经过完整链路：

```
for each UClass (7853):
  GenerateFunctionList()           -- 拷贝 TArray<FName>
  for each FName:
    FindFunctionByName()           -- 哈希查找 UFunction*
    过滤（继承/EditorOnly等）
    BindBlueprintCallable():
      ClassFuncMaps 查找 FFuncEntry -- 确认有 native 指针
      FAngelscriptFunctionSignature 构造:
        TFieldIterator<FProperty>  -- 遍历参数
        FromProperty()             -- 解析每个参数的 AS 类型
        GetMetaData() x N          -- 查询默认值、WorldContext 等
        BuildFunctionDeclaration() -- 拼 declaration 字符串
      BindMethodDirect():
        RegisterObjectMethod():
          ParseDataType(obj)       -- 按类名字符串查找 asCObjectType*
          ParseFunctionDeclaration -- 重新解析 declaration 字符串
          CheckNameConflictMember  -- 命名冲突检查
          FindMethod               -- 重复注册检查
```

其中每层都有独立的开销，下面按可优化的环节梳理方向。

## 优化方向

### 方向 A：替换函数枚举方式

**目标**：消除 `GenerateFunctionList` + `FindFunctionByName` 的开销。

**现状**：当前代码先调 `GenerateFunctionList()` 拷贝一个 `TArray<FName>`，再逐个 `FindFunctionByName()` 做哈希查找。这是因为 UE 5.7 不暴露 `UClass::GetFunctionMap()`（Hazelight 通过引擎补丁暴露了该 API）。

**方案**：改用 `TFieldIterator<UFunction>(Class, EFieldIteratorFlags::ExcludeSuper)` 直接遍历，避免数组分配和逐个哈希查找。

**涉及文件**：
- [`Bind_BlueprintType.cpp`](Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintType.cpp) 行 1381-1385

**预期收益**：低（函数枚举本身不是主要开销，主要开销在后续的签名构造和 AS 引擎注册）

**风险**：低。`TFieldIterator` 是标准 UE API。

---

### 方向 B：缓存 AS 引擎类型查找，绕过重复 ParseDataType

**目标**：消除同一 UClass 的所有方法重复解析类型名。

**现状**：`BindMethodDirect` -> `RegisterObjectMethod` 每次调用都先 `ParseDataType(obj)` 按类名字符串查找 `asCObjectType*`。同一个类的所有方法共享同一个类型，这是纯粹的冗余。

**方案**：在 per-class 循环中，每个类只做一次类型查找得到 `asCObjectType*`，然后直接调 `RegisterMethodToObjectType`（AS 引擎已有此内部方法，签名见 `as_scriptengine.h:226`）。需要将该方法访问权限改为 public 或加友元。

**涉及文件**：
- [`as_scriptengine.h`](Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptengine.h) 行 226（改访问权限）
- [`Bind_BlueprintType.cpp`](Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintType.cpp) 段 2 循环
- [`AngelscriptBinds.cpp`](Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.cpp)（可能需要新增带 `asCObjectType*` 的 `BindMethodDirect` 重载）

**预期收益**：中。6312 次 `ParseDataType` 中约 5000+ 次是冗余的（7853 个类 vs 6312 个函数，平均每类不到 1 个函数，但大类上百个方法共享一次查找，总省约 5000 次字符串解析）。

**风险**：低。`RegisterMethodToObjectType` 已存在，只是访问级别的改动。

---

### 方向 C：UHT 预生成 AS 声明字符串，跳过运行时签名构造

**目标**：消除 `FAngelscriptFunctionSignature` 的构造开销（每函数涉及参数遍历、类型解析、metadata 查询、字符串拼接）。

**现状**：UHT 工具（`AngelscriptFunctionTableCodeGenerator.cs`）已经在编译期遍历了所有 `UFunction`，但当前只生成了 `AddFunctionEntry`（native 函数指针）。`BindBlueprintCallable` 在运行时仍然要构造 `FAngelscriptFunctionSignature`，走完整的反射链路。

**方案**：扩展 UHT 工具，在编译期额外生成：
- 完整的 AS declaration 字符串（如 `"bool GetActorLocation() const"`）
- 签名元数据（bStatic、ClassName、WorldContextArgument 等）

运行时 `BindBlueprintCallable` 检测到 `FFuncEntry` 中有预生成数据时，直接使用，跳过 `InitFromFunction` 和 `BuildFunctionDeclaration`。

**涉及文件**：
- [`AngelscriptFunctionTableCodeGenerator.cs`](Plugins/Angelscript/Source/AngelscriptUHTTool/AngelscriptFunctionTableCodeGenerator.cs)（扩展生成内容）
- [`FunctionCallers.h`](Plugins/Angelscript/Source/AngelscriptRuntime/Core/FunctionCallers.h)（扩展 `FFuncEntry` 结构）
- [`Bind_BlueprintCallable.cpp`](Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintCallable.cpp) 行 54-55（添加快速路径）
- [`Helper_FunctionSignature.h`](Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Helper_FunctionSignature.h)（可能需要 `InitFromPrebuilt` 方法）

**预期收益**：高。`InitFromFunction`（行 178-340）是每函数开销最重的部分之一，涉及 `TFieldIterator<FProperty>`、多次 `GetMetaData`、`FromProperty` 类型解析、`BuildFunctionDeclaration` 字符串拼接。对 6312 个函数全部跳过该路径，预计能砍掉段 2 中 40-60% 的耗时。

**风险**：中。UHT 生成的声明必须与运行时反射生成的完全一致，需要全面回归验证。

---

### 方向 D：Editor 模式下的 Bind DB 缓存

**目标**：让 Editor 也能从缓存加载绑定数据，避免每次启动都全量反射。

**现状**：`AS_USE_BIND_DB` 定义为 `(!WITH_EDITOR)`（`AngelscriptEngine.h:17`），所以 Editor 永远走全反射路径。非 Editor 构建可以从 `Binds.Cache` 加载。

**方案**：
- 首次 Editor 启动时走全反射路径，完成后写出 `Binds.Cache`
- 后续 Editor 启动时比对缓存有效性（模块时间戳/哈希），有效则从 DB 加载
- 模块变更时自动失效缓存

**涉及文件**：
- [`AngelscriptEngine.h`](Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.h) 行 17（条件化 `AS_USE_BIND_DB`）
- [`AngelscriptEngine.cpp`](Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp)（缓存加载/写入/失效逻辑）

**预期收益**：极高。如果缓存命中，段 2 耗时可从 36 秒降到 < 1 秒（DB 路径仅做数据反序列化 + 直接注册）。

**风险**：高。需要可靠的缓存失效机制，否则会产生绑定不一致的 bug。Editor 环境下模块热重载、插件增减等都需要正确处理。

---

### 方向 E：批量注册 API，减少 AS 引擎内部解析开销

**目标**：减少 AS 引擎 `ParseFunctionDeclaration` + `CheckNameConflictMember` + `FindMethod` 的重复开销。

**现状**：每次 `RegisterObjectMethod` 调用都完整解析 declaration 字符串、做命名冲突检查、做重复注册检查。对同一个类的多个方法，冲突检查列表逐渐增长。

**方案**：在 AS 引擎中新增批量注册 API，一次传入同一类型的所有方法声明，内部只做一次类型查找和一次批量冲突检查。

**涉及文件**：
- [`as_scriptengine.h`](Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptengine.h) / [`as_scriptengine.cpp`](Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptengine.cpp)（新增批量 API）

**预期收益**：中。主要省去重复的类型查找和逐渐增长的冲突检查列表遍历。

**风险**：中。涉及修改 fork 的 AS 引擎核心 API，需要仔细验证不影响现有注册逻辑。

---

## 优先级建议

按"收益/风险"比排序：

| 优先级 | 方向 | 预期影响 | 工作量 | 风险 |
|---|---|---|---|---|
| 1 | B - 缓存类型查找 | 段 2 减 10-15% | 1-2 天 | 低 |
| 2 | C - UHT 预生成声明 | 段 2 减 40-60% | 3-5 天 | 中 |
| 3 | A - TFieldIterator 替换 | 段 2 减 < 5% | 0.5 天 | 极低 |
| 4 | E - 批量注册 API | 段 2 减 10-20% | 2-3 天 | 中 |
| 5 | D - Editor Bind DB | 段 2 减 95%+ | 5-8 天 | 高 |

方向 B + C 组合可将 36 秒压缩到 ~15 秒范围。方向 D 是终极方案但风险最高。方向 A 风险极低可随时做。
