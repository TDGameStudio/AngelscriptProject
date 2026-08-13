## Why

脚本目前既没有“无需声明、按 UObject 类型获取”的默认单例，也没有“同一类型可以声明多份、按名字访问”的具名单例。现有 GMP、GenericStorages 和 TDGame/TDStandalone 方案可以作为行为参考，但插件需要一个由每个 `FAngelscriptEngine` 自己拥有、能正确处理 World、GC、PIE 和 Hot Reload 的内置实现。

## What Changes

- 新增真正的顶层关键字 `singleton`，语法为 `singleton Name of UObjectType { ... }`；它定义具名单例，不是 `UCLASS` 的另一种写法。
- 新增可选声明修饰 `USINGLETON()`、`USINGLETON(Global)` 和 `USINGLETON(World)`；不写 `USINGLETON` 时默认 Global。`USINGLETON` 不能脱离后续 `singleton` 单独使用。
- 具名单例按 `(Scope, Module, Namespace, Name)` 建立稳定身份，同一个 UObject 类型可以有多个不同名字的实例。
- 每个具名声明自动生成 `Type Name::Get()`；World 声明额外生成 `Type Name::Get(UObject Context)`，无参版本只使用严格的当前 Engine World 上下文。
- 新增无需 `singleton` 声明的默认单例接口 `Singleton::GetGlobal(UClass Type)` 与 `Singleton::GetWorld(UClass Type, UObject Context)`，并通过 `DeterminesOutputType` 返回调用方传入的具体 UObject 类型。
- 声明块支持可选 `Create`、`Init`、`Reload`、`Deinit` 生命周期块；所有实例都在第一次 `Get` 时延迟创建。
- 在合法 Scope 和合法 UE 创建路径内支持普通 UObject、Actor、Widget 与 Component 子类；拒绝 abstract、CDO、Subsystem 及其他由 UE collection 专有管理的对象类型。
- Global 实例按 Engine 隔离，World 实例按 `UWorld` 隔离；Registry 强引用活动实例，并在 World teardown 或 Engine shutdown 时逆序释放。
- 非 PIE 热更新区分纯函数体更新、兼容结构替换和身份变化；PIE 中所有会影响具名单例声明、生命周期块或活动默认单例类型的更新都拒绝并排队，last-good 模块和实例继续工作。
- 与兄弟变更 `refactor-as-runtime-asset-model` 建立明确迁移边界：旧 `asset Name of UClass` 的 UObject 用途迁移到具名 `singleton`，Dynamic Asset 仍由 `asset` 关键字负责。

## Capabilities

### New Capabilities

- `as-usingleton-runtime`: 定义默认/具名单例的语法、生成 API、身份、创建、生命周期、GC、World/Engine 隔离、诊断、PIE 与 Hot Reload 契约。

### Modified Capabilities

- None.

## Impact

- Runtime：`AngelscriptPreprocessor`、`FAngelscriptModuleDesc`/StaticJIT 描述序列化、`FAngelscriptEngine`、新的 Engine-owned Singleton Registry、通用脚本绑定、ClassGenerator reload 与 State Dump。
- Editor：`ClassReloadHelper` 的对象替换输入，以及 PIE 中的相关变更分类与延迟 full reload。
- Tests：Preprocessor、Singleton、GC、HotReload、Dump、World/Multiplayer PIE、multi-engine 与 Standalone UE-validation。
- Compatibility：新增语言关键字和 API；不引入 GMP、GenericStorages、TDCommon 或 TDStandalone 的运行时依赖，也不建立进程静态 singleton map。
- Detailed record：`attachments/syntax-and-lowering.md`、`attachments/registry-and-lifecycle.md`、`attachments/reload-and-pie.md`、`attachments/test-plan.md`。
