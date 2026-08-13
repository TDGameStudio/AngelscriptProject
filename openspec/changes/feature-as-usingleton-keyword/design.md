## Context

现有 literal `asset` 预处理会生成一个模块全局 UObject 缓存和 `Get{Name}()`，并把 Getter 强制加入 `PostInitFunctions`。它同时承担了“具名对象”“延迟 Getter”“模块生命周期”三种职责，却没有 World scope、多 Engine 隔离或完整 reload 契约。兄弟变更会把 `asset` 重构成真正的 `UAssetManager` Dynamic Asset，因此 UObject 单对象能力必须由独立的 Singleton 模型接管。

`FAngelscriptEngine` 已经是生产、测试和工具 Engine 的隔离边界，并拥有模块 swap、full/post reload hook 和严格的当前 World 上下文。`ClassReloadHelper` 已经能消费对象替换关系。新系统沿用这些既有边界，不使用进程静态 fallback，也不复制外部插件的全局容器。

## Goals / Non-Goals

**Goals:**

- 同时提供无需声明的默认单例和由 `singleton` 声明的具名单例。
- 允许同一 UObject 类型拥有多个不同名称的具名单例，同时保证默认槽与具名槽永不混用。
- 对 Global/World scope、World 解析、UObject 家族创建、GC 保活、失败重试和释放顺序给出确定语义。
- 把语法、生命周期块、稳定描述符和生成 Getter 纳入模块编译、StaticJIT/offline 描述及 reload 分类。
- PIE 期间保持 last-good：任何相关单例变化只排队，不修改活动模块、类、槽或实例。
- 为旧 literal UObject asset 提供机械可执行的迁移目标。

**Non-Goals:**

- 不提供进程级静态单例；“Global”始终表示一个 `FAngelscriptEngine` 内全局。
- 不新增 GameInstance、LocalPlayer 或 Editor 第三/第四种 Scope。
- 不替代 `USubsystem`、`UWorldSubsystem`、`UGameInstanceSubsystem` 或其他 collection-owned 生命周期。
- 不在首期提供线程安全的后台创建；所有 Get/Create/Init/Reload/Deinit 都要求 Game Thread。
- 不允许通过 Custom `Create` 借用任意外部实例来绕过唯一性和所有权检查。

## Decisions

### 1. `singleton` 是关键字，`USINGLETON` 只是可选修饰

最终语法是：

```angelscript
singleton DefaultConfig of UGameConfig
{
    Init
    {
        Profile = n"Default";
    }
}

USINGLETON(World)
singleton CombatManager of ACombatManager
{
    Init
    {
        Capacity = 128;
    }
}
```

无宏、`USINGLETON()` 与 `USINGLETON(Global)` 都是 Global；`USINGLETON(World)` 是 World。选择真实关键字可以明确区分声明本体和 UE 风格 specifier，也与无 `USTRUCT` 宏仍可声明普通 `struct` 的语言习惯一致。详细 grammar、回调签名和 lowering 见 `attachments/syntax-and-lowering.md`。

### 2. 默认槽与具名槽是两套身份模型

具名定义 ID 为 `(Scope, ModuleStableId, Namespace, DeclarationName)`；声明的 UObject Type 是受校验的槽元数据，而不是唯一键。这样同一 Type 可以声明 `DefaultConfig`、`PreviewConfig` 等多份具名单例。World 实例键在定义 ID 后再追加弱 `UWorld` key。

默认槽不需要声明，键为 `(Scope, ResolvedUClassStablePath)`，World 实例再追加弱 `UWorld` key。运行时通过 class replacement map 更新 UClass 指针缓存，但稳定 class path 不随 reinstancing 指针改变。

默认槽和具名槽使用不同 key kind；即使 Scope 与 Type 完全相同，也必须创建两个实例。这避免声明的 Init/Reload/Deinit 意外作用于通用 `Singleton` API 创建的对象。

### 3. 具名 Getter 是命名空间 API，默认 Getter 是通用绑定

每个声明生成同名 namespace：

- Global：`Type Name::Get()`。
- World：`Type Name::Get()` 与 `Type Name::Get(UObject Context)`。

World 无参 Getter 只接受 `FAngelscriptEngine::TryGetCurrentWorldContextObject()` 能解析到的 eligible Engine World；不得读取 `GWorld`、枚举 `GEngine->GetWorldContexts()` 或选择第一个 PIE World。

默认槽由 `Singleton::GetGlobal(UClass Type)` 与 `Singleton::GetWorld(UClass Type, UObject Context)` 暴露。两个函数都带 `DeterminesOutputType`，脚本调用可直接得到传入 UClass 对应的对象类型。默认 API 不会合成声明、名字或生命周期块。

### 4. 描述符先于运行时对象，所有实例均延迟创建

预处理器识别 declaration 后生成稳定 `FAngelscriptSingletonDesc`，记录 source location、scope、stable ID、声明 Type、四个生命周期入口、结构 hash 与 body hash，并写入 `FAngelscriptModuleDesc`。编译/模块激活只验证描述符和生成函数，不访问 Registry，也不创建 UObject；不再使用 `PostInitFunctions` 实现 singleton。

第一次成功 Get 才进入 Registry 的 `Empty -> Creating -> Initializing -> Ready` 状态机。创建和 Init 完全成功后才发布对象；任何调用方都不能观察半初始化实例。

### 5. Registry 由 `FAngelscriptEngine` 独占并显式参与 GC

每个 Engine 拥有一个 `FAngelscriptSingletonRegistry`，不设置静态 fallback。Registry 对 Ready/Creating candidate 保持强 GC 引用，优先使用明确的 GC bridge/strong object holder，而不是 `RF_MarkAsRootSet`。World key 使用弱引用并监听 World cleanup；Engine shutdown 先释放残留 World 槽，再释放 Global 槽。

每个 scope 维护单调 creation sequence。释放按 sequence 逆序调用 Deinit，使 A.Init 中 Get(B) 的常见依赖关系在关闭时先释放 A、后释放 B。详细状态、创建矩阵和失败规则见 `attachments/registry-and-lifecycle.md`。

### 6. “任意 UObject 子类”受合法 Scope 和 UE 创建协议约束

普通非 abstract UObject 可以使用内置路径；Actor、Widget 和 Component 只能是 World scope，并分别走 Spawn、CreateWidget、NewObject/Register 路径。Global 不会为了 Actor/Widget/Component 借用 `GWorld`。需要特定 Actor 参数、Component Owner/Attachment 或特殊 Outer 的声明可以提供 Custom `Create`，但返回值仍要通过 Type、World、template/CDO、唯一性和所有权校验。

`USubsystem` 及由 engine/world/game-instance/local-player collection 独占创建的类型直接拒绝，并给出现有 Subsystem API 指引。抽象类、deprecated/newer-version class、CDO/archetype、另一个槽已拥有的对象和另一个 World 的对象也拒绝。

### 7. 生命周期函数使用固定形状和事务式发布

- Global `Create` lower 为 `Type __Create()`；World `Create` lower 为 `Type __Create(UObject Context)`。
- 用户编写的 `Init`、`Reload`、`Deinit` block 均为 `void` 且不能声明参数；隐藏 lowering 函数必须是 `void __Lifecycle(Type __Receiver) external_implicit_this`，其中 declared parameter 0 是 Registry candidate/replacement/ready object 的真实 VM/StaticJIT ABI 参数，并同时作为函数体 implicit receiver。它仍是 global function，不能 lower 成无参数函数或普通 C++/AS instance method。
- `Init` 仅在新 candidate 的 UE 构造完成后执行一次。
- `Reload` 仅在非 PIE 的兼容结构替换完成状态迁移后执行；普通函数体 soft reload 和生命周期 body-only 更新不重放它。
- `Deinit` 仅在 Registry 最终放弃一个 Ready 实例时调用一次；异常只记录诊断，不能中断其余槽的释放。

Create/Init 失败会清除 candidate、恢复 Empty，并允许后续 Get 重试。递归 Get 命中 Creating/Initializing 槽时报告包含完整 slot chain 的循环异常，不返回 partial object。

该 receiver 形状与当前旧 literal asset 的 `void __Init_Name(Type Name) external_implicit_this` 一致，但未来 Dynamic Asset 不再使用它。Typed Semantic AOT 必须保留参数 0 并把它规范化为 `ExplicitParameterAlias`；首期对象 emitter 不支持时走逐函数/调用根 Legacy/VM fallback，不能删除生命周期调用或改变次数。完整 trait/receiver 证据与 callee-closure 规则见兄弟 change `feature-as-typed-semantic-aot/research/function-traits-and-effective-receiver.md`。

### 8. 非 PIE reload 按“路由、结构、身份”分类

描述符身份和 Type 不变、仅普通函数或生命周期函数体变化时，保留对象地址与 Getter 路由；不调用 Init/Reload。兼容 UClass 结构替换时，Registry 创建 replacement，复制同名且类型兼容的 reflected state，保留 Actor World/Level/Transform，然后发布 replacement map 并调用一次 Reload。

Name、Namespace、ModuleStableId、Scope 或声明 Type 变化被视为旧定义删除加新定义增加：旧 Ready 槽 Deinit，新槽保持 Empty，绝不跨身份迁移。默认槽的 UClass 被合法 reinstancing 时按 stable class path 迁移，不把新类视为另一个默认 key。

### 9. PIE 对相关变化采取全拒绝、排队策略

PIE 中不只拒绝结构变化；下列任一变化都拒绝候选并排队到 PIE 结束：具名单例 descriptor、任一生命周期 block、具名单例引用 Type 的类 body/shape，以及任一已创建默认槽 Type 的类 body/shape。活动模块、Getter、对象地址和生命周期状态保持 last-good；不得“先 soft swap 一部分再排 full reload”。完全不相关的普通代码仍可沿现有 soft reload 路径。

详细分类矩阵、提交顺序与 rollback 见 `attachments/reload-and-pie.md`。

### 10. State Dump 与 Standalone 只观察/校验，不拥有实例

State Dump 新增只读定义行和活动槽行，至少包含 Engine id、key kind、stable ID/type、scope、world、state、instance path、creation sequence 和 last error；Dump 不触发 Get 或创建。

Standalone `ue-validation` 只消费/验证完整描述符和生成签名，所有 Singleton runtime Getter 都是不可执行 trap；`native-runtime` 不伪造 UObject、World 或 Registry。

## Implementation File Map

| Area | Planned files | Responsibility |
| --- | --- | --- |
| Syntax | `AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.h/.cpp` | token-aware declaration parsing, specifier validation, lifecycle lowering, migration diagnostics |
| Descriptors | `AngelscriptRuntime/Core/AngelscriptEngine.h`, `StaticJIT/PrecompiledData.h/.cpp` | singleton descriptors, hashes, archive/offline preservation |
| Runtime | new `AngelscriptRuntime/Core/AngelscriptSingletonRegistry.h/.cpp`, `AngelscriptEngine.h/.cpp` | per-engine slots, GC, World cleanup, creation, release and reload reconciliation |
| Script API | new `AngelscriptRuntime/Binds/Bind_Singleton.cpp` (split helper files if needed) | generic default APIs and generated named Getter bridge |
| Reload | `AngelscriptRuntime/ClassGenerator/AngelscriptClassReloadPlanner.h/.cpp`, Engine compile/swap code | related-change classification, structural migration, class-pointer remap |
| Editor replacement | `AngelscriptEditor/HotReload/ClassReloadHelper.h/.cpp` | consume singleton replacement pairs once |
| Observability | `AngelscriptRuntime/Dump/AngelscriptStateDump.h/.cpp` and offline export schema/writer | read-only rows and descriptor export |
| Tests | files listed in `attachments/test-plan.md` | parser, runtime, GC, reload, PIE, dump and standalone coverage |

## Risks / Trade-offs

- [具名 identity 不包含 Type，声明改 Type 可能被误迁移] → reconcile 明确把 Type 变化分类为 delete+add，禁止跨 Type 状态复制。
- [“任意 UObject”会让调用方误以为所有 Scope 都可 Spawn] → compile/first-Get 双重 creation matrix 校验；Global 对 World-owned 类型给出修复建议。
- [初始化依赖形成循环] → 显式状态机和 per-thread creation stack 输出完整循环链。
- [Registry 强引用造成 World 泄漏] → 弱 World key、World cleanup delegate、Engine shutdown sweep 和 GC/teardown 自动化测试。
- [Actor/Component replacement 被 Runtime 和 Editor 重复处理] → Runtime 只创建一次 replacement 并发布统一 map；Editor 只做外部引用替换，不再 Spawn。
- [PIE 误分类导致半热更] → descriptor/type dependency index 在 swap 前决定整批接受或排队；测试覆盖单 PIE、多玩家 PIE 和活动默认槽。
- [Deinit/Reload 脚本抛异常] → 记录 slot-scoped error，确保 cleanup/transaction 继续；不把异常对象发布回 Ready。

## Migration Plan

1. 先加入 parser/descriptor/生成签名和失败测试，保持 runtime trap。
2. 加入 Engine-owned Registry、默认 API、具名 Getter 与 UObject 创建路径。
3. 接入 GC、World cleanup、逆序生命周期及错误恢复。
4. 接入 non-PIE reload、Editor replacement map 和 PIE 全拒绝队列。
5. 将旧 literal UObject asset fixtures 迁移到 `singleton Name of Type { Init { ... } }`，随后由兄弟 Asset change 删除旧 bridge。
6. 独立完成本 change 的 focused/full verification；两个兄弟 change 可以共同落地，但任何一个都不得靠另一个的未实现状态通过验证。

Rollback 时先恢复旧 literal asset bridge/fixtures，再移除 Singleton descriptor 和 Registry；不得只移除绑定而留下能编译却无法执行的生成 Getter。

## Open Questions

None. Public syntax, identity, APIs, creation matrix, lifecycle and reload/PIE policy are fixed by this record.
