# Compile flow: current code vs contracted shrink

This is the comparison the user asked for: what the reconstructed SDK actually does today, versus the lifecycle we have already settled in this draft. Binding and host `CompileModules` stay out of the shrink. Nothing here is implemented yet.

## What to throw away (public surface)

| Today | After |
| --- | --- |
| `asCMetadataImage` public SDK product, Engine `metadataImages`, five states Building→Retired | **delete the type**; Builder holds pending Type/Function/Global |
| Builder scatter getters + `asSBuilderStageResult` as if they were the product | one external bag: `asCCompileOutput` |
| Kitchen-sink compile bag that also holds symbolic bytecode | `asCCompileOutput` = UE/ClassGen descriptions + diagnostics only |
| `asCExecutableFunction` as a public sibling of `asCScriptFunction` | fold runtime bytecode onto `asCScriptFunction` |
| Caller wires `RegisterMetadataImage` then `asLinkByteCodeImage` by hand | `asCEngineCompileRegistration` does install + Link |
| Image-owned TypeInfo/Function until Engine retire, with `metadataOwner` back-pointer | no Image; pending on Builder, then Engine owns them; Function holds both bytecodes |

Frontend stages inside Builder (lex → freeze definitions) can stay. The shrink is ownership and products, not “delete sema”.

## Now: two pipelines, many bags, Image lives with Engine

```text
─────────────  SDK (asCBuilder) — no Engine required  ─────────────

SourceReady
  │  asCSourceSnapshot + Diagnostics + StableScope
  ▼
Lexed → Preprocessed → DeclarationsCollected → DeclarationsResolved
  │  workers only on BodiesAnalyzed (std::thread stride)
  ▼
BodiesAnalyzed → ASTVerified
  │  product: asCCompilationSession (AST + fragments)
  ▼
DefinitionsBuilt → LayoutsFinalized → DefinitionsFrozen
  │  product: TUniquePtr<asCMetadataImage>
  │           real TypeInfo / asCScriptFunction / Global
  │           Image.State = Frozen
  │  RunThrough STOPS HERE — no Emit, no Engine, no UClass
  ▼
outsiders poke Builder
  ├─ GetCompilationSession()
  ├─ GetDefinitions() / TakeDefinitions()
  ├─ GetLexedSources() / GetPreprocessedSources()
  └─ GetStageResult()                          // dump, not ClassGen input

─────────────  Emit — still no Engine, second call  ─────────────

asCByteCodeEmitter::Emit(Session, FrozenImage)
  └─ asCByteCodeImage                           // StableKey slots; cannot run

─────────────  Engine adopt — third call  ─────────────

Engine.RegisterMetadataImage(TakeDefinitions())
  Image: Frozen → Attaching → Attached
  Engine.metadataImages keeps UniquePtr until Engine dies
  Type->engine set; BoundTypeIds on Image
  Function still has no scriptData

─────────────  Link — fourth call  ─────────────

asLinkByteCodeImage(Engine, ByteCodeImage)
  └─ asCExecutableSnapshot
       └─ asCExecutableFunction.scriptData      // VM actually runs this

VM Prepare → AcquirePublishedExecutable(StableKey)
           → m_currentExecutable->scriptData

─────────────  Host (FAngelscriptEngine) — disconnected  ─────────────

CompileModules Stage1–3
  └─ fail on purpose: "use frozen Builder inputs"
ClassGenerator still wants FAngelscriptModuleDesc / asITypeInfo*
FAngelscriptDescriptorConsumer::Project is a parallel UE bag
```

Ownership today:

```text
asCMetadataImage                         // unique owner of live objects
├─ Types / Functions / Globals           // real runtime types
├─ *ByKey + IdentityContext
├─ layouts + schema/layout fingerprints
├─ BoundTypeIds / BoundFunctionIds
└─ State: Building → Frozen → Attaching → Attached → Retired

asCScriptFunction
├─ signature + StableKey
├─ metadataOwner → Image
└─ scriptData = null on metadata ctor     // legacy still has it here

asCExecutableFunction                    // public sibling
├─ Declaration → asCScriptFunction
└─ scriptData                            // lowered DWORDs
```

## After: two worlds, two products, one Function

```text
─────────────  无 Engine — asCBuilder  ─────────────

Source → lex / preprocess / sema / bodies (workers here only)
  │
  ├─ pending asCScriptFunction / TypeInfo / Global
  │     └─ [member] 稳定字节码                 // Emit hangs it here
  │
  └─ asCCompileOutput                       // 唯一对外袋子
       ├─ diagnostics
       └─ asCDefinitionCompileOutput         // ClassGen / UE 描述，不是 TypeInfo 图

Emit 仍是编译侧（Builder 或它调用的 emitter）。
asCCompileOutput 不背字节码。
没有 asCMetadataImage。

─────────────  有 Engine — 延迟  ─────────────

asCEngineCompileRegistration                 // 对外一次成功
  ├─ Install → Engine 拥有 Type/Function/Global
  └─ Link    → **唯一**写出 Function.runtime 可执行字节码
               成功之前函数不可 Prepare

VM Prepare → 只读 Function 上的 runtime bytecode；不生成
```

Ownership after:

```text
asCScriptFunction                         // 一个函数，跟一个 Engine
├─ 声明（签名、asSStableKey）
├─ 稳定字节码                               // 没 Engine 也可以有
└─ runtime 可执行字节码                     // Link 之后才有；VM 跑这份

asCCompileOutput                          // 短命、给外部
├─ diagnostics
└─ asCDefinitionCompileOutput              // 描述

asCEngineCompileRegistration               // 对着一个 Engine 做事
├─ Install definitions
└─ Link bytecode
```

Native `asFUNC_SYSTEM`: 稳定码空，runtime 仍是 `sysFuncIntf`。

## Same compile, side by side

```text
  现在                                      收缩后
  ────                                      ────
  asCBuilder 停在 Frozen Image
  外人 Get/Take 一堆东西                    外人只拿 asCCompileOutput

  Emit → asCByteCodeImage                   Emit → 挂到 asCScriptFunction
  RegisterMetadataImage(Image)             Registration.Install
  asLink → asCExecutableFunction            Registration.Link → 同一 Function
  Image 跟着 Engine 活到关机               没有 asCMetadataImage
  VM 查 published executable               VM 跑 Function 上的 runtime 码
  ClassGen 还在旧 Module TypeInfo          ClassGen 读 DefinitionCompileOutput
```

## What does not move into this shrink

- Binding Record / BindInfo / native Install (out of scope).
- Host `CompileModules` Stage1–3 still dead until a later host wiring Change.
- `asSStableKey` stays the content-addressed identity (rename round later if wanted).
- Builder internal stages and body workers stay; Registration does not own workers and does not Emit.

## Open (not needed to read this comparison)

- Whether `asCByteCodeImage` remains a batch/codec container, or only per-function bodies exist.
- Whether `asCExecutableSnapshot` stays as an internal Link lease; it is not the public function type.
