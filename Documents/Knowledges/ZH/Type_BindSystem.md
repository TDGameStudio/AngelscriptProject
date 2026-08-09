# Type_BindSystem — Bind 系统与 Native 绑定

> **所属前缀**: Type_（类型系统与生成链路族）
> **关注层面**: `Bind_*.cpp`、UHT RuntimeLinked 和 Editor CodeGen 如何通过文件级 `FAngelscriptBind`，把 C++ 类型、函数、属性与辅助数据直接注册到一个明确的 `FAngelscriptEngine`。本文不展开 `FAngelscriptType` 内部类型匹配、generic trampoline 参数编组或 UHT C# 解析器细节。
> **关键源码**:
> [AngelscriptBinds.h](../../../Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.h)
> · [AngelscriptBinds.cpp](../../../Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.cpp)
> · [Bind_FColor.cpp](../../../Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FColor.cpp)
> · [Bind_FColor_Functions.h](../../../Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FColor_Functions.h)
> · [Bind_FColor_Functions.cpp](../../../Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FColor_Functions.cpp)
> **关联文档**:
> [Type_Core](Type_Core.md)
> · [Type_FunctionCaller](Type_FunctionCaller.md)
> · [Arch_UHTToolchain](Arch_UHTToolchain.md)
> · [Guide_UHTToolchain](Guide_UHTToolchain.md)

---

## 概览

当前 Bind 架构只有一份紧凑的进程级回调集合。每个手写或生成 provider 通过文件级 `FAngelscriptBind` 提交以下元数据：

- 必填的逻辑名称；
- 七个语义阶段之一；
- `void (*)(FAngelscriptBinds&)` 回调指针；
- 自动记录的 owner module、源文件与行号。

静态构造期只追加这条紧凑记录，不访问 `GEngine`，不调用 AngelScript 注册 API，也不保存 `asITypeInfo*`、函数 id 或其他 engine-owned 对象。生成模块加载完成后，集合被验证、稳定排序并永久 seal。此后每个完整 `FAngelscriptEngine` 都用自己的 `FAngelscriptBinds` 重放同一组回调，直接创建属于该 engine 的类型、函数、属性与辅助状态。

```text
Bind_*.cpp / generated source
        |
        | file-static FAngelscriptBind
        | name + phase + owner + source + callback pointer
        v
single process callback collection
        |
        | load BindModules.Cache modules
        | validate -> stable sort -> seal once
        v
immutable callback collection
        |
        | replay for each full engine
        v
FAngelscriptBinds(explicit engine)
        |
        +-- immediate AS registration
        +-- engine-owned BindState / TypeDatabase / BindDB
        `-- exact FAngelscriptBoundFunction / FAngelscriptBoundProperty results
```

这不是一套延迟描述数据库：进程级集合不缓存展开后的 declaration、method、property、trait 或反射结果。创建第二个完整 engine 时会再次执行相同 callback，因为 AngelScript id、对象和数据库都属于各自 engine。

---

## 一、文件级 `FAngelscriptBind`

### 1.1 标准写法

```cpp
namespace
{
	void BindFVectorManual(FAngelscriptBinds& Binds)
	{
		auto FVector_ = Binds.ExistingClassForTarget("FVector");

		FVector_.Method("float64 Size() const", METHOD_TRIVIAL(FVector, Size))
			.NoDiscard()
			.Documentation(TEXT("Returns the vector length."));
	}
}

AS_FORCE_LINK const FAngelscriptBind Bind_FVector(
	TEXT("FVector"),
	EAngelscriptBindPhase::ManualBindings,
	&BindFVectorManual);
```

这里有四条必须遵守的约束：

1. 注册对象位于文件作用域，命名保持 `Bind_<Name>`，不加 `G` 前缀。
2. 必须使用 `AS_FORCE_LINK`，防止链接器把仅靠静态构造产生效果的对象 dead-strip。
3. 外层 callback 是接收 `FAngelscriptBinds&` 的非捕获函数指针；生产代码优先使用有语义的命名函数。
4. callback 只能通过传入的 `Binds` 修改目标 engine，不自行查找 ambient/current engine。

一个文件可以有多条 `FAngelscriptBind`。如果同一主题既贡献类型基础设施又注册手写方法，应按语义拆成两个 phase callback，而不是靠整数偏移制造隐式先后关系。

### 1.2 静态构造与执行的边界

`FAngelscriptBind` 的构造函数只登记元数据。静态构造期不得：

- 调用 `RegisterObjectType`、`RegisterObjectMethod` 等 AS API；
- 访问 `FAngelscriptEngine::GetCurrent()` 或 engine-owned database；
- 枚举反射类型或读取必须在模块加载后才存在的生成表；
- 捕获 UObject 实例、AS 指针或注册 id；
- 从 `StartupModule()` 再提交同一 provider。

真正的注册发生在 callback 被某个 `FAngelscriptBinds` 执行时。静态发现、进程级 finalization、逐 engine 执行是三个不同动作。

### 1.3 Seal、晚到模块与重启

正常启动先加载 `BindModules.Cache` 列出的生成模块，然后验证、排序并 seal 唯一回调集合。稳定 identity 是 `(OwnerModule, BindName, Phase)`；源文件与行号用于排序 tie-break 和诊断，不属于 identity。

Seal 之后不接受新的原生 direct callback provider。Live Coding、后加载模块或 DLL 替换若改变了 native bind，必须重启进程，让所有 provider 在下一次 seal 前重新到齐。系统不提供 direct callback 的晚到重放、卸载或原地替换。

唯一暂时保留的传输例外是 `NativeModuleFunctionAddress` 的 POD/`IModularFeatures` bridge；它不改变普通 `FAngelscriptBind` 的 seal 规则。

Bind 集合没有 runtime disable/filter 接口，也没有 `DisabledBindNames`、依赖级联、priority 或按名字跳过 provider 的配置面。若某能力不应存在，应在构建配置或源代码层决定，而不是让已 seal 的运行期绑定面因配置而改变。

---

## 二、七个必选阶段

每条 `FAngelscriptBind` 必须选择一个 `EAngelscriptBindPhase`：

| 阶段 | 职责 | 典型内容 |
|---|---|---|
| `TypeDeclarations` | 声明 AS 类型壳 | typedef、enum、funcdef、interface、object/value/template type |
| `TypeInfrastructure` | 补齐后续注册依赖的类型基础设施 | behaviours、string factory、default array、type adapter/finder、well-known slot、ToString contribution |
| `ManualBindings` | 注册手写脚本表面 | method、constructor、property、behaviour、global、namespace function |
| `GeneratedBindings` | 消费生成的 function binding provider | UHT RuntimeLinked、Editor CodeGen、Runtime 侧 NativeModule bridge bootstrap |
| `ReflectionBindings` | 注册反射类型与 UFunction fallback | UClass/UStruct/property/UFunction、`BlueprintCallableReflectiveFallback` |
| `PostReflectionBindings` | 注册依赖完整反射面的可调用项 | function-library mixin、actor/component/subsystem synthesis |
| `Finalization` | 只做完整性与元数据收口 | ToString/BindDB consistency、save inputs、metadata finalizer |

排序键依次为：phase、owner module、logical bind name、source file、source line。静态初始化顺序和链接顺序不定义执行结果。

`Finalization` 不得再注册新类型、函数或属性。如果一个“finalizer”仍在产生脚本调用面，应把它移到 `ReflectionBindings` 或 `PostReflectionBindings`。

旧式 `EOrder::Early/Normal/Late`、整数偏移、priority 和 dependency string 不属于当前 authoring contract。碰到真实依赖时，优先选择正确 phase、拆 callback，或把强耦合操作合并到同一 callback；不能表达的新依赖应单独设计，不能重新引入任意数字顺序。

---

## 三、明确的 `FAngelscriptBinds` 目标

### 3.1 每个 callback 只修改传入 engine

`FAngelscriptBinds` 构造时绑定一个 `FAngelscriptEngine`。callback 应使用 target-aware API，例如：

```cpp
void BindFColorManual(FAngelscriptBinds& Binds)
{
	auto FColor_ = Binds.ExistingClassForTarget("FColor");
	FColor_.Property("uint DWColor", 0);

	FAngelscriptBinds::FNamespace Namespace(Binds.GetTargetEngine(), "FColor");
	Binds.BindGlobalFunctionForTarget("FColor FromHex(const FString& HexString) no_discard", &FColor::FromHex);
}
```

同一个 facade 还提供目标 engine 的 script engine、bind state、type database、bind database、ToString collection 与 interface-signature registry。所有 AS id、type info、function object、反射快照与辅助结果仍由目标 engine 持有。

这条边界保证多 engine 场景中 Engine A 的 callback 不会把状态写到 Engine B，也不需要依赖 `FAngelscriptEngineScope` 来猜当前写入目标。

### 3.2 `FAngelscriptType`、generic 与 BindDB 语义不变

本次架构只改变 provider 的发现、阶段与 target routing，不重新定义以下领域：

- `FAngelscriptType` / `FAngelscriptTypeUsage` 的匹配、template/subtype 解析和 property 创建语义；
- direct/generic 注册、`asIScriptGeneric` 参数编组、ASAutoCaller、call convention 与 userdata；
- `Script/Binds.Cache` 与 `Binds.Cache.Headers` 的 schema、行序和 create/load 行为；
- 反射类型、动态 declaration 与 ClassGenerator 的脚本可见语义。

阶段信息和 provider identity 不写入 `Binds.Cache`。`BindModules.Cache` 负责在 seal 前找齐生成模块；`Binds.Cache` 仍是 engine 使用的反射绑定数据库缓存，两者不能混为一谈。

---

## 四、精确结果与 fluent trait

函数类注册返回 `FAngelscriptBoundFunction`，属性注册返回 `FAngelscriptBoundProperty`：

```cpp
FVector_.Method("float64 Size() const", METHOD_TRIVIAL(FVector, Size)).NoDiscard();

FVector_.Method("FVector GetSafeNormal(float64 Tolerance = SMALL_NUMBER) const", METHOD_TRIVIAL(FVector, GetSafeNormal))
	.NoDiscard()
	.Documentation(TEXT("Returns a normalized copy."));

FVector_.Property("float64 X", &FVector::X).PureConstant(0.0);
```

结果对象记录目标 engine 与刚刚返回的准确 function/property id，所以链式 trait 不依赖“最近一次注册”的全局槽位。即使函数、属性或两个 engine 的注册交错，trait 也只修改所属结果。丢弃结果值仍然合法；它们不是 provider handle，不进入进程级集合，也不应越过目标 engine 生命周期保存。

可用的 fluent 操作覆盖 editor-only、deprecation、property/generated accessor、no-discard、world context、callable、implicit constructor、compile-out、forced-const arguments、output type selection、script function/object injection、documentation、native/trivial metadata 与 pure constant property。

旧 `SetPreviousBind*`、`PreviouslyBoundFunction`、`PreviouslyBoundGlobalProperty` 依赖隐含全局“上一条”状态，不应出现在新代码中。

### 4.1 链式排版规范

注册链使用确定的物理排版：

- 恰好一个短 trait，并且整条 raw line 不超过 120 列时，可以同行。
- 注册调用本身较长，或有多个 trait 时，注册调用先独立闭合；每个 trait 各占一条同级缩进续行。
- 不把两个 trait 压在一行，也不为了“链式好看”超过 120 列。

```cpp
// 单个短 trait，整行 <= 120：允许同行。
FVector_.Method("float64 Size() const", METHOD_TRIVIAL(FVector, Size)).NoDiscard();

// 长注册或多个 trait：逐条续行。
FVector_.Method(
	"FVector GetSafeNormal(float64 Tolerance = SMALL_NUMBER) const",
	METHOD_TRIVIAL(FVector, GetSafeNormal))
	.NoDiscard()
	.Documentation(TEXT("Returns a normalized copy."));
```

---

## 五、手写 callable 的文件族

当一个 hand-written bind 拥有项目自定义的 AS callable 实现时，使用同 stem 文件族：

```text
Bind_FColor.cpp
Bind_FColor_Functions.h
Bind_FColor_Functions.cpp
```

职责分工：

- `Bind_<Name>.cpp`：`FAngelscriptBind`、phase、完整 AS declaration、typed DSL 调用与 fluent trait。
- `Bind_<Name>_Functions.h`：一个主 owner，通常命名为 `FAngelscript<Name>Binds`。
- `Bind_<Name>_Functions.cpp`：非 template callable 的实现；实现细节 helper 可放其匿名 namespace。
- 必须在实例化点可见的 template body 可以留在 `_Functions.h`。

```cpp
struct FAngelscriptFColorBinds
{
	static void ConstructRGBA(FColor* Address, uint8 R, uint8 G, uint8 B, uint8 A);
	static void AppendToString(void* Address, FString& OutString);
};
```

生产 callable 使用可搜索、可取地址的语义名称，例如 `ConstructDefault`、`ConstructFromString`、`GetByIndex` 或 `OpEqualsObject`；不要使用 `Function1`、`Lambda2` 一类数字后缀。一个注册文件只有一个 primary owner，即使它顺带绑定多个紧密相关的 UE 类型。

### 5.1 Pointer-only exemption

如果 `Bind_<Name>.cpp` 只转发现有 UE member/free function pointer，没有插件自定义 callable body，就不创建空的 `_Functions.h/.cpp`。这类 pointer-only bind 直接保留 `METHOD`、`METHODPR`、`FUNC` 等注册即可。

### 5.2 Lambda API 仍兼容

Facade 仍支持既有的非捕获 method/global/constructor lambda overload，测试或局部 DSL fixture 可以继续用它们。类型 finder、局部算法、UE delegate/async callback 等非 AS direct entry 也按其真实 capture/lifetime 需要保留 lambda。

“生产手写 callable 使用命名 owner”是源码所有权与可维护性规范，不是从 API 删除 lambda。UHT/Editor 自动生成的命名 thunk 也不需要人为创建 `_Functions` companion。

---

## 六、生成、反射与 optional plugin 路径

### 6.1 UHT RuntimeLinked

每个有注册项的 RuntimeLinked 模块生成一个 `AS_FunctionBinding_<Module>.gen.cpp`。文件内以最多 256 条 registration 的私有 batch helper 控制编译单元大小，最终由唯一 callback 执行：

```cpp
namespace
{
	static void BindGeneratedFunctionBindings_AIModule(FAngelscriptBinds& Binds)
	{
		Binds.RegisterGeneratedFunctionBindingForTarget(
			AAIController::StaticClass(),
			"ClaimTaskResource",
			{ ERASE_AUTO_METHOD_PTR(AAIController, ClaimTaskResource) });
	}
}

AS_FORCE_LINK const FAngelscriptBind Bind_AS_FunctionBinding_AIModule(
	TEXT("UHT.FunctionBinding.AIModule"),
	EAngelscriptBindPhase::GeneratedBindings,
	&BindGeneratedFunctionBindings_AIModule);
```

能安全拿到 native 地址的 entry 保存 `ERASE_AUTO_*_PTR`；不满足直接链接策略的 entry 保存 `ERASE_NO_FUNCTION()`，随后由 `ReflectionBindings` 的 `BlueprintCallableReflectiveFallback` 注册。RPC/Net UFunction 必须保留反射 fallback，不能通过 raw native thunk 绕过 Unreal RPC routing。

### 6.2 Editor CodeGen

Editor CodeGen 生成的 `ASRuntimeBind_*` / `ASEditorBind_*` 模块也拥有 file-static `FAngelscriptBind`，使用 `GeneratedBindings` 并接收显式 `FAngelscriptBinds&`。生成模块的 `StartupModule()` 不提交 binding；模块只需在 seal 前由 `BindModules.Cache` 加载，使其静态 provider 进入唯一集合。

### 6.3 NativeModuleFunctionAddress

目标模块函数地址模式仍通过 Runtime-independent POD table、thunk 与 `IModularFeatures` 传输。以下内容在本架构中不变：

- `FAngelscriptNativeModuleFunctionBinding` / `FAngelscriptNativeModuleFunctionBindingView` layout；
- layout version 文件与 Runtime/UHT 两端 ABI 对齐要求；
- target module 不依赖 `AngelscriptRuntime` 的编译边界；
- 安全签名白名单以及不支持签名的 fallback/deferred 决策。

任何 POD layout 修改仍必须显式 bump layout version，并同步 bridge、emitter 与测试；不能借 Bind 架构重构顺带改变 ABI。

### 6.4 Optional plugins

GameplayTags、GAS 等 optional plugin 使用相同 file-static phase/direct-callback 模型。普通 direct provider 同样受 seal 与重启规则约束，不应在 `StartupModule()` 持有注册 handle 或重复提交 provider。

---

## 七、Native / StaticJIT 元数据边界

`METHOD`、`METHOD_TRIVIAL`、`FUNC`、`FUNC_TRIVIAL`、custom-native 与 `SCRIPT_NATIVE_TEMPLATED_CALL*` 关联的是 callable 的 native/trivial/header/generated-name 等 StaticJIT/AOT 元数据。把 callable 移到 `FAngelscript<Name>Binds` 时，必须保持这些分类、可见性、include reachability 与生成 C++ spelling 一致。

这类宏不会把 callable 变成新的 provider，也不是 runtime tracing、descriptor cache 或长期 registration handle。普通旧 lambda 若原先没有 native/trivial 形式，迁成命名函数后也不能因为“现在能取地址”就自动获得 StaticJIT native form。

---

## 八、常见错误

1. **漏写 `AS_FORCE_LINK`**：静态 provider 可能被 dead-strip，脚本表面缺失。
2. **用 phase 内名字排序表达依赖**：logical name 只是稳定排序键，不是 dependency DSL。应选择正确 phase、拆分或合并 callback。
3. **callback 内查 ambient engine**：多 engine 时可能写错目标。始终沿传入的 `Binds` 取 engine-owned store。
4. **seal 后加载 direct provider**：注册会 fail closed；原生 binding 变化需要重启。
5. **为 pointer-only bind 创建空 companion**：没有自定义 callable body 就不需要 `_Functions` 文件。
6. **继续使用 PreviousBind helper**：把 trait 链到 registration 返回的准确结果。
7. **把多个 trait 挤在同一行**：多个 trait 各占一条续行；单个短 trait 也必须满足整行不超过 120 列。
8. **把 RPC 直接绑到 raw native thunk**：这会绕过 Unreal 网络路由；RPC/Net UFunction 必须走 reflective fallback。
9. **把 `Binds.Cache` 当 provider 集合**：它是反射绑定数据库缓存；provider 模块发现使用 `BindModules.Cache`。
10. **迁移 callable 时改变 native 分类**：StaticJIT/AOT metadata 需要一一保持，不因函数改名或移文件而扩大。

---

## 速查

| 需求 | 当前做法 |
|---|---|
| 新增手写注册 | file-static `AS_FORCE_LINK const FAngelscriptBind` |
| 选择顺序 | 七个 `EAngelscriptBindPhase` 之一 |
| 访问 engine | callback 参数 `FAngelscriptBinds&` |
| 添加一个 trait | 短且整行 `<= 120` 时同行，否则续行 |
| 添加多个 trait | registration 独立闭合，每个 trait 一条续行 |
| 自定义 callable | `Bind_<Name>_Functions.h/.cpp` + `FAngelscript<Name>Binds` |
| 只转发 UE 函数指针 | pointer-only，不创建空 companion |
| 局部/test lambda | API 兼容，可继续使用 |
| 生产手写 direct entry | 命名 callable，稳定取地址 |
| 原生 bind 改动 | 重启进程，在 seal 前重新发现 |
| runtime 禁用某条 provider | 不支持；在 source/build 配置层决定 |
| UHT RuntimeLinked / Editor CodeGen | `GeneratedBindings` file-static callback |
| RPC/Net UFunction | `BlueprintCallableReflectiveFallback` |
| NativeModuleFunctionAddress | 保持 POD/`IModularFeatures` bridge 与 layout version |

## 小结

当前 Bind 系统的核心是“一个不可变的进程级 callback 集合 + 每个 engine 的直接重放”，而不是旧式整数 order 队列或可运行时过滤的描述 registry。`FAngelscriptBind` 负责稳定发现和 phase；`FAngelscriptBinds&` 负责明确目标；`FAngelscriptBoundFunction` / `FAngelscriptBoundProperty` 负责把 trait 精确应用到刚注册的结果。

手写源码以 `Bind_<Name>.cpp + _Functions.h/.cpp` 管理自定义 callable，pointer-only 文件免建空 companion；lambda overload 保持兼容，但生产 direct entry 使用命名 owner。生成与反射路径接入同一阶段模型，同时保持 RPC routing、generic marshalling、`FAngelscriptType`、`Binds.Cache`、StaticJIT callable metadata 与 NativeModule POD ABI 的原有语义。
