# Function traits, effective receiver, and call-shape research

日期：2026-08-13

状态：`feature-as-typed-semantic-aot` 的实现约束。本文记录 maintained fork 的当前事实、Typed HIR 的规范化模型、首期 fallback 边界，以及与 Singleton change 的交叉约束。它不是新的 AngelScript 公共 ABI，也不把研究 fixture schema 变成 Runtime 持久化格式。

## 1. 结论

Typed Semantic AOT 不能把函数修饰符当作 emitter 末端的一组独立布尔开关。最终函数和调用语义同时来自：

- `asCScriptFunction::traits`；
- `objectType`、`funcType`、`vfTableIdx`；
- return/parameter `asCDataType` 与 `inOutFlags`；
- `hiddenArgumentIndex`、`hiddenArgumentDefault`；
- `determinesOutputTypeArgumentIndex`；
- `compileOutType`；
- system-function call convention、`PassScriptFunctionAsFirstParam` 等 native-call metadata；
- `DoesReturnOnStack()`、异常清理和 suspend 状态；
- ClassGenerator 最终 UFUNCTION/RPC/Blueprint route。

因此 HIR 必须在函数级保存一个规范化语义头，并在表达式级保存编译器最终解析的 receiver、target、参数和 call rewrite。Raw trait bits 可以作为诊断快照保留，但 eligibility、entry planning 和 emitter 不得各自重新解释一遍 raw bits。

推荐的语义边界是：

```text
source declaration/modifiers
  -> builder produces asCScriptFunction shape
  -> compiler performs name lookup, overload selection and call rewrites
  -> Typed HIR captures normalized function header and resolved expressions
  -> HIR verifier proves every receiver/symbol/argument relationship
  -> Semantic eligibility selects emit/direct/bridge/fallback
  -> shared entry plan preserves VM/raw/parameter ABI
```

## 2. `external_implicit_this` 的真实语义

### 2.1 现有 literal asset lowering

`Preprocessor/AngelscriptPreprocessor.cpp::PostProcessLiteralAssets()` 当前把：

```angelscript
asset ExampleAsset of ULiteralPostInitAsset
{
    bWasPostInit = true;
    InitMarker = 1337;
}
```

lower 为近似：

```angelscript
ULiteralPostInitAsset __Asset_ExampleAsset;

ULiteralPostInitAsset GetExampleAsset()
{
    if (__Asset_ExampleAsset != nullptr)
        return __Asset_ExampleAsset;

    __Asset_ExampleAsset = Cast<ULiteralPostInitAsset>(
        __CreateLiteralAsset(ULiteralPostInitAsset, "ExampleAsset"));
    if (__Asset_ExampleAsset == nullptr)
        return nullptr;

    __Init_ExampleAsset(__Asset_ExampleAsset);
    __PostLiteralAssetSetup(__Asset_ExampleAsset, "ExampleAsset");
    return __Asset_ExampleAsset;
}

void __Init_ExampleAsset(
    ULiteralPostInitAsset ExampleAsset
) external_implicit_this
{
    bWasPostInit = true;
    InitMarker = 1337;
}
```

直接证据：

- `Preprocessor/AngelscriptPreprocessor.cpp:4544-4569` 生成全局缓存、Getter、显式 `__Init_(Object)` 调用和带第一个参数的 `external_implicit_this` 函数；
- `AngelscriptLiteralAssetPostInitTests.cpp:43-72` 证明 body 使用未限定成员名且初始化确实落到生成 UObject；
- `as_builder.cpp:5224-5225` 只在 `objType == nullptr` 时为脚本函数设置该 trait，所以它不是普通 instance method；
- `as_compiler.cpp:777-782` 把参数 0 的 object type 与真实 stack position 保存为 `ExternalThisType/ExternalThisOffset`；
- `as_compiler.cpp:11303-11513` 用该 type/offset 解析 `this`、字段和 property accessor；
- `as_compiler.cpp:13128-13313` 用同一个 receiver 解析未限定方法并准备对象参数。

`Reference/angelsea` 的上游 AngelScript trait 集合没有 `external_implicit_this`。它是 maintained UE/Hazelight fork 的语言扩展，不能从 Angelsea runtime JIT 获得语义实现。

### 2.2 它不是隐藏 ABI 参数

`external_implicit_this` 的参数 0 同时扮演两个角色：

1. `DeclaredParameter(0)`：真实存在于函数签名、VM stack、raw entry 和调用点；
2. `EffectiveReceiver`：函数体未限定成员访问和显式 `this` 的对象来源。

它不是 C++/AngelScript instance method 的隐藏 object slot，也不是 `hiddenArgumentIndex`。AOT 删除参数 0 会破坏入口 ABI；把它直接翻译成 C++ `this` 会生成一个并非 C++ member function 的非法/错误 body。

规范化表示必须保留 parameter symbol，并让 receiver 引用同一个 symbol：

```text
FunctionHeader
  InvocationKind = Global
  DeclaredParameters = [S0: ULiteralPostInitAsset]
  EffectiveReceiver
    Kind = ExplicitParameterAlias
    ParameterIndex = 0
    Symbol = S0
    Type = ULiteralPostInitAsset
```

未来对象 emitter 应生成显式对象表达式，例如 `Receiver->InitMarker` 或经过审核的 UObject property bridge；不得生成裸 `this->InitMarker`，也不得按字符串重新查找 `InitMarker`。

### 2.3 名称解析和安全语义不能丢失

当前编译器先查局部变量、显式参数和其他正常符号，只有未命中时才尝试 implicit receiver。HIR 捕获必须位于这次解析之后，从而自然保存名称遮蔽结果。Emitter 不执行第二次 lookup。

对象 handle/value/reference 的实际 dereference、null check、property access-control、deprecated/editor-only 检查和 property accessor 选择也由现有 compiler path 决定。尤其对于 reference UObject receiver，未来 native emitter 必须保留 AS null-pointer exception 行为；旧 asset Getter 的非空检查不能被当作该语言修饰符对所有调用者的全局保证。

`ExternalThisType` 只保存 object type，而当前未限定成员路径的一些 const 判断仍读取 `outFunc->IsReadOnly()`。由于该函数是 global，不能把参数 spelling 中的 constness自行扩展成新的语言规则。HIR 只记录现有编译器最终允许并解析出的 read/write/call 结果；若要强化 `external_implicit_this` 的 const 语言语义，应另立 frontend change，不应由 AOT 暗中改变。

### 2.4 无效形状的处理

Builder 已限制该 trait 只能出现在 global function，但当前 compiler 只有在参数 0 存在且 `type.GetTypeInfo() != nullptr` 时才建立 receiver。Typed AOT change 不把 HIR capture 变成第二套语言诊断器：

- 正常脚本编译结果仍由现有 frontend 决定；
- HIR verifier 要求 `ExplicitParameterAlias` 精确指向存在的 object-typed parameter symbol 0；
- 缺参、primitive 参数、dangling symbol、type mismatch 或 receiver/trait 不一致得到稳定 `InvalidEffectiveReceiver`/`InvalidIR`；
- Semantic 不发布部分 C++，Legacy/VM 按配置继续；
- 是否把这些 no-op/malformed 源形状升级为编译错误，留给独立语言 hardening 工作。

## 3. Receiver 模型不能合并的四种形状

| Function shape | Declaration ownership | Effective receiver | Parameter 0 | Source call | Entry ABI |
| --- | --- | --- | --- | --- | --- |
| ordinary global | namespace/module | none | ordinary formal when present | `F(A)` | global |
| ordinary instance | `objectType` | native object `this` | first explicit formal, not receiver | `O.F(A)` / implicit method | object slot + formals |
| `external_implicit_this` | namespace/module | explicit parameter alias | retained and aliased | ordinary global `F(O, A)` | global formals |
| function `mixin` | namespace/module | source-call receiver mapped to formal 0 | retained formal; body normally uses its name explicitly | only `O.F(A)` | global formals |

`mixin` 和 `external_implicit_this` 都与 formal 0 有关，但语义相反：

- mixin 在调用者侧把方法语法 receiver 规范化为 ABI argument 0；callee body 不自动获得 implicit `this`；
- external implicit this 在调用者侧仍是普通 global call；callee body 把 argument 0 同时当作 implicit receiver。

两者不能共用一个模糊的 `HasReceiver=true`。建议首版枚举：

```cpp
enum class asETypedSemanticReceiverKind : asBYTE
{
    None,
    NativeObjectThis,
    ExplicitParameterAlias,
    MixinFirstParameter,
};
```

其中 `NativeObjectThis` 使用独立 synthetic receiver symbol；另外两种必须引用真实 parameter symbol 0。Synthetic receiver 不得伪装成 declared parameter，否则 VM object slot 和显式参数布局会错位。

## 4. Function header 和 call node 的建议形状

### 4.1 Function header

```cpp
enum class asETypedSemanticInvocationKind : asBYTE
{
    Global,
    InstanceMethod,
    Constructor,
    Destructor,
    Factory,
    Imported,
    System,
    Funcdef,
    Synthesized,
};

struct asSTypedSemanticEffectiveReceiver
{
    asETypedSemanticReceiverKind Kind;
    asCTypedSemanticSymbolId Symbol;
    int ParameterIndex;
    asCDataType Type;
};

struct asSTypedSemanticFunctionHeader
{
    asDWORD DeclaredTraitBits;
    asETypedSemanticInvocationKind InvocationKind;
    asSTypedSemanticEffectiveReceiver Receiver;
    asECompileOutType CompileOutType;
    int HiddenArgumentIndex;
    int DeterminesOutputTypeArgumentIndex;
    bool ReturnsOnStack;
    bool HasSuspendState;
    bool HasExceptionCleanup;
};
```

这是方向性字段图，不冻结具体 C++ 名字或布局。实际实现还需沿用 indexed IDs、owned types/source spans 和 function-owned lifetime。Raw pointers、UClass addresses、VM stack offsets和provider pointers都不能成为 HIR identity。

### 4.2 Resolved call

Call HIR 需要同时表达源级角色与 ABI 顺序，避免 mixin、hidden arg 或 call rewrite 让 emitter 猜测：

```text
ResolvedCall
  ResolvedTargetFunctionId
  SourceInvocationKind
  OptionalReceiverExpression
  SourceArguments[]
  EffectiveArguments[]       # formal/ABI order after defaults/hidden/mixin normalization
  HiddenArgumentOrigins[]
  CompileRewrite
  ConcreteResultType
  DispatchKind
```

要求：

- receiver 表达式只求值一次；
- source arguments 保持 AngelScript 求值顺序；
- named/default/hidden arguments 在 compiler 已确定后记录，不由 emitter 重跑匹配；
- mixin receiver 映射到 effective argument 0，但不重复求值；
- `determinesOutputTypeArgumentIndex` 的 concrete result type 直接取 compiler 最终类型；
- virtual/interface/RPC/Blueprint route 记录为 dispatch disposition，不因 target ID 已解析就擅自 direct-call；
- `PassScriptFunctionAsFirstParam` 等 native hidden ABI 通过 external-call descriptor/call plan 表达，不伪装成 AS source parameter。

### 4.3 Member/property nodes

所有 resolved member form 都必须携带显式 receiver expression：

- field/property storage read/write；
- property getter/setter；
- unqualified method call；
- explicit `this`；
- operator/accessor rewrite。

首期不支持对象语义时，可以把它们记录为包含 receiver operand 的 typed unsupported node。这样 fallback 不丢信息，后续对象 slice 也不需要重新设计 function header。

## 5. Maintained fork trait policy matrix

`as_scriptfunction.h:116-147` 当前定义 27 个 trait。以下 disposition 是 Semantic AOT 的处理原则，不表示首期全部可生成 C++。

| Trait | 主要语义 | HIR/eligibility 处理 |
| --- | --- | --- |
| `CONSTRUCTOR` | 构造 invocation/lifetime | 记录 function kind；首期 fallback，后续专用 entry/lifetime lowering |
| `DESTRUCTOR` | 析构 invocation/cleanup | 同上；不得按普通 void method direct-call |
| `CONST` | receiver mutability 与 overload | 进入 receiver/call plan；不是诊断-only |
| `PRIVATE` | frontend access control | 保存快照；已成功解析的 body 不重复检查，但跨函数 direct-call仍不得绕过 route |
| `PROTECTED` | frontend access control | 同上 |
| `FINAL` | 非虚/可直达证据之一 | 进入 dispatch eligibility；单独一个 final bit 仍不足以证明 UE raw-direct 安全 |
| `OVERRIDE` | override/virtual route | 进入 dispatch disposition；首期普通 instance root 仍受 UFUNCTION flags/receiver shape 限制 |
| `SHARED` | 跨模块 shared identity/body ownership | 进入 target identity与body availability；不能假设当前 module 拥有可发射 body |
| `EXTERNAL` | shared declaration without local body | 记录 body kind；不能尝试从 HIR 发射不存在的 body |
| `PROPERTY` | getter/setter property syntax | call/member node保存最终 accessor target；不能重跑 property lookup |
| `IMPLICITCONSTRUCTOR` | implicit conversion候选 | conversion node保存 compiler 选择；constructor body仍按专用 function kind |
| `MIXIN` | 方法语法映射到 global formal 0 | call node保存 receiver→argument 0 映射；callee body不获得 implicit this |
| `LOCAL` | module-local visibility | target identity/availability；不得错误跨 provider/export direct-call |
| `NODISCARD` | compile-time unused-result policy | raw snapshot/diagnostic provenance；成功 body 的 runtime ABI不变 |
| `DEPRECATED` | compile-time warning | raw snapshot/diagnostic provenance；AOT不重复发 warning |
| `GENERIC_TEMPLATE_FUNCTION` | concrete template instantiation | 只消费 compiler 已实例化 target/concrete types；未实例化形状 fallback |
| `USES_WORLDCONTEXT` | ambient world/thread policy | call disposition保留；不得因参数被隐藏就删除 runtime policy/route |
| `ACCEPT_TEMPORARY_OBJECT` | temporary receiver overload eligibility | compiler selection后记录来源；AOT不重新判断 overload，但要保留 lifetime需求 |
| `GENERATED_FUNCTION` | generated diagnostics/dependency policy | 记录 source/body origin；generated 不是自动安全，也不是自动禁止 |
| `NOT_CALLABLE` | frontend call prohibition | 成功 source不应产生非法 call；外部/生成调用仍不得绕过 contract |
| `FORCE_CONST_ARGUMENT_EXPRESSIONS` | 编译参数时限制可调用集合 | 捕获最终 argument expressions；emitter不重新应用 source policy |
| `EXTERNAL_IMPLICIT_THIS` | global parameter 0兼作 callee receiver | `ExplicitParameterAlias`；参数保留；首期对象语义 fallback |
| `ALLOWDISCARD` | unused-result policy override | raw snapshot/diagnostic provenance |
| `EDITOR_ONLY` | build/profile availability | 进入 artifact profile、dependency和fallback；Runtime target不能引用缺失符号 |
| `EXPLICIT` | explicit conversion/constructor policy | conversion provenance；不改变已解析 call 的 ABI |
| `UNSAFE_DURING_CONSTRUCTION` | construction/defaults call restriction | compiler继续执法；call plan保留 lifecycle policy，不能通过 direct-call绕过 |
| `DEFAULTS_ONLY` | 仅 defaults/edit context合法 | compiler继续执法；root/call route不得绕过上下文限制 |

未知的未来 trait bit 必须 fail closed：HIR 可以保存 raw bits，但 Semantic eligibility 返回 `UnsupportedFunctionTrait`，Legacy/VM继续。不能忽略未知 bit 后生成 native body。

## 6. 不在 trait bitset 中但同样影响 AOT 的函数语义

### 6.1 `compileOutType`

`asECompileOutType` 包含：

- `CompileCalls`；
- `CompileOutEntirely`；
- `ReplaceWithFirstParam`；
- `CompileOutAsMethodChain`。

`as_compiler.cpp:13427-13494` 在真正 call emission 前执行这些 rewrite。因此 HIR 应捕获 rewrite 后的最终表达式：

- entirely：没有虚构 `ResolvedCall`；保留一个有 source span/provenance 的 erased-call marker 供诊断即可；
- replace-first-param：HIR value就是被选中的参数表达式，且只求值一次；
- method-chain：HIR 保留链上的现有 receiver/value，不发出已删除调用；
- normal：才产生 resolved call。

只在 call node 保存 target 的 `compileOutType`、但仍发射一次 C++ call，是错误实现。

### 6.2 hidden/default arguments

`hiddenArgumentIndex` 当前用于 WorldContext 等默认插入参数；它和 receiver 完全独立。HIR 需要区分：

- source-visible argument；
- source default argument；
- host-hidden argument/default；
- mixin receiver formal；
- native ABI-only script-function/user-data argument。

所有这些最终都进入 call plan，但只有 source-visible/default expression属于普通 source evaluation tree。Host runtime value不能被伪造成可常量折叠的 source literal。

### 6.3 determines-output-type

`determinesOutputTypeArgumentIndex` 会让 compiler 根据某个 argument 的 concrete type改写结果 type。HIR expression 的 `asCDataType` 必须是改写后的最终类型，同时保存 target/formal metadata用于诊断；emitter不得从声明返回类型覆盖它。

### 6.4 function kind、return ABI 与 cleanup

以下信息在 trait 之外：

- `funcType` 的 script/system/imported/interface/funcdef；
- `vfTableIdx`；
- object slot；
- `DoesReturnOnStack()`；
- system call convention；
- `dontCleanUpOnException`；
- script temporaries/try-catch/suspend state。

它们共同决定 entry、bridge、direct-call与fallback。首期 scalar slice继续排除 return-on-stack、object lifetime、complex cleanup和suspend，但 header/verifier要有明确 disposition，不能等 emitter生成到一半才失败。

### 6.5 UFUNCTION/ClassGenerator route

函数 trait 不表达 RPC、BlueprintEvent、BlueprintOverride、WorldContext wrapper、thread-safe special path 或最终 `UASFunction` dispatch。Semantic root eligibility继续以最终 `FAngelscriptFunctionDesc::ScriptFunction` 指针图为权威；call directness继续消费 ClassGenerator/provider route。Resolved function ID 只证明 frontend 选择了哪个函数，不证明可以绕过 `ProcessEvent` 或 current-function routing。

## 7. Root、callee closure 和 generated lifecycle

Semantic AOT 从最终 UFUNCTION descriptor graph选择 production roots，但 root body调用的普通 AS helper、mixin或generated lifecycle仍属于call graph closure。规则是：

1. `NotUFunctionRoot` 只表示该函数不独立发布 UASFunction entry，不表示它不能作为 callee生成provider-private helper；
2. 每个 reachable callee单独验证 function header、receiver、signature、body和route；
3. 可安全生成的 helper获得internal Semantic symbol；
4. 可安全bridge的 helper走bridge；
5. 任一必须执行但不可生成/bridge的 call使该root按call span稳定fallback；
6. 不允许 root 使用Semantic body、却在未声明的情况下直接链接Legacy-generated helper symbol。

旧 literal asset 的 `GetName()`/`__Init_Name()` 和未来 Singleton lifecycle 都是这一问题的例子。它们通常不是UFUNCTION root，但可能位于root/helper closure内。

## 8. 首期支持和后续开放顺序

### 8.1 首期必须正确捕获但允许 fallback

- raw traits + normalized function kind；
-四类 receiver；
- hidden/default argument origins；
- concrete result type；
- compile-out final expression；
- member/property/call的显式 receiver operand；
- malformed receiver verifier；
- unknown trait fail-closed；
- generated helper/callee closure disposition。

### 8.2 首期 Semantic emitter仍只开放安全 scalar subset

- ordinary global scalar/enum function；
-无receiver、无hidden ABI、无object lifetime；
- structured scalar control flow；
-已证明link/bridge的scalar calls。

`external_implicit_this`、ordinary object method、mixin object receiver、property/member access在该阶段获得精确fallback，而不是错误C++。

### 8.3 后续对象 slice建议顺序

1. scalar instance method receiver entry与null/route parity；
2. scalar mixin receiver→formal 0 call normalization；
3. `external_implicit_this` receiver alias与显式 `this`；
4. script value/object member storage；
5. UObject reflected/native property bridge；
6. property accessors与method calls；
7. handles/references、GC/lifetime和exception cleanup；
8. constructors/destructors；
9. virtual/interface/RPC/Blueprint route的受控bridge，仍不默认raw-direct。

## 9. Singleton lowering 的交叉约束

`feature-as-usingleton-keyword` 的用户语法允许：

```angelscript
singleton DefaultConfig of UGameConfig
{
    Init
    {
        Profile = n"Default";
    }
}
```

“Init无显式参数”只描述用户block。按当前compiler，隐藏函数必须实际带candidate参数：

```angelscript
void __Singleton_Init_<StableHash>(
    UGameConfig __Receiver
) external_implicit_this
{
    Profile = n"Default";
}
```

Registry调用：

```angelscript
__Singleton_Init_<StableHash>(Candidate);
```

同一规则适用于 Reload/Deinit。Descriptor记录hidden entry和declared type；它不把receiver参数从函数ABI中删除。Singleton tests必须证明：

-用户block拒绝自定义参数；
-生成函数恰有一个declared-type parameter 0；
-trait存在且function `objectType == nullptr`；
-未限定字段、显式 `this` 和未限定方法解析到parameter 0 candidate；
-Registry以candidate显式调用；
-null/失败/exception不会发布partial slot；
-StaticJIT/bytecode archive保留traits和真实签名；
-Semantic unsupported时逐函数/逐root fallback，不改变lifecycle次数和顺序。

未来 Dynamic Asset change 的纯数据builder不应使用该修饰符；旧 literal asset仅作为当前实现证据和迁移fixture。

## 10. Test matrix

| Axis | Required cases |
| --- | --- |
| receiver kind | none、native this、external param alias、mixin formal 0 |
| external-this shape | valid object param 0、missing param、primitive param、wrong symbol、wrong type |
| body lookup | unqualified field、explicit this、unqualified method、property accessor、local/param shadowing |
| receiver storage | value、reference、handle/null；unsupported forms still preserve operand/type/span |
| call form | global call、implicit member、explicit member、mixin method syntax、Super/virtual disposition |
| argument origin | explicit、named、source default、hidden WorldContext、mixin receiver、native ABI-only |
| rewrite | compile normal、erase、replace-first-param、method-chain |
| trait safety | every known trait classified、unknown bit fail-closed、generated/editor-only profile |
| root/closure | UFUNCTION root、ordinary helper、generated lifecycle callee、recursive/SCC fallback |
| invariance | capture on/off bytecode、VM behavior、cache bytes、trait/signature identity |
| differential | VM vs Legacy vs Semantic where eligible；fallback route counter where ineligible |

Research fixtures under `research/fixtures/semantic-aot-v1/` include a valid external receiver alias fallback case and a dangling/wrong receiver alias verifier case. They remain virtual data only; real implementation tests must compile source through maintained `asCCompiler` and compare actual bytecode/runtime behavior.

### 10.1 已落地的提前验证

本 change 现在保留三类可立即运行的证据，边界不同，不应互相替代：

| Evidence | Command | Proves | Does not prove |
| --- | --- | --- | --- |
| schema-v3 virtual HIR corpus | `research/fixtures/semantic-aot-v1/Test-ValidateFixtures.ps1` | receiver header、trait bit、显式break/continue目标、稳定dump、合法fallback、损坏receiver/control verifier、hash/token guards | production compiler已生成HIR，或对象receiver已可Semantic emit |
| maintained-fork source drift probe | `research/probes/Test-FunctionTraitSourceEvidence.ps1` | 当前fork仍由参数0建立 `ExternalThisType/Offset`，asset lowering仍显式传参 | runtime执行、StaticJIT entry parity |
| native Standalone runtime probe | `research/probes/Test-ExternalImplicitThisRuntime.ps1` | 参数0仍可按名字访问，同时驱动未限定字段/方法解析和caller可见mutation | UObject/GC、ClassGenerator、literal asset lifecycle或Semantic StaticJIT |

2026-08-13 的基线结果为：fixture validator `13 assertions`、source evidence `11 assertions`（其中一项自动比较 fork 的全部 `asEFuncTrait` 与本文件 policy matrix）、Standalone runtime `PASS`。Standalone probe 使用维护中的同一 AngelScript fork，但不包含 UE；因此它正好证明该核心语义不是 UE 专属，同时仍不能替代现有 `LiteralAsset` UE Automation test。

`research/patches/external-implicit-this-test-first-patch.md` 另保留了可直接加入 `AngelscriptNativeFunctionsTests.cpp` 的 characterization test cell、生产patch顺序和 focused 验证命令。当前未直接修改 plugin test 文件，以免和工作区正在进行的架构改造争用同一 submodule；真正开始任务 1.3/2.10 时先应用该 test cell。

## 11. Patch anchors

| Responsibility | Planned anchor |
| --- | --- |
| trait/function header model | `ThirdParty/angelscript/source/as_typed_semantic_ir.h/.cpp` |
| provisional receiver builder | `ThirdParty/angelscript/source/as_compiler.h/.cpp` near `ExternalThisType/ExternalThisOffset` and parameter setup |
| resolved member capture | `CompileVariableAccess()` after final property/accessor resolution |
| resolved call capture | `CompileFunctionCall()` / `PerformFunctionCall()` after overload, mixin, hidden/default and compile-out decisions |
| verifier/dump | typed HIR private model; no `angelscript.h` public ABI |
| root/callee eligibility | `StaticJIT/SemanticAOT/AngelscriptSemanticAOTEligibility.*` |
| shared entry ABI | `StaticJIT/SemanticAOT/AngelscriptStaticJITEntryPlan.*` |
| object receiver emitter | later `AngelscriptSemanticAOTEmitter.*` object slice |
| Singleton lowering | `Preprocessor/AngelscriptPreprocessor.*` plus Singleton descriptor/Registry tests |

The existing Legacy bytecode StaticJIT remains the compatibility oracle. It already consumes bytecode in which these frontend decisions have been lowered; this research exists because a source-known HIR backend observes the decisions earlier and must preserve them explicitly.
