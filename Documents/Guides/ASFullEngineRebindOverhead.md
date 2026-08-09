# Full Engine 重建时的 Binding 重放开销

> 当前状态：适用于 `refactor-as-manual-binding-architecture` 完成后的主线架构。
> 历史测量：`Documents/Guides/ASTestSuiteMemoryPeakRootCause.md`、
> `Documents/Guides/ASBindAllocationInventory.md`。

## 1. 结论

手写 binding 的“指令”只收集一次，但每个完整 `FAngelscriptEngine` 都必须把这些指令重放到自己的
`asIScriptEngine`。重放会重新创建该引擎拥有的 object type、script function、property、type adapter、
BindDB、documentation 和 StaticJIT native-form 状态。

因此：

- process-wide callback metadata 不会为每个 Engine 复制或重新排序；
- script-visible binding 产物仍然是 per-engine，完整 Engine 创建必然执行一次七阶段 binding；
- 普通测试应复用 shared test Engine，只在确实验证 Engine/binding 生命周期时创建 Full Engine；
- 当前主线没有 Clone Engine 路径，不能把历史 Clone 方案当成可用 API。

## 2. 当前 binding 架构

### 2.1 Process-wide 指令集合

每个 provider 以 file-static `FAngelscriptBind` 声明一个非捕获 callback：

```cpp
static void BindFExample(FAngelscriptBinds& Binds)
{
	FAngelscriptBinds Type = Binds.ValueClassForTarget<FExample>("FExample");
	Type.Method("bool IsValid() const", &FAngelscriptFExampleBinds::IsValid).NoDiscard();
}

static FAngelscriptBind Bind_FExample(
	TEXT("AngelscriptRuntime"),
	TEXT("FExample.ManualBindings"),
	EAngelscriptBindPhase::ManualBindings,
	&BindFExample);
```

启动协调器先加载 `BindModules.Cache` 中的生成模块，再对同一个 callback array 原地
validate/sort/seal。sealed collection 按以下固定阶段执行：

1. `TypeDeclarations`
2. `TypeInfrastructure`
3. `ManualBindings`
4. `GeneratedBindings`
5. `ReflectionBindings`
6. `PostReflectionBindings`
7. `Finalization`

不存在旧的 `FAngelscriptBinds::FBind`、integer `BindOrder`、`CallBinds()`、
`GetSortedBindArray()` 或 runtime `DisabledBindNames` 路径。

### 2.2 Per-engine 产物

`FAngelscriptEngine::BindScriptTypes()` 构造 `FAngelscriptBinds(*this)`，并直接迭代 sealed collection。
callback metadata 只读复用，但以下产物属于目标 Engine：

| 产物 | 归属 |
|---|---|
| `asCObjectType`、`asCScriptFunction`、properties/behaviours | 目标 `asIScriptEngine` |
| `FAngelscriptTypeDatabase` | 目标 `FAngelscriptEngine` |
| `FAngelscriptBindState` 与 generated/reflective function table | 目标 `FAngelscriptEngine` |
| `FAngelscriptBindDatabase` | 目标 `FAngelscriptEngine`；`Binds.Cache` schema 不变 |
| ToString、interface signature、documentation state | 目标 `FAngelscriptEngine` |
| StaticJIT native forms | 目标 Engine + 精确 `asIScriptFunction` |

Full Engine 之间不能共享上述 AS 指针或可变 store。显式 Engine routing 正是为了避免重放时把数据写进
另一个 Engine 或 process fallback。

## 3. 测试 Engine 选择

| 入口 | 行为 | 适用范围 |
|---|---|---|
| `ASTEST_CREATE_ENGINE()` | 获取 shared Full Engine，并通过 `ResetModules()` 清理 module 状态 | 普通编译、执行和 binding 行为测试 |
| `ASTEST_GET_ENGINE()` | 获取已由 fixture 准备好的 shared Engine，不主动 reset | `BEFORE_ALL` 已准备 Engine 的测试 |
| `ASTEST_CREATE_ENGINE_FULL()` | 创建独立 Full Engine，完整执行七阶段 binding | Engine 生命周期、多 Engine 隔离、binding failure、初始化/销毁测试 |
| `ASTEST_CREATE_ENGINE_NATIVE()` | 创建裸 AngelScript SDK Engine，不执行 UE plugin binding | 原生 SDK/embedding 测试 |

一个直接注册失败会在该 Engine 的 `FAngelscriptBindState` 中保持 sticky，并阻止后续 provider 和 publication。
故意制造 binding failure 的负向测试必须使用 `ASTEST_CREATE_ENGINE_FULL()`，不能污染 shared Engine。

## 4. 为什么 Full Engine 仍然昂贵

Full Engine 的主要成本不是 callback collection，而是重建 script-visible 产物：

- UE class/struct/delegate/enum 对应的 AS type；
- UFunction signature、direct/generated/reflective callable；
- Blueprint event/interface bridge；
- `Bind_BlueprintType` 内部 prepare/commit 临时数组；
- 可选的 StaticJIT/AOT metadata；
- 初始化、teardown 与 GC。

历史测量记录过单次完整 binding 约 `880–950 ms`、工作集瞬时增长约 `1.2 GB`。这些数字来自旧基线，
用于量级判断，不应当作当前硬阈值。当前实现通过以下 observation 分开记录：

- collection finalization；
- 每个 Engine 的 callback 总数和总耗时；
- 七阶段 attempted/succeeded/failed/duration；
- top-N provider duration；
- publication success/failure。

未启用开发/自动化 observation 时，不保留 per-provider clock/storage，也没有 per-call tracing。

## 5. 优化与测试原则

### 5.1 优先复用 shared Engine

仅编译或执行脚本、调用已绑定 API、验证普通类型行为时，应使用 shared Engine。每个测试通过唯一 module
name 和现有 fixture reset 隔离，不需要为了“看起来干净”而重建完整 Engine。

### 5.2 Full Engine 只用于真正的 Engine 边界

以下测试应保留 Full Engine：

- callback collection/phase/publication 的端到端验证；
- engine-owned state、同名 type id/pointer 的多 Engine 隔离；
- 初始化失败、extension attach/detach、shutdown/recreation；
- StaticJIT 生成模式或需要全新 SDK registration surface 的场景；
- hot reload/GC 测试中明确依赖完整 Engine 生命周期的场景。

### 5.3 不引入运行时裁剪

减少重放成本不能通过重新引入 `DisabledBindNames`、provider dependency、priority、alias 或动态卸载来完成。
file-static provider 在 collection seal 后要求 rebuild + restart。NativeModuleFunctionAddress 的
POD/`IModularFeatures` transport 是唯一保留的动态到达/卸载例外。

### 5.4 内存 allocator 调优是正交项

`mi.MemoryResetDelay` 等 allocator 设置可以改善已释放页归还 OS 的速度，但不会减少 Full Engine 必须创建的
binding 产物，也不能代替测试 Engine 选择和 allocation profiling。

## 6. 验证入口

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 `
  -TestPrefix "Angelscript.TestModule.Engine.BindingArchitecture" `
  -Label direct-bind-architecture -TimeoutMs 600000

powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 `
  -TestPrefix "Angelscript.TestModule.Engine.Performance" `
  -Label direct-bind-performance -TimeoutMs 600000
```

全量结论必须以 `Tools\RunTestSuite.ps1 -Suite All` 的实际 live count 为准，不沿用历史总数。

---

**末更新**：2026-08-08。binding collection、Engine ownership 或测试 Engine acquisition 变化时同步更新。
