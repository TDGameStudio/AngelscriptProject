# AngelScript Binding 阶段分配与所有权清单

> 当前状态：适用于 `refactor-as-manual-binding-architecture` 完成后的主线。
> 关联文档：`ASFullEngineRebindOverhead.md`、`ASTestSuiteMemoryPeakRootCause.md`、
> `ASEngineMemoryAnalysis.md`。

## 1. 范围与历史量级

本文区分三类对象：

1. process-wide、只构建一次的 callback metadata；
2. 每个 `FAngelscriptEngine` 独立拥有的 binding 产物；
3. 单次 binding 执行期间的临时工作集。

历史 isolation 测量曾记录约 `5037` 个 UClass、`5623` 个 UFunction、单次完整 binding
`880–950 ms`，以及约 `1.2 GB` 工作集瞬时增长。这些数字是量级基线，不是当前版本的固定门槛。
实际数量和时间必须读取当次 `AS_BIND_CALLBACK_SUMMARY`、七阶段 totals、state dump 和 performance 测试。

## 2. 当前入口与执行模型

`UAngelscriptSubsystem` 在 Engine 创建前加载 `BindModules.Cache` 中的生成模块，并把唯一的 process callback
collection 原地 validate/sort/seal。`FAngelscriptEngine::BindScriptTypes()` 随后构造显式目标 facade：

```cpp
FAngelscriptBinds Binds(*this);
if (!FAngelscriptBind::ExecuteSealed(Binds, Diagnostic))
{
	return false;
}
```

provider 使用 file-static `FAngelscriptBind` 和非捕获 `void(*)(FAngelscriptBinds&)` callback。固定阶段为：

1. `TypeDeclarations`
2. `TypeInfrastructure`
3. `ManualBindings`
4. `GeneratedBindings`
5. `ReflectionBindings`
6. `PostReflectionBindings`
7. `Finalization`

当前不存在以下旧路径：

- nested `FAngelscriptBinds::FBind`；
- integer `EOrder` / `BindOrder` 作为外层 provider 顺序；
- `CallBinds()` 或每 Engine `GetSortedBindArray()`；
- `DisabledBindNames` runtime 裁剪；
- PreviousBind process-global trait/native-form 附着。

`Bind_BlueprintType.cpp` 内部仍有局部 `FBindOrder`、prepare/commit 和 Phase 1–5 算法。这些是一个
`ReflectionBindings` callback 内部的反射工作计划，不是外层 provider Registry 或 integer phase API。

## 3. Process-wide 分配

### 3.1 Sealed callback collection

每个 record 仅保存执行所需的紧凑 metadata：owner、logical bind name、七阶段 enum、source file/line 和
函数指针。collection 只构建、排序和 seal 一次；每个 Engine 直接读取同一 backing array。

明确禁止：

- 为每个 Engine 复制或重排 callback array；
- expanded per-operation description/cache；
- provider dependency graph、priority、alias、handle/lease；
- seal 后动态添加普通手写 provider。

原生 C++ provider 变化需要 rebuild + restart。NativeModuleFunctionAddress 的 POD/`IModularFeatures`
transport 是唯一保留的动态 arrival/unload 例外。

### 3.2 可重建的 process observer/cache

少数 UE reflection observer 仍可使用 process cache，例如 `GBlueprintEventsByScriptName`。它们必须能在
Engine recreation 时清理/重建，不能保存跨 Engine 可变的 `asITypeInfo*` 或 `asIScriptFunction*`。

## 4. Per-engine 持久分配

### 4.1 AngelScript SDK 对象

下列 registration API 会在目标 `asIScriptEngine` 内创建持久对象，并在该 SDK Engine 释放时销毁：

| API | 主要产物 |
|---|---|
| `RegisterObjectType` | `asCObjectType`、type lookup/index |
| `RegisterObjectMethod` | `asCScriptFunction`、signature/argument storage |
| `RegisterObjectBehaviour` | constructor/destructor/copy/assignment/cast function |
| `RegisterObjectProperty` | object property/type metadata |
| `RegisterEnum` / `RegisterEnumValue` | enum type/value storage |
| `RegisterFuncdef` | delegate/function definition |
| `RegisterGlobalFunction` / `RegisterGlobalProperty` | global callable/property entries |

这部分是 Full Engine 无法跳过的核心成本：callback metadata 可以共享，注册产物不能跨 Engine 共享。

### 4.2 Engine-owned plugin state

| Store | 所有权与生命周期 |
|---|---|
| `FAngelscriptTypeDatabase` | 每 Engine；type adapter、finder 与 AS type pointer 不跨 Engine |
| `FAngelscriptBindState` | 每 Engine；class DB、generated/reflective table、provenance、failure state |
| `FAngelscriptBindDatabase` | 每 Engine；加载/生成 `Binds.Cache`，schema 保持不变 |
| ToString contribution list | 每 Engine；在声明/基础设施阶段收集并 finalization |
| interface signature registry | 每 Engine；保存接口 generic-call userdata 所需 ownership |
| documentation state | 每 Engine；精确 function/property result 附着，不依赖 PreviousBind |
| StaticJIT native-form state | 每 Engine + 精确 `asIScriptFunction`；Engine shutdown 统一释放 |
| static name/index tables | 每 Engine；不写 process fallback |

direct registration 的首个失败记录在目标 `FAngelscriptBindState`，在该 Engine 生命周期内保持 sticky。
后续 provider 停止，Engine 不进入 publication-ready 状态。

## 5. Binding 期间的主要临时分配

### 5.1 Reflection prepare/commit

`Bind_BlueprintType.cpp` 的 `ReflectionBindings` provider 内部会：

- 收集 UClass/UStruct/UFunction；
- 构造局部 `ClassesToBind` / `FBindOrder`；
- 在 Phase 2A 生成 `FUFunctionBindPrep` 与 `FAngelscriptFunctionSignature`；
- 在 Phase 2B 把 prep commit 到目标 Engine；
- 清空每类 `FunctionPreps`；
- 在内部 Phase 5 收集/注册 native UInterface 方法。

这些临时数组通常是 binding 瞬时工作集的重要来源，但它们不进入 process callback record，也不会由
`UAngelscriptSubsystem` 保存。

### 5.2 Bind database 字符串和数组

`FAngelscriptBindDatabase` 会为 class/struct/method/property/enum/delegate/header link 构造 FString/TArray
metadata。普通加载路径读取现有 `Binds.Cache`；生成路径写回相同 schema。当前架构只改变调用目标和
provider phase，不改变 cache 格式或 generic/reflection marshalling。

### 5.3 Reflection callable bridge

BlueprintCallable、BlueprintEvent、interface 和 RPC fallback 会创建 function signature、userdata、
out-reference 描述等对象。RPC/Net UFunction 继续走 `BlueprintCallableReflectiveFallback`，不得为减少
分配而改成 raw direct thunk，否则会绕过 Unreal RPC routing。

### 5.4 StaticJIT/AOT

仅在生成预编译数据时创建 native-form 对象。旧 `SCRIPT_NATIVE_TEMPLATED_CALL*` / PreviousBind 附着已由
精确 fluent result 取代，例如：

```cpp
FAngelscriptBoundFunction Function = Type.Method("int32 Num() const", &FAngelscriptArrayBinds::Num);
Function.NativeTemplateInstantiatedCall("TArray::Num", true, false, false);
```

native/trivial/template classification、generated C++ spelling 和 call ABI 保持不变。

## 6. 观测与性能约束

开发/自动化 observation 启用时记录：

- collection finalization 次数与 callback 总数；
- 每个 Engine 的 execution epoch、publication 结果和总耗时；
- 七阶段 attempted/succeeded/failed/duration；
- top-N provider duration；
- aborted execution 的首个失败与未执行阶段。

未启用 observation define 时，不创建 per-provider timer/storage。state dump 只读取 sealed metadata 和
Engine-owned results，不执行 provider。

性能回归重点：

- callback array 没有 per-engine copy/sort；
- subsystem 没有 binding container/cache；
- process metadata 没有 expanded operation graph；
- ordinary callable 没有因为迁移而获得 native/trivial form；
- fluent result 不跨 Engine 生命周期保存。

## 7. 优化优先级

1. 普通测试复用 shared Engine；只有 lifecycle/binding isolation 使用 Full Engine。
2. 优化 `Bind_BlueprintType` 内部 prepare/commit 的临时数组和 string churn。
3. 使用 state dump/performance observation 定位 top provider，避免凭旧行号猜测。
4. allocator page-return 配置只改善释放后的 OS working set，不减少 binding 产物。
5. 不通过恢复 runtime disabled provider、dependency 或动态普通 provider 来换取局部成本。

## 8. 验证入口

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 `
  -TestPrefix "Angelscript.TestModule.Engine.BindingArchitecture" `
  -Label direct-bind-architecture -TimeoutMs 600000

powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 `
  -TestPrefix "Angelscript.TestModule.Engine.Performance" `
  -Label direct-bind-performance -TimeoutMs 600000

powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 `
  -TestPrefix "Angelscript.TestModule.Dump" `
  -Label direct-bind-dump -TimeoutMs 600000
```

---

**末更新**：2026-08-08。Engine-owned store、reflection prepare/commit 或 observation schema 变化时同步更新。
